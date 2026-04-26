import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class UnifiedLogManager {
  static const String _keyHistory = 'swasthyogi_unified_logs';

  /// Save a new record (medical or crisis)
  static Future<void> saveRecord(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> currentHistory = await getHistory();
    
    // Add timestamp if not present
    if (!record.containsKey('timestamp')) {
      record['timestamp'] = DateTime.now().toIso8601String();
    }
    
    currentHistory.add(record);
    
    // Keep only last 50 records to save space
    if (currentHistory.length > 50) {
      currentHistory.removeAt(0);
    }

    await prefs.setString(_keyHistory, json.encode(currentHistory));
    
    // SYNC TO CLOUD FIRESTORE
    await DatabaseService.logEmergencyIncident(record);
  }

  /// Get all history records
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString(_keyHistory);
    
    if (historyString == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(historyString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print("Error decoding history: $e");
      return [];
    }
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }
}
