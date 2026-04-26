import 'package:flutter/material.dart';
import 'theme.dart';

class SelfCareScreen extends StatefulWidget {
  final String language;
  const SelfCareScreen({super.key, required this.language});

  @override
  State<SelfCareScreen> createState() => _SelfCareScreenState();
}

class _SelfCareScreenState extends State<SelfCareScreen> {
  final List<Map<String, dynamic>> wellnessTips = [
    {
      'title': 'Hydration',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'tips': ['Drink 8 glasses of water daily.', 'Carry a reusable bottle.', 'Drink water before meals.'],
    },
    {
      'title': 'Sleep Hygiene',
      'icon': Icons.nightlight_round,
      'color': Colors.purple,
      'tips': ['Keep a consistent schedule.', 'No screens 1hr before bed.', 'Cool, dark room environment.'],
    },
    {
      'title': 'Breathing',
      'icon': Icons.air,
      'color': AppTheme.primaryGreen,
      'tips': ['Practice box breathing.', '5-min mindfulness daily.', 'Breathe through your nose.'],
    },
    {
      'title': 'Eye Strain',
      'icon': Icons.visibility,
      'color': Colors.orange,
      'tips': ['20-20-20 rule.', 'Adjust screen brightness.', 'Blink frequently.'],
    },
  ];

  final List<Map<String, dynamic>> safetyTips = [
    {
      'title': 'Fire Safety',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
      'tips': ['Know your exit routes.', 'Stop, Drop, and Roll.', 'Never use elevators in fire.'],
    },
    {
      'title': 'Theft Prevention',
      'icon': Icons.gavel,
      'color': Colors.brown,
      'tips': ['Lock all doors at night.', 'Don\'t share room codes.', 'Keep valuables in the safe.'],
    },
    {
      'title': 'Evacuation',
      'icon': Icons.exit_to_app,
      'color': Colors.orange,
      'tips': ['Follow illuminated signs.', 'Stay low if there is smoke.', 'Gather at the assembly point.'],
    },
    {
      'title': 'First Aid',
      'icon': Icons.medical_services,
      'color': Colors.redAccent,
      'tips': ['Apply pressure to bleeding.', 'Cool burns with water.', 'Call for help immediately.'],
    },
  ];

  bool get isHindi => widget.language == "हिंदी" || widget.language == "Hindi";
  bool get isMarathi => widget.language == "मराठी" || widget.language == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allTips = [...wellnessTips, ...safetyTips];

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "आरोग्य आणि सुरक्षा" : (isHindi ? "स्वास्थ्य और सुरक्षा" : "Wellness & Safety")),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: allTips.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(allTips[index], isDark);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isDark) {
    final color = category['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: ExpansionTile(
        leading: Icon(category['icon'], color: color),
        title: Text(category['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: (category['tips'] as List<String>).map((tip) => ListTile(
                dense: true,
                leading: Icon(Icons.check_circle_outline, color: color, size: 16),
                title: Text(tip),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
