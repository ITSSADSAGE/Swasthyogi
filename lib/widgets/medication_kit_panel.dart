import 'package:flutter/material.dart';
import '../theme.dart';
import '../medication_kit_screen.dart';

class MedicationKitPanel extends StatelessWidget {
  final bool isEmergencyMode;
  final String language;

  const MedicationKitPanel({
    super.key,
    required this.isEmergencyMode,
    required this.language,
  });

  bool get isHindi => language == "हिंदी" || language == "Hindi";
  bool get isMarathi => language == "मराठी" || language == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isEmergencyMode ? AppTheme.emergencyRed : AppTheme.medicalBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(isEmergencyMode ? Icons.inventory_2_outlined : Icons.medication_outlined, 
                     color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  isEmergencyMode
                      ? (isMarathi ? "आणीबाणी किट" : (isHindi ? "आपातकालीन किट" : "Emergency Kit"))
                      : (isMarathi ? "औषधोपचार" : (isHindi ? "दवाएं" : "Medication Track")),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationKitScreen(language: language))),
              child: Text(isMarathi ? "अधिक पहा >" : (isHindi ? "अधिक देखें >" : "Manage >"), style: TextStyle(color: color)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            children: isEmergencyMode 
              ? [
                  _kitItem("First Aid Kit", "Checked", Icons.check_circle, Colors.green),
                  _kitItem("Fire Extinguisher", "Ready", Icons.check_circle, Colors.green),
                  _kitItem("Oxygen Cylinder", "Full", Icons.check_circle, Colors.green),
                ]
              : [
                  _medItem("Paracetamol", "08:00 AM", true),
                  _medItem("Vitamin C", "12:00 PM", false),
                  _medItem("Omeprazole", "08:00 PM", false),
                ],
          ),
        ),
      ],
    );
  }

  Widget _kitItem(String label, String status, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _medItem(String name, String time, bool taken) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(taken ? Icons.check_circle : Icons.radio_button_unchecked, 
               color: taken ? AppTheme.medicalBlue : Colors.grey, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          if (!taken) 
            TextButton(
              onPressed: () {}, 
              child: const Text("Take", style: TextStyle(fontSize: 12, color: AppTheme.medicalBlue)),
            )
          else
            const Icon(Icons.done_all, color: AppTheme.medicalBlue, size: 16),
        ],
      ),
    );
  }
}
