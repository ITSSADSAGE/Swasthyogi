import 'package:flutter/material.dart';
import '../theme.dart';
import '../self_care_screen.dart';
import '../breathing_screen.dart';

class SelfCarePanel extends StatelessWidget {
  final String language;

  const SelfCarePanel({
    super.key,
    required this.language,
  });

  bool get isHindi => language == "हिंदी" || language == "Hindi";
  bool get isMarathi => language == "मराठी" || language == "Marathi";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.spa_outlined, color: AppTheme.medicalBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  isMarathi ? "आरोग्य आणि सुरक्षा" : (isHindi ? "स्व-देखभाल" : "Self-Care & Safety"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SelfCareScreen(language: language))),
              child: Text(isMarathi ? "अधिक वाचा >" : (isHindi ? "अधिक पढ़ें >" : "Read More >"), style: const TextStyle(color: AppTheme.medicalBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accentCyan.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.accentCyan),
                  const SizedBox(width: 12),
                  const Text(
                    "Wellness Tip",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Staying hydrated improves focus. Try to drink at least 2 liters of water today for optimal health.",
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _breathingQuickLink(context, "4-7-8 Relax", Colors.purple, BreathingTechnique.relax),
              _breathingQuickLink(context, "Box Breath", Colors.blue, BreathingTechnique.box),
              _breathingQuickLink(context, "Calm", AppTheme.medicalBlue, BreathingTechnique.calm),
              _breathingQuickLink(context, "Energise", Colors.orange, BreathingTechnique.energise),
            ],
          ),
        ),
      ],
    );
  }

  Widget _breathingQuickLink(BuildContext context, String label, Color color, BreathingTechnique tech) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BreathingScreen(language: language, initialTechnique: tech))),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.air, size: 14, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
