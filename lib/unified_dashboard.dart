import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:provider/provider.dart';
import 'unified_report_screen.dart';
import 'unified_log_screen.dart';
import 'nearby_services_screen.dart';
import 'emergency_manager.dart';
import 'journal_screen.dart';
import 'breathing_screen.dart';
import 'analytics_screen.dart';
import 'vitals_screen.dart';
import 'medication_kit_screen.dart';
import 'self_care_screen.dart';
import 'ai_assistant_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'network_service.dart';
import 'journal_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'settings_screen.dart';

// Reusable Modules
import 'widgets/mode_indicator_banner.dart';
import 'hybrid_crisis_service.dart';
import 'widgets/journal_panel.dart';
import 'widgets/analytics_panel.dart';
import 'widgets/vitals_panel.dart';
import 'widgets/emergency_panel.dart';
import 'widgets/self_care_panel.dart';
import 'widgets/medication_kit_panel.dart';
import 'widgets/nearby_facilities_panel.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_manager.dart';

class UnifiedDashboard extends StatefulWidget {
  final String language;
  const UnifiedDashboard({super.key, required this.language});

  @override
  State<UnifiedDashboard> createState() => _UnifiedDashboardState();
}

class _UnifiedDashboardState extends State<UnifiedDashboard> {
  late String selectedLanguage;
  bool isEmergencyMode = true;
  List<JournalEntry> recentEntries = [];
  UserProfile? _userProfile;
  bool _isProfileLoading = true;

