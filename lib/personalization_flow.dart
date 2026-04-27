import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'unified_dashboard.dart';
import 'profile_manager.dart';
import 'auth_service.dart';

class PersonalizationFlow extends StatefulWidget {
  final bool isGoogleUser;
  const PersonalizationFlow({super.key, this.isGoogleUser = false});

  @override
  State<PersonalizationFlow> createState() => _PersonalizationFlowState();
}

class _PersonalizationFlowState extends State<PersonalizationFlow> {
  int _currentStep = 1;
  late int _totalSteps;
  late bool _isGoogleUser;

  @override
  void initState() {
    super.initState();
    _isGoogleUser = widget.isGoogleUser;
    _totalSteps = _isGoogleUser ? 6 : 5;
  }

  // Data State
  String _selectedGender = "Male";
  final _ageController = TextEditingController(text: "25");
  final _heightController = TextEditingController(text: "170");
  final _weightController = TextEditingController(text: "70");

  String _activityLevel = "Lightly active";
  final _workHoursController = TextEditingController(text: "8");
  final _sleepHoursController = TextEditingController(text: "7");
  final _waterIntakeController = TextEditingController(text: "2");

  double _stressLevel = 3.0;
  double _moodLevel = 3.0;
  String _dietPreference = "Omnivore";

  String _mainGoal = "General health";
  
