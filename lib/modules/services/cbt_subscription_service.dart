import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage CBT subscription status and test attempts
class CbtSubscriptionService {
  static const String _keyTestCount = 'cbt_test_count';
  static const String _keyHasPaid = 'cbt_has_paid';
  static const String _keyPaymentDate = 'cbt_payment_date';
  static const String _keySignupPromptShown = 'cbt_signup_prompt_shown';
  static const String _keyPaymentDialogDismissed =
      'cbt_payment_dialog_dismissed';
  static const String _keyUserEmail =
      'cbt_user_email'; // Track which user's data this is
  static const String _keyTrialStartDate =
      'cbt_trial_start_date'; // Track when trial started

  // Dynamic values from API (with fallbacks)
  int _freeTrialDays = 7; // Default 7 days

  /// Set the free trial days from API settings
  void setMaxFreeTests(int freeTrialDays) {
    _freeTrialDays = freeTrialDays > 0 ? freeTrialDays : 7;
    print('🔧 Free trial period set to: $_freeTrialDays days');
  }

  /// Get the current free trial days
  int get maxFreeTests => _freeTrialDays;

  /// Get the trial start date
  Future<DateTime?> getTrialStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyTrialStartDate);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Set the trial start date (called on first test)
  Future<void> setTrialStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final existingDate = await getTrialStartDate();
    if (existingDate == null) {
      final now = DateTime.now();
      await prefs.setString(_keyTrialStartDate, now.toIso8601String());
      print('🎬 Trial started: $now');
    }
  }

  /// Check if trial period has expired
  Future<bool> isTrialExpired() async {
    final startDate = await getTrialStartDate();
    if (startDate == null) return false; // Trial hasn't started yet

    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays;
    final expired = daysPassed >= _freeTrialDays;

    print(
        '📅 Trial days passed: $daysPassed/$_freeTrialDays (expired: $expired)');
    return expired;
  }

  /// Get the current test count (for analytics)
  Future<int> getTestCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTestCount) ?? 0;
  }

  /// Increment the test count by 1 and start trial if needed
  Future<void> incrementTestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getTestCount();
    await prefs.setInt(_keyTestCount, currentCount + 1);

    // Start trial on first test
    await setTrialStartDate();

    print('🔢 Test count incremented to: ${currentCount + 1}');
  }

  /// Check if user has paid for subscription (from local storage)
  Future<bool> hasPaid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasPaid) ?? false;
  }

  /// Mark user as paid and store their email
  Future<void> markAsPaid(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasPaid, true);
    await prefs.setString(_keyPaymentDate, DateTime.now().toIso8601String());
    await prefs.setString(_keyUserEmail, userEmail);
    print('✅ User marked as paid subscriber: $userEmail');
  }

  /// Sync payment status from CbtUserProvider
  /// This should be called after user sign-in or when app starts
  Future<void> syncPaymentStatus({
    required String userEmail,
    required bool hasReference,
    required int subscribed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyUserEmail);

    // If different user, clear old data
    if (storedEmail != null && storedEmail != userEmail) {
      print('🔄 Different user detected, clearing old subscription data');
      await clearUserData();
    }

    // Update payment status based on backend data
    final isPaid = hasReference || subscribed == 1;
    await prefs.setBool(_keyHasPaid, isPaid);
    await prefs.setString(_keyUserEmail, userEmail);

    if (isPaid && !await hasPaid()) {
      await prefs.setString(_keyPaymentDate, DateTime.now().toIso8601String());
    }

    print('✅ Payment status synced for $userEmail: paid=$isPaid');
  }

  /// Clear user-specific data (for logout or user switch)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasPaid);
    await prefs.remove(_keyPaymentDate);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keySignupPromptShown);
    await prefs.remove(_keyPaymentDialogDismissed);
    await prefs.remove(_keyTrialStartDate);
    // Keep test count as it's device-specific, not user-specific
    print('🗑️ User subscription data cleared');
  }

  /// Get payment date
  Future<DateTime?> getPaymentDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyPaymentDate);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Check if user can take a test (has paid or trial not expired)
  Future<bool> canTakeTest() async {
    final isPaid = await hasPaid();
    if (isPaid) return true;

    // Check if trial has expired
    final trialExpired = await isTrialExpired();
    return !trialExpired;
  }

  /// Check if user should see signup prompt (after taking first test)
  Future<bool> shouldShowSignupPrompt() async {
    final testCount = await getTestCount();
    final isPaid = await hasPaid();
    return testCount >= 1 && !isPaid;
  }

  /// Check if user must pay (trial expired and not paid)
  Future<bool> mustPay() async {
    final isPaid = await hasPaid();
    if (isPaid) return false;

    final trialExpired = await isTrialExpired();
    return trialExpired;
  }

  /// Check if signup prompt has been shown
  Future<bool> hasShownSignupPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySignupPromptShown) ?? false;
  }

  /// Mark signup prompt as shown
  Future<void> markSignupPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignupPromptShown, true);
  }

  /// Check if payment dialog was dismissed
  Future<bool> hasPaymentDialogBeenDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPaymentDialogDismissed) ?? false;
  }

  /// Mark payment dialog as dismissed
  Future<void> markPaymentDialogDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPaymentDialogDismissed, true);
  }

  /// Reset all subscription data (for testing purposes)
  Future<void> resetSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTestCount);
    await prefs.remove(_keyHasPaid);
    await prefs.remove(_keyPaymentDate);
    await prefs.remove(_keySignupPromptShown);
    await prefs.remove(_keyPaymentDialogDismissed);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyTrialStartDate);
    print('🔄 Subscription data reset');
  }

  /// Get remaining free trial days
  Future<int> getRemainingFreeTests() async {
    final isPaid = await hasPaid();
    if (isPaid) return -1; // -1 means unlimited

    final startDate = await getTrialStartDate();
    if (startDate == null) {
      return _freeTrialDays; // Trial hasn't started yet
    }

    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays;
    final remainingDays =
        (_freeTrialDays - daysPassed).clamp(0, _freeTrialDays);

    print('📊 Remaining trial days: $remainingDays');
    return remainingDays;
  }

  /// Get subscription status summary
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    return {
      'testCount': await getTestCount(),
      'hasPaid': await hasPaid(),
      'canTakeTest': await canTakeTest(),
      'shouldShowSignupPrompt': await shouldShowSignupPrompt(),
      'mustPay': await mustPay(),
      'remainingTrialDays': await getRemainingFreeTests(),
      'trialStartDate': await getTrialStartDate(),
      'trialExpired': await isTrialExpired(),
      'freeTrialDays': _freeTrialDays,
      'paymentDate': await getPaymentDate(),
      'userEmail':
          (await SharedPreferences.getInstance()).getString(_keyUserEmail),
    };
  }
}
