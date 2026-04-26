import 'package:flutter/material.dart';
import '../network_service.dart';
import '../theme.dart';

class ModeIndicatorBanner extends StatelessWidget {
  final bool isEmergencyMode;
  
  const ModeIndicatorBanner({
    super.key, 
    required this.isEmergencyMode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NetworkSpeed>(
      stream: NetworkService.onSpeedChanged,
      initialData: NetworkSpeed.high,
      builder: (context, snapshot) {
        final speed = snapshot.data ?? NetworkSpeed.none;
        final isOffline = speed == NetworkSpeed.none;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isEmergencyMode ? AppTheme.emergencyRed.withOpacity(0.9) : AppTheme.medicalBlue.withOpacity(0.9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isEmergencyMode ? Icons.warning_amber_rounded : Icons.health_and_safety_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEmergencyMode ? "EMERGENCY MODE" : "MEDICAL MODE",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    isOffline ? Icons.wifi_off : Icons.wifi,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOffline ? "OFFLINE" : "ONLINE",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
