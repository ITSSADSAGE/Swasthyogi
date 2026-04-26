import 'package:flutter/material.dart';
import '../unified_report_screen.dart';
import '../crisis_coordination_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyPanel extends StatelessWidget {
  final bool isWide;
  final String language;

  const EmergencyPanel({
    super.key,
    required this.isWide,
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
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  isMarathi ? "त्वरीत मदत" : (isHindi ? "त्वरित सहायता" : "Crisis Check-In"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            _statusBadge("LIVE TRACKING", Colors.redAccent),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _incidentButton(context, isMarathi ? "आग" : (isHindi ? "आग" : "Fire"), Icons.local_fire_department, Colors.red),
            _incidentButton(context, isMarathi ? "जखम" : (isHindi ? "चोट" : "Injury"), Icons.medical_services, Colors.orange),
            _incidentButton(context, isMarathi ? "चोरी" : (isHindi ? "चोरी" : "Theft"), Icons.gavel, Colors.brown),
            _incidentButton(context, isMarathi ? "घबराट" : (isHindi ? "घबराहट" : "Panic"), Icons.psychology, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            text, 
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
          ),
        ],
      ),
    );
  }

  Widget _incidentButton(BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => CrisisCoordinationScreen(incidentType: label))
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
