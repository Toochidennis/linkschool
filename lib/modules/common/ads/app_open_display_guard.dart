class AppOpenDisplayGuard {
  AppOpenDisplayGuard._();

  static bool _isPresenting = false;
  static DateTime? _lastClosedAt;

  // Prevent back-to-back app-open ads from different listeners on one resume.
  static const Duration _cooldown = Duration(seconds: 3);

  static bool tryAcquire() {
    final now = DateTime.now();
    if (_isPresenting) {
      return false;
    }
    final lastClosedAt = _lastClosedAt;
    if (lastClosedAt != null && now.difference(lastClosedAt) < _cooldown) {
      return false;
    }

    _isPresenting = true;
    return true;
  }

  static void releaseWithoutShowing() {
    _isPresenting = false;
  }

  static void markClosed() {
    _isPresenting = false;
    _lastClosedAt = DateTime.now();
  }
}
