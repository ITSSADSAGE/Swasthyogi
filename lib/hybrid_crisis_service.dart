import 'ai_service.dart';
import 'crisis_risk_engine.dart';
import 'network_service.dart';
import 'risk_engine.dart';
import 'remedy_engine.dart';
import 'safety_guide_engine.dart';
import 'emergency_manager.dart';

class HybridResponse {
  final String message;
  final String mode; // 'online' or 'offline'
  final String severity;
  final String analysisType; // 'medical' or 'crisis'
  final bool shouldTriggerSOS;
  final List<String> advice;

  HybridResponse({
    required this.message,
    required this.mode,
    required this.severity,
    this.analysisType = 'medical',
    this.shouldTriggerSOS = false,
    this.advice = const [],
  });
}

class HybridCrisisService {
  final AIService _aiService = AIService();

  /// Analyze user input and dynamically choose between medical and crisis engine
  Future<HybridResponse> analyzeIncident(
    String incident,
    String language,
  ) async {
    NetworkSpeed speed = await NetworkService.getNetworkSpeed();

    // Dynamically detect analysis type based on keywords
    String crisisSeverity = assessCrisis(incident);
    String medicalSeverity = assessRisk(incident);

    String analysisType = 'medical';
    String severity = medicalSeverity;

    if (crisisSeverity != "UNRECOGNIZED") {
      analysisType = 'crisis';
      severity = crisisSeverity;
    }

    // Online mode: Use AI for both medical and crisis analysis
    if (speed == NetworkSpeed.high) {
      try {
        _aiService.setLanguage(language);
        String aiResult = await _aiService.getAIResponse(incident);

        return HybridResponse(
          message: aiResult,
          mode: 'online',
          severity: severity,
          analysisType: analysisType,
        );
      } catch (e) {
        print("AI Error, falling back to offline: $e");
      }
    }

    // Get automated advice based on type
    List<String> advice = [];
    if (analysisType == 'crisis') {
      final safetyResult = SafetyGuideEngine.getSafetySteps(incident, language);
      if (safetyResult.found) {
        advice = safetyResult.steps;
      }
    } else {
      final remedyResult = RemedyEngine.getRemedies(incident, severity, language);
      if (remedyResult.found) {
        advice = remedyResult.remedies;
      }
    }

    // Offline mode: Generate message based on severity and type
    String offlineMessage = _generateOfflineMessage(
      severity,
      language,
      analysisType,
    );
    
    // Normalize for headers
    String langCode = language.toLowerCase();
    bool isHindi = langCode.contains("hi") || langCode.contains("हिंदी");
    bool isMarathi = langCode.contains("mr") || langCode.contains("मराठी");

    // Append advice to offline message if available
    if (advice.isNotEmpty) {
      String adviceHeader = isHindi 
          ? "\n\nत्वरित सलाह:" 
          : (isMarathi ? "\n\nत्वरीत सल्ला:" : "\n\nQuick Advice:");
      offlineMessage += adviceHeader;
      for (var step in advice) {
        offlineMessage += "\n• $step";
      }
    }

    // Trigger SOS if no network (fallback)
    bool triggerSOS = (speed == NetworkSpeed.none);
    
    if (triggerSOS && analysisType == 'crisis') {
       // Append SOS notice to message if it's a crisis and no network
       String sosNotice = isHindi 
           ? "\n\n(नेटवर्क नहीं है। आपातकालीन एसएमएस भेजा जा रहा है...)" 
           : (isMarathi 
               ? "\n\n(नेटवर्क नाही. आपत्कालीन एसएमएस पाठविला जात आहे...)" 
               : "\n\n(No network. Sending emergency SMS SOS...)");
       offlineMessage += sosNotice;
    }

    return HybridResponse(
      message: offlineMessage,
      mode: 'offline',
      severity: severity,
      analysisType: analysisType,
      shouldTriggerSOS: triggerSOS,
      advice: advice,
    );
  }

