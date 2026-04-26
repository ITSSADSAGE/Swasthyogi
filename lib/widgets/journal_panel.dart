import 'package:flutter/material.dart';
import '../theme.dart';
import '../journal_manager.dart';
import '../journal_screen.dart';

class JournalPanel extends StatelessWidget {
  final List<JournalEntry> recentEntries;
  final String language;
  final VoidCallback onRefresh;

  const JournalPanel({
    super.key,
    required this.recentEntries,
    required this.language,
    required this.onRefresh,
  });

  bool get isHindi => language == "हिंदी" || language == "Hindi";
  bool get isMarathi => language == "मराठी" || language == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.book_outlined, color: AppTheme.medicalBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  isMarathi ? "दैनिक नोंद" : (isHindi ? "जर्नल" : "Recent Reflections"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => JournalScreen(language: language))
              ).then((_) => onRefresh()),
              child: Text(
                isMarathi ? "सर्व पहा >" : (isHindi ? "सभी देखें >" : "View All >"), 
                style: const TextStyle(color: AppTheme.medicalBlue)
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentEntries.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
            ),
            child: Center(
              child: Text(
                isMarathi ? "कोणतीही नोंद नाही" : (isHindi ? "कोई प्रविष्टि नहीं" : "No recent notes. How are you feeling?"),
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            ),
          )
        else
          ...recentEntries.map((entry) {
            final isHealth = entry.type == 'health';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (isHealth ? Colors.teal : Colors.red).withOpacity(0.1)),
                boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)] : null,
              ),
              child: Row(
                children: [
                  Icon(isHealth ? Icons.health_and_safety : Icons.warning_amber_rounded, 
                       color: isHealth ? Colors.teal : Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.content, maxLines: 1, overflow: TextOverflow.ellipsis, 
                             style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          isHealth 
                            ? (isMarathi ? "आरोग्य नोंद" : "Health Log") 
                            : (isMarathi ? "घटना नोंद" : "Incident Log"),
                          style: TextStyle(fontSize: 11, color: isHealth ? Colors.teal : Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    entry.timestamp.substring(11, 16),
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
