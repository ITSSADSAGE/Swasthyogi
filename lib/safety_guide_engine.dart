import 'safety_guide_map.dart';

class SafetyGuideResult {
  final List<String> steps;
  final bool found;

  SafetyGuideResult({
    required this.steps,
    required this.found,
  });
}

class SafetyGuideEngine {
  static SafetyGuideResult getSafetySteps(String input, String language) {
    final lowerInput = input.toLowerCase();
    final langCode = language.toLowerCase();
    final isHindi = langCode.contains("hi") || langCode.contains("हिंदी");
    final isMarathi = langCode.contains("mr") || langCode.contains("मराठी");

    String? matchedKey;
    for (final entry in SAFETY_GUIDE_DATA.entries) {
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
      return SafetyGuideResult(
        steps: [],
        found: false,
      );
    }

    final entry = SAFETY_GUIDE_DATA[matchedKey]!;
    final List<String> steps = isMarathi
        ? List<String>.from(entry['steps_mr'] as List<dynamic>)
        : (isHindi
            ? List<String>.from(entry['steps_hi'] as List<dynamic>)
            : List<String>.from(entry['steps_en'] as List<dynamic>));

    return SafetyGuideResult(
      steps: steps,
      found: true,
    );
  }
}
