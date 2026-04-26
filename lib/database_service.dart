import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'journal_manager.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initializes Firestore with offline persistence enabled.
  /// (This happens by default on Android/iOS, but good to configure explicitly if needed).
  static Future<void> initialize() async {
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Helper to get the current user ID
  static String? get _userId => _auth.currentUser?.uid;

  /// --------------------------------------------------------------------------
  /// 1. USER PROFILE DATA
  /// --------------------------------------------------------------------------
  static Future<void> saveUserProfile(Map<String, dynamic> data) async {
    if (_userId == null) return;
    try {
      await _db.collection('users').doc(_userId).set(data, SetOptions(merge: true));
    } catch (e) {
      print("Error saving profile to Firestore: $e");
    }
  }

  /// --------------------------------------------------------------------------
  /// 2. EMERGENCY LOGS & INCIDENTS
  /// --------------------------------------------------------------------------
  static Future<void> logEmergencyIncident(Map<String, dynamic> incidentData) async {
    if (_userId == null) return;
    try {
      // Add timestamp if not exists
      incidentData['timestamp'] ??= FieldValue.serverTimestamp();
      
      await _db
          .collection('users')
          .doc(_userId)
          .collection('emergency_logs')
          .add(incidentData);
    } catch (e) {
      print("Error logging emergency to Firestore: $e");
    }
  }

  static Stream<QuerySnapshot> streamEmergencyLogs() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_userId)
        .collection('emergency_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// --------------------------------------------------------------------------
  /// 3. JOURNAL ENTRIES
  /// --------------------------------------------------------------------------
  static Future<void> syncJournalEntry(JournalEntry entry) async {
    if (_userId == null) return;
    try {
      // Use timestamp as ID
      await _db
          .collection('users')
          .doc(_userId)
          .collection('journals')
          .doc(entry.timestamp)
          .set({
            'content': entry.content,
            'timestamp': entry.timestamp,
            'type': entry.type,
          });
    } catch (e) {
      print("Error syncing journal to Firestore: $e");
    }
  }

  static Stream<QuerySnapshot> streamJournals() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
