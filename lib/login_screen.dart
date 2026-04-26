import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'unified_dashboard.dart';
import 'signup_screen.dart';
import 'personalization_flow.dart';
import 'theme.dart';

class LoginScreen extends StatefulWidget {
  final String language;
  const LoginScreen({super.key, this.language = "en-IN"});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _navigateToDashboard();
    } else {
      switch (result.errorCode) {
        case 'user-not-found':
          _showError("No account found with this email.");
          break;
        case 'wrong-password':
        case 'invalid-credential':
          _showError("Incorrect password. Please try again.");
          break;
        case 'user-disabled':
          _showError("This account has been disabled.");
          break;
        default:
          _showError("Login failed. Please check your credentials.");
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final result = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (result.isNewUser) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => PersonalizationFlow())
        );
      } else {
        _navigateToDashboard();
      }
    } else if (result.errorCode != 'cancelled') {
      _showError("Google sign-in failed. Please try again.");
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => UnifiedDashboard(language: widget.language))
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.medicalBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.medical_services_outlined, size: 60, color: AppTheme.medicalBlue),
                ),
              ),
              const SizedBox(height: 40),
              
              Text(
                "Welcome Back",
                style: GoogleFonts.outfit(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to access Swasthyogi",
                style: GoogleFonts.outfit(
                  fontSize: 16, 
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              _buildLabel("Email Address"),
              _buildTextField(
                controller: _emailController,
                hint: "alex@example.com",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),

              _buildLabel("Password"),
              _buildTextField(
                controller: _passwordController,
                hint: "••••••••",
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: !_isPasswordVisible,
                toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.outfit(color: AppTheme.medicalBlue, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.medicalBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Sign In", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("OR", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.g_mobiledata, size: 30, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "Continue with Google", 
                        style: GoogleFonts.outfit(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        )
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.outfit(color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => SignupScreen(language: widget.language))
                      ),
                      child: Text(
                        "Create Account",
                        style: GoogleFonts.outfit(color: AppTheme.medicalBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14, 
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.outfit(),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: AppTheme.medicalBlue),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, size: 20),
                onPressed: toggleVisibility,
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
