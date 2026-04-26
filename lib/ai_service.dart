import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  final List<String> _apiKeys = [];
  int _currentKeyIndex = 0;
  late String selectedLanguage;
  String? userName;
  String? userAge;
  final List<Content> _conversationHistory = [];
  late GenerativeModel _model;

  AIService({String language = "en-IN", String? geminiApiKey, this.userName, this.userAge}) {
    selectedLanguage = language;
    
    if (geminiApiKey != null) {
      _apiKeys.add(geminiApiKey);
    } else {
      final rawKeys = dotenv.get('GEMINI_API_KEY', fallback: "");
      if (rawKeys.isNotEmpty) {
        _apiKeys.addAll(rawKeys.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty));
      }
    }
    
    _initModel();
  }

  bool get isOnline => _apiKeys.isNotEmpty;

  String get _currentKey => _apiKeys.isNotEmpty ? _apiKeys[_currentKeyIndex] : "";

  void _initModel() {
    if (_currentKey.isEmpty) {
      print("Warning: No Gemini API Keys found. Chatbot will run in offline mode.");
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _currentKey,
      systemInstruction: Content.system(_getSystemPrompt()),
    );
  }

  void _rotateKey() {
    if (_apiKeys.length > 1) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
      print("Rotating to next API Key (Index: $_currentKeyIndex)");
      _initModel();
    }
  }

  void setLanguage(String language) {
    if (selectedLanguage != language) {
      selectedLanguage = language;
      _initModel(); // Re-init with new system prompt language
    }
  }

  String _getSystemPrompt() {
    String langInstruction;
    if (selectedLanguage == "hi-IN") {
      langInstruction = "Respond ONLY in Hindi. Use simple Hindi words.";
    } else if (selectedLanguage == "mr-IN") {
      langInstruction = "Respond ONLY in Marathi. Use simple Marathi words.";
    } else {
      langInstruction = "Respond ONLY in English. Use simple English words.";
    }
    
    return '''You are Swasthyogi, a compassionate crisis triage AI assistant for elderly rural users in India who may have limited literacy and technology experience.

$langInstruction

IMPORTANT GUIDELINES:
1. Speak in simple, clear language. Use short sentences.
2. Be empathetic and calming - these users may be frightened or stressed.
3. Only ask ONE question at a time.
4. Always wait for their complete answer before asking the next question.
5. Acknowledge the situation and reassure them.
6. Do not diagnose; classify the urgency and recommend the next safe step.

CONVERSATION FLOW:
- Start by greeting warmly${userName != null ? ' to $userName' : ''}
${userName == null ? '- Ask for their name' : ''}
${userAge == null ? '- Ask for their age' : ''}
- Ask for their phone number
- Ask what emergency or crisis is happening now
- Listen carefully to understand what they are experiencing
- Be ready to guide them to emergency help if the situation is urgent

CRISIS ASSESSMENT:
When assessing an incident, consider urgency levels:
- HIGH RISK (immediate action needed): fire, accident, severe bleeding, unconsciousness, drowning, poisoning, heart attack, stroke, violence, building collapse
- MODERATE RISK (urgent help needed): injury, fracture, sprain, swelling, shock, trapped, road accident, gas leak
- LOW RISK (support needed): power outage, water outage, road block, shelter request, evacuation, panic, help request

TONE:
- Calm and reassuring
- Avoid panic language
- Encourage safety and getting help quickly

SERVICE REFERRAL:
- If the situation is HIGH or MODERATE, recommend emergency services like ambulance, police, or fire brigade.
- Inform the user that Swasthyogi can help them find nearby emergency services.
- If the user agrees, mention that they can use the 'Nearby Services' icon or button to locate help.
''';
  }

  Future<String> getAIResponse(String userMessage) async {
    try {
      if (_apiKeys.isEmpty) {
        return _getFallbackResponse(userMessage) + "\n\n(Note: Gemini AI is currently offline. Please add your API key to .env to enable full AI features.)";
      }

      print("=== GEMINI AI REQUEST ===");
      print("User message: $userMessage");
      print("Language: $selectedLanguage");

      final userContent = Content.text(userMessage);

      // Ensure history is alternating (User -> Model -> User)
      final history = _conversationHistory.toList();
      
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(userContent);
      
      final aiResponse = response.text ?? _getFallbackResponse(userMessage);
      
      // Update local history ONLY after successful round-trip
      _conversationHistory.add(userContent);
      _conversationHistory.add(Content.model([TextPart(aiResponse)]));

      print("AI Response: $aiResponse");
      print("=== GEMINI RESPONSE END ===");

      return aiResponse;
    } catch (e) {
      print("Gemini AI Error: $e");
      
      // If we have more keys, try rotating and retrying (one attempt)
      if (_apiKeys.length > 1 && !e.toString().contains("API_KEY_INVALID")) {
        _rotateKey();
        try {
          return await getAIResponse(userMessage);
        } catch (retryError) {
          print("Retry also failed: $retryError");
        }
      }
      
      if (e.toString().contains("API_KEY_INVALID")) {
        if (selectedLanguage == "hi-IN") {
          return "API कुंजी गलत है। कृपया अपनी Gemini API कुंजी की जांच करें।";
        } else if (selectedLanguage == "mr-IN") {
          return "API की चुकीची आहे. कृपया आपली Gemini API की तपासा.";
        } else {
          return "Invalid API key. Please check your Gemini API key in Google AI Studio.";
        }
      }
      
      // Use fallback when API fails
      print("Using fallback response...");
      return _getFallbackResponse(userMessage);
    }
  }

  Future<String> analyzeSymptoms(String symptoms, String language) async {
    setLanguage(language);
    final prompt = "I am experiencing these symptoms: $symptoms. Please triage them and tell me what should be my immediate next step.";
    return await getAIResponse(prompt);
  }

  void reset() {
    _conversationHistory.clear();
  }

  // Fallback: Rule-based response when API fails
  String _getFallbackResponse(String userMessage) {
    final msgLower = userMessage.toLowerCase();
    final words = msgLower.split(RegExp(r'\W+'));
    
    // Check for "greeting"
    if (words.contains("hi") || words.contains("hello") || words.contains("hey")) {
      return "Hello${userName != null ? ' $userName' : ''}! I am your Swasthyogi AI Assistant. I am currently in offline mode, but I can still help with medical, fire, police, or safety emergencies. How can I assist you?";
    }

    // 1. HIGHEST SEVERITY: FIRE
    if (words.contains("fire") || words.contains("burning") || words.contains("smoke")) {
      if (selectedLanguage == "hi-IN") return "आग का आपातकाल! कृपया तुरंत इमारत खाली करें और 101 डायल करें। क्या आप सुरक्षित हैं?";
      if (selectedLanguage == "mr-IN") return "आगीची आणीबाणी! कृपया ताबडतोब इमारत रिकामी करा आणि 101 वर कॉल करा. तुम्ही सुरक्षित ठिकाणी आहात का?";
      return "Fire emergency detected! Please evacuate the building immediately and call the fire department (101). Are you in a safe place?";
    }

    // 2. HIGH SEVERITY: MEDICAL / ACCIDENT
    if (msgLower.contains("bleeding") || msgLower.contains("unconscious") || msgLower.contains("heart attack") || msgLower.contains("chest pain") || msgLower.contains("breath") || words.contains("accident") || words.contains("crash") || words.contains("stroke")) {
      if (selectedLanguage == "hi-IN") return "यह एक गंभीर चिकित्सा आपातकाल है। कृपया शांत रहें और एम्बुलेंस (108) बुलाएं। क्या मैं आपके लिए नजदीकी अस्पताल ढूंढूं?";
      if (selectedLanguage == "mr-IN") return "ही एक गंभीर वैद्यकीय आणीबाणी आहे. कृपया शांत राहा आणि रुग्णवाहिका (108) बोलवा. मी तुमच्यासाठी जवळचे रुग्णालय शोधू का?";
      return "This looks like a severe medical emergency. Please stay calm, sit or lie down, and call an ambulance (108). Should I locate the nearest hospital for you?";
    }

    // 3. MENTAL HEALTH CRISIS (Depression, Anxiety, Panic)
    if (words.contains("depressed") || words.contains("depression") || words.contains("anxious") || words.contains("anxiety") || words.contains("panic") || words.contains("suicide") || words.contains("die")) {
      if (selectedLanguage == "hi-IN") return "मैं सुन रहा हूँ। आप अकेले नहीं हैं। कृपया किसी ऐसे व्यक्ति से बात करें जिस पर आप भरोसा करते हैं, या हेल्पलाईन 9152987821 पर कॉल करें।";
      if (selectedLanguage == "mr-IN") return "मी ऐकत आहे. तुम्ही एकटे नाही आहात. कृपया तुमच्या जवळच्या व्यक्तीशी बोला, किंवा हेल्पलाईन 9152987821 वर कॉल करा.";
      return "I hear you, and you are not alone. Please reach out to someone you trust immediately, or call a crisis helpline like 9152987821. Your life is valuable. Please stay safe.";
    }

    // 4. MODERATE SEVERITY: SAFETY/POLICE
    if (words.contains("theft") || words.contains("robbery") || words.contains("attack") || words.contains("police") || words.contains("fight") || words.contains("harassed") || words.contains("stalked")) {
      if (selectedLanguage == "hi-IN") return "यह सुरक्षा का मामला है। कृपया सुरक्षित और भीड़-भाड़ वाली जगह पर जाएं। पुलिस (100) या महिला हेल्पलाइन (1091) पर कॉल करें।";
      if (selectedLanguage == "mr-IN") return "हे सुरक्षेचे प्रकरण आहे. कृपया सुरक्षित आणि गर्दीच्या ठिकाणी जा. पोलीस (100) किंवा महिला हेल्पलाईन (1091) वर कॉल करा.";
      return "This sounds like a serious safety threat. Please move to a safe, well-lit, crowded location immediately. Should I trigger the SOS or call the Police (100 / 112)?";
    }

    // 5. NATURAL DISASTERS
    if (words.contains("earthquake") || words.contains("flood") || words.contains("storm")) {
      return "For natural disasters, stay away from windows and heavy objects. If there's an earthquake, Drop, Cover, and Hold On. Are you trapped?";
    }

    // 6. MINOR MEDICAL (Fever, Cut, Headache)
    if (words.contains("fever") || words.contains("headache") || words.contains("cold") || words.contains("cough") || words.contains("cut") || words.contains("burn")) {
      if (selectedLanguage == "hi-IN") return "यह एक मामूली स्वास्थ्य समस्या लग रही है। आराम करें और खूब पानी पिएं। अगर दर्द बढ़ता है, तो डॉक्टर से मिलें।";
      if (selectedLanguage == "mr-IN") return "ही एक किरकोळ आरोग्य समस्या दिसते. विश्रांती घ्या आणि भरपूर पाणी प्या. वेदना वाढल्यास, डॉक्टरांचा सल्ला घ्या.";
      return "This appears to be a minor health issue. Rest, stay hydrated, and monitor your symptoms. If it's a minor cut or burn, clean it with water. Would you like to see nearby pharmacies?";
    }

    // 7. DEFAULT CATCH-ALL
    if (selectedLanguage == "hi-IN") {
      return "मैं आपकी बात समझ नहीं पाया। आपातकालीन स्थिति में, कृपया 'आग', 'दुर्घटना', 'चोट', या 'पुलिस' जैसे शब्दों का उपयोग करें ताकि मैं तुरंत मदद कर सकूं।";
    } else if (selectedLanguage == "mr-IN") {
      return "मला तुमची समस्या समजली नाही. आणीबाणीच्या परिस्थितीत, कृपया 'आग', 'अपघात', 'दुखापत' किंवा 'पोलीस' यांसारखे शब्द वापरा जेणेकरून मी त्वरित मदत करू शकेन.";
    } else {
      return "I didn't quite catch that. I am currently offline. To help me understand, please use clear keywords like 'Fire', 'Accident', 'Depressed', 'Bleeding', or 'Police'.";
    }
  }
}
