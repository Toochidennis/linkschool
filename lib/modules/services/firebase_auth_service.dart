import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  
  factory FirebaseAuthService() {
    return _instance;
  }
  
  FirebaseAuthService._internal();
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String _signupShownKey = 'has_signup_shown';
  
  /// Check if user is already signed up
  Future<bool> isUserSignedUp() async {
    final user = _firebaseAuth.currentUser;
    return user != null;
  }
  
  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      
      await markSignupAsShown();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Google signin error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Google signin error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await markSignupAsShown();
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase email signin error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Email signin error: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      await markSignupAsShown();
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase email signup error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Email signup error: $e');
      rethrow;
    }
  }
  
  /// Mark signup as shown
  Future<void> markSignupAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signupShownKey, true);
  }
  
  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
  
  /// Get current user ID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }
  
  /// Get current user email
  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signupShownKey, false);
  }
}
