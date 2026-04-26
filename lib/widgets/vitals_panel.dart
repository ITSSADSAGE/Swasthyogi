import 'package:flutter/material.dart';
import '../theme.dart';
import '../vitals_screen.dart';

class VitalsPanel extends StatelessWidget {
  final bool isWide;
  final String language;

  const VitalsPanel({
    super.key,
    required this.isWide,
    required this.language,
  });

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
                Icon(Icons.favorite_outline, color: AppTheme.medicalBlue, size: 20),
                const SizedBox(width: 8),
                const Text("Vitals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => VitalsScreen(language: language))
              ), 
              child: const Text("Update >", style: TextStyle(color: AppTheme.medicalBlue))
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 6 : 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 1.0 : 0.75,
          children: [
            _vitalsCard(context, Icons.favorite, "74", "bpm", Colors.red),
            _vitalsCard(context, Icons.timeline, "118/76", "mmHg", Colors.purple),
            _vitalsCard(context, Icons.water_drop, "98%", "SpO2", Colors.blue),
            _vitalsCard(context, Icons.thermostat, "36.6°", "temp", Colors.orange),
            _vitalsCard(context, Icons.directions_walk, "4,250", "steps", Colors.teal),
            _vitalsCard(context, Icons.local_fire_department, "320", "kcal", Colors.deepOrange),
          ],
        ),
      ],
    );
  }

  Widget _vitalsCard(BuildContext context, IconData icon, String value, String unit, Color color) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: theme.brightness == Brightness.light ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(unit, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}
