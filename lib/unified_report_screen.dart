import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'unified_log_manager.dart';
import 'network_service.dart';
import 'hybrid_crisis_service.dart';
import 'emergency_manager.dart';
import 'notification_service.dart';
import 'unified_response_screen.dart';

enum UnifiedStep { greeting, askIncident, analyzing, result }

class UnifiedReportScreen extends StatefulWidget {
  final String language;
  const UnifiedReportScreen({super.key, required this.language});

  @override
  State<UnifiedReportScreen> createState() => _UnifiedReportScreenState();
}

class _UnifiedReportScreenState extends State<UnifiedReportScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final HybridCrisisService _hybridService = HybridCrisisService();
  
  bool _speechEnabled = false;
  String _lastWords = '';
  List<Map<String, String>> chatMessages = [];
  UnifiedStep step = UnifiedStep.greeting;
  bool isProcessing = false;
  
  String get selectedLanguage => widget.language;
  bool get isMarathi => selectedLanguage == "Marathi" || selectedLanguage == "मराठी";
  bool get isHindi => selectedLanguage == "Hindi" || selectedLanguage == "हिंदी";

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _startFlow();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _initTts() async {
    await _flutterTts.setLanguage(isMarathi ? "mr-IN" : (isHindi ? "hi-IN" : "en-US"));
    await _flutterTts.setPitch(1.0);
  }

  void _startFlow() async {
    String greeting = isMarathi 
        ? "नमस्कार, मी स्वास्थ्योगी आहे. तुम्हाला काय होत आहे किंवा काही आणीबाणी आहे का?" 
        : (isHindi ? "नमस्ते, मैं स्वास्थ्योगी हूँ। आपको क्या हो रहा है या कोई आपातकालीन स्थिति है?" : "Hello, I am Swasthyogi. What is happening or is there an emergency?");
    
    await _addBotMessage(greeting);
    setState(() => step = UnifiedStep.askIncident);
  }

  Future<void> _addBotMessage(String text) async {
    setState(() {
      chatMessages.add({"role": "bot", "content": text});
    });
    await _flutterTts.speak(text);
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (result.finalResult) {
      _processInput(_lastWords);
    }
  }

  Future<void> _processInput(String input) async {
    if (input.isEmpty) return;
    
    setState(() {
      chatMessages.add({"role": "user", "content": input});
    });

    await _analyzeAndRespond(input);
  }

  Future<void> _analyzeAndRespond(String input) async {
    setState(() => isProcessing = true);
    
    final response = await _hybridService.analyzeIncident(
      input,
      selectedLanguage,
    );

    if (response.shouldTriggerSOS) {
      EmergencyManager.sendSOS(selectedLanguage);
    }

    if (response.analysisType == 'crisis') {
      NotificationService.notifyStaff(input, response.severity);
      EmergencyManager.triggerAlert(); // Vibration + sound
    }

    // Store in history
    await UnifiedLogManager.saveRecord({
      'input': input,
      'severity': response.severity,
      'type': response.analysisType,
      'date': DateTime.now().toString(),
    });

    await _addBotMessage(response.message);

    if (mounted) {
      setState(() {
        isProcessing = false;
        step = UnifiedStep.result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "अहवाल" : (isHindi ? "रिपोर्ट" : "Unified Report")),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                final isBot = msg['role'] == 'bot';
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey[200] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['content'] ?? ""),
                  ),
                );
              },
            ),
          ),
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            child: FloatingActionButton(
              onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
              child: Icon(_speechToText.isNotListening ? Icons.mic_none : Icons.mic),
            ),
          ),
        ],
      ),
    );
  }
}
