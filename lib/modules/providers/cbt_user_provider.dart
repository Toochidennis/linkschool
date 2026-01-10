import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/cbt_user_service.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/services/cbt_history_service.dart';
import 'dart:convert';

class CbtUserProvider with ChangeNotifier {
  final CbtUserService _userService = CbtUserService();

  // User state
  CbtUserModel? _currentUser;
  CbtUserModel? get currentUser => _currentUser;

  // Payment reference notifier
  final ValueNotifier<String?> paymentReferenceNotifier =
      ValueNotifier<String?>(null);

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // SharedPreferences keys
  static const String _keyCurrentUser = 'cbt_current_user';
  static const String _keyPaymentReference = 'cbt_payment_reference';

  // =========================================================================
  // 🔄 INITIALIZE - Load user from SharedPreferences on app start
  // =========================================================================
  Future<void> initialize() async {
    print('🚀 Initializing CbtUserProvider...');
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user from SharedPreferences
      final userJson = prefs.getString(_keyCurrentUser);
      if (userJson != null && userJson.isNotEmpty) {
        final userData = json.decode(userJson);
        _currentUser = CbtUserModel.fromJson(userData);
        print('✅ User loaded from SharedPreferences: ${_currentUser?.email}');

        // ✨ SYNC SUBSCRIPTION SERVICE WITH USER PAYMENT STATUS
        await syncSubscriptionService();

        notifyListeners();
      }

      // Load payment reference
      final savedReference = prefs.getString(_keyPaymentReference);
      if (savedReference != null && savedReference.isNotEmpty) {
        paymentReferenceNotifier.value = savedReference;
        print('✅ Payment reference loaded: $savedReference');
      }
    } catch (e) {
      print('⚠️ Error initializing provider: $e');
    }
  }

  Future<void> syncSubscriptionService() async {
    if (_currentUser == null) return;

    final subscriptionService = CbtSubscriptionService();
    await subscriptionService.syncPaymentStatus(
      userEmail: _currentUser!.email,
      hasReference: _currentUser!.reference != null &&
          _currentUser!.reference!.isNotEmpty,
      subscribed: _currentUser!.subscribed,
    );

    print('✅ Subscription service synced with user payment status');
  }

  // =========================================================================
  // 💾 SAVE USER TO SHARED PREFERENCES
  // =========================================================================
  Future<void> _saveUserToPreferences(CbtUserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_keyCurrentUser, userJson);
      print('✅ User saved to SharedPreferences: ${user.email}');
    } catch (e) {
      print('❌ Error saving user to SharedPreferences: $e');
    }
  }

  // =========================================================================
  // 🗑️ CLEAR USER FROM SHARED PREFERENCES
  // =========================================================================
  Future<void> _clearUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if keys exist before removing
      final userExists = prefs.containsKey(_keyCurrentUser);
      final refExists = prefs.containsKey(_keyPaymentReference);

      print('🗑️ Clearing user data from SharedPreferences...');
      print('   - User key exists: $userExists');
      print('   - Payment reference key exists: $refExists');

      if (userExists) {
        final removed = await prefs.remove(_keyCurrentUser);
        print('   - User key removed: $removed');
      }

      if (refExists) {
        final removed = await prefs.remove(_keyPaymentReference);
        print('   - Payment reference removed: $removed');
      }

      // Verify removal
      final stillExists = prefs.containsKey(_keyCurrentUser) ||
          prefs.containsKey(_keyPaymentReference);
      if (stillExists) {
        throw Exception('Failed to remove user data from SharedPreferences');
      }

      print('✅ User data cleared from SharedPreferences');
    } catch (e) {
      print('❌ Error clearing user data: $e');
      rethrow;
    }
  }

  // =========================================================================
  // 👤 FETCH USER BY EMAIL - Simple GET and Save
  // =========================================================================
  Future<CbtUserModel?> fetchUserByEmail(String email) async {
    if (email.isEmpty) {
      print('⚠️ Cannot fetch user: email is empty');
      return null;
    }

    print('📡 [FETCH USER] GET request for: $email');
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userService.fetchUserByEmail(email);

      if (user != null) {
        print('✅ [FETCH USER] User found');
        print('   - Subscribed: ${user.subscribed}');
        print('   - Reference: ${user.reference}');

        // Save to state
        _currentUser = user;

        // Save to SharedPreferences
        await _saveUserToPreferences(user);

        // Update payment reference if user has paid
        if (user.reference != null && user.reference!.isNotEmpty) {
          await _savePaymentReference(user.reference!);
        }

        print('✅ [FETCH USER] User saved to SharedPreferences');
      } else {
        print('⚠️ [FETCH USER] User not found in database');
      }

      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      print('❌ [FETCH USER] Error: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // =========================================================================
  // 🆕 HANDLE FIREBASE SIGN UP - OPTIMIZED FLOW
  // Flow: GET → (if empty) → POST → GET → Save
  //       GET → (not empty) → Save → Proceed
  // =========================================================================
  Future<CbtUserModel?> handleFirebaseSignUp({
    required String email,
    required String name,
    required String profilePicture,
  }) async {
    print('🔐 Handling Firebase sign-up for: $email');
    print('📋 Flow: GET → Check → (POST if needed) → Save');

    _isLoading = true;
    notifyListeners();

    try {
      // =====================================================================
      // STEP 1: First GET - Check if user exists
      // =====================================================================
      print('📡 [STEP 1] Making initial GET request...');
      CbtUserModel? existingUser = await _userService.fetchUserByEmail(email);

      if (existingUser != null) {
        // ===================================================================
        // User EXISTS → Save to SharedPreferences and proceed
        // ===================================================================
        print('✅ [STEP 1] User found in database');
        print('   - Email: ${existingUser.email}');
        print('   - Subscribed: ${existingUser.subscribed}');
        print('   - Reference: ${existingUser.reference}');

        // Update user info (name, profile picture may have changed)
        if (existingUser.name != name ||
            existingUser.profilePicture != profilePicture) {
          print('🔄 Updating user profile info...');
          existingUser = existingUser.copyWith(
            name: name,
            profilePicture: profilePicture,
          );

          // Update in backend
          existingUser = await _userService.createOrUpdateUser(existingUser);
          print('✅ User profile updated');
        }

        // Save to state and SharedPreferences
        _currentUser = existingUser;
        await _saveUserToPreferences(existingUser);

        // Update payment reference if exists
        if (existingUser.reference != null &&
            existingUser.reference!.isNotEmpty) {
          await _savePaymentReference(existingUser.reference!);
        }

        print('✅ User saved to SharedPreferences. Ready to proceed.');

        _isLoading = false;
        notifyListeners();
        return existingUser;
      }

      void loadUserOnStartup() {
        final user = FirebaseAuthService().getCurrentUser();
        if (user != null) {
          // Set user as logged in, load profile info, etc.
          _currentUser = CbtUserModel(
            id: null, // or assign an appropriate id if available
            name: user.displayName ?? '',
            email: user.email ?? '',
            profilePicture: user.photoURL,
            attempt: 0,
            subscribed: 0,
            reference: null,
          );
          notifyListeners();
        } else {
          _currentUser = null;
          notifyListeners();
        }
      }

      // =======================================================================
      // User DOESN'T EXIST → Create new user (POST) → GET again → Save
      // =======================================================================
      print('⚠️ [STEP 1] User NOT found in database');
      print('🆕 [STEP 2] Creating new user via POST...');

      // Create new user model
      final newUser = CbtUserModel(
        name: name,
        email: email,
        profilePicture: profilePicture,
        attempt: 0,
        subscribed: 1, // New users start as subscribed
        reference: null,
      );

      // POST to create user
      final createdUser = await _userService.createOrUpdateUser(newUser);
      print('✅ [STEP 2] User created successfully');
      print('   - User ID: ${createdUser.id}');

      // =======================================================================
      // STEP 3: GET again to ensure data consistency
      // =======================================================================
      print('📡 [STEP 3] Fetching newly created user to verify...');
      final verifiedUser = await _userService.fetchUserByEmail(email);

      if (verifiedUser == null) {
        print('⚠️ [STEP 3] Could not verify user after creation');
        // Fallback to created user data
        _currentUser = createdUser;
        await _saveUserToPreferences(createdUser);

        _isLoading = false;
        notifyListeners();
        return createdUser;
      }

      print('✅ [STEP 3] User verified successfully');
      print('   - Email: ${verifiedUser.email}');
      print('   - Subscribed: ${verifiedUser.subscribed}');
      print('   - Reference: ${verifiedUser.reference}');

      // =======================================================================
      // STEP 4: Save to SharedPreferences
      // =======================================================================
      print('💾 [STEP 4] Saving user to SharedPreferences...');
      _currentUser = verifiedUser;
      await _saveUserToPreferences(verifiedUser);

      if (verifiedUser.reference != null &&
          verifiedUser.reference!.isNotEmpty) {
        await _savePaymentReference(verifiedUser.reference!);
      }
      await syncSubscriptionService();

      print('✅ Sign-up flow completed successfully');

      _isLoading = false;
      notifyListeners();
      return verifiedUser;
    } catch (e) {
      print('❌ Error in sign-up flow: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to sync user: $e');
    }
  }

  // =========================================================================
  // 💳 UPDATE USER AFTER PAYMENT (PUT + Fetch + Persist)
  // =========================================================================
  Future<void> updateUserAfterPayment({required String reference}) async {
    if (_currentUser == null) {
      print('⚠️ Cannot update: currentUser is null');
      throw Exception('No current user to update');
    }

    print('💳 Updating user after payment...');
    print('   - Email: ${_currentUser!.email}');
    print('   - Reference: $reference');

    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Make PUT request to update user
      print('📡 Making PUT request to update user...');
      final updatedUser = await _userService.updateUserAfterPayment(
        email: _currentUser!.email,
        name: _currentUser!.name,
        profilePicture: _currentUser!.profilePicture ?? '',
        reference: reference,
      );

      // Step 2: Update current user
      _currentUser = updatedUser;

      // Step 3: Save to SharedPreferences
      await _saveUserToPreferences(updatedUser);

      // Step 4: Save payment reference and trigger notifier
      await _savePaymentReference(reference);

      // ✨ Step 5: Mark as paid in subscription service
      final subscriptionService = CbtSubscriptionService();
      await subscriptionService.markAsPaid(_currentUser!.email);

      // ✨ Step 6: Sync subscription service
      await syncSubscriptionService();

      print('✅ User updated and persisted after payment');
      print('   - Subscribed: ${updatedUser.subscribed}');
      print('   - Reference: ${updatedUser.reference}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error updating user after payment: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to update user: $e');
    }
  }

  // =========================================================================
  // 💾 SAVE PAYMENT REFERENCE
  // =========================================================================
  Future<void> _savePaymentReference(String reference) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPaymentReference, reference);
      paymentReferenceNotifier.value = reference;
      print('✅ Payment reference saved: $reference');
    } catch (e) {
      print('❌ Error saving payment reference: $e');
    }
  }

  // =========================================================================
  // 🔄 REFRESH USER DATA (Force fetch from API)
  // =========================================================================
  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) {
      print('⚠️ Cannot refresh: currentUser is null');
      return;
    }

    print('🔄 Refreshing user data for: ${_currentUser!.email}');
    await fetchUserByEmail(_currentUser!.email);
  }

  // =========================================================================
  // 🚪 LOGOUT
  // =========================================================================
  Future<void> logout() async {
    print('🚪 Logging out user...');

    // Clear state
    _currentUser = null;
    paymentReferenceNotifier.value = null;

    // Clear SharedPreferences
    try {
      await _clearUserFromPreferences();
      print('✅ User data cleared from SharedPreferences');
    } catch (e) {
      print('❌ Error clearing user from preferences: $e');
      rethrow; // Re-throw to let caller handle
    }

    // ✨ Clear subscription service data
    try {
      final subscriptionService = CbtSubscriptionService();
      await subscriptionService.clearUserData();
      print('✅ Subscription service data cleared');
    } catch (e) {
      print('❌ Error clearing subscription service data: $e');
    }

    // ✨ Clear CBT test history data
    try {
      final historyService = CbtHistoryService();
      await historyService.clearHistory();
      print('✅ CBT test history cleared on logout');
    } catch (e) {
      print('❌ Error clearing CBT test history on logout: $e');
    }

    notifyListeners();
    print('✅ User logged out successfully');
  }

  // =========================================================================
  // ✅ CHECK IF USER HAS PAID
  // =========================================================================
  bool get hasPaid {
    if (_currentUser == null) return false;
    final hasReference =
        _currentUser!.reference != null && _currentUser!.reference!.isNotEmpty;
    final isSubscribed = _currentUser!.subscribed == 1;
    return hasReference || isSubscribed;
  }

  // =========================================================================
  // 📊 GET SUBSCRIPTION STATUS
  // =========================================================================
  Map<String, dynamic> get subscriptionStatus {
    if (_currentUser == null) {
      return {
        'isSignedIn': false,
        'hasPaid': false,
        'subscribed': 0,
        'reference': null,
      };
    }

    return {
      'isSignedIn': true,
      'hasPaid': hasPaid,
      'subscribed': _currentUser!.subscribed,
      'reference': _currentUser!.reference,
      'email': _currentUser!.email,
    };
  }
}



// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:linkschool/modules/model/cbt_user_model.dart';
// import 'package:linkschool/modules/services/cbt_user_service.dart';
// import 'package:linkschool/modules/services/firebase_auth_service.dart';
// import 'package:linkschool/modules/services/cbt_subscription_service.dart';

// /// Provider class for managing CBT user state
// class CbtUserProvider extends ChangeNotifier {
//   final CbtUserService _userService = CbtUserService();
//   final FirebaseAuthService _authService = FirebaseAuthService();

//   CbtUserModel? _currentUser;
//   bool _isLoading = false;
//   String? _errorMessage;
//   int _attemptCountBeforeSignup = 0;
  
//   // ValueNotifier for payment reference to trigger dialog dismissal
//   final ValueNotifier<String?> paymentReferenceNotifier = ValueNotifier<String?>(null);

//   // SharedPreferences keys
//   static const String _keyAttemptBeforeSignup = 'cbt_attempt_before_signup';
//   static const String _keyUserData = 'cbt_user_data';
//   static const String _keyPaymentReference = 'cbt_payment_reference';

//   // Getters
//   CbtUserModel? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   int get attemptCountBeforeSignup => _attemptCountBeforeSignup;
//   bool get isUserLoggedIn => _currentUser != null;
//   bool get isUserSubscribed => _currentUser?.subscribed == 1;

