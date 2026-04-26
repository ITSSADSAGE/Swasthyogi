import 'package:flutter/material.dart';
import 'theme.dart';

class MedicationKitScreen extends StatefulWidget {
  final String language;
  const MedicationKitScreen({super.key, required this.language});

  @override
  State<MedicationKitScreen> createState() => _MedicationKitScreenState();
}

class _MedicationKitScreenState extends State<MedicationKitScreen> {
  bool isEmergencyKitView = false;

  // Mock Medication Data
  final List<Map<String, dynamic>> medications = [
    {'name': 'Paracetamol', 'time': '08:00 AM', 'taken': true},
    {'name': 'Vitamin C', 'time': '12:00 PM', 'taken': false},
    {'name': 'Omeprazole', 'time': '08:00 PM', 'taken': false},
  ];

  // Mock Emergency Kit Data
  final List<Map<String, dynamic>> emergencyKit = [
    {'name': 'First Aid Kit', 'location': 'Reception Desk', 'status': 'Stocked'},
    {'name': 'Oxygen Cylinder', 'location': 'Hall A', 'status': 'Full'},
    {'name': 'Fire Extinguisher', 'location': 'Kitchen Entrance', 'status': 'Checked'},
    {'name': 'Emergency Lights', 'location': 'All Corridors', 'status': 'Functional'},
  ];

  bool get isHindi => widget.language == "हिंदी" || widget.language == "Hindi";
  bool get isMarathi => widget.language == "मराठी" || widget.language == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEmergencyKitView 
            ? (isMarathi ? "आणीबाणी किट" : (isHindi ? "आपातकालीन किट" : "Emergency Kit"))
            : (isMarathi ? "औषधोपचार" : (isHindi ? "दवाएं" : "Medications"))),
        actions: [
          Switch(
            value: isEmergencyKitView,
            onChanged: (v) => setState(() => isEmergencyKitView = v),
            activeColor: Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 12),
          Expanded(
            child: isEmergencyKitView ? _buildEmergencyKitList() : _buildMedicationList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: isEmergencyKitView ? Colors.red : AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEmergencyKitView 
              ? [Colors.red.shade900, Colors.red.shade700] 
              : [AppTheme.primaryGreen.withOpacity(0.8), AppTheme.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEmergencyKitView ? "Crisis Readiness" : "Adherence Stats",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            isEmergencyKitView ? "All Systems Ready" : "85% Adherence",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: isEmergencyKitView ? 1.0 : 0.85,
            backgroundColor: Colors.white24,
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final med = medications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.medication, color: med['taken'] ? AppTheme.primaryGreen : Colors.grey),
            title: Text(med['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Time: ${med['time']}"),
            trailing: Checkbox(
              value: med['taken'],
              onChanged: (v) => setState(() => med['taken'] = v),
              activeColor: AppTheme.primaryGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyKitList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: emergencyKit.length,
      itemBuilder: (context, index) {
        final item = emergencyKit[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.inventory_2, color: Colors.red.shade300),
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Location: ${item['location']}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['status'],
                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
