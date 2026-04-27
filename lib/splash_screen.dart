import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'unified_dashboard.dart';
import 'unified_onboarding_screen.dart';
import 'landing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personalization_flow.dart';
import 'profile_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = "";

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Fetch version info
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = "Version ${info.version}";
      });
    } catch (e) {
      print("Error fetching version: $e");
    }

    // 2. Wait for 2 seconds (splash delay)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Check if onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    // 4. Check Authentication
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    bool isProfileComplete = await ProfileManager.isProfileComplete();

    if (user != null) {
      try {
        await user.reload();
        user = auth.currentUser;
      } catch (e) {
        await auth.signOut();
        user = null;
      }
    }

    // 5. Navigate to appropriate screen
    if (mounted) {
      if (!onboardingCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UnifiedOnboardingScreen()),
        );
      } else if (user != null) {
        if (!isProfileComplete) {
          // If logged in but questions not finished, force flow
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PersonalizationFlow()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UnifiedDashboard(language: "English")),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen(language: "English")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A1A12) : Colors.white;
    final primaryColor = Theme.of(context).primaryColor;
    final subtitleColor = isDark ? Colors.white60 : Colors.grey[600];
    final versionColor = isDark ? Colors.white54 : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
             ClipRRect(
              borderRadius: BorderRadius.circular(24.0), // Rounded corners
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                   return Icon(Icons.favorite, size: 100, color: primaryColor);
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
             Text(
              "Swasthyogi",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Unified Triage & Crisis Management",
               style: TextStyle(
                fontSize: 16,
                color: subtitleColor,
              ),
            ),

            const SizedBox(height: 48),

            // Loading Indicator
            CircularProgressIndicator(
              color: primaryColor,
            ),

            const SizedBox(height: 24),

            // Version
            Text(
              _version,
              style: TextStyle(
                fontSize: 14,
                color: versionColor,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }
}
