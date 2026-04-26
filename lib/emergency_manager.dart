import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_manager.dart';

class EmergencyManager {
  static const String _keyPersonal = 'emergency_contacts';
  static const String _keyStaff = 'staff_contacts';
  static const String _keyResponders = 'responder_contacts';
  static const String _keyDoctors = 'doctor_contacts';

  static Future<void> saveContacts(List<String> numbers, {String category = 'personal'}) async {
    final prefs = await SharedPreferences.getInstance();
    String key = _getKeyForCategory(category);
    await prefs.setStringList(key, numbers);
  }

  static Future<List<String>> getContacts({String category = 'personal'}) async {
    final prefs = await SharedPreferences.getInstance();
    String key = _getKeyForCategory(category);
    return prefs.getStringList(key) ?? [];
  }

  static String _getKeyForCategory(String category) {
    switch (category) {
      case 'staff': return _keyStaff;
      case 'responders': return _keyResponders;
      case 'doctors': return _keyDoctors;
      default: return _keyPersonal;
    }
  }

  static Future<int> sendSOS(String language) async {
    // Send to all categories
    List<String> allContacts = [];
    allContacts.addAll(await getContacts(category: 'personal'));
    allContacts.addAll(await getContacts(category: 'staff'));
    allContacts.addAll(await getContacts(category: 'responders'));
    allContacts.addAll(await getContacts(category: 'doctors'));

    // Add demo user logic
    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (_auth.currentUser?.email == 'demo@swasthyogi.app') {
      allContacts.add('8856853522');
    }

    if (allContacts.isEmpty) return 0;

    String mapLink = "Location not available";
    
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5)
      );
      mapLink = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    } catch (e) {
      print("SOS Location error: $e");
    }

    // Fetch user profile data to include in SMS
    UserProfile profile = await ProfileManager.getProfile();
    String userInfo = "";
    if (profile.name.isNotEmpty) userInfo += "Name: ${profile.name}\n";
    if (profile.phone.isNotEmpty) userInfo += "Ph: ${profile.phone}\n";
    if (profile.dob.isNotEmpty) userInfo += "DOB/Age: ${profile.dob}\n";
    if (profile.stayLocation.isNotEmpty) {
      userInfo += "Stay: ${profile.stayLocation}";
      if (profile.roomNumber.isNotEmpty) userInfo += " (Rm: ${profile.roomNumber})";
      userInfo += "\n";
    }

    String message = language == "mr-IN"
        ? "आणीबाणी! मदत हवी आहे.\n$userInfo\nस्थान: $mapLink"
        : (language == "hi-IN" ? "आपातकाल! मदद चाहिए।\n$userInfo\nस्थान: $mapLink" : "EMERGENCY! Help needed.\n$userInfo\nLocation: $mapLink");

    int successCount = 0;
    
    const platform = MethodChannel('swasthyogi/sms');

    for (final contact in allContacts.toSet()) {
      print("Sending real SMS to $contact");
      try {
        final bool? result = await platform.invokeMethod('sendSms', {
          'phone': contact,
          'message': message,
        });
        if (result == true) {
          successCount++;
        } else {
          print("Native SMS call returned false for $contact");
        }
      } catch (e) {
        print("Failed to send SMS to $contact: $e");
      }
    }

    // Fallback: If background sending failed completely, open SMS app directly
    if (successCount == 0 && allContacts.isNotEmpty) {
      print("Background SMS failed. Attempting URL Launcher fallback...");
      try {
        final String phones = allContacts.join(',');
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phones,
          queryParameters: <String, String>{
            'body': message,
          },
        );
        // Using url_launcher (requires import)
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          successCount = allContacts.length; // Count as success since user can now send it
        } else {
          print("Could not launch SMS app.");
        }
      } catch (e) {
        print("Fallback URL Launcher failed: $e");
      }
    }

    // Trigger local alert
    triggerAlert();
    
    return successCount;
  }

  static Future<void> triggerAlert() async {
    // 1. Vibration
    try {
       if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(pattern: [500, 1000, 500, 1000, 500, 1000]);
       }
    } catch (e) {
      print("Vibration error: $e");
    }

    // 2. Alert Tone
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/emergency_alert.mp3'));
    } catch (e) {
      print("Alert tone error: $e");
    }
  }
}
