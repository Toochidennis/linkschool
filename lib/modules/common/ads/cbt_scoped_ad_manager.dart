import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/modules/common/ads/app_open_display_guard.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:provider/provider.dart';

enum CbtScopedAdTrigger {
  topicStart,
  questionFailure,
  topicCompletion,
  resultNavigation,
  testExit,
  paywallContinue,
}

enum CbtScopedAdTier {
  paid,
  freeTrial,
  continueWithAds,
}

class CbtScopedAdManager {
  CbtScopedAdManager({
    required this.label,
    required this.appOpenAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    this.allowAppOpenForPaid = false,
  });

  static const String _unsetValue = '__SET_VIA_DART_DEFINE__';

  final String label;
  final String appOpenAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;
  final bool allowAppOpenForPaid;

  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isAppOpenLoading = false;
  bool _isAppOpenShowing = false;
  bool _isInterstitialLoading = false;
  bool _isInterstitialShowing = false;
  bool _isRewardedLoading = false;
  bool _isRewardedShowing = false;

  Completer<bool>? _appOpenLoadCompleter;
  Completer<bool>? _interstitialLoadCompleter;
  Completer<bool>? _rewardedLoadCompleter;

  bool get isPresentingFullscreenAd =>
      _isAppOpenShowing || _isInterstitialShowing || _isRewardedShowing;

  void _log(String message) {
    debugPrint('[$label] $message');
  }

  bool _isConfigured(String adUnitId) {
    return adUnitId.isNotEmpty && adUnitId != _unsetValue;
  }

