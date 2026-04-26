import 'package:flutter/material.dart';
import 'theme.dart';
import 'emergency_manager.dart';
import 'profile_manager.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  final String language;
  const SettingsScreen({super.key, required this.language});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _contactController = TextEditingController();
  List<String> _emergencyContacts = [];
  bool _isLoading = true;
  UserProfile _userProfile = UserProfile();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final contacts = await EmergencyManager.getContacts(category: 'personal');
    final profile = await ProfileManager.getProfile();
    
    // Fallback to Firebase Auth if local profile is empty (for existing users)
    final authService = AuthService();
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      if (profile.name.isEmpty && currentUser.displayName != null) {
        profile.name = currentUser.displayName!;
      }
      if (profile.email.isEmpty && currentUser.email != null) {
        profile.email = currentUser.email!;
      }
    }

    setState(() {
      _emergencyContacts = contacts;
      _userProfile = profile;
      _isLoading = false;
    });
  }

  // --- Profile Management ---
  Future<void> _editProfile() async {
    final nameCtrl = TextEditingController(text: _userProfile.name);
    final phoneCtrl = TextEditingController(text: _userProfile.phone);
    final emailCtrl = TextEditingController(text: _userProfile.email);
    final dobCtrl = TextEditingController(text: _userProfile.dob);
    final heightCtrl = TextEditingController(text: _userProfile.height);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number")),
              TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: "Date of Birth")),
              TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: "Height")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              _userProfile.name = nameCtrl.text;
              _userProfile.email = emailCtrl.text;
              _userProfile.phone = phoneCtrl.text;
              _userProfile.dob = dobCtrl.text;
              _userProfile.height = heightCtrl.text;
              await ProfileManager.saveProfile(_userProfile);
              setState(() {});
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- Emergency Contacts ---
  Future<void> _addContact() async {
    final number = _contactController.text.trim();
    if (number.isNotEmpty && number.length >= 10) {
      _emergencyContacts.add(number);
      await EmergencyManager.saveContacts(_emergencyContacts, category: 'personal');
      _contactController.clear();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact added!')));
      }
    }
  }

  Future<void> _removeContact(int index) async {
    _emergencyContacts.removeAt(index);
    await EmergencyManager.saveContacts(_emergencyContacts, category: 'personal');
    setState(() {});
  }

  Future<bool> _verifyPassword() async {
    final passwordController = TextEditingController();
    final user = AuthService().currentUser;
    final isGoogleUser = user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGoogleUser ? "Enter Security Password" : "Enter Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isGoogleUser 
              ? "Please enter the secondary security password you set during setup." 
              : "This is a sensitive action. Please enter your password to confirm."),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final authService = AuthService();
              if (isGoogleUser) {
                final savedPassword = await authService.readSecureData('security_password');
                if (savedPassword == passwordController.text) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect security password")));
                }
              } else {
                final email = authService.currentUser?.email;
                if (email != null) {
                  final result = await authService.loginWithEmail(email, passwordController.text);
                  if (result.isSuccess) {
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect password")));
                  }
                }
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    ) ?? false;
  }

  // --- Account Deletion ---
  Future<void> _deleteAccountHistory({bool skipVerify = false}) async {
    if (!skipVerify && !await _verifyPassword()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History?"),
        content: const Text("Are you absolutely sure? This will delete all your local health data and logs permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Clear Data"),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    // Clear local app data but keep the user logged in
    await ProfileManager.clearProfile();
    await EmergencyManager.saveContacts([], category: 'personal');
    setState(() {
      _userProfile = UserProfile();
      _emergencyContacts.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account History Cleared.')));
    }
  }

  Future<void> _deleteAccountPermanently() async {
    if (!await _verifyPassword()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account Permanently?"),
        content: const Text("WARNING: This will delete your account and all data from our servers. This action cannot be undone. Are you really sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Actually delete from Firebase so the email is freed up
      try {
        final authService = AuthService();
        await authService.currentUser?.delete();
        await _deleteAccountHistory(skipVerify: true); // clear local storage
        await authService.logout();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (_) => const LoginScreen(language: "English")),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account. Please re-login and try again.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'mr-IN' ? "सेटिंग्ज" : (widget.language == 'hi-IN' ? "सेटिंग्स" : "Settings")),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Section
              _buildSectionHeader("Profile Details", Icons.person, theme),
              Card(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileRow("Name", _userProfile.name.isEmpty ? "Not set" : _userProfile.name),
                      _profileRow("Email", _userProfile.email.isEmpty ? "Not set" : _userProfile.email),
                      _profileRow("Phone", _userProfile.phone.isEmpty ? "Not set" : _userProfile.phone),
                      _profileRow("DOB", _userProfile.dob.isEmpty ? "Not set" : _userProfile.dob),
                      _profileRow("Height", _userProfile.height.isEmpty ? "Not set" : _userProfile.height),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit Profile"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Contacts Section
              _buildSectionHeader("Emergency Contacts (SOS)", Icons.sos, theme, color: Colors.red),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter Phone Number",
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_emergencyContacts.isEmpty)
                const Padding(padding: EdgeInsets.all(8), child: Text("No contacts added yet."))
              else
                ..._emergencyContacts.asMap().entries.map((entry) => Card(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: AppTheme.primaryGreen),
                    title: Text(entry.value),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeContact(entry.key)),
                  ),
                )),
              
              const SizedBox(height: 24),
              // App Preferences
              _buildSectionHeader("Preferences", Icons.tune, theme),
              Card(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: const Text("Push Notifications"),
                          trailing: Switch(
                            value: settings.notificationsEnabled, 
                            onChanged: (v) => settings.toggleNotifications(v), 
                            activeColor: AppTheme.medicalBlue
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.dark_mode),
                          title: const Text("Dark Mode"),
                          trailing: Switch(
                            value: settings.themeMode == ThemeMode.dark, 
                            onChanged: (v) => settings.toggleTheme(v), 
                            activeColor: AppTheme.medicalBlue
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),

              const SizedBox(height: 24),
              // Danger Zone
              _buildSectionHeader("Account & Data", Icons.warning_amber_rounded, theme, color: Colors.red),
              Card(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.orange),
                      title: const Text("Clear Account History"),
                      subtitle: const Text("Deletes local data but keeps account active"),
                      onTap: _deleteAccountHistory,
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text("Delete Account Permanently", style: TextStyle(color: Colors.red)),
                      subtitle: const Text("Frees up email for future use"),
                      onTap: _deleteAccountPermanently,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color ?? theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? theme.colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