//   /// Initialize provider - load cached user data and attempt count
//   Future<void> initialize() async {
//     _log('🚀 Initializing CbtUserProvider...');
//     await _loadAttemptCount();
//     await _loadCachedUserData();
//     _log('✅ CbtUserProvider initialized');
//   }

//   /// Load attempt count before signup from SharedPreferences
//   Future<void> _loadAttemptCount() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _attemptCountBeforeSignup = prefs.getInt(_keyAttemptBeforeSignup) ?? 0;
//       _log('📊 Loaded attempt count: $_attemptCountBeforeSignup');
//     } catch (e) {
//       _log('❌ Error loading attempt count: $e');
//     }
//   }

//   /// Load cached user data from SharedPreferences
//   Future<void> _loadCachedUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userDataString = prefs.getString(_keyUserData);
      
//       if (userDataString != null) {
//         final Map<String, dynamic> userData = {};
//         userDataString.split('|').forEach((item) {
//           final parts = item.split(':');
//           if (parts.length == 2) {
//             userData[parts[0]] = parts[1];
//           }
//         });
        
//         if (userData.isNotEmpty) {
//           _currentUser = CbtUserModel(
//             id: int.tryParse(userData['id'] ?? '0'),
//             name: userData['name'] ?? '',
//             email: userData['email'] ?? '',
//             profilePicture: userData['profile_picture'],
//             attempt: int.tryParse(userData['attempt'] ?? '0') ?? 0,
//             subscribed: int.tryParse(userData['subscribed'] ?? '0') ?? 0,
//             reference: userData['reference'],
//           );
//           _log('✅ Loaded cached user: ${_currentUser?.name}');
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       _log('❌ Error loading cached user data: $e');
//     }
//   }