  Future<CbtScopedAdTier> getTier(BuildContext context) async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    return _resolveTier(userProvider);
  }

  Future<CbtScopedAdTier> _resolveTier(CbtUserProvider userProvider) async {
    if (userProvider.hasValidLicense && userProvider.licenseSource == 'trial') {
      return CbtScopedAdTier.freeTrial;
    }

    if (userProvider.hasPaid) {
      return CbtScopedAdTier.paid;
    }

    final subscriptionService = CbtSubscriptionService();
    final adMode = await subscriptionService.getAdMode();
    if (adMode == 'continue_with_ads') {
      return CbtScopedAdTier.continueWithAds;
    }

    if (adMode == 'free_trial') {
      final trialExpired = await subscriptionService.isTrialExpired();
      return trialExpired
          ? CbtScopedAdTier.continueWithAds
          : CbtScopedAdTier.freeTrial;
    }

    final hasPaidLocally = await subscriptionService.hasPaid();
    if (hasPaidLocally) {
      return CbtScopedAdTier.paid;
    }

    final userId = userProvider.currentUser?.id;
    if (userId != null) {
      try {
        final status =
            await CbtLicenseService().getLicenseStatus(userId: userId);
        if (status.isTrial) return CbtScopedAdTier.freeTrial;
        if (status.isPaid) return CbtScopedAdTier.paid;
      } catch (_) {
        // Fall back to local subscription state if the license request fails.
      }
    }

    final trialExpired = await subscriptionService.isTrialExpired();
    return trialExpired
        ? CbtScopedAdTier.continueWithAds
        : CbtScopedAdTier.freeTrial;
  }

  Future<bool> _isAdEligible(BuildContext context) async {
    final tier = await getTier(context);
    return tier != CbtScopedAdTier.paid;
  }

  Future<bool> canShowRewarded(BuildContext context) async {
    return _isAdEligible(context);
  }

  Future<void> preloadAll(BuildContext context) async {
    if (!await _isAdEligible(context)) {
      return;
    }
    if (!context.mounted) return;

    await preloadInterstitial();
    await preloadRewarded();
    if (!context.mounted) return;

    if (await shouldShowAppOpenAds(context)) {
      await preloadAppOpen();
    }
  }

  Future<void> preloadAppOpen() async {
    if (!_isConfigured(appOpenAdUnitId)) {
      _log('Skipping app-open preload because the ad unit is not configured');
      return;
    }
    if (_isAppOpenLoading || _appOpenAd != null) {
      return;
    }

    _isAppOpenLoading = true;
    _appOpenLoadCompleter = Completer<bool>();

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _isAppOpenLoading = false;
          _appOpenLoadCompleter?.complete(true);
          _log('App-open ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          _isAppOpenLoading = false;
          _appOpenLoadCompleter?.complete(false);
          _log(
            'App-open failed to load: code=${error.code}, message=${error.message}',
          );
        },
      ),
    );
  }

  Future<void> preloadInterstitial() async {
    if (!_isConfigured(interstitialAdUnitId)) {
      _log(
          'Skipping interstitial preload because the ad unit is not configured');
      return;
    }
    if (_isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    _interstitialLoadCompleter = Completer<bool>();

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialLoadCompleter?.complete(true);
          _log('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _interstitialLoadCompleter?.complete(false);
          _log(
            'Interstitial failed to load: code=${error.code}, message=${error.message}',
          );
        },
      ),
    );
  }

  Future<void> preloadRewarded() async {
    if (!_isConfigured(rewardedAdUnitId)) {
      _log('Skipping rewarded preload because the ad unit is not configured');
      return;
    }
    if (_isRewardedLoading || _rewardedAd != null) {
      return;
    }

    _isRewardedLoading = true;
    _rewardedLoadCompleter = Completer<bool>();

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedLoadCompleter?.complete(true);
          _log('Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          _rewardedLoadCompleter?.complete(false);
          _log(
            'Rewarded failed to load: code=${error.code}, message=${error.message}',
          );
        },
      ),
    );
  }

  Future<bool> _waitForLoad(
    Completer<bool>? completer, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (completer == null) {
      return false;
    }

    try {
      return await completer.future.timeout(timeout, onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  Future<bool> shouldShowAppOpenAds(BuildContext context) async {
    if (allowAppOpenForPaid) {
      return true;
    }
    return _isAdEligible(context);
  }

  Future<bool> showAppOpenIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 3),
  }) async {
    if (!_isConfigured(appOpenAdUnitId)) return false;
    if (!await shouldShowAppOpenAds(context) || _isAppOpenShowing) {
      return false;
    }

    if (_appOpenAd == null && !_isAppOpenLoading) {
      await preloadAppOpen();
    }
    if (_appOpenAd == null) {
      final loaded = await _waitForLoad(
        _appOpenLoadCompleter,
        timeout: waitForLoad,
      );
      if (!loaded || _appOpenAd == null) {
        return false;
      }
    }

    final ad = _appOpenAd;
    if (ad == null) {
      return false;
    }

    if (!AppOpenDisplayGuard.tryAcquire()) {
      _log('Skipping app-open ad: blocked by global app-open guard');
      return false;
    }

    _isAppOpenShowing = true;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenShowing = false;
        AppOpenDisplayGuard.markClosed();
        preloadAppOpen();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenShowing = false;
        AppOpenDisplayGuard.markClosed();
        preloadAppOpen();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await Future<void>.sync(() => ad.show());
    } on PlatformException catch (error) {
      ad.dispose();
      if (identical(_appOpenAd, ad)) {
        _appOpenAd = null;
      }
      _isAppOpenShowing = false;
      AppOpenDisplayGuard.markClosed();
      preloadAppOpen();
      _log(
        'App-open show threw PlatformException: code=${error.code}, message=${error.message}',
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    } catch (error) {
      ad.dispose();
      if (identical(_appOpenAd, ad)) {
        _appOpenAd = null;
      }
      _isAppOpenShowing = false;
      AppOpenDisplayGuard.markClosed();
      preloadAppOpen();
      _log('App-open show threw unexpected error: $error');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<bool> showIfEligible({
    required BuildContext context,
    required CbtScopedAdTrigger trigger,
    Duration waitForLoad = const Duration(milliseconds: 900),
  }) async {
    final tier = await getTier(context);
    if (!_shouldShow(tier, trigger)) {
      return false;
    }
    if (!context.mounted) return false;

    return showInterstitialIfEligible(
      context: context,
      waitForLoad: waitForLoad,
    );
  }

  Future<bool> showInterstitialIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(milliseconds: 900),
  }) async {
    if (!_isConfigured(interstitialAdUnitId)) return false;
    if (!await _isAdEligible(context) || _isInterstitialShowing) {
      return false;
    }

    if (_interstitialAd == null && !_isInterstitialLoading) {
      await preloadInterstitial();
    }
    if (_interstitialAd == null) {
      final loaded = await _waitForLoad(
        _interstitialLoadCompleter,
        timeout: waitForLoad,
      );
      if (!loaded || _interstitialAd == null) {
        return false;
      }
    }

    final ad = _interstitialAd;
    if (ad == null) {
      return false;
    }

    _isInterstitialShowing = true;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialShowing = false;
        preloadInterstitial();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialShowing = false;
        preloadInterstitial();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await Future<void>.sync(() => ad.show());
    } on PlatformException catch (error) {
      ad.dispose();
      if (identical(_interstitialAd, ad)) {
        _interstitialAd = null;
      }
      _isInterstitialShowing = false;
      preloadInterstitial();
      _log(
        'Interstitial show threw PlatformException: code=${error.code}, message=${error.message}',
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    } catch (error) {
      ad.dispose();
      if (identical(_interstitialAd, ad)) {
        _interstitialAd = null;
      }
      _isInterstitialShowing = false;
      preloadInterstitial();
      _log('Interstitial show threw unexpected error: $error');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<bool> showRewardedIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 2),
  }) async {
    if (!_isConfigured(rewardedAdUnitId)) return false;
    if (!await canShowRewarded(context) || _isRewardedShowing) {
      return false;
    }

    if (_rewardedAd == null && !_isRewardedLoading) {
      await preloadRewarded();
    }
    if (_rewardedAd == null) {
      final loaded = await _waitForLoad(
        _rewardedLoadCompleter,
        timeout: waitForLoad,
      );
      if (!loaded || _rewardedAd == null) {
        return false;
      }
    }

    final ad = _rewardedAd;
    if (ad == null) {
      return false;
    }

    _isRewardedShowing = true;
    final completer = Completer<bool>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedShowing = false;
        preloadRewarded();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedShowing = false;
        preloadRewarded();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await Future<void>.sync(
        () => ad.show(
          onUserEarnedReward: (_, __) {
            rewardEarned = true;
          },
        ),
      );
    } on PlatformException catch (error) {
      ad.dispose();
      if (identical(_rewardedAd, ad)) {
        _rewardedAd = null;
      }
      _isRewardedShowing = false;
      preloadRewarded();
      _log(
        'Rewarded show threw PlatformException: code=${error.code}, message=${error.message}',
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    } catch (error) {
      ad.dispose();
      if (identical(_rewardedAd, ad)) {
        _rewardedAd = null;
      }
      _isRewardedShowing = false;
      preloadRewarded();
      _log('Rewarded show threw unexpected error: $error');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<bool> showRewardedForPaywall({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 2),
  }) async {
    return showRewardedIfEligible(
      context: context,
      waitForLoad: waitForLoad,
    );
  }

  bool _shouldShow(CbtScopedAdTier tier, CbtScopedAdTrigger trigger) {
    if (tier == CbtScopedAdTier.paid) return false;

    if (tier == CbtScopedAdTier.freeTrial) {
      return trigger == CbtScopedAdTrigger.topicCompletion ||
          trigger == CbtScopedAdTrigger.resultNavigation ||
          trigger == CbtScopedAdTrigger.testExit;
    }

    return trigger == CbtScopedAdTrigger.topicCompletion ||
        trigger == CbtScopedAdTrigger.topicStart ||
        trigger == CbtScopedAdTrigger.resultNavigation ||
        trigger == CbtScopedAdTrigger.testExit ||
        trigger == CbtScopedAdTrigger.paywallContinue;
  }

  void disposeAll() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
