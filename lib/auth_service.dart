import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'profile_manager.dart';

class AuthResult {
  final User? user;
  final String? errorCode; // e.g. "email-already-in-use", "wrong-password"
  final bool isNewUser;
  final String? errorMessage;

  AuthResult({this.user, this.errorCode, this.isNewUser = false, this.errorMessage});

  bool get isSuccess => user != null;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Stream to listen to auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserUid => _auth.currentUser?.uid;

  // Sign up with Email and Password
  Future<AuthResult> signUpWithEmail(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await result.user?.updateDisplayName(name);
      return AuthResult(user: result.user, isNewUser: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorCode: e.code, errorMessage: e.message);
    } catch (e) {
      return AuthResult(errorCode: 'unknown', errorMessage: e.toString());
    }
  }

  // Login with Email and Password
  Future<AuthResult> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return AuthResult(user: result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorCode: e.code, errorMessage: e.message);
    } catch (e) {
      return AuthResult(errorCode: 'unknown', errorMessage: e.toString());
    }
  }

  // Sign In / Register with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      print("AuthService: Starting Google Sign-In flow...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("AuthService: Google Sign-In cancelled by user.");
        return AuthResult(errorCode: 'cancelled', errorMessage: 'Sign-in cancelled.');
      }

      print("AuthService: Fetching authentication tokens for ${googleUser.email}...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("AuthService: Signing in to Firebase with credential...");
      UserCredential result = await _auth.signInWithCredential(credential);
      
      print("AuthService: Google Sign-In successful for ${result.user?.email}");
      return AuthResult(user: result.user, isNewUser: result.additionalUserInfo?.isNewUser ?? false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // Here we could implement advanced linking logic if needed
        print("AuthService: Account exists with different provider. Please use manual login or link account.");
      }
      return AuthResult(errorCode: e.code, errorMessage: e.message);
    } catch (e) {
      print("AuthService: Unexpected error during Google Sign-In: $e");
      String errorMsg = e.toString();
      
      // Handle common Google Sign-In errors on Android
      if (errorMsg.contains('10')) {
        errorMsg = "Developer Error (10): This usually means the SHA-1 fingerprint is missing or incorrect in Firebase Console.";
      } else if (errorMsg.contains('12500')) {
        errorMsg = "Sign-in Failed (12500): Check if the 'Support Email' is set in your Firebase Project Settings.";
      } else if (errorMsg.contains('7')) {
        errorMsg = "Network Error (7): Please check your internet connection.";
      }
      
      return AuthResult(errorCode: 'unknown', errorMessage: errorMsg);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await ProfileManager.clearProfile();
    await _storage.deleteAll(); // Clear security passwords for testing
    print("AuthService: User logged out and all data cleared.");
  }

  // Force Google account picker to show up again
  Future<void> disconnectGoogle() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
    await _storage.deleteAll(); // Clear security passwords for testing
    print("AuthService: Google account disconnected and data wiped.");
  }

  // Securely store data
  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // --- Phone Authentication ---
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<AuthResult> signInWithPhone(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      return AuthResult(user: result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorCode: e.code, errorMessage: e.message);
    }
  }

  // Link Phone Number to existing user (useful for Google users)
  Future<bool> linkPhone(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.currentUser?.linkWithCredential(credential);
      return true;
    } catch (e) {
      print("Link Phone Error: $e");
      return false;
    }
  }

  // Check if security password exists (for Google users)
  Future<bool> hasSecurityPassword() async {
    final password = await readSecureData('security_password');
    return password != null && password.isNotEmpty;
  }
}
