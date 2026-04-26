const Map<String, Map<String, dynamic>> REMEDY_DATA = {
  "fever": {
    "keywords": ["fever", "temperature", "hot", "warm", "shivering", "बुखार", "ताप", "गर्म", "ताप", "थंडी", "कडक ताप", "तेज बुखार", "तापमान"],
    "remedies_en": [
      "Drink plenty of fluids to stay hydrated.",
      "Rest and get enough sleep.",
      "Use a cold compress on your forehead."
    ],
    "medicines_en": [
      {
        "name": "Paracetamol (Crocin/Dolo 650)",
        "contraindications": [] // Safe for most people
      }
    ],
    "remedies_hi": [
      "खूब पानी और तरल पदार्थ पिएं।",
      "आराम करें और पर्याप्त नींद लें।",
      "माथे पर ठंडे पानी की पट्टी रखें।"
    ],
    "medicines_hi": [
      {
        "name": "पैरासिटामोल (क्रोसिन/डोलो 650)",
        "contraindications": []
      }
    ],
    "remedies_mr": [
      "हायड्रेटेड राहण्यासाठी भरपूर द्रव प्या.",
      "आराम करा आणि पुरेशी झोप घ्या.",
      "कपाळावर थंड पाण्याच्या पट्ट्या ठेवा."
    ],
    "medicines_mr": [
      {
        "name": "पॅरासिटामोल (क्रोसीन/डोलो ६५०)",
        "contraindications": []
      }
    ]
  },
  "cold_cough": {
    "keywords": ["cold", "cough", "runny nose", "sneeze", "throat", "सर्दी", "जुकाम", "खांसी", "गला", "सर्दी", "खोकला", "घसा", "तेज खांसी", "खाकला"],
    "remedies_en": [
      "Drink warm water and herbal tea (ginger/honey).",
      "Steam inhalation 2-3 times a day.",
      "Gargle with warm salt water."
    ],
    "medicines_en": [
      {
        "name": "Cetirizine (for runny nose)",
        "contraindications": []
      },
      {
        "name": "Cough Syrup (Benadryl/Grilinctus)",
        "contraindications": ["diabetes"] // High sugar content
      }
    ],
    "remedies_hi": [
      "गर्म पानी और अदरक/शहद वाली चाय पिएं।",
      "दिन में 2-3 बार भाप लें।",
      "गर्म नमक के पानी से गरारे करें।"
    ],
    "medicines_hi": [
      {
        "name": "सिट्रिज़िन (बहती नाक के लिए)",
        "contraindications": []
      },
      {
        "name": "कफ सिरप (बेनाड्रिल)",
        "contraindications": ["diabetes"]
      }
    ],
    "remedies_mr": [
      "कोमट पाणी आणि आले/मधाचा चहा प्या.",
      "दिवसातून २-३ वेळा वाफ घ्या.",
      "मिठाच्या कोमट पाण्याने गुळण्या करा."
    ],
    "medicines_mr": [
      {
        "name": "सिट्रिझिन (नाक गळत असल्यास)",
        "contraindications": []
      },
      {
        "name": "कफ सिरप (बेनाड्रिल/ग्रिलिंक्टस)",
        "contraindications": ["diabetes"]
      }
    ]
  },
  "headache": {
    "keywords": ["headache", "head pain", "migraine", "सिरदर्द", "सिर दर्द", "सर दर्द", "डोकेदुखी", "डोकं दुखणे"],
    "remedies_en": [
      "Rest in a dark and quiet room.",
      "Stay hydrated.",
      "Apply balm or massage gently."
    ],
    "medicines_en": [
      {
        "name": "Paracetamol",
        "contraindications": []
      },
      {
        "name": "Disprin (if no acidity)",
        "contraindications": ["thyroid", "diabetes"]
      }
    ],
    "remedies_hi": [
      "अंधेरे और शांत कमरे में आराम करें।",
      "पानी पीते रहें।",
      "बाम लगाएं या हल्की मालिश करें।"
    ],
    "medicines_hi": [
      {
        "name": "पैरासिटामोल",
        "contraindications": []
      },
      {
        "name": "डिस्प्रिन",
        "contraindications": ["thyroid", "diabetes"]
      }
    ],
    "remedies_mr": [
      "गडद आणि शांत खोलीत आराम करा.",
      "हायड्रेटेड रहा.",
      "बाम लावा किंवा हलका मसाज करा."
    ],
    "medicines_mr": [
      {
        "name": "पॅरासिटामोल",
        "contraindications": []
      },
      {
        "name": "डिस्प्रिन (अॅसिडिटी नसल्यास)",
        "contraindications": ["thyroid", "diabetes"]
      }
    ]
  },
  "stomach": {
    "keywords": ["stomach", "acidity", "gas", "pain in tummy", "diarrhea", "vomit", "पेट", "एसिडिटी", "गैस", "दस्त", "उल्टी", "पोटदुखी", "उलट्या", "जुलाब", "गॅस", "अॅसिडिटी"],
    "remedies_en": [
      "Drink lemon water or buttermilk.",
      "Avoid spicy and oily food.",
      "Eat light food like Khichdi."
    ],
    "medicines_en": [
      {
        "name": "Digene/Eno (for acidity)",
        "contraindications": ["diabetes"] // Contains sugar
      },
      {
        "name": "ORS (for diarrhea/vomiting)",
        "contraindications": []
      }
    ],
    "remedies_hi": [
      "नींबू पानी या छाछ पिएं।",
      "मसालेदार और तैलीय भोजन से बचें।",
      "खिचड़ी जैसा हल्का भोजन करें।"
    ],
    "medicines_hi": [
      {
        "name": "डायजीन/ईनो (एसिडिटी के लिए)",
        "contraindications": ["diabetes"]
      },
      {
        "name": "ओआरएस (दस्त/उल्टी के लिए)",
        "contraindications": []
      }
    ],
    "remedies_mr": [
      "लिंबू पाणी किंवा ताक प्या.",
      "मसालेदार आणि तेलकट पदार्थ टाळा.",
      "खिचडीसारखा हलका आहार घ्या."
    ],
    "medicines_mr": [
      {
        "name": "डायजीन/ईनो (अॅसिडिटीसाठी)",
        "contraindications": ["diabetes"]
      },
      {
        "name": "ओआरएस (जुलाब/उलट्यांसाठी)",
        "contraindications": []
      }
    ]
  },
  "body_pain": {
    "keywords": ["body pain", "knee", "back pain", "joint", "muscle", "शरीर दर्द", "घुटने", "पीठ", "कमर", "मांसपेशियों", "अंगदुखी", "गुडघे", "कंबर", "सांधे"],
    "remedies_en": [
      "Apply hot water bag on affected area.",
      "Gentle stretching.",
      "Rest the affected part."
    ],
    "medicines_en": [
      {
        "name": "Volini/Moov Spray",
        "contraindications": []
      },
      {
        "name": "Paracetamol",
        "contraindications": []
      }
    ],
    "remedies_hi": [
      "दर्द वाली जगह पर गर्म पानी की थैली से सिकाई करें।",
      "हल्का व्यायाम करें।",
      "प्रभावित हिस्से को आराम दें।"
    ],
    "medicines_hi": [
      {
        "name": "वोलिनी/मूव स्प्रे",
        "contraindications": []
      },
      {
        "name": "पैरासिटामोल",
        "contraindications": []
      }
    ],
    "remedies_mr": [
      "दुखणाऱ्या भागावर गरम पाण्याच्या पिशवीने शेका.",
      "हलका व्यायाम करा.",
      "प्रभावित भागाला विश्रांती द्या."
    ],
    "medicines_mr": [
      {
        "name": "वोलिनी/मूव्ह स्प्रे",
        "contraindications": []
      },
      {
        "name": "पॅरासिटामोल",
        "contraindications": []
      }
    ]
  }
};
