import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';

class JournalEntry {
  final String content;
  final String timestamp;
  final String type; // 'health' or 'incident'

  JournalEntry({
    required this.content,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'timestamp': timestamp,
    'type': type,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    content: json['content'],
    timestamp: json['timestamp'],
    type: json['type'],
  );
}

class JournalManager {
  static String get _keyJournal {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
    return 'swasthyogi_journal_$uid';
  }

  static Future<void> saveEntry(String content, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final List<JournalEntry> entries = await getEntries();
    
    final newEntry = JournalEntry(
      content: content,
      timestamp: DateTime.now().toIso8601String(),
      type: type,
    );
    
    entries.add(newEntry);

    final String encoded = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_keyJournal, encoded);
    
    // SYNC TO CLOUD FIRESTORE
    await DatabaseService.syncJournalEntry(newEntry);
  }

  static Future<List<JournalEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_keyJournal);
    
    if (encoded == null) return [];

    try {
      final List<dynamic> decoded = json.decode(encoded);
      return decoded.map((e) => JournalEntry.fromJson(e)).toList();
    } catch (e) {
      print("Error decoding journal: $e");
      return [];
    }
  }

  static Future<void> clearJournal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyJournal);
  }
}