  // Wellness Stats (Reset to 0 for fresh accounts)
  double stressLevel = 0.0;
  double hydrationLevel = 0.0;
  double activityLevel = 0.0;
  int sleepHours = 0;
  int steps = 0;
  int bpm = 0;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.language;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email == 'demo@swasthyogi.app') {
      // Load Demo Data for presentation
      setState(() {
        stressLevel = 0.45;
        hydrationLevel = 0.5;
        activityLevel = 0.5;
        sleepHours = 7;
        steps = 6842;
        bpm = 74;
      });
    }
    
    await _loadProfile();
    _loadJournalPreview();
    _requestPermissions();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileManager.getProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    // Request all necessary permissions for the app to function properly
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.location,
      Permission.sms,
      Permission.phone,
    ].request();
    
    // Log statuses if needed
    statuses.forEach((permission, status) {
      print('$permission: $status');
    });
  }

  Future<void> _loadJournalPreview() async {
    final entries = await JournalManager.getEntries();
    if (mounted) {
      setState(() {
        recentEntries = entries.reversed.take(3).toList();
      });
    }
  }

  bool get isHindi => selectedLanguage == "हिंदी" || selectedLanguage == "Hindi";
  bool get isMarathi => selectedLanguage == "मराठी" || selectedLanguage == "Marathi";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      drawer: _buildSidebar(context),
      appBar: AppBar(
        title: const Text("Swasthyogi Dashboard"),
        actions: [
          StreamBuilder<NetworkSpeed>(
            stream: NetworkService.onSpeedChanged,
            initialData: NetworkSpeed.high,
            builder: (context, snapshot) {
              final isOffline = snapshot.data == NetworkSpeed.none;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isOffline ? Colors.red : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (isOffline ? Colors.red : Colors.green).withOpacity(0.5)),
                ),
                child: Center(
                  child: Text(
                    isOffline ? "OFFLINE" : "ONLINE",
                    style: TextStyle(
                      color: isOffline ? Colors.red : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 20),
                Text(
                  selectedLanguage.substring(0, 2).toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            onSelected: (String lang) {
              setState(() {
                selectedLanguage = lang;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'English', child: Text('English')),
              const PopupMenuItem<String>(value: 'Hindi', child: Text('हिंदी (Hindi)')),
              const PopupMenuItem<String>(value: 'Marathi', child: Text('मराठी (Marathi)')),
            ],
          ),
          const SizedBox(width: 4),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Alex+Johnson&background=random'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          ModeIndicatorBanner(isEmergencyMode: isEmergencyMode),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    if (isEmergencyMode) 
                      EmergencyPanel(isWide: isWide, language: selectedLanguage) 
                    else 
                      VitalsPanel(isWide: isWide, language: selectedLanguage),
                    const SizedBox(height: 24),
                    NearbyFacilitiesPanel(isEmergencyMode: isEmergencyMode, language: selectedLanguage),
                    const SizedBox(height: 24),
                    _buildRecommendations(context),
                    const SizedBox(height: 24),
                    _buildStatsRow(isWide),
                    const SizedBox(height: 24),
                    JournalPanel(
                      recentEntries: recentEntries, 
                      language: selectedLanguage, 
                      onRefresh: _loadJournalPreview
                    ),
                    const SizedBox(height: 24),
                    SelfCarePanel(language: selectedLanguage),
                    const SizedBox(height: 24),
                    AnalyticsPanel(language: selectedLanguage),
                    const SizedBox(height: 24),
                    MedicationKitPanel(isEmergencyMode: isEmergencyMode, language: selectedLanguage),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _triggerSOS(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.sos, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
            context,
            Icons.auto_awesome,
            isMarathi ? "एआय सहाय्यक" : (isHindi ? "एआई सहायक" : "AI Assistant"),
            Colors.orange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiAssistantScreen(language: selectedLanguage))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionCard(
            context,
            Icons.location_on,
            isMarathi ? "जवळपासच्या सुविधा" : (isHindi ? "नजदीकी सुविधाएं" : "Nearby Facilities"),
            Colors.blue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => NearbyServicesScreen(language: selectedLanguage))),
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = _userProfile?.name ?? "User";
    final goal = _userProfile?.mainGoal ?? "";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? "नमस्कार, $name" : (isHindi ? "नमस्ते, $name" : "Hello, $name"),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        if (goal.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              isMarathi ? "तुमचे ध्येय: $goal" : (isHindi ? "आपका लक्ष्य: $goal" : "Focusing on: $goal"),
              style: TextStyle(color: AppTheme.medicalBlue, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        Text(
          isMarathi ? "आज तुमचे आरोग्य कसे आहे?" : (isHindi ? "आज आपका स्वास्थ्य कैसा है?" : "How is your health today?"),
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: isDark ? AppTheme.bgDark : Colors.grey[100]),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: isEmergencyMode ? AppTheme.emergencyRed : AppTheme.medicalBlue, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.health_and_safety, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text("Swasthyogi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              ],
            ),
          ),
          // Mode Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Emergency Mode", style: TextStyle(fontWeight: FontWeight.bold, color: isEmergencyMode ? Colors.red : null)),
                Switch(
                  value: isEmergencyMode,
                  activeColor: Colors.red,
                  onChanged: (val) {
                    setState(() {
                      isEmergencyMode = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 4,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _sidebarItem(context, Icons.grid_view, "Dashboard", isSelected: true),
                    _sidebarItem(context, Icons.check_box_outlined, "Check-In", onTap: () {
                      Navigator.pop(context);
                      _showCheckInSheet();
                    }),
                    _sidebarItem(context, Icons.book_outlined, "Journal", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JournalScreen(language: selectedLanguage)))),
                    _sidebarItem(context, Icons.air, "Breathing", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BreathingScreen(language: selectedLanguage)))),
                    _sidebarItem(context, Icons.bar_chart, "Analytics", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(language: selectedLanguage)))),
                    _sidebarItem(context, Icons.favorite_border, "Vitals", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VitalsScreen(language: selectedLanguage)))),
                    _sidebarItem(context, Icons.medical_services_outlined, "Medications", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationKitScreen(language: selectedLanguage)))),
                    _sidebarItem(context, Icons.person_outline, "Self-Care", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SelfCareScreen(language: selectedLanguage)))),
                    _sidebarItem(context, Icons.auto_awesome, "AI Assistant", isAI: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiAssistantScreen(language: selectedLanguage)))),
                    _sidebarItem(context, Icons.location_on_outlined, "Nearby Facilities", isNew: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NearbyServicesScreen(language: selectedLanguage)))),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _sidebarItem(context, Icons.settings_outlined, "Settings", onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(language: selectedLanguage)));
          }),
          ListTile(
            onTap: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginScreen(language: "English")),
                  (route) => false,
                );
              }
            },
            leading: CircleAvatar(
              radius: 16, 
              backgroundImage: NetworkImage(
                FirebaseAuth.instance.currentUser?.photoURL ?? 
                'https://ui-avatars.com/api/?name=${FirebaseAuth.instance.currentUser?.displayName ?? "User"}'
              )
            ),
            title: Text(
              FirebaseAuth.instance.currentUser?.displayName ?? "Guest User", 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              FirebaseAuth.instance.currentUser?.email ?? "No email linked", 
              style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)
            ),
            trailing: const Icon(Icons.logout, size: 18),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sidebarItem(BuildContext context, IconData icon, String label, {bool isSelected = false, bool isAI = false, bool isNew = false, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected ? AppTheme.medicalBlue : (isDark ? Colors.white60 : Colors.black54);
    
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: isSelected ? (isDark ? Colors.white : Colors.black) : color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isAI 
          ? _badge("AI", Colors.orange)
          : (isNew ? _badge("New", Colors.blue) : null),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final theme = Theme.of(context);
    final goal = _userProfile?.mainGoal?.toLowerCase() ?? "";
    
    String rec1Title = "Improve your sleep routine";
    String rec1Sub = "Getting 7-8 hours of sleep helps recovery.";
    IconData rec1Icon = Icons.nightlight_round;
    Color rec1Color = Colors.purple;

    if (goal.contains("weight") || goal.contains("muscle")) {
      rec1Title = "Daily Protein Target";
      rec1Sub = "Based on your weight, aim for 60g+ protein today.";
      rec1Icon = Icons.fitness_center;
      rec1Color = Colors.orange;
    } else if (goal.contains("mental") || goal.contains("stress")) {
      rec1Title = "Mindful Minute";
      rec1Sub = "Take 60 seconds to breathe and ground yourself.";
      rec1Icon = Icons.spa;
      rec1Color = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.brightness == Brightness.light ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tailored for you", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("Update →", style: TextStyle(color: AppTheme.medicalBlue))),
            ],
          ),
          Text(isMarathi ? "तुमच्या प्रोफाइलवर आधारित" : (isHindi ? "आपके प्रोफाइल के आधार पर" : "Based on your personalization"), style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
          const SizedBox(height: 16),
          _recItem(context, rec1Icon, rec1Title, rec1Sub, "View Details", rec1Color),
          const SizedBox(height: 12),
          _recItem(context, Icons.water_drop, "Hydration Goal", "Drink at least 2.5L of water today.", "Set reminder", Colors.blue),
        ],
      ),
    );
  }

  Widget _recItem(BuildContext context, IconData icon, String title, String sub, String action, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
                const SizedBox(height: 4),
                Text("→ $action", style: TextStyle(color: AppTheme.medicalBlue, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMarathi ? "आजची स्थिती" : (isHindi ? "आज की स्थिति" : "Today's Stats"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _showCheckInSheet(),
              child: Text(isMarathi ? "अपडेट करा" : (isHindi ? "अपडेट करें" : "Update All"), style: const TextStyle(color: AppTheme.medicalBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statBox(context, "Mood", "Good", Icons.sentiment_satisfied, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _statBox(context, "Sleep", "${sleepHours}h", Icons.nightlight_round, Colors.purple, sub: "Good rest")),
            const SizedBox(width: 12),
            Expanded(child: _statBox(context, "Water", "${(hydrationLevel * 8).toInt()} glasses", Icons.water_drop, Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statBox(context, "Stress", "${(stressLevel * 100).toInt()}%", Icons.psychology, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _statBox(context, "Activity", "${(activityLevel * 100).toInt()}%", Icons.bolt, Colors.amber)),
            const SizedBox(width: 12),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  void _showCheckInSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMarathi ? "दैनिक तपासणी" : (isHindi ? "दैनिक चेक-इन" : "Daily Check-In"),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildSheetSlider(isMarathi ? "ताण" : (isHindi ? "तनाव" : "Stress Level"), stressLevel, (v) {
                    setSheetState(() => stressLevel = v);
                    setState(() {});
                  }),
                  _buildSheetSlider(isMarathi ? "झोप (तास)" : (isHindi ? "नींद (घंटे)" : "Sleep Hours"), sleepHours / 12, (v) {
                    setSheetState(() => sleepHours = (v * 12).toInt());
                    setState(() {});
                  }, labelOverride: "${sleepHours}h"),
                  _buildSheetSlider(isMarathi ? "पाणी" : (isHindi ? "पानी" : "Hydration"), hydrationLevel, (v) {
                    setSheetState(() => hydrationLevel = v);
                    setState(() {});
                  }),
                  _buildSheetSlider(isMarathi ? "हालचाल" : (isHindi ? "गतिविधि" : "Activity"), activityLevel, (v) {
                    setSheetState(() => activityLevel = v);
                    setState(() {});
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.medicalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isMarathi ? "पूर्ण झाले" : (isHindi ? "हो गया" : "Done")),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildSheetSlider(String label, double value, ValueChanged<double> onChanged, {String? labelOverride}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(labelOverride ?? "${(value * 100).toInt()}%", style: const TextStyle(color: AppTheme.medicalBlue, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value, 
          onChanged: onChanged,
          activeColor: AppTheme.medicalBlue,
          inactiveColor: AppTheme.medicalBlue.withOpacity(0.1),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _statBox(BuildContext context, String title, String value, IconData icon, Color color, {String? sub}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
          if (sub != null) Text(sub, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _triggerSOS() async {
    bool cancelled = false;
    
    // Show countdown dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        int countdown = 5;
        bool timerStarted = false;
        
        return StatefulBuilder(
          builder: (context, setState) {
            // Start countdown only once
            if (!timerStarted) {
              timerStarted = true;
              Future.microtask(() async {
                for (int i = 5; i > 0; i--) {
                  if (cancelled) return;
                  if (context.mounted) setState(() => countdown = i);
                  await Future.delayed(const Duration(seconds: 1));
                }
                if (!cancelled && context.mounted) {
                  Navigator.of(dialogContext).pop(true); // Proceed with SOS
                }
              });
            }

            return AlertDialog(
              backgroundColor: Colors.red[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                  SizedBox(width: 10),
                  Text("Emergency SOS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isMarathi ? "अलर्ट पाठविला जात आहे..." : (isHindi ? "अलर्ट भेजा जा रहा है..." : "Sending alert in..."),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "$countdown",
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      cancelled = true;
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: Text(
                      isMarathi ? "रद्द करा" : (isHindi ? "रद्द करें" : "CANCEL SOS"),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((proceed) async {
      if (proceed == true) {
        final crisisService = HybridCrisisService();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMarathi ? "आपत्कालीन अलर्ट पाठविला गेला!" : (isHindi ? "आपातकालीन अलर्ट भेज दिया गया!" : "Emergency SOS Alert Sent!"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Execute Backend SOS (SMS + Staff Alerts)
        await crisisService.executeSOS(selectedLanguage);
      }
    });
  }
}
