import 'symptom_map.dart';

/// Calculate Levenshtein distance between two strings
/// for fuzzy matching of crisis keywords
int levenshteinDistance(String a, String b) {
  final aLen = a.length;
  final bLen = b.length;

  if (aLen == 0) return bLen;
  if (bLen == 0) return aLen;

  final matrix = List<List<int>>.generate(
    aLen + 1,
    (i) => List<int>.generate(bLen + 1, (j) => 0),
  );

  for (int i = 0; i <= aLen; i++) {
    matrix[i][0] = i;
  }
  for (int j = 0; j <= bLen; j++) {
    matrix[0][j] = j;
  }

  for (int i = 1; i <= aLen; i++) {
    for (int j = 1; j <= bLen; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,      // deletion
        matrix[i][j - 1] + 1,      // insertion
        matrix[i - 1][j - 1] + cost // substitution
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  return matrix[aLen][bLen];
}

/// Check if a symptom matches using fuzzy matching (Levenshtein distance)
/// Returns true if distance is within 30% of the longer string's length
bool isSimilar(String input, String symptom) {
  // Stop words to ignore during matching
  const stopWords = {
    'and', 'or', 'the', 'a', 'an', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'is', 'am', 'are', 'was', 'were',
    'i', 'me', 'my', 'mine', 'you', 'your', 'he', 'him', 'his', 'she', 'her', 'it', 'its', 'we', 'us', 'our', 'they', 'them', 'their',
    'have', 'has', 'had', 'do', 'does', 'did', 'but', 'so', 'if', 'because', 'as', 'not', 'no', 'very'
  };

  final inputWords = input.toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => !stopWords.contains(w) && w.length > 2) // Ignore stop words and very short words
      .toList();
      
  final symptomWords = symptom.toLowerCase().split(RegExp(r'\s+'));

  if (inputWords.isEmpty) return false;

  // Check for exact substring match first (fastest)
  for (var word in inputWords) {
    // Only substring match significant words (length >= 4)
    if (symptom.contains(word)) return true;
    
    if (word.length >= 5) {
      String sub = word.substring(0, (word.length * 0.8).toInt());
      if (symptom.contains(sub)) {
        return true;
      }
    }
  }

  // Check for fuzzy match using Levenshtein distance
  for (var inputWord in inputWords) {
    for (var symptomWord in symptomWords) {
      final distance = levenshteinDistance(inputWord, symptomWord);
      final maxLen = [inputWord.length, symptomWord.length].reduce((a, b) => a > b ? a : b);
      
      // Stricter threshold: 20% diff max, or max distance of 2
      final threshold = (maxLen * 0.2).toInt(); 

      if (distance <= threshold) {
        return true;
      }
    }
  }

  return false;
}

String assessRisk(String input) {
  final lower = input.toLowerCase();
  
  bool hasHighSymptom = false;
  bool hasModerateSymptom = false;
  bool hasLowSymptom = false;

  // Check HIGH_SYMPTOMS with fuzzy matching for urgent crisis signals
  for (var s in HIGH_SYMPTOMS) {
    if (lower.contains(s) || isSimilar(input, s)) {
      hasHighSymptom = true;
    }
  }

  // Check MODERATE_SYMPTOMS with fuzzy matching for serious but not immediately deadly events
  for (var s in MODERATE_SYMPTOMS) {
    if (lower.contains(s) || isSimilar(input, s)) {
      hasModerateSymptom = true;
    }
  }

  // Check LOW_SYMPTOMS with fuzzy matching for non-critical incidents or support requests
  for (var s in LOW_SYMPTOMS) {
    if (lower.contains(s) || isSimilar(input, s)) {
      hasLowSymptom = true;
    }
  }

  // Return the HIGHEST severity found (priority: HIGH > MODERATE > LOW > UNRECOGNIZED)
  if (hasHighSymptom) {
    return "HIGH";
  } else if (hasModerateSymptom) {
    return "MODERATE";
  } else if (hasLowSymptom) {
    return "LOW";
  }

  // If no symptom is recognized, return UNRECOGNIZED
  return "UNRECOGNIZED";
}
