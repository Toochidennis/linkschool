import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton service that manages a cached banner ad instance.
/// Keeps one loaded banner alive across widget rebuilds and only reloads
/// on ad unit changes, load failures, or explicit disposal.
class HomeCarouselBannerAdCache {
  HomeCarouselBannerAdCache._();

  static final HomeCarouselBannerAdCache _instance =
      HomeCarouselBannerAdCache._();

  factory HomeCarouselBannerAdCache() => _instance;

  BannerAd? _cachedAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _currentAdUnitId;

  final ValueNotifier<BannerAd?> adNotifier = ValueNotifier<BannerAd?>(null);
  final ValueNotifier<bool> loadedNotifier = ValueNotifier<bool>(false);

  BannerAd? get cachedAd => _cachedAd;
  bool get isLoaded => _isLoaded;

  /// Load the ad once and reuse it while the ad unit stays the same.
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

  /// Clean up resources.
  void dispose() {
    _cachedAd?.dispose();
    _cachedAd = null;
    _isLoaded = false;
    _isLoading = false;
    _currentAdUnitId = null;
    adNotifier.value = null;
    loadedNotifier.value = false;
  }
}
