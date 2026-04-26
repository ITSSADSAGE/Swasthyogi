// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class MicrophoneDebugScreen extends StatefulWidget {
  const MicrophoneDebugScreen({super.key});

  @override
  State<MicrophoneDebugScreen> createState() => _MicrophoneDebugScreenState();
}

class _MicrophoneDebugScreenState extends State<MicrophoneDebugScreen> {
  late stt.SpeechToText sttEngine;
  String debugOutput = "Starting diagnostics...\n";
  bool isListening = false;
  static const MethodChannel _audioChannel = MethodChannel('swasthyogi/audio');

  @override
  void initState() {
    super.initState();
    sttEngine = stt.SpeechToText();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    try {
      _addDebugLog("=== MICROPHONE DIAGNOSTICS ===\n");

      // Check permission status
      _addDebugLog("1. Checking Microphone Permission...");
      PermissionStatus permStatus = await Permission.microphone.status;
      _addDebugLog("   Status: $permStatus");
      _addDebugLog("   isDenied: ${permStatus.isDenied}");
      _addDebugLog("   isGranted: ${permStatus.isGranted}");
      _addDebugLog("   isPermanentlyDenied: ${permStatus.isPermanentlyDenied}");
      _addDebugLog("   isLimited: ${permStatus.isLimited}\n");

      if (!permStatus.isGranted) {
        _addDebugLog("⚠️ Microphone permission not granted!");
        return;
      }

      // Initialize STT
      _addDebugLog("2. Initializing Speech-to-Text Engine...");
      final available = await sttEngine.initialize(
        onError: (error) {
          try {
            _addDebugLog("   ❌ STT Error: ${error.errorMsg} (permanent=${error.permanent})");
          } catch (e) {
            _addDebugLog("   ❌ STT Error: $error");
          }
        },
        onStatus: (status) {
          _addDebugLog("   → Status: $status");
        },
      );
      _addDebugLog("   Available: $available\n");

      if (!available) {
        _addDebugLog("❌ STT not available on this device");
        return;
      }

      // Check available locales
      _addDebugLog("3. Checking Available Locales...");
      List<stt.LocaleName> locales = await sttEngine.locales();
      _addDebugLog("   Found ${locales.length} locales:");
      for (var locale in locales) {
        String localeName = '';
        try {
          final dyn = locale as dynamic;
          localeName = (dyn.name ?? dyn.label ?? '').toString();
        } catch (e) {
          localeName = '';
        }
        _addDebugLog("   - ${locale.localeId}: $localeName");
      }
      _addDebugLog("");

      // Check if hindi and english locales are available
      bool hasHindi = locales.any((l) => l.localeId.startsWith("hi"));
      bool hasEnglish = locales.any((l) => l.localeId.startsWith("en"));
      _addDebugLog("   Hindi available: $hasHindi");
      _addDebugLog("   English available: $hasEnglish\n");

      _addDebugLog("✅ All checks passed!");
      _addDebugLog("Ready to test voice input.\n");

    } catch (e, stackTrace) {
      _addDebugLog("❌ Error: $e");
      _addDebugLog("Stack: $stackTrace");
    }
  }

  Future<void> _testVoiceInput() async {
    if (isListening) {
      sttEngine.stop();
      setState(() => isListening = false);
      return;
    }

    try {
      // Set audio mode to communication before starting listening (native method)
      try {
        await _audioChannel.invokeMethod('startRecordingMode');
        _addDebugLog("Audio channel: startRecordingMode invoked");
      } catch (e) {
        _addDebugLog("Audio channel startRecordingMode error: $e");
      }

      // Ensure STT is initialized
      bool available = sttEngine.isAvailable;
      _addDebugLog("STT isAvailable before listen: $available");
      if (!available) {
        try {
          final initAvail = await sttEngine.initialize(
            onError: (err) {
              try {
                _addDebugLog("   ❌ STT Error during init: ${err.errorMsg} (permanent=${err.permanent})");
              } catch (e) {
                _addDebugLog("   ❌ STT Error during init: $err");
              }
            },
            onStatus: (status) {
              _addDebugLog("   → STT Status (init): $status");
            },
          );
          _addDebugLog("STT initialize returned: $initAvail");
          available = initAvail;
        } catch (e) {
          _addDebugLog("Error initializing STT before listen: $e");
          setState(() => isListening = false);
          return;
        }
      }

      if (!available) {
        _addDebugLog("STT not available, aborting listen.");
        setState(() => isListening = false);
        return;
      }

      setState(() => isListening = true);
      _addDebugLog("\n🎤 Starting voice recording...\n");

      final stt.SpeechListenOptions listenOptions = stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      );

      sttEngine.listen(
        localeId: 'en-IN',
        listenOptions: listenOptions,
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 4),
        onSoundLevelChange: (level) {
          _addDebugLog("Sound level: $level");
        },
        onResult: (result) async {
          _addDebugLog("Heard: ${result.recognizedWords}");
          _addDebugLog("Is final: ${result.finalResult}");
          _addDebugLog("Confidence: ${result.confidence}");
          if (result.finalResult) {
            setState(() => isListening = false);
            try {
              await sttEngine.stop();
            } catch (e) {
              _addDebugLog("Error stopping STT: $e");
            }
            try {
              await _audioChannel.invokeMethod('stopRecordingMode');
            } catch (e) {
              _addDebugLog("Audio channel stopRecordingMode error: $e");
            }
            _addDebugLog("✅ Recording stopped\n");
          }
        },
      );
    } catch (e) {
      _addDebugLog("❌ Error during listening: $e");
      setState(() => isListening = false);
    }
  }

  void _addDebugLog(String message) {
    setState(() {
      debugOutput += "$message\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Microphone Diagnostics")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Text(
                  debugOutput,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _testVoiceInput,
              icon: Icon(isListening ? Icons.stop : Icons.mic),
              label: Text(isListening ? "Stop Recording" : "Test Voice Input"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening ? Colors.red : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    sttEngine.stop();
    super.dispose();
  }
}
