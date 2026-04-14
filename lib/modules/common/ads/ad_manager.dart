import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/ads/app_open_display_guard.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:provider/provider.dart';

enum AdTrigger {
  topicStart,
  questionFailure,
  topicCompletion,
  resultNavigation,
  testExit,
  paywallContinue,
}

enum AdTier {
  paid,
  freeTrial,
  freeAds,
}

class _AdEntitlementSnapshot {
  const _AdEntitlementSnapshot({
    required this.tier,
    required this.adMode,
    required this.providerHasPaid,
    required this.providerHasValidLicense,
    required this.providerLicenseSource,
    required this.providerLicenseReason,
    required this.localPaid,
    required this.licenseActive,
    required this.licenseSource,
    required this.licenseReason,
    required this.trialExpired,
    required this.userId,
    required this.userEmail,
  });

  final AdTier tier;
  final String? adMode;
  final bool providerHasPaid;
  final bool providerHasValidLicense;
  final String? providerLicenseSource;
  final String? providerLicenseReason;
  final bool localPaid;
  final bool licenseActive;
  final String? licenseSource;
  final String? licenseReason;
  final bool trialExpired;
  final int? userId;
  final String? userEmail;
}

class AdManager {
  AdManager._();

  static final AdManager instance = AdManager._();

  AppOpenAd? _appOpenAd;
  bool _isAppOpenLoading = false;
  bool _isAppOpenLoaded = false;
  bool _isAppOpenShowing = false;
  Completer<bool>? _appOpenLoadCompleter;
  int _appOpenRetryAttempt = 0;
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isLoaded = false;
  bool _isShowing = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;
  bool _isRewardedShowing = false;
  Completer<bool>? _rewardedLoadCompleter;
  int _retryAttempt = 0;
  static const int _maxRetryAttempts = 3;

  bool get isPresentingFullscreenAd =>
      _isShowing || _isAppOpenShowing || _isRewardedShowing;

  void _log(String message) {
    debugPrint('[AdManager] $message');
  }

  String _tierLabel(AdTier tier) {
    switch (tier) {
      case AdTier.paid:
        return 'paid';
      case AdTier.freeTrial:
        return 'free_trial';
      case AdTier.freeAds:
        return 'continue_with_ads';
    }
  }

  String _appOpenReason(_AdEntitlementSnapshot snapshot) {
    if (snapshot.tier == AdTier.paid) {
      return 'blocked because entitlement is paid';
    }
    if (_isAppOpenShowing) {
      return 'eligible but already showing';
    }
    if (_isAppOpenLoaded && _appOpenAd != null) {
      return 'eligible and ready to show';
    }
    if (_isAppOpenLoading) {
      return 'eligible but still loading';
    }
    return 'eligible but not loaded yet';
  }

  String _interstitialReason(_AdEntitlementSnapshot snapshot) {
    if (snapshot.tier == AdTier.paid) {
      return 'blocked because entitlement is paid';
    }
    if (_isShowing) {
      return 'eligible but already showing';
    }
    if (_isLoaded && _interstitialAd != null) {
      return 'eligible and ready to show';
    }
    if (_isLoading) {
      return 'eligible but still loading';
    }
    return 'eligible but not loaded yet';
  }

  String _rewardedReason(_AdEntitlementSnapshot snapshot) {
    if (snapshot.adMode != 'continue_with_ads') {
      return 'not applicable until user is on continue_with_ads';
    }
    if (_isRewardedShowing) {
      return 'eligible but already showing';
    }
    if (_rewardedAd != null) {
      return 'eligible and ready to show at the 10-question gate';
    }
    if (_isRewardedLoading) {
      return 'eligible but still loading';
    }
    return 'eligible for continue_with_ads gate but not loaded yet';
  }

  Future<_AdEntitlementSnapshot> _collectEntitlementSnapshot(
    BuildContext context,
  ) async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    final adMode = await CbtSubscriptionService().getAdMode();
    final providerHasPaid = userProvider.hasPaid;
    final providerHasValidLicense = userProvider.hasValidLicense;
    final localPaid = await CbtSubscriptionService().hasPaid();
    final trialExpired = await CbtSubscriptionService().isTrialExpired();

    var licenseActive = false;
    String? licenseSource;
    String? licenseReason;
    if (user?.id != null) {
      try {
        final licenseStatus =
            await CbtLicenseService().getLicenseStatus(userId: user!.id!);
        licenseActive = licenseStatus.active;
        licenseSource = licenseStatus.source;
        licenseReason = licenseStatus.reason;
      } catch (_) {
        licenseActive = false;
      }
    }

