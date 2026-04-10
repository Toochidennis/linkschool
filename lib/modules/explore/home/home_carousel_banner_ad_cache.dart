import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton service that manages a cached banner ad with controlled refresh timing.
/// Ensures compliance with Google AdMob policy (minimum 120 seconds between refreshes).
class HomeCarouselBannerAdCache {
  HomeCarouselBannerAdCache._();

  static final HomeCarouselBannerAdCache _instance =
      HomeCarouselBannerAdCache._();

  factory HomeCarouselBannerAdCache() => _instance;

  BannerAd? _cachedAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  Timer? _refreshTimer;
  String? _currentAdUnitId;

  final ValueNotifier<BannerAd?> adNotifier = ValueNotifier<BannerAd?>(null);
  final ValueNotifier<bool> loadedNotifier = ValueNotifier<bool>(false);

  BannerAd? get cachedAd => _cachedAd;
  bool get isLoaded => _isLoaded;

  /// Load the ad for the first time or after refresh timeout.
  Future<void> loadAd({required String adUnitId}) async {
    if (_isLoading) return;
    if (_isLoaded && _cachedAd != null && _currentAdUnitId == adUnitId) return;

    _isLoading = true;
    _currentAdUnitId = adUnitId;

    // Dispose old ad if any
    _cachedAd?.dispose();
    _cachedAd = null;
    _isLoaded = false;
    loadedNotifier.value = false;
    adNotifier.value = null;

    _cachedAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          _isLoading = false;
          loadedNotifier.value = true;
          adNotifier.value = ad as BannerAd;
          _startRefreshTimer(adUnitId);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _cachedAd = null;
          _isLoaded = false;
          _isLoading = false;
          adNotifier.value = null;
          loadedNotifier.value = false;
        },
      ),
    )..load();
  }

  /// Start a 120-second timer before allowing refresh.
  void _startRefreshTimer(String adUnitId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(seconds: 120), () {
      // After 120 seconds, the ad can be refreshed on next request
      _isLoaded = false;
      loadedNotifier.value = false;
    });
  }

  /// Clean up resources.
  void dispose() {
    _refreshTimer?.cancel();
    _cachedAd?.dispose();
    _cachedAd = null;
    _isLoaded = false;
    _isLoading = false;
    _currentAdUnitId = null;
    adNotifier.value = null;
    loadedNotifier.value = false;
  }
}
