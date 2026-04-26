import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  static Future<void> initialize() async {
    // Note: This requires a valid google-services.json and Firebase setup
    try {
      await Firebase.initializeApp();
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      // Get token for staff alerts
      String? token = await messaging.getToken();
      print("FCM Token: $token");

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
    } catch (e) {
      print("Firebase initialization skipped (likely no config file): $e");
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }

  /// Send a mock alert to staff (In a real app, this would be a server-side call)
  static Future<void> notifyStaff(String incident, String severity) async {
    print("NOTIFYING STAFF: Crisis detected - $incident ($severity)");
    // Real implementation would use http to call a cloud function that sends FCM to staff tokens
  }
}