    final tier = await _resolveTier(userProvider);
    return _AdEntitlementSnapshot(
      tier: tier,
      adMode: adMode,
      providerHasPaid: providerHasPaid,
      providerHasValidLicense: providerHasValidLicense,
      providerLicenseSource: userProvider.licenseSource,
      providerLicenseReason: userProvider.licenseReason,
      localPaid: localPaid,
      licenseActive: licenseActive,
      licenseSource: licenseSource,
      licenseReason: licenseReason,
      trialExpired: trialExpired,
      userId: user?.id,
      userEmail: user?.email,
    );
  }

  Future<void> logEntitlementSnapshot({
    required BuildContext context,
    required String location,
  }) async {
    final snapshot = await _collectEntitlementSnapshot(context);
    _log(
      'Entitlement @ $location: '
      'tier=${_tierLabel(snapshot.tier)}, '
      'adMode=${snapshot.adMode ?? 'null'}, '
      'providerHasPaid=${snapshot.providerHasPaid}, '
      'providerHasValidLicense=${snapshot.providerHasValidLicense}, '
      'providerLicenseSource=${snapshot.providerLicenseSource ?? 'null'}, '
      'providerLicenseReason=${snapshot.providerLicenseReason ?? 'null'}, '
      'localPaid=${snapshot.localPaid}, '
      'licenseActive=${snapshot.licenseActive}, '
      'licenseSource=${snapshot.licenseSource ?? 'null'}, '
      'licenseReason=${snapshot.licenseReason ?? 'null'}, '
      'trialExpired=${snapshot.trialExpired}, '
      'userId=${snapshot.userId}, '
      'userEmail=${snapshot.userEmail ?? 'null'}',
    );
    _log(
      'Ad reasons @ $location: '
      'appOpen=${_appOpenReason(snapshot)} '
      '[loaded=$_isAppOpenLoaded, loading=$_isAppOpenLoading, showing=$_isAppOpenShowing]; '
      'interstitial=${_interstitialReason(snapshot)} '
      '[loaded=$_isLoaded, loading=$_isLoading, showing=$_isShowing]; '
      'rewarded=${_rewardedReason(snapshot)} '
      '[loaded=${_rewardedAd != null}, loading=$_isRewardedLoading, showing=$_isRewardedShowing]',
    );
  }

  Future<void> preload() async {
    if (_isLoading || _isLoaded) return;
    _isLoading = true;
    _log('Preloading interstitial ad');

    InterstitialAd.load(
      adUnitId: EnvConfig.googleCbtInterstitialAdsApiKey,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isLoaded = true;
          _isLoading = false;
          _retryAttempt = 0;
          _log('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isLoaded = false;
          _isLoading = false;
          _log(
            'Interstitial ad failed to load: code=${error.code}, message=${error.message}',
          );

          if (error.code == 3 && _retryAttempt < _maxRetryAttempts) {
            _retryAttempt++;
            final delaySeconds = _retryAttempt * 30;
            Future.delayed(Duration(seconds: delaySeconds), () => preload());
          } else {
            _retryAttempt = 0; // reset after max attempts
          }
        },
      ),
    );
  }

  Future<bool> _ensureRewardedLoaded() async {
    if (_rewardedAd != null) return true;
    if (_isRewardedLoading) {
      return await (_rewardedLoadCompleter?.future ?? Future.value(false));
    }

    _isRewardedLoading = true;
    _rewardedLoadCompleter = Completer<bool>();

    RewardedAd.load(
      adUnitId: EnvConfig.googleAdsApiKey,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedLoadCompleter?.complete(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          _rewardedLoadCompleter?.complete(false);
        },
      ),
    );

    return await _rewardedLoadCompleter!.future;
  }

  Future<bool> showRewardedForPaywall() async {
    if (_isRewardedShowing) return false;
    final isReady = await _ensureRewardedLoaded();
    if (!isReady || _rewardedAd == null) {
      _log('Rewarded ad not ready for paywall');
      return false;
    }

    _isRewardedShowing = true;
    _log('Showing rewarded ad for paywall');
    final completer = Completer<bool>();
    var rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedShowing = false;
        _ensureRewardedLoaded();
        _log('Rewarded ad dismissed; rewardEarned=$rewardEarned');
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedShowing = false;
        _ensureRewardedLoaded();
        _log(
          'Rewarded ad failed to show: code=${error.code}, message=${error.message}',
        );
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    final ad = _rewardedAd!;
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
      _ensureRewardedLoaded();
      _log(
        'Rewarded ad show threw PlatformException: code=${error.code}, message=${error.message}',
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
      _ensureRewardedLoaded();
      _log('Rewarded ad show threw unexpected error: $error');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return await completer.future;
  }

  Future<void> preloadAppOpen() async {
    if (_isAppOpenLoading || _isAppOpenLoaded) return;

    _isAppOpenLoading = true;
    _appOpenLoadCompleter = Completer<bool>();
    _log('Preloading app-open ad');

    AppOpenAd.load(
      adUnitId: EnvConfig.cbtAdsOpenApiKey,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _isAppOpenLoaded = true;
          _isAppOpenLoading = false;
          _appOpenRetryAttempt = 0;
          _log('App-open ad loaded');
          _appOpenLoadCompleter?.complete(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          _isAppOpenLoaded = false;
          _isAppOpenLoading = false;
          _log(
            'App-open ad failed to load: code=${error.code}, message=${error.message}',
          );
          _appOpenLoadCompleter?.complete(false);
          if (error.code == 3 && _appOpenRetryAttempt < _maxRetryAttempts) {
            _appOpenRetryAttempt++;
            final delaySeconds = _appOpenRetryAttempt * 30;
            _log(
              'Retrying app-open preload in ${delaySeconds}s (attempt=$_appOpenRetryAttempt)',
            );
            Future.delayed(
              Duration(seconds: delaySeconds),
              () => preloadAppOpen(),
            );
          } else {
            _appOpenRetryAttempt = 0;
          }
        },
      ),
    );
  }

  Future<bool> _ensureAppOpenLoaded({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (_isAppOpenLoaded && _appOpenAd != null) return true;

    if (!_isAppOpenLoading) {
      await preloadAppOpen();
    }

    final completer = _appOpenLoadCompleter;
    if (completer == null) return false;

    try {
      final loaded = await completer.future.timeout(
        timeout,
        onTimeout: () => false,
      );
      return loaded && _isAppOpenLoaded && _appOpenAd != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> showAppOpenIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 2),
  }) async {
    final shouldShow = await shouldShowCbtOpenAds(context);
    if (!shouldShow || _isAppOpenShowing) {
      _log(
        'Skipping app-open ad: shouldShow=$shouldShow, isShowing=$_isAppOpenShowing',
      );
      return false;
    }

    final isReady = await _ensureAppOpenLoaded(timeout: waitForLoad);
    final ad = _appOpenAd;
    if (!isReady || ad == null) {
      _log('App-open ad not ready within ${waitForLoad.inSeconds}s; skipping');
      preloadAppOpen();
      return false;
    }

    if (!AppOpenDisplayGuard.tryAcquire()) {
      _log('Skipping app-open ad: blocked by global app-open guard');
      return false;
    }

    _isAppOpenShowing = true;
    _log('Showing app-open ad');
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenLoaded = false;
        _isAppOpenShowing = false;
        AppOpenDisplayGuard.markClosed();
        preloadAppOpen();
        _log('App-open ad dismissed');
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenLoaded = false;
        _isAppOpenShowing = false;
        AppOpenDisplayGuard.markClosed();
        preloadAppOpen();
        _log(
          'App-open ad failed to show: code=${error.code}, message=${error.message}',
        );
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
      _isAppOpenLoaded = false;
      _isAppOpenShowing = false;
      AppOpenDisplayGuard.markClosed();
      preloadAppOpen();
      _log(
        'App-open ad show threw PlatformException: code=${error.code}, message=${error.message}',
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    } catch (error) {
      ad.dispose();
      if (identical(_appOpenAd, ad)) {
        _appOpenAd = null;
      }
      _isAppOpenLoaded = false;
      _isAppOpenShowing = false;
      AppOpenDisplayGuard.markClosed();
      preloadAppOpen();
      _log('App-open ad show threw unexpected error: $error');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<void> warmUpPracticeAds(BuildContext context) async {
    await preload();
    if (!context.mounted) return;
    final shouldWarmAppOpen = await shouldShowCbtOpenAds(context);
    _log('Warm-up practice ads: shouldWarmAppOpen=$shouldWarmAppOpen');
    if (shouldWarmAppOpen) {
      await preloadAppOpen();
    }
  }

  Future<void> showIfEligible({
    required BuildContext context,
    required AdTrigger trigger,
  }) async {
    final tier = await _getTier(context);
    _log('Evaluating interstitial trigger=$trigger for tier=$tier');
    if (!_shouldShow(tier, trigger)) {
      _log('Skipping interstitial trigger=$trigger for tier=$tier');
      return;
    }
    await _showInterstitialOrContinue();
  }

  Future<bool> shouldShowCbtOpenAds(BuildContext context) async {
    final tier = await _getTier(context);
    final should = tier != AdTier.paid;
    _log('App-open eligibility resolved: tier=$tier, shouldShow=$should');
    return should;
  }

  Future<AdTier> getCbtAdTier(BuildContext context) async {
    return _getTier(context);
  }

  Future<AdTier> _getTier(BuildContext context) async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    return _resolveTier(userProvider);
  }

  Future<AdTier> _resolveTier(CbtUserProvider userProvider) async {
    if (userProvider.hasValidLicense && userProvider.licenseSource == 'trial') {
      return AdTier.freeTrial;
    }
    if (userProvider.hasPaid) {
      return AdTier.paid;
    }

    final adMode = await CbtSubscriptionService().getAdMode();
    if (adMode == 'continue_with_ads') {
      return AdTier.freeAds;
    }
    if (adMode == 'free_trial') {
      final trialExpired = await CbtSubscriptionService().isTrialExpired();
      return trialExpired ? AdTier.freeAds : AdTier.freeTrial;
    }

    final localPaid = await CbtSubscriptionService().hasPaid();
    if (localPaid) {
      return AdTier.paid;
    }

    final userId = userProvider.currentUser?.id;
    if (userId != null) {
      try {
        final status =
            await CbtLicenseService().getLicenseStatus(userId: userId);
        if (status.isTrial) return AdTier.freeTrial;
        if (status.isPaid) return AdTier.paid;
      } catch (_) {
        // Fall through to ad-mode / trial logic if license check fails.
      }
    }

    final trialExpired = await CbtSubscriptionService().isTrialExpired();
    return trialExpired ? AdTier.freeAds : AdTier.freeTrial;
  }

  bool _shouldShow(AdTier tier, AdTrigger trigger) {
    if (tier == AdTier.paid) return false;

    if (tier == AdTier.freeTrial) {
      return trigger == AdTrigger.topicCompletion ||
          trigger == AdTrigger.resultNavigation ||
          trigger == AdTrigger.testExit;
    }

    // freeAds
    return trigger == AdTrigger.topicCompletion ||
        trigger == AdTrigger.topicStart ||
        // trigger == AdTrigger.questionFailure ||
        trigger == AdTrigger.resultNavigation ||
        trigger == AdTrigger.testExit ||
        trigger == AdTrigger.paywallContinue;
  }

// print which ad triger is shown for which tier

  Future<void> _showInterstitialOrContinue() async {
    if (_isShowing) return;

    if (_isLoaded && _interstitialAd != null) {
      _isShowing = true;
      _log('Showing interstitial ad');
      final completer = Completer<void>();

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _interstitialAd = null;
          _isLoaded = false;
          _isShowing = false;
          preload(); // preload next ad
          _log('Interstitial ad dismissed');
          completer.complete();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _interstitialAd = null;
          _isLoaded = false;
          _isShowing = false;
          preload();
          _log(
            'Interstitial ad failed to show: code=${error.code}, message=${error.message}',
          );
          completer.complete();
        },
      );

      final ad = _interstitialAd!;
      try {
        await Future<void>.sync(() => ad.show());
      } on PlatformException catch (error) {
        ad.dispose();
        if (identical(_interstitialAd, ad)) {
          _interstitialAd = null;
        }
        _isLoaded = false;
        _isShowing = false;
        preload();
        _log(
          'Interstitial ad show threw PlatformException: code=${error.code}, message=${error.message}',
        );
        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (error) {
        ad.dispose();
        if (identical(_interstitialAd, ad)) {
          _interstitialAd = null;
        }
        _isLoaded = false;
        _isShowing = false;
        preload();
        _log('Interstitial ad show threw unexpected error: $error');
        if (!completer.isCompleted) {
          completer.complete();
        }
      }

      await completer.future;
      return;
    }

    // No ad ready — silently continue and preload for next time
    _log('Interstitial not ready; continuing without showing');

    preload();
  }
}
