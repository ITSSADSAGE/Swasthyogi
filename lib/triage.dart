class TriageResult {
  final String risk;
  final List<String> matchedSymptoms;

  TriageResult({required this.risk, required this.matchedSymptoms});
}

class TriageEngine {
  static final Map<String, String> symptomMap = {
    "fever": "fever",
    "bukhar": "fever",
    "headache": "headache",
    "sar dard": "headache",
    "cough": "cough",
    "khansi": "cough",
    "vomit": "vomit",
    "ulti": "vomit",
    "dizziness": "dizziness",
    "chakkar": "dizziness",
    "breathless": "breathless",
    "saans": "breathless",
  };

  static TriageResult triage(String input) {
    input = input.toLowerCase();

    List<String> matched = [];
    for (var entry in symptomMap.entries) {
      if (input.contains(entry.key)) {
        matched.add(entry.value);
      }
    }

    if (matched.contains("breathless")) {
      return TriageResult(risk: "HIGH", matchedSymptoms: matched);
    }

    if (matched.contains("fever") && matched.contains("dizziness")) {
      return TriageResult(risk: "MODERATE", matchedSymptoms: matched);
    }

    if (matched.contains("fever")) {
      return TriageResult(risk: "LOW", matchedSymptoms: matched);
    }

    return TriageResult(risk: "UNKNOWN", matchedSymptoms: matched);
  }
}