//   /// Save user data to SharedPreferences
//   Future<void> _cacheUserData(CbtUserModel user) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userData = 'id:${user.id}|name:${user.name}|email:${user.email}|'
//           'profile_picture:${user.profilePicture ?? ''}|'
//           'attempt:${user.attempt}|subscribed:${user.subscribed}|'
//           'reference:${user.reference ?? ''}';
      
//       await prefs.setString(_keyUserData, userData);
//       _log('💾 User data cached');
//     } catch (e) {
//       _log('❌ Error caching user data: $e');
//     }
//   }

//   /// Increment attempt count before signup
//   Future<void> incrementAttemptBeforeSignup() async {
//     _attemptCountBeforeSignup++;
//     _log('➕ Attempt count incremented to: $_attemptCountBeforeSignup');
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_keyAttemptBeforeSignup, _attemptCountBeforeSignup);
//     notifyListeners();
//   }

//   /// Reset attempt count (called after successful signup)
//   Future<void> _resetAttemptCount() async {
//     _attemptCountBeforeSignup = 0;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_keyAttemptBeforeSignup, 0);
//     _log('🔄 Attempt count reset');
//   }

//   /// Fetch user data by email from API
//   Future<void> fetchUserByEmail(String email) async {
//     _log('🔍 Fetching user by email: $email');
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       final user = await _userService.fetchUserByEmail(email);
      
