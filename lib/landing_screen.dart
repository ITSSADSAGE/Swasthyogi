import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'unified_dashboard.dart';
import 'theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, this.language = "en-IN"});
  final String language;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  bool _googleLoading = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogle() async {
    setState(() => _googleLoading = true);
    final result = await _authService.signInWithGoogle();
    setState(() => _googleLoading = false);
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => UnifiedDashboard(language: widget.language)),
      );
    } else if (result.errorCode != 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google sign-in failed. Please try again.",
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0D2B1F),
                        const Color(0xFF0A1A12),
                      ]
                    : [
                        const Color(0xFFE8F5E9),
                        const Color(0xFFF1F8E9),
                      ],
              ),
            ),
          ),

          // ── Decorative circle top-right ──────────────────────────────
          Positioned(
            top: -size.width * 0.25,
            right: -size.width * 0.25,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.08),
              ),
            ),
          ),

          // ── Decorative circle bottom-left ────────────────────────────
          Positioned(
            bottom: -size.width * 0.2,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.06),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Logo
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 56,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // App name
                      Text(
                        "Swasthyogi",
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1B4332),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                        "Unified Triage & Crisis Management\nfor everyday health and emergencies.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          height: 1.5,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Feature pills
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _pill("🩺  Symptom Triage", isDark),
                          _pill("🚨  Crisis SOS", isDark),
                          _pill("📶  Works Offline", isDark),
                          _pill("🤖  AI Assistant", isDark),
                        ],
                      ),

                      const Spacer(flex: 3),

                      // ── CTAs ────────────────────────────────────────
                      // Create Account (primary)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    SignupScreen(language: widget.language)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            "Create Account",
                            style: GoogleFonts.outfit(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Sign In (secondary)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    LoginScreen(language: widget.language)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppTheme.primaryGreen, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Google (tertiary)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _googleLoading ? null : _handleGoogle,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _googleLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryGreen),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.g_mobiledata,
                                        size: 28, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Continue with Google",
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        "By continuing you agree to our Terms & Privacy Policy",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : AppTheme.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : AppTheme.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : const Color(0xFF1B4332),
        ),
      ),
    );
  }
}