  String _generateOfflineMessage(String severity, String language, String analysisType) {
    // Normalize language codes
    String langCode = language.toLowerCase();
    bool isHindi = langCode.contains("hi") || langCode.contains("हिंदी");
    bool isMarathi = langCode.contains("mr") || langCode.contains("मराठी");
    
    String res = "";

    if (analysisType == 'crisis') {
      // Crisis-specific messages (Critical, Urgent, Minor)
      if (isMarathi) {
        if (severity == "UNRECOGNIZED") {
          res = "आपल्या परिस्थितीचे विश्लेषण करण्यास आम्हाला पुरेशी माहिती मिळाली नाही. कृपया जवळच्या आपत्कालीन सेवेशी संपर्क करा.";
        } else if (severity == "HIGH") {
          res = "ही अतिशय गंभीर (HIGH) स्थिति आहे. कृपया ताबडतोब आपत्कालीन मदत मागवा. ११२ वर कॉल करा किंवा नजीकचे रुग्णालय शोधा.";
        } else if (severity == "MODERATE") {
          res = "ही तातडीची (MODERATE) घटना असू शकते. जवळच्या पोलिस/रुग्णालयाशी संपर्क करा आणि सुरक्षित ठिकाणी जा.";
        } else {
          res = "ही घटना कमी तीव्रतेची (LOW) दिसते. कृपया शांत राहा आणि आवश्यकतेनुसार सहाय्य घ्या.";
        }
      } else if (isHindi) {
        if (severity == "UNRECOGNIZED") {
          res = "हम आपकी स्थिति को पूरी तरह से समझ नहीं पाए। कृपया नजदीकी आपातकालीन सेवा से संपर्क करें।";
        } else if (severity == "HIGH") {
          res = "यह एक अति गंभीर (HIGH) आपातकालीन स्थिति है। तुरंत 112 पर कॉल करें या नजदीकी अस्पताल से संपर्क करें।";
        } else if (severity == "MODERATE") {
          res = "यह तत्काल (MODERATE) ध्यान देने योग्य है। पास के अस्पताल/पुलिस/आग विभाग से मदद लें।";
        } else {
          res = "यह घटना कम गंभीर (LOW) लगती है। शांत रहें और आवश्यक सहायता लें।";
        }
      } else {
        if (severity == "UNRECOGNIZED") {
          res = "I could not fully classify this incident. Please contact nearby emergency services.";
        } else if (severity == "HIGH") {
          res = "This is a HIGH emergency. Call 112 immediately or contact nearby hospital.";
        } else if (severity == "MODERATE") {
          res = "This is a MODERATE situation. Reach out to nearby police, ambulance, or fire services.";
        } else {
          res = "This appears to be a LOW incident, but please stay safe and seek help if the situation worsens.";
        }
      }
    } else {
      // Medical-specific messages (HIGH, MODERATE, LOW)
      if (isMarathi) {
        if (severity == "UNRECOGNIZED") {
          res = "मला तुमच्या लक्षणांची माहिती आमच्या डेटाबेसमध्ये आढळली नाही. कृपया डॉक्टरांचा सल्ला घ्या.";
        } else if (severity == "HIGH") {
          res = "तुमची लक्षणे गंभीर (HIGH) आहेत. तुम्ही तातडीने डॉक्टरकडे जावे.";
        } else if (severity == "MODERATE") {
          res = "तुमची लक्षणे मध्यम (MODERATE) आहेत. कृपया पुढील २-३ दिवस काळजी घ्या.";
        } else {
          res = "चांगली बातमी! तुमची लक्षणे सौम्य (LOW) आहेत.";
        }
      } else if (isHindi) {
        if (severity == "UNRECOGNIZED") {
          res = "मुझे आपके लक्षण हमारे डेटाबेस में नहीं मिले। कृपया एक डॉक्टर से परामर्श लें।";
        } else if (severity == "HIGH") {
          res = "आपके लक्षण गंभीर (HIGH) हैं। आपको तुरंत डॉक्टर से मिलना चाहिए।";
        } else if (severity == "MODERATE") {
          res = "आपके लक्षण मध्यम (MODERATE) हैं। कृपया अगले 2-3 दिनों में ध्यान रखें।";
        } else {
          res = "अच्छी खबर! आपके लक्षण हल्के (LOW) हैं।";
        }
      } else {
        if (severity == "UNRECOGNIZED") {
          res = "I couldn't find your symptoms in our database. Please consult a doctor.";
        } else if (severity == "HIGH") {
          res = "Your symptoms are severe (HIGH). You should see a doctor immediately.";
        } else if (severity == "MODERATE") {
          res = "Your symptoms are moderate (MODERATE). Please take care for the next 2-3 days.";
        } else {
          res = "Good news! Your symptoms are mild (LOW).";
        }
      }
    }

    return res;
  }

  /// Execute the actual SOS action (SMS + Staff Notification)
  Future<void> executeSOS(String language) async {
    NetworkSpeed speed = await NetworkService.getNetworkSpeed();
    
    String langCode = language.toLowerCase();
    bool isHindi = langCode.contains("hi") || langCode.contains("हिंदी");
    bool isMarathi = langCode.contains("mr") || langCode.contains("मराठी");

    String sosMessage = isHindi 
        ? "आपातकालीन अलर्ट: उपयोगकर्ता को तुरंत सहायता की आवश्यकता है! स्थान: होटल लॉबी।" 
        : (isMarathi 
            ? "आपत्कालीन अलर्ट: वापरकर्त्याला त्वरित मदतीची आवश्यकता आहे! स्थान: हॉटेल लॉबी." 
            : "EMERGENCY ALERT: User needs immediate assistance! Location: Hotel Lobby.");

    // 1. Notify Staff via Firebase (Online)
    if (speed != NetworkSpeed.none) {
      print("Sending Firebase Alert to Staff: $sosMessage");
    }

    // 2. Send SMS Fallback (Offline or Poor Connection)
    print("Executing SMS SOS via EmergencyManager...");
    await EmergencyManager.sendSOS(language);
  }
}
