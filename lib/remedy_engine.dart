import 'remedy_map.dart';

class RemedyResult {
  final List<String> remedies;
  final List<String> medicines;
  final List<String> contraindications;
  final bool found;

  RemedyResult({
    required this.remedies,
    required this.medicines,
    required this.contraindications,
    required this.found,
  });
}

class RemedyEngine {
  static RemedyResult getRemedies(
    String input,
    String riskLevel,
    String language, {
    List<String> medicalConditions = const [],
  }) {
    if (riskLevel == "HIGH" || riskLevel == "UNRECOGNIZED") {
      return RemedyResult(
        remedies: [],
        medicines: [],
        contraindications: [],
        found: false,
      );
    }

    final lowerInput = input.toLowerCase();
    final langCode = language.toLowerCase();
    final isHindi = langCode.contains("hi") || langCode.contains("हिंदी");
    final isMarathi = langCode.contains("mr") || langCode.contains("मराठी");

    String? matchedKey;
    for (final entry in REMEDY_DATA.entries) {
      final keywords = List<String>.from(entry.value['keywords'] as List<dynamic>);
      for (final keyword in keywords) {
        if (lowerInput.contains(keyword.toLowerCase())) {
          matchedKey = entry.key;
          break;
        }
      }
      if (matchedKey != null) break;
    }

    if (matchedKey == null) {
      return RemedyResult(
        remedies: [],
        medicines: [],
        contraindications: [],
        found: false,
      );
    }

    final entry = REMEDY_DATA[matchedKey]!;
    final medicinesData = isMarathi
        ? List<Map<String, dynamic>>.from(entry['medicines_mr'] as List<dynamic>)
        : (isHindi
            ? List<Map<String, dynamic>>.from(entry['medicines_hi'] as List<dynamic>)
            : List<Map<String, dynamic>>.from(entry['medicines_en'] as List<dynamic>));

    final List<String> safeMedicines = [];
    final List<String> contraindicated = [];

    for (final med in medicinesData) {
      final medName = med['name'] as String;
      final contraindicationsData = List<String>.from(med['contraindications'] as List<dynamic>);
      final bool isContraindicated = medicalConditions.any((condition) {
        final lowerCondition = condition.toLowerCase();
        return contraindicationsData.contains(lowerCondition);
      });

      if (isContraindicated) {
        contraindicated.add(medName);
      } else {
        safeMedicines.add(medName);
      }
    }

    final List<String> remedies = isMarathi
        ? List<String>.from(entry['remedies_mr'] as List<dynamic>)
        : (isHindi
            ? List<String>.from(entry['remedies_hi'] as List<dynamic>)
            : List<String>.from(entry['remedies_en'] as List<dynamic>));

    return RemedyResult(
      remedies: remedies,
      medicines: safeMedicines,
      contraindications: contraindicated,
      found: true,
    );
  }
}
