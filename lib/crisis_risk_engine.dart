/// Crisis/Emergency Risk Assessment Engine
/// Classifies incidents as HIGH, MODERATE, LOW, or UNRECOGNIZED
/// Optimized for life-threatening emergencies, accidents, and urgent situations

const HIGH_CRISIS_KEYWORDS = [
  "fire", "burning", "flame", "smoke",
  "accident", "collision", "crash", "hit",
  "bleeding", "hemorrhage", "blood loss",
  "unconscious", "unconsciousness", "passed out", "fainted",
  "drowning", "water emergency", "submerged",
  "poisoning", "toxic", "overdose",
  "heart attack", "cardiac", "chest pain",
  "stroke", "paralysis", "unable to move",
  "violence", "attack", "assault", "injury",
  "collapse", "building collapse", "structure",
  "trapped", "stuck", "unable to escape",
  "electric shock", "electrocution",
  "respiratory distress", "choking", "asphyxia",
  "severe burn", "chemical burn",
  // Hindi/Marathi
  "आग", "जल रहा है", "धुआं",
  "दुर्घटना", "टकराव", "मार",
  "जख्म", "रक्तस्राव", "कट",
  "बेहोश", "गिर गया", "चेतना खो गई",
  "डूबना", "पानी", "सर्फ़",
  "जहर", "विष", "ओवरडोज",
  "हृदय गति रुक गई", "दिल का दौरा",
  "स्ट्रोक", "लकवा",
  "हिंसा", "हमला", "मार",
  "गिरना", "संरचना", "कोलाहल",
  "फंसा हुआ", "फंसना",
  "आग", "जळत आहे", "धूर",
  "अपघात", "भिडती",
  "रक्तस्राव", "रक्त",
  "बेसावध", "गिरले", "वेडोळलेले",
  "डुबणे", "पाणी",
  "विष", "ओव्हरडोज",
  "हृदय विकार", "हार्ट अटॅक",
  "पक्षाघात",
  "हिंसा", "हल्ला",
  "अडकलेले",
];

const MODERATE_CRISIS_KEYWORDS = [
  "injury", "fracture", "break", "sprain", "twist",
  "swelling", "inflammation", "bruise", "contusion",
  "shock", "panic", "fear", "distress",
  "road accident", "vehicle", "car crash",
  "gas leak", "chemical", "fume", "odor",
  "evacuation", "danger", "hazard",
  "trapped in elevator", "stuck door", "jammed",
  "severe allergy", "anaphylaxis",
  "severe pain", "acute pain",
  "unresponsive", "lethargy", "confusion",
  // Hindi/Marathi
  "चोट", "फ्रैक्चर", "टूटा हुआ", "मोच",
  "सूजन", "चोट", "चिड़चिड़ा",
  "झटका", "घबराहट", "डर",
  "सड़क दुर्घटना", "गाड़ी", "कार",
  "गैस", "रासायनिक", "धुआं",
  "निकालना", "खतरा",
  "लिफ्ट", "दरवाजा", "फंसा",
  "एलर्जी", "एनाफिलेक्सिस",
  "गंभीर दर्द",
  "बेतहाशा", "भ्रम",
  "चोट", "फ्रॅक्चर", "तुटलेले", "मोच",
  "स्फीती", "जखम",
  "धक्का", "घबराहट",
  "रस्ता अपघात",
  "गॅस", "रासायनिक",
  "निष्काशन", "धोका",
  "लिफ्ट", "दरवाजा",
  "गंभीर दुखणे",
];

const LOW_CRISIS_KEYWORDS = [
  "power outage", "electricity", "no power",
  "water outage", "no water",
  "road block", "traffic", "stuck",
  "shelter request", "homeless", "help",
  "evacuation", "moving", "relocation",
  "minor injury", "small cut", "scratch",
  "anxiety", "worried", "concerned",
  // Hindi/Marathi
  "बिजली", "बिजली चली गई",
  "पानी नहीं", "पानी बंद",
  "रास्ता बंद", "ट्रैफिक",
  "आश्रय", "बेघर",
  "निकालना", "जाना",
  "छोटी चोट", "कट", "स्क्रैच",
  "चिंता", "परेशान",
  "वीज", "वीज बंद",
  "पाणी नाही",
  "रस्ता बंद", "रहदारी",
  "आश्रय", "बेघर",
];

/// Assess crisis severity (similar to medical risk assessment)
String assessCrisis(String input) {
  final lower = input.toLowerCase();

  bool hasHighCrisis = false;
  bool hasModerateCrisis = false;
  bool hasLowCrisis = false;

  // Check HIGH_CRISIS_KEYWORDS with fuzzy matching
  for (var keyword in HIGH_CRISIS_KEYWORDS) {
    if (lower.contains(keyword.toLowerCase())) {
      hasHighCrisis = true;
      break;
    }
  }

  // Check MODERATE_CRISIS_KEYWORDS with fuzzy matching
  if (!hasHighCrisis) {
    for (var keyword in MODERATE_CRISIS_KEYWORDS) {
      if (lower.contains(keyword.toLowerCase())) {
        hasModerateCrisis = true;
        break;
      }
    }
  }

  // Check LOW_CRISIS_KEYWORDS with fuzzy matching
  if (!hasHighCrisis && !hasModerateCrisis) {
    for (var keyword in LOW_CRISIS_KEYWORDS) {
      if (lower.contains(keyword.toLowerCase())) {
        hasLowCrisis = true;
        break;
      }
    }
  }

  // Return the HIGHEST severity found
  if (hasHighCrisis) {
    return "HIGH";
  } else if (hasModerateCrisis) {
    return "MODERATE";
  } else if (hasLowCrisis) {
    return "LOW";
  }

  // If no keyword is recognized, return UNRECOGNIZED
  return "UNRECOGNIZED";
}
