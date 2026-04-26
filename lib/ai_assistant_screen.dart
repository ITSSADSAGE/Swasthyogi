import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'theme.dart';

class AiAssistantScreen extends StatefulWidget {
  final String language;
  const AiAssistantScreen({super.key, required this.language});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hello! I am your Swasthyogi AI Assistant. How can I help you with your health or safety today?");
  }

  void _addBotMessage(String text) {
    setState(() {
      messages.add({'role': 'bot', 'content': text});
    });
  }

  void _handleSend() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userMsg = _controller.text;
    setState(() {
      messages.add({'role': 'user', 'content': userMsg});
      isTyping = true;
    });
    _controller.clear();

    try {
      final response = await _aiService.analyzeSymptoms(userMsg, widget.language);
      if (mounted) {
        setState(() {
          messages.add({'role': 'bot', 'content': response});
          isTyping = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          messages.add({'role': 'bot', 'content': "I'm sorry, I encountered an error. Please try again or check your connection."});
          isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _aiService.isOnline ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _aiService.isOnline ? "Connected to Gemini AI" : "Offline Assistant Mode",
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isBot = msg['role'] == 'bot';
                return _buildChatBubble(msg['content']!, isBot, isDark);
              },
            ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          _buildInputArea(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isBot, bool isDark) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isBot 
              ? (isDark ? AppTheme.surfaceDark : Colors.grey[100])
              : AppTheme.medicalBlue,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 0 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 0),
          ),
          border: isBot ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? (isDark ? Colors.white : Colors.black87) : Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark : Colors.white,
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask me anything...",
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppTheme.medicalBlue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}
