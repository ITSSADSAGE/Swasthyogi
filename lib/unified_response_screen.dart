import 'package:flutter/material.dart';
import 'risk_engine.dart';
import 'crisis_risk_engine.dart';

class UnifiedResponseScreen extends StatelessWidget {
  final String input;
  final String language;
  final String type; // 'medical' or 'crisis'
  final String severity;
  final List<String> advice;

  const UnifiedResponseScreen({
    super.key,
    required this.input,
    required this.language,
    required this.type,
    required this.severity,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    final isHindi = language == "Hindi" || language == "हिंदी";
    final isMarathi = language == "Marathi" || language == "मराठी";
    final isCrisis = type == 'crisis';
    
    final Color themeColor = isCrisis ? Colors.red : Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "प्रतिसाद" : (isHindi ? "प्रतिक्रिया" : "Unified Response")),
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
              isMarathi ? "तुमची माहिती:" : (isHindi ? "आपकी जानकारी:" : "Your Input:"),
              input,
              Icons.info_outline,
            ),
            const SizedBox(height: 20),
            _buildSeverityBox(severity, themeColor, isHindi, isMarathi),
            const SizedBox(height: 20),
            if (advice.isNotEmpty)
              _buildAdviceCard(
                isMarathi ? "सल्ला / पावले:" : (isHindi ? "सलाह / कदम:" : "Advice / Steps:"),
                advice,
                themeColor,
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              child: Text(isMarathi ? "बंद करा" : (isHindi ? "बंद करें" : "Close")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBox(String severity, Color color, bool isHindi, bool isMarathi) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            isMarathi ? "गंभीरता स्तर" : (isHindi ? "गंभीरता स्तर" : "Severity Level"),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            severity,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(String title, List<String> advice, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 12),
            ...advice.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(step, style: const TextStyle(fontSize: 15))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
