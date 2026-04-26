import 'package:flutter/material.dart';
import 'journal_manager.dart';
import 'package:intl/intl.dart';

class JournalScreen extends StatefulWidget {
  final String language;
  const JournalScreen({super.key, required this.language});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> entries = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  String selectedType = 'health';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final data = await JournalManager.getEntries();
    setState(() {
      entries = data.reversed.toList();
      isLoading = false;
    });
  }

  bool get isHindi => widget.language == "हिंदी" || widget.language == "Hindi";
  bool get isMarathi => widget.language == "मराठी" || widget.language == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "दैनिक नोंद" : (isHindi ? "जर्नल" : "Private Journal")),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildInputSection(theme, isDark),
          const Divider(height: 1),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: theme.textTheme.bodySmall?.color?.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              isMarathi ? "कोणतीही नोंद नाही" : (isHindi ? "कोई प्रविष्टि नहीं" : "Your journal is empty"),
                              style: TextStyle(color: theme.textTheme.bodySmall?.color),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final date = DateTime.parse(entry.timestamp);
                          final isHealth = entry.type == 'health';
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                              boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)] : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isHealth ? Colors.teal : Colors.red).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isHealth ? Icons.health_and_safety : Icons.warning_amber_rounded,
                                  color: isHealth ? Colors.teal : Colors.red,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                entry.content,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, size: 12, color: theme.textTheme.bodySmall?.color),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd MMM, hh:mm a').format(date),
                                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isHealth ? Colors.teal : Colors.red).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isHealth ? (isMarathi ? "आरोग्य" : "HEALTH") : (isMarathi ? "घटना" : "INCIDENT"),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isHealth ? Colors.teal : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: isDark ? Colors.transparent : Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _typeChip('health', isMarathi ? "आरोग्य" : (isHindi ? "स्वास्थ्य" : "Health Log")),
              const SizedBox(width: 12),
              _typeChip('incident', isMarathi ? "घटना" : (isHindi ? "घटना" : "Incident Log")),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: isMarathi ? "आजचा अनुभव लिहा..." : (isHindi ? "आज का अनुभव लिखें..." : "Reflect on today..."),
              hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.teal),
                  onPressed: () async {
                    if (_controller.text.trim().isNotEmpty) {
                      await JournalManager.saveEntry(_controller.text, selectedType);
                      _controller.clear();
                      FocusScope.of(context).unfocus();
                      _loadEntries();
                    }
                  },
                ),
              ),
            ),
            maxLines: 3,
            minLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type, String label) {
    bool isSelected = selectedType == type;
    Color color = type == 'health' ? Colors.teal : Colors.red;
    
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
