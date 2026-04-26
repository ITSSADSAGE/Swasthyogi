# Microphone Troubleshooting Guide

## If You're Facing Microphone Issues:

### **Step 1: Test with Diagnostics**
I've created a diagnostic screen to help identify the problem:

1. In your `main.dart`, temporarily add this to test:
```dart
import 'package:swasthyogi/microphone_debug.dart';

// In your home screen, add a debug button:
TextButton(
  onPressed: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const MicrophoneDebugScreen(),
    ));
  },
  child: const Text("Microphone Debug"),
)
```

2. Run the app and tap "Microphone Debug"
3. Check the diagnostic output - it will tell you:
   - ✅ If permission is granted
   - ✅ If STT is available
   - ✅ What locales your device supports
   - ✅ If voice recording works

### **Step 2: Common Issues & Fixes**

| Issue | Solution |
|-------|----------|
| "Speech recognition not available" | Your device doesn't have Google Speech Recognition. Install it from Play Store |
| Permission denied | Go to Settings > Apps > Swasthyogi > Permissions > Microphone > Allow |
| Nothing happens when speaking | Try switching to English (en-IN) locale instead of Hindi |
| Crashes on listen | Check your device API level (need 21+) |
| Audio not detected | Check your mic is not muted/covered |

### **Step 3: Manual Fixes**

**Option A: Add Google Speech Recognition**
- Go to Play Store
- Search "Google Recorder" or "Google Assistant"
- Install it (adds speech-to-text support)

**Option B: Force Text Mode**
Edit `conversation_screen.dart` line ~55:
```dart
// Change from 'voice' to 'text'
String inputMode = 'text';  // Start in text mode by default
```

**Option C: Add Fallback Locale**
Edit `conversation_screen.dart` in the `_startListening` method:
```dart
// Replace selectedLanguage with a known locale
String localeToUse = 'en-US';  // Use en-US instead of hi-IN
```

### **Step 4: Check Device Requirements**

Your device needs:
- ✅ Android 5.0+ (API 21+)
- ✅ Google Play Services installed
- ✅ Speech recognition engine (usually pre-installed)
- ✅ Working microphone

### **Step 5: Enable Verbose Logging**

To see detailed logs:
1. Connect device via USB
2. Run: `flutter logs`
3. Use the app
4. Look for lines with "STT" or "LISTENING"
5. Copy errors and share them

### **Report the Issue**

If you still have issues, run these commands:
```powershell
cd "e:\Projects\Swasthyogi\swasthyogi"
flutter logs > mic_debug.txt
# Use app and try voice
# Then share the mic_debug.txt file
```

## What I've Improved:

✅ Better error handling with try-catch  
✅ Added mounting checks to prevent crashed  
✅ More detailed debug logging  
✅ Auto-fallback to text mode  
✅ Locale availability checking  
✅ Proper initialization of STT engine  

## Next Steps:

1. **Run the app**: `flutter run`
2. **Try voice mode**: Should now work better with improved error messages
3. **If it doesn't work**: Use the debug screen to identify the exact issue
4. **Then report**: What the debug screen shows you

Good luck! 🎤
