import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'landing_screen.dart';

class UnifiedOnboardingScreen extends StatefulWidget {
  const UnifiedOnboardingScreen({super.key});

  @override
  State<UnifiedOnboardingScreen> createState() => _UnifiedOnboardingScreenState();
}

class _UnifiedOnboardingScreenState extends State<UnifiedOnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to Swasthyogi",
      "desc": "Your unified companion for health triage and crisis management.",
      "icon": "🏥",
    },
    {
      "title": "Medical Health Checks",
      "desc": "Speak about your symptoms. We provide remedies and guide you to nearby clinics.",
      "icon": "🩺",
    },
    {
      "title": "Crisis Emergency Support",
      "desc": "Report fire, accidents, or theft. We trigger SOS and find nearest emergency responders.",
      "icon": "🚨",
    },
    {
      "title": "Offline Reliability",
      "desc": "Works even without internet using built-in risk engines and SMS fallback.",
      "icon": "📶",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_pages[i]['icon']!, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 40),
                      Text(
                        _pages[i]['title']!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _pages[i]['desc']!,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('onboarding_completed', true);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LandingScreen()),
                      );
                    }
                  },
                  child: const Text("SKIP"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentPage == _pages.length - 1) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', true);
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LandingScreen()),
                        );
                      }
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? "FINISH" : "NEXT"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
