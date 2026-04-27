import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class UserProfile {
  String name;
  String email;
  String phone;
  String dob;
  String gender;
  String height;
  String weight;
  String activityLevel;
  String sleepHours;
  String waterIntake;
  String stressLevel;
  String moodLevel;
  String dietPreference;
  String mainGoal;
  String stayLocation;
  String roomNumber;
  String receptionContact;

  UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dob = '',
    this.gender = '',
    this.height = '',
    this.weight = '',
    this.activityLevel = '',
    this.sleepHours = '',
    this.waterIntake = '',
    this.stressLevel = '',
    this.moodLevel = '',
    this.dietPreference = '',
    this.mainGoal = '',
    this.stayLocation = '',
    this.roomNumber = '',
    this.receptionContact = '',
  });

  Map<String, String> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'sleepHours': sleepHours,
      'waterIntake': waterIntake,
      'stressLevel': stressLevel,
      'moodLevel': moodLevel,
      'dietPreference': dietPreference,
      'mainGoal': mainGoal,
      'stayLocation': stayLocation,
      'roomNumber': roomNumber,
      'receptionContact': receptionContact,
    };
  }

  factory UserProfile.fromMap(Map<String, String> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? '',
      height: map['height'] ?? '',
      weight: map['weight'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      sleepHours: map['sleepHours'] ?? '',
      waterIntake: map['waterIntake'] ?? '',
      stressLevel: map['stressLevel'] ?? '',
      moodLevel: map['moodLevel'] ?? '',
      dietPreference: map['dietPreference'] ?? '',
      mainGoal: map['mainGoal'] ?? '',
      stayLocation: map['stayLocation'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      receptionContact: map['receptionContact'] ?? '',
    );
  }
}

class ProfileManager {
  static const String _keyName = 'profile_name';
  static const String _keyEmail = 'profile_email';
  static const String _keyPhone = 'profile_phone';
  static const String _keyDob = 'profile_dob';
  static const String _keyGender = 'profile_gender';
  static const String _keyHeight = 'profile_height';
  static const String _keyWeight = 'profile_weight';
  static const String _keyActivity = 'profile_activity';
  static const String _keySleep = 'profile_sleep';
  static const String _keyWater = 'profile_water';
  static const String _keyStress = 'profile_stress';
  static const String _keyMood = 'profile_mood';
  static const String _keyDiet = 'profile_diet';
  static const String _keyGoal = 'profile_goal';
  static const String _keyStayLoc = 'profile_stayLoc';
  static const String _keyRoomNum = 'profile_roomNum';
  static const String _keyReception = 'profile_reception';
  static const String _keyOnboardingComplete = 'onboarding_completed';
  static const String _keyForceOnboarding = 'force_onboarding_debug';

  static Future<void> setForceOnboarding(bool force) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyForceOnboarding, force);
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, profile.name);
    await prefs.setString(_keyEmail, profile.email);
    await prefs.setString(_keyPhone, profile.phone);
    await prefs.setString(_keyDob, profile.dob);
    await prefs.setString(_keyGender, profile.gender);
    await prefs.setString(_keyHeight, profile.height);
    await prefs.setString(_keyWeight, profile.weight);
    await prefs.setString(_keyActivity, profile.activityLevel);
    await prefs.setString(_keySleep, profile.sleepHours);
    await prefs.setString(_keyWater, profile.waterIntake);
    await prefs.setString(_keyStress, profile.stressLevel);
    await prefs.setString(_keyMood, profile.moodLevel);
    await prefs.setString(_keyDiet, profile.dietPreference);
    await prefs.setString(_keyGoal, profile.mainGoal);
    await prefs.setString(_keyStayLoc, profile.stayLocation);
    await prefs.setString(_keyRoomNum, profile.roomNumber);
    await prefs.setString(_keyReception, profile.receptionContact);
    
    // Sync to Cloud Firestore
    await DatabaseService.saveUserProfile(profile.toMap());
  }

  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: prefs.getString(_keyName) ?? '',
      email: prefs.getString(_keyEmail) ?? '',
      phone: prefs.getString(_keyPhone) ?? '',
      dob: prefs.getString(_keyDob) ?? '',
      gender: prefs.getString(_keyGender) ?? '',
      height: prefs.getString(_keyHeight) ?? '',
      weight: prefs.getString(_keyWeight) ?? '',
      activityLevel: prefs.getString(_keyActivity) ?? '',
      sleepHours: prefs.getString(_keySleep) ?? '',
      waterIntake: prefs.getString(_keyWater) ?? '',
      stressLevel: prefs.getString(_keyStress) ?? '',
      moodLevel: prefs.getString(_keyMood) ?? '',
      dietPreference: prefs.getString(_keyDiet) ?? '',
      mainGoal: prefs.getString(_keyGoal) ?? '',
      stayLocation: prefs.getString(_keyStayLoc) ?? '',
      roomNumber: prefs.getString(_keyRoomNum) ?? '',
      receptionContact: prefs.getString(_keyReception) ?? '',
    );
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear everything
    await prefs.setBool(_keyForceOnboarding, true); // Force onboarding after reset
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, complete);
    await prefs.setBool(_keyForceOnboarding, false); // Clear debug flag
  }

  static Future<bool> isProfileComplete({bool checkCloud = true}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we are forcing onboarding for testing
    if (prefs.getBool(_keyForceOnboarding) ?? false) {
      return false;
    }

    bool complete = prefs.getBool(_keyOnboardingComplete) ?? false;
    
    // If not complete locally, check if we have data in the cloud
    if (!complete && checkCloud) {
      final cloudData = await DatabaseService.getUserProfile();
      if (cloudData != null && cloudData.isNotEmpty) {
        // Map dynamic to string map
        final Map<String, String> stringMap = {};
        cloudData.forEach((key, value) {
          stringMap[key] = value.toString();
        });
        
        await saveProfile(UserProfile.fromMap(stringMap));
        await setOnboardingComplete(true);
        return true;
      }
    }
    return complete;
  }

  static Future<void> syncFromCloud() async {
    final cloudData = await DatabaseService.getUserProfile();
    if (cloudData != null && cloudData.isNotEmpty) {
      final Map<String, String> stringMap = {};
      cloudData.forEach((key, value) {
        stringMap[key] = value.toString();
      });
      await saveProfile(UserProfile.fromMap(stringMap));
      await setOnboardingComplete(true);
    }
  }
}