  // Hospitality Sync Data
  final _roomController = TextEditingController(text: "504");
  final _wingController = TextEditingController(text: "East Wing, 5th Floor");
  final _securityPasswordController = TextEditingController();
  bool _obscurePassword = true;

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeSetup() async {
    // Save the collected personalization data
    final profile = await ProfileManager.getProfile();
    profile.gender = _selectedGender;
    profile.dob = _ageController.text;
    profile.height = _heightController.text;
    profile.weight = _weightController.text;
    profile.activityLevel = _activityLevel;
    profile.sleepHours = _sleepHoursController.text;
    profile.waterIntake = _waterIntakeController.text;
    profile.stressLevel = _stressLevel.toString();
    profile.moodLevel = _moodLevel.toString();
    profile.dietPreference = _dietPreference;
    profile.mainGoal = _mainGoal;
    profile.roomNumber = _roomController.text;
    profile.stayLocation = _wingController.text;
    
    await ProfileManager.saveProfile(profile);
    await ProfileManager.setOnboardingComplete(true);

    // Save security password for Google users
    if (_securityPasswordController.text.isNotEmpty) {
      final auth = AuthService();
      await auth.saveSecureData('security_password', _securityPasswordController.text);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const UnifiedDashboard(language: "English"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 24),
              _buildNavigationButtons(),
              const SizedBox(height: 12),
              // Only allow skipping if we are NOT on the mandatory security step and NOT on the last step
              if (!(_isGoogleUser && _currentStep == 1) && _currentStep < _totalSteps)
                TextButton(
                  onPressed: _nextStep, 
                  child: Text("Skip this step", style: GoogleFonts.outfit(color: Colors.grey))
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.medicalBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Let's personalise Swasthyogi", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Step $_currentStep of $_totalSteps", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _currentStep / _totalSteps,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.medicalBlue),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_isGoogleUser) {
      switch (_currentStep) {
        case 1: return _buildSecurityStep();
        case 2: return _buildStep1();
        case 3: return _buildStep2();
        case 4: return _buildStep3();
        case 5: return _buildStep4();
        case 6: return _buildStep5();
        default: return const SizedBox();
      }
    } else {
      switch (_currentStep) {
        case 1: return _buildStep1();
        case 2: return _buildStep2();
        case 3: return _buildStep3();
        case 4: return _buildStep4();
        case 5: return _buildStep5();
        default: return const SizedBox();
      }
    }
  }

  Widget _buildSecurityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle("Security Setup"),
        const SizedBox(height: 8),
        Text(
          "Since you logged in with Google, please set a secondary security password. This will be used to verify sensitive actions like deleting your profile.",
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceDark : Colors.grey[50],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.medicalBlue.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _securityPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Security Password",
                  hintText: "Min 6 characters",
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.medicalBlue),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle("Tell us about yourself"),
        const SizedBox(height: 20),
        _sectionLabel("Gender"),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _choiceChip("Male", Icons.male, _selectedGender == "Male", (s) => setState(() => _selectedGender = s)),
            _choiceChip("Female", Icons.female, _selectedGender == "Female", (s) => setState(() => _selectedGender = s)),
            _choiceChip("Non-binary", Icons.transgender, _selectedGender == "Non-binary", (s) => setState(() => _selectedGender = s)),
            _choiceChip("Prefer not to say", Icons.remove, _selectedGender == "Prefer not to say", (s) => setState(() => _selectedGender = s)),
          ],
        ),
        const SizedBox(height: 24),
        _inputField("Age", _ageController, "years"),
        const SizedBox(height: 16),
        _inputField("Height", _heightController, "cm"),
        const SizedBox(height: 16),
        _inputField("Weight", _weightController, "kg"),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle("Your lifestyle"),
        const SizedBox(height: 20),
        _sectionLabel("Activity level"),
        _activityOption("Sedentary", "Desk job, little movement"),
        _activityOption("Lightly active", "1-3 light workouts / week"),
        _activityOption("Moderately active", "3-5 moderate workouts / week"),
        _activityOption("Very active", "6-7 intense workouts / week"),
        _activityOption("Extra active", "Athlete / very physical job"),
        const SizedBox(height: 24),
        _inputField("Work / study hours per day", _workHoursController, "hrs"),
        const SizedBox(height: 16),
        _inputField("Average sleep hours", _sleepHoursController, "hrs"),
        const SizedBox(height: 16),
        _inputField("Water intake", _waterIntakeController, "L / day"),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle("Wellness baseline"),
        const SizedBox(height: 20),
        _sectionLabel("Typical stress level — ${_stressLevel.toInt()}/5"),
        _customSlider(_stressLevel, (v) => setState(() => _stressLevel = v), "Very calm", "Very stressed"),
        const SizedBox(height: 24),
        _sectionLabel("Typical mood — ${_moodLevel.toInt()}/5"),
        _customSlider(_moodLevel, (v) => setState(() => _moodLevel = v), "Low", "Great"),
        const SizedBox(height: 24),
        _sectionLabel("Diet preference"),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _dietChip("Omnivore", Icons.restaurant),
            _dietChip("Vegetarian", Icons.eco),
            _dietChip("Vegan", Icons.grass),
            _dietChip("Pescatarian", Icons.set_meal),
            _dietChip("Keto", Icons.egg),
            _dietChip("Paleo", Icons.hardware),
            _dietChip("Gluten-free", Icons.no_meals),
            _dietChip("Other", Icons.more_horiz),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle("What's your main goal?"),
        Text("Swasthyogi will personalise your recommendations around this.", style: GoogleFonts.outfit(color: Colors.grey)),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _goalCard("Reduce stress", "🧘"),
            _goalCard("Improve sleep", "😴"),
            _goalCard("Improve fitness", "💪"),
            _goalCard("Mental wellness", "🧠"),
            _goalCard("Better nutrition", "🥗"),
            _goalCard("Lose weight", "⚖️"),
            _goalCard("Gain muscle", "🏋️"),
            _goalCard("General health", "💗"),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle("Venue Check-In"),
        Text("Link your stay to the hotel's rapid response hub.", style: GoogleFonts.outfit(color: Colors.grey)),
        const SizedBox(height: 24),
        _inputField("Current Room Number", _roomController, "Room"),
        const SizedBox(height: 20),
        _inputField("Wing / Floor", _wingController, "Location"),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.sync, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "This data is synchronized instantly with hotel security and medical staff for emergency coordination.",
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold));
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _choiceChip(String label, IconData icon, bool isSelected, Function(String) onSelect) {
    return InkWell(
      onTap: () => onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.medicalBlue : Colors.grey.withOpacity(0.3)),
          color: isSelected ? AppTheme.medicalBlue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.medicalBlue : Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(color: isSelected ? AppTheme.medicalBlue : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, String suffix) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              Text(suffix, style: GoogleFonts.outfit(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityOption(String title, String subtitle) {
    bool isSelected = _activityLevel == title;
    return InkWell(
      onTap: () => setState(() => _activityLevel = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.medicalBlue : Colors.grey.withOpacity(0.2)),
          color: isSelected ? AppTheme.medicalBlue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.medicalBlue : null)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _customSlider(double value, Function(double) onChanged, String minLabel, String maxLabel) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.medicalBlue,
            thumbColor: AppTheme.medicalBlue,
            overlayColor: AppTheme.medicalBlue.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            Text(maxLabel, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _dietChip(String label, IconData icon) {
    bool isSelected = _dietPreference == label;
    return InkWell(
      onTap: () => setState(() => _dietPreference = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppTheme.medicalBlue : Colors.grey.withOpacity(0.2)),
          color: isSelected ? AppTheme.medicalBlue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppTheme.medicalBlue : Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 13, color: isSelected ? AppTheme.medicalBlue : null)),
          ],
        ),
      ),
    );
  }

  Widget _goalCard(String label, String emoji) {
    bool isSelected = _mainGoal == label;
    return InkWell(
      onTap: () => setState(() => _mainGoal = label),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.medicalBlue : Colors.grey.withOpacity(0.2)),
          color: isSelected ? AppTheme.medicalBlue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.medicalBlue : null)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _prevStep,
                child: Text("Back", style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
              ),
            ),
          ),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Validate security password if on step 1 for Google users
                if (_isGoogleUser && _currentStep == 1) {
                  if (_securityPasswordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password must be at least 6 characters"), backgroundColor: Colors.orange)
                    );
                    return;
                  }
                }
                _nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.medicalBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _currentStep == _totalSteps ? "Complete setup" : "Continue",
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
