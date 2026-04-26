import 'package:flutter/material.dart';
import 'theme.dart';

class VitalsScreen extends StatefulWidget {
  final String language;
  const VitalsScreen({super.key, required this.language});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  // Mock Vitals Data
  int bpm = 74;
  String bp = "118/76";
  int spo2 = 98;
  double temp = 36.6;

  bool isScanning = false;
  bool isConnected = false;

  bool get isHindi => widget.language == "हिंदी" || widget.language == "Hindi";
  bool get isMarathi => widget.language == "मराठी" || widget.language == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "जीवनरक्षक चिन्हे" : (isHindi ? "वाइटल्स" : "Vitals Dashboard")),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.watch : Icons.watch_off, color: isConnected ? AppTheme.medicalBlue : Colors.grey),
            onPressed: _toggleWatchConnection,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatus(),
            const SizedBox(height: 24),
            _buildVitalsGrid(),
            const SizedBox(height: 32),
            _buildManualEntrySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isConnected ? AppTheme.medicalBlue : AppTheme.accentCyan).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isConnected ? AppTheme.medicalBlue : AppTheme.accentCyan).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching, color: isConnected ? AppTheme.medicalBlue : AppTheme.accentCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? "Connected to Swasthyogi Watch V2" : (isScanning ? "Scanning for devices..." : "No device connected"),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isConnected) const Text("Last synced: Just now", style: TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          if (!isConnected)
            TextButton(
              onPressed: _scanForDevices,
              child: Text(isScanning ? "STOP" : "SCAN"),
            ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _vitalInputCard("Heart Rate", "$bpm", "bpm", Icons.favorite, Colors.red),
        _vitalInputCard("Blood Pressure", bp, "mmHg", Icons.timeline, Colors.purple),
        _vitalInputCard("Oxygen", "$spo2", "SpO2", Icons.water_drop, Colors.blue),
        _vitalInputCard("Temperature", "$temp", "°C", Icons.thermostat, Colors.orange),
      ],
    );
  }

  Widget _vitalInputCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          Text(unit, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildManualEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? "मॅन्युअल एन्ट्री" : (isHindi ? "मैनुअल एंट्री" : "Manual Entry"),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTextField("Heart Rate (bpm)", (v) => setState(() => bpm = int.tryParse(v) ?? bpm)),
        const SizedBox(height: 12),
        _buildTextField("Blood Pressure (systolic/diastolic)", (v) => setState(() => bp = v)),
        const SizedBox(height: 12),
        _buildTextField("Oxygen (%)", (v) => setState(() => spo2 = int.tryParse(v) ?? spo2)),
        const SizedBox(height: 12),
        _buildTextField("Temperature (°C)", (v) => setState(() => temp = double.tryParse(v) ?? temp)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.medicalBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(isMarathi ? "जतन करा" : (isHindi ? "सहेजें" : "Save Vitals")),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, ValueChanged<String> onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  void _scanForDevices() {
    setState(() => isScanning = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isScanning = false;
          isConnected = true;
          // Simulated IoT Sync
          bpm = 78;
          spo2 = 99;
          temp = 36.7;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syncing data from Smartwatch..."), backgroundColor: AppTheme.medicalBlue));
      }
    });
  }

  void _toggleWatchConnection() {
    setState(() => isConnected = !isConnected);
  }
}