//       if (user != null) {
//         _currentUser = user;
//         await _cacheUserData(user);
//         _log('✅ User fetched successfully: ${user.name}');
//       } else {
//         _currentUser = null;
//         _log('🔍 User not found');
//       }
      
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Failed to fetch user: $e';
//       _log('❌ Error fetching user: $e');
//       notifyListeners();
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> handleFirebaseSignUp({
//     required String email,
//     required String name,
//     required String profilePicture,
//     String? reference,
//   }) async {
//     _log('🔐 Handling Firebase sign-up...');
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       final cbtSubscriptionService = CbtSubscriptionService();
//       final actualTestCount = await cbtSubscriptionService.getTestCount();
      
//       _log('📊 User has taken $actualTestCount tests before signup');
//       _log('📡 Step 1: Checking if user exists with GET request...');

//       final existingUser = await _userService.fetchUserByEmail(email);

//       if (existingUser != null) {
//         _log('👤 User already exists, saving to SharedPreferences and proceeding');
//         _currentUser = existingUser;
//         await _cacheUserData(existingUser);
//         await _resetAttemptCount();
//         _log('✅ Existing user loaded and cached');
//         notifyListeners();
//         return;
//       }

//       _log('🔍 User not found (empty), proceeding with POST request...');

//       final newUser = CbtUserModel(
//         name: name,
//         email: email,
//         profilePicture: profilePicture,
//         attempt: actualTestCount,
//         subscribed: 1,
//         reference: reference,
//       );

//       await _userService.createOrUpdateUser(newUser);
//       _log('✅ POST request successful, user created');

//       _log('📡 Step 2: Fetching user data back with GET request...');

//       final fetchedUser = await _userService.fetchUserByEmail(email);

//       if (fetchedUser == null) {
//         throw Exception('Failed to fetch user data after creation');
//       }

//       _log('✅ User data fetched successfully, saving to SharedPreferences');

//       _currentUser = fetchedUser;
//       await _cacheUserData(fetchedUser);
//       await _resetAttemptCount();

//       _log('✅ Sign-up completed successfully');
//       _log('📊 User: ${fetchedUser.name}, Subscribed: ${fetchedUser.subscribed}, Attempts: ${fetchedUser.attempt}');

//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Failed to sign up: $e';
//       _log('❌ Error during sign-up: $e');
//       notifyListeners();
//       rethrow;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> handleFirebaseSignIn({String? reference}) async {
//     _log('🔐 Handling Firebase sign-in...');
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       final firebaseUser = _authService.getCurrentUser();

//       if (firebaseUser == null) {
//         throw Exception('No Firebase user found');
//       }

//       _log('👤 Firebase user: ${firebaseUser.email}');

//       final user = await _userService.syncUserOnLogin(
//         email: firebaseUser.email ?? '',
//         name: firebaseUser.displayName ?? '',
//         profilePicture: firebaseUser.photoURL ?? '',
//         attemptCount: _attemptCountBeforeSignup,
//         reference: reference,
//       );

//       _currentUser = user;
//       await _cacheUserData(user);
//       await _resetAttemptCount();

//       _log('✅ User synced successfully: ${user.name}');
//       _log('📊 Subscribed status: ${user.subscribed}');

//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Failed to sync user: $e';
//       _log('❌ Error handling Firebase sign-in: $e');
//       notifyListeners();
//       rethrow;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Create or update user manually
//   Future<void> createOrUpdateUser({
//     required String email,
//     required String name,
//     String? profilePicture,
//     int? attempt,
//     int? subscribed,
//     String? reference,
//   }) async {
//     _log('📝 Creating/Updating user: $email');
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       final user = CbtUserModel(
//         email: email,
//         name: name,
//         profilePicture: profilePicture,
//         attempt: attempt ?? _attemptCountBeforeSignup,
//         subscribed: subscribed ?? 1, // Default to subscribed on creation
//         reference: reference,
//       );

//       final updatedUser = await _userService.createOrUpdateUser(user);
//       _currentUser = updatedUser;
//       await _cacheUserData(updatedUser);
      
//       if (subscribed == 1) {
//         await _resetAttemptCount();
//       }
      
//       _log('✅ User created/updated successfully');
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Failed to create/update user: $e';
//       _log('❌ Error creating/updating user: $e');
//       notifyListeners();
//       rethrow;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Update user's subscription status
//   Future<void> updateSubscriptionStatus(int subscribed) async {
//     if (_currentUser == null) {
//       _log('❌ Cannot update subscription: No user logged in');
//       return;
//     }

//     _log('🔄 Updating subscription status to: $subscribed');
//     _setLoading(true);

//     try {
//       final updatedUser = _currentUser!.copyWith(subscribed: subscribed);
//       final result = await _userService.createOrUpdateUser(updatedUser);
      
//       _currentUser = result;
//       await _cacheUserData(result);
      
//       _log('✅ Subscription status updated');
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Failed to update subscription: $e';
//       _log('❌ Error updating subscription: $e');
//       notifyListeners();
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Update user after successful payment with payment reference
//   Future<void> updateUserAfterPayment({
//     required String reference,
//   }) async {
//     _log('💳 Updating user after payment with reference: $reference');
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       final firebaseUser = _authService.getCurrentUser();

//       if (firebaseUser == null) {
//         throw Exception('No Firebase user found. Please sign in first.');
//       }

//       final email = firebaseUser.email ?? '';
//       final name = firebaseUser.displayName ?? '';
//       final profilePicture = firebaseUser.photoURL ?? '';

//       _log('👤 Updating user: $email');
//       _log('💰 Payment reference: $reference');

//       // Make PUT request to update user with payment reference
//       final updatedUser = await _userService.updateUserAfterPayment(
//         email: email,
//         name: name,
//         profilePicture: profilePicture,
//         reference: reference,
//       );

//       _currentUser = updatedUser;
//       await _cacheUserData(updatedUser);

//       // Save payment reference to SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_keyPaymentReference, reference);
      
//       // Update the notifier to trigger dialog dismissal
//       paymentReferenceNotifier.value = reference;

//       _log('✅ User updated successfully after payment');
//       _log('📊 User: ${updatedUser.name}, Subscribed: ${updatedUser.subscribed}, Reference: $reference');

//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Failed to update user after payment: $e';
//       _log('❌ Error updating user after payment: $e');
//       notifyListeners();
//       rethrow;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Get stored payment reference from SharedPreferences
//   Future<String?> getPaymentReference() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getString(_keyPaymentReference);
//     } catch (e) {
//       _log('❌ Error getting payment reference: $e');
//       return null;
//     }
//   }

//   /// Clear payment reference from SharedPreferences
//   Future<void> clearPaymentReference() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_keyPaymentReference);
//       paymentReferenceNotifier.value = null;
//       _log('🗑️ Payment reference cleared');
//     } catch (e) {
//       _log('❌ Error clearing payment reference: $e');
//     }
//   }

//   /// Sign out user
//   Future<void> signOut() async {
//     _log('👋 Signing out user...');
    
//     try {
//       await _authService.signOut();
      
//       _currentUser = null;
//       _errorMessage = null;
      
//       // Clear cached data
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_keyUserData);
      
//       _log('✅ User signed out successfully');
//       notifyListeners();
//     } catch (e) {
//       _log('❌ Error signing out: $e');
//     }
//   }

//   /// Clear error message
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   /// Set loading state
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   /// Helper method to log messages with timestamps
//   void _log(String message) {
//     final timestamp = DateTime.now().toIso8601String();
//     print('[$timestamp] [CbtUserProvider] $message');
//   }

//   /// Get user summary for debugging
//   Map<String, dynamic> getUserSummary() {
//     return {
//       'isLoggedIn': isUserLoggedIn,
//       'isSubscribed': isUserSubscribed,
//       'attemptBeforeSignup': _attemptCountBeforeSignup,
//       'user': _currentUser?.toString(),
//       'isLoading': _isLoading,
//       'error': _errorMessage,
//     };
//   }
// }
