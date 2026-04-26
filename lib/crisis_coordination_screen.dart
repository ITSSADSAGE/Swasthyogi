import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'dart:async';

class CrisisCoordinationScreen extends StatefulWidget {
  final String incidentType;
  const CrisisCoordinationScreen({super.key, required this.incidentType});

  @override
  State<CrisisCoordinationScreen> createState() => _CrisisCoordinationScreenState();
}

class _CrisisCoordinationScreenState extends State<CrisisCoordinationScreen> {
  int _currentStage = 0;
  late Timer _timer;
  
  final List<Map<String, dynamic>> _stages = [
    {"title": "Alert Transmitted", "subtitle": "Venue security server has received your signal.", "icon": Icons.cloud_done_outlined},
    {"title": "Staff Dispatched", "subtitle": "A rapid response team member is heading to your location.", "icon": Icons.directions_run},
    {"title": "First Responders Notified", "subtitle": "Local emergency services have been given your room/GPS data.", "icon": Icons.local_police_outlined},
    {"title": "Help is On-Site", "subtitle": "Assistance has arrived at your location.", "icon": Icons.verified_user_outlined},
  ];

  @override
  void initState() {
    super.initState();
    // Simulate real-time coordination updates
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentStage < _stages.length - 1) {
        setState(() => _currentStage++);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildCriticalHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIncidentBadge(),
                    const SizedBox(height: 32),
                    Text(
                      "Live Response Timeline",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(_stages.length, (index) => _buildTimelineStep(index)),
                  ],
                ),
              ),
            ),
            _buildActionFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: const Border(bottom: BorderSide(color: Colors.redAccent, width: 2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_share, color: Colors.redAccent, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CRISIS ACTIVE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.redAccent)),
                Text("Syncing with Hospitality Response Hub...", style: GoogleFonts.outfit(color: Colors.grey)),
              ],
            ),
          ),
          const _PulseBeacon(),
        ],
      ),
    );
  }

  Widget _buildIncidentBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Text("Incident Type: ", style: GoogleFonts.outfit(color: Colors.grey)),
          Text(widget.incidentType, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(int index) {
    final bool isCompleted = index <= _currentStage;
    final bool isCurrent = index == _currentStage;
    final color = isCompleted ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppTheme.primaryGreen : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: isCompleted 
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
              ),
              if (index != _stages.length - 1)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stages[index]["title"],
                    style: GoogleFonts.outfit(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stages[index]["subtitle"],
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                  ),
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text("IN PROGRESS", style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("I AM SAFE", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {}, 
            icon: const Icon(Icons.call, color: Colors.redAccent),
            label: Text("Request Immediate Call-back", style: GoogleFonts.outfit(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _PulseBeacon extends StatefulWidget {
  const _PulseBeacon();

  @override
  State<_PulseBeacon> createState() => _PulseBeaconState();
}

class _PulseBeaconState extends State<_PulseBeacon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withOpacity(0.3 + (_controller.value * 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.5),
                blurRadius: 10 * _controller.value,
                spreadRadius: 5 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
