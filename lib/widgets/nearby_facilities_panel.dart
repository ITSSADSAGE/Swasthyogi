import 'package:flutter/material.dart';
import '../theme.dart';
import '../nearby_services_screen.dart';

class NearbyFacilitiesPanel extends StatelessWidget {
  final bool isEmergencyMode;
  final String language;

  const NearbyFacilitiesPanel({
    super.key,
    required this.isEmergencyMode,
    required this.language,
  });

  bool get isHindi => language == "हिंदी" || language == "Hindi";
  bool get isMarathi => language == "मराठी" || language == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: AppTheme.medicalBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  isMarathi ? "जवळच्या सेवा" : (isHindi ? "नज़दीकी सेवाएँ" : "Nearby Facilities"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NearbyServicesScreen(language: language))),
              child: Text(isMarathi ? "नकाशा पहा >" : (isHindi ? "नक्शा देखें >" : "View Map >"), style: const TextStyle(color: AppTheme.medicalBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: isEmergencyMode
              ? [
                  _facilityCard(context, "Police Station", "0.8 km", Icons.local_police, Colors.blue),
                  _facilityCard(context, "Fire Station", "1.5 km", Icons.fire_truck, Colors.red),
                  _facilityCard(context, "City Hospital", "2.1 km", Icons.local_hospital, Colors.orange),
                ]
              : [
                  _facilityCard(context, "Dr. Alex (Clinic)", "0.5 km", Icons.person, Colors.teal),
                  _facilityCard(context, "Global Pharma", "1.2 km", Icons.local_pharmacy, Colors.blue),
                  _facilityCard(context, "Health Center", "1.8 km", Icons.apartment, Colors.purple),
                ],
          ),
        ),
      ],
    );
  }

  Widget _facilityCard(BuildContext context, String name, String distance, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.navigation, size: 10, color: Colors.green),
              const SizedBox(width: 4),
              Text(distance, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
