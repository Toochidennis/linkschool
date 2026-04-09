import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:provider/provider.dart';

enum GamifyAdTier {
  paid,
  freeTrial,
  continueWithAds,
}

class GamifyAdManager {
  GamifyAdManager._();

  static final GamifyAdManager instance = GamifyAdManager._();

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
    debugPrint('[GamifyAdManager] $message');
  }

  Future<GamifyAdTier> getTier(BuildContext context) async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    return _resolveTier(userProvider);
  }

  Future<GamifyAdTier> _resolveTier(CbtUserProvider userProvider) async {
    if (userProvider.hasPaid) {
      return GamifyAdTier.paid;
    }

    if (userProvider.hasValidLicense && userProvider.licenseSource == 'trial') {
      return GamifyAdTier.freeTrial;
    }

    final subscriptionService = CbtSubscriptionService();
    final adMode = await subscriptionService.getAdMode();
    if (adMode == 'continue_with_ads') {
      return GamifyAdTier.continueWithAds;
    }

    if (adMode == 'free_trial') {
      final trialExpired = await subscriptionService.isTrialExpired();
      return trialExpired
          ? GamifyAdTier.continueWithAds
          : GamifyAdTier.freeTrial;
    }

    final hasPaidLocally = await subscriptionService.hasPaid();
    if (hasPaidLocally) {
      return GamifyAdTier.paid;
    }

    final trialExpired = await subscriptionService.isTrialExpired();
    return trialExpired ? GamifyAdTier.continueWithAds : GamifyAdTier.freeTrial;
  }

  Future<bool> _isAdEligible(BuildContext context) async {
    final tier = await getTier(context);
    return tier != GamifyAdTier.paid;
  }

  Future<bool> canShowRewarded(BuildContext context) async {
    return _isAdEligible(context);
  }

  Future<void> preloadAll(BuildContext context) async {
    if (!await _isAdEligible(context)) {
      return;
    }
    await preloadAppOpen();
    await preloadInterstitial();
    await preloadRewarded();
  }

  Future<void> preloadAppOpen() async {
    if (_isAppOpenLoading || _appOpenAd != null) {
      return;
    }

    _isAppOpenLoading = true;
    _appOpenLoadCompleter = Completer<bool>();

    AppOpenAd.load(
      adUnitId: EnvConfig.gamifyAdOpenKey,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _isAppOpenLoading = false;
          _appOpenLoadCompleter?.complete(true);
          _log('Gamify app-open ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          _isAppOpenLoading = false;
          _appOpenLoadCompleter?.complete(false);
          _log(
            'Gamify app-open failed to load: code=${error.code}, message=${error.message}',
          );
        },
      ),
    );
  }

  Future<void> preloadInterstitial() async {
    if (_isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    _interstitialLoadCompleter = Completer<bool>();

    InterstitialAd.load(
      adUnitId: EnvConfig.gamifyInterstitialKey,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialLoadCompleter?.complete(true);
          _log('Gamify interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _interstitialLoadCompleter?.complete(false);
          _log(
            'Gamify interstitial failed to load: code=${error.code}, message=${error.message}',
          );
        },
      ),
    );
  }

  Future<void> preloadRewarded() async {
    if (_isRewardedLoading || _rewardedAd != null) {
      return;
    }

    _isRewardedLoading = true;
    _rewardedLoadCompleter = Completer<bool>();

    RewardedAd.load(
      adUnitId: EnvConfig.gamifyRewardKey,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedLoadCompleter?.complete(true);
          _log('Gamify rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          _rewardedLoadCompleter?.complete(false);
          _log(
            'Gamify rewarded failed to load: code=${error.code}, message=${error.message}',
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

  Future<bool> showAppOpenIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 3),
  }) async {
    if (!await _isAdEligible(context) || _isAppOpenShowing) {
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

    _isAppOpenShowing = true;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenShowing = false;
        preloadAppOpen();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenShowing = false;
        preloadAppOpen();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.show();
    return completer.future;
  }

  Future<bool> showInterstitialIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(milliseconds: 900),
  }) async {
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

    ad.show();
    return completer.future;
  }

  Future<bool> showRewardedIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 2),
  }) async {
    if (!await _isAdEligible(context) || _isRewardedShowing) {
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

    ad.show(
      onUserEarnedReward: (_, __) {
        rewardEarned = true;
      },
    );

    return completer.future;
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
