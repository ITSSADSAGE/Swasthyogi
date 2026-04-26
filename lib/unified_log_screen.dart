import 'package:flutter/material.dart';
import 'unified_log_manager.dart';

class UnifiedLogScreen extends StatefulWidget {
  final String language;
  const UnifiedLogScreen({super.key, required this.language});

  @override
  State<UnifiedLogScreen> createState() => _UnifiedLogScreenState();
}

class _UnifiedLogScreenState extends State<UnifiedLogScreen> {
  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final data = await UnifiedLogManager.getHistory();
    if (mounted) {
      setState(() {
        logs = data.reversed.toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = widget.language == "Hindi" || widget.language == "हिंदी";
    final isMarathi = widget.language == "Marathi" || widget.language == "मराठी";

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "एकत्रित नोंदी" : (isHindi ? "यूनिफाइड लॉग" : "Unified Activity Log")),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? Center(child: Text(isMarathi ? "नोंदी आढळल्या नाहीत" : (isHindi ? "कोई लॉग नहीं मिला" : "No logs found")))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final isCrisis = log['type'] == 'crisis';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCrisis ? Colors.red[100] : Colors.blue[100],
                          child: Icon(
                            isCrisis ? Icons.warning : Icons.health_and_safety,
                            color: isCrisis ? Colors.red : Colors.blue,
                          ),
                        ),
                        title: Text(log['input'] ?? ""),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${log['date']} | Severity: ${log['severity']}"),
                            if (isCrisis)
                              const Text("Action: Emergency SOS Sent", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
