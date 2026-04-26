import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'theme.dart';
import 'personalization_flow.dart';
import 'unified_dashboard.dart';
import 'login_screen.dart';
import 'profile_manager.dart';

class SignupScreen extends StatefulWidget {
  final String language;
  const SignupScreen({super.key, this.language = "en-IN"});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  // Optional stay details
  final _stayLocationController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _receptionContactController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _showStayDetails = false;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.language;
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    bool hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasLetter && hasDigit && hasSpecial;
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    if (!_isPasswordValid(password)) {
      _showError(
          "Password must be at least 8 characters and include letters, numbers, and symbols.");
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.signUpWithEmail(email, password, name);
    
    if (result.isSuccess) {
      // Save profile details
      await ProfileManager.saveProfile(UserProfile(
        name: name,
        email: email,
        phone: _phoneController.text.trim(),
        dob: _dobController.text.trim(),
        stayLocation: _stayLocationController.text.trim(),
        roomNumber: _roomNumberController.text.trim(),
        receptionContact: _receptionContactController.text.trim(),
      ));
    }
    
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PersonalizationFlow()));
      }
    } else {
      _handleAuthError(result.errorCode, email);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    final result = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (mounted) {
        // Google users skip personalization if they've signed in before;
        // for new users Flutter will land them on the dashboard (Firebase
        // handles de-duplication automatically).
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => PersonalizationFlow()),
        );
      }
    } else if (result.errorCode != 'cancelled') {
      _showError("Google sign-up failed. Please try again.");
    }
  }

  void _handleAuthError(String? code, String email) {
    switch (code) {
      case 'email-already-in-use':
        _showEmailExistsDialog(email);
        break;
      case 'weak-password':
        _showError("Password is too weak. Use at least 8 characters with letters, numbers & symbols.");
        break;
      case 'invalid-email':
        _showError("The email address is not valid.");
        break;
      default:
        _showError("Signup failed. Please try again.");
    }
  }

  void _showEmailExistsDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Account Already Exists",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          "An account with $email already exists.\nWould you like to sign in instead?",
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.medicalBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Pre-fill email on the login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => LoginScreen(language: widget.language)),
              );
            },
            child: Text("Go to Sign In",
                style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join Swasthyogi for a safer health journey",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel("Select Language"),
              Row(
                children: [
                  _languageChip("English", "en-IN"),
                  const SizedBox(width: 10),
                  _languageChip("हिंदी", "hi-IN"),
                  const SizedBox(width: 10),
                  _languageChip("मराठी", "mr-IN"),
                ],
              ),

              const SizedBox(height: 30),

              _buildLabel("Full Name"),
              _buildTextField(
                  controller: _nameController,
                  hint: "John Doe",
                  icon: Icons.person_outline),
              const SizedBox(height: 20),

              _buildLabel("Phone Number"),
              _buildTextField(
                  controller: _phoneController,
                  hint: "+91 9876543210",
                  icon: Icons.phone_outlined,
                  isPhone: true),
              const SizedBox(height: 20),

              _buildLabel("Date of Birth (DD/MM/YYYY)"),
              _buildTextField(
                  controller: _dobController,
                  hint: "01/01/1990",
                  icon: Icons.calendar_today_outlined),
              const SizedBox(height: 20),

              _buildLabel("Email Address"),
              _buildTextField(
                  controller: _emailController,
                  hint: "john@example.com",
                  icon: Icons.email_outlined),
              const SizedBox(height: 20),

              _buildLabel("Password"),
              _buildTextField(
                controller: _passwordController,
                hint: "Min 8 chars, mix of A-z, 0-9, & symbols",
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: !_isPasswordVisible,
                toggleVisibility: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),

              const SizedBox(height: 30),

              // Optional Stay Details Section
              GestureDetector(
                onTap: () => setState(() => _showStayDetails = !_showStayDetails),
                child: Row(
                  children: [
                    Icon(
                      _showStayDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppTheme.medicalBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Stay Details (Optional - Hotel/Dorm)",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.medicalBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_showStayDetails) ...[
                const SizedBox(height: 20),
                _buildLabel("Hotel/Dormitory Name"),
                _buildTextField(
                    controller: _stayLocationController,
                    hint: "e.g. Taj Hotel / Heritage Dorm",
                    icon: Icons.hotel_outlined),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Room Number"),
                          _buildTextField(
                              controller: _roomNumberController,
                              hint: "302",
                              icon: Icons.meeting_room_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Reception Number"),
                          _buildTextField(
                              controller: _receptionContactController,
                              hint: "022-XXXX",
                              icon: Icons.phone_callback_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 40),

              // Primary: Email sign-up
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.medicalBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Create Account",
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: isDark ? Colors.white10 : Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("OR",
                        style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 12)),
                  ),
                  Expanded(
                      child: Divider(
                          color: isDark ? Colors.white10 : Colors.black12)),
                ],
              ),

              const SizedBox(height: 24),

              // Google sign-up
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.g_mobiledata,
                          size: 30, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "Sign up with Google",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  "By signing up, you agree to our Terms and Conditions",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38),
                ),
              ),

              const SizedBox(height: 20),

              // Already have account
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  LoginScreen(language: widget.language))),
                      child: Text(
                        "Sign In",
                        style: GoogleFonts.outfit(
                            color: AppTheme.medicalBlue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageChip(String label, String code) {
    final isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.medicalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.medicalBlue : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      bool isPhone = false,
      bool obscureText = false,
      VoidCallback? toggleVisibility}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: AppTheme.medicalBlue),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 20),
                  onPressed: toggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
