import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:provider/provider.dart';

enum AdTrigger {
  topicStart,
  questionFailure,
  topicCompletion,
  resultNavigation,
  paywallContinue,
}

enum AdTier {
  paid,
  freeTrial,
  freeAds,
}

class AdManager {
  AdManager._();

  static final AdManager instance = AdManager._();

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

Future<void> preload() async {
  if (_isLoading || _isLoaded) return;
  _isLoading = true;

  InterstitialAd.load(
    adUnitId: EnvConfig.googleCbtInterstitialAdsApiKey,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        _interstitialAd = ad;
        _isLoaded = true;
        _isLoading = false;
        _retryAttempt = 0; 
        print('Ad loaded successfully');
      },
      onAdFailedToLoad: (LoadAdError error) {
        _interstitialAd = null;
        _isLoaded = false;
        _isLoading = false;
        print('Ad failed to load: $error');

       
        if (error.code == 3 && _retryAttempt < _maxRetryAttempts) {
          _retryAttempt++;
          final delaySeconds = _retryAttempt * 30; 
          print('Retrying ad load in ${delaySeconds}s (attempt $_retryAttempt)');
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
          print('Rewarded ad failed to load: $error');
        },
      ),
    );

    return await _rewardedLoadCompleter!.future;
  }

  Future<bool> showRewardedForPaywall() async {
    if (_isRewardedShowing) return false;
    final isReady = await _ensureRewardedLoaded();
    if (!isReady || _rewardedAd == null) {
      print('Rewarded ad not ready');
      return false;
    }

    _isRewardedShowing = true;
    final completer = Completer<bool>();
    var rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedShowing = false;
        _ensureRewardedLoaded();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedShowing = false;
        _ensureRewardedLoaded();
        print('Rewarded ad failed to show: $error');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (_, __) {
        rewardEarned = true;
      },
    );

    return await completer.future;
  }

  Future<void> showIfEligible({
    required BuildContext context,
    required AdTrigger trigger,
  }) async {
    final tier = await _getTier(context);
    if (!_shouldShow(tier, trigger)) {
      print('No ad to show for trigger: $trigger, tier: $tier');
      return;
    }
    print('Showing ad for trigger: $trigger, tier: $tier');
    await _showInterstitialOrContinue();
  }

  Future<AdTier> _getTier(BuildContext context) async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final adMode = await CbtSubscriptionService().getAdMode();
    if (adMode == 'continue_with_ads') {
      print('Ad mode is continue_with_ads, treating as freeAds tier');
      return AdTier.freeAds;
    }
    if (adMode == 'free_trial') {
      return AdTier.freeTrial;
    }

    final userId = userProvider.currentUser?.id;
    if (userId != null) {
      try {
        final cached = await CbtLicenseService().getCachedLicenseStatus(userId);
        if (cached == true) return AdTier.paid;
        if (cached == false) {
          final trialExpired = await CbtSubscriptionService().isTrialExpired();
          return trialExpired ? AdTier.freeAds : AdTier.freeTrial;
        }

        final isActive =
            await CbtLicenseService().isLicenseActive(userId: userId);
        if (isActive) return AdTier.paid;
      } catch (_) {
        // Fall through to trial logic if license check fails.
      }
    }

    final trialExpired = await CbtSubscriptionService().isTrialExpired();
    return trialExpired ? AdTier.freeAds : AdTier.freeTrial;
  }

  bool _shouldShow(AdTier tier, AdTrigger trigger) {
    if (tier == AdTier.paid) return false;

    if (tier == AdTier.freeTrial) {
      return  trigger == AdTrigger.topicStart ||
          trigger == AdTrigger.topicCompletion ||
          trigger == AdTrigger.resultNavigation;
    }

    // freeAds
    return  trigger == AdTrigger.topicCompletion ||
         trigger == AdTrigger.topicStart ||
        // trigger == AdTrigger.questionFailure ||
       
        trigger == AdTrigger.resultNavigation ||
        trigger == AdTrigger.paywallContinue;
  }

// print which ad triger is shown for which tier


Future<void> _showInterstitialOrContinue() async {
  if (_isShowing) return;

  if (_isLoaded && _interstitialAd != null) {
    _isShowing = true;
    final completer = Completer<void>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        _isLoaded = false;
        _isShowing = false;
        preload(); // preload next ad
        completer.complete();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        _isLoaded = false;
        _isShowing = false;
        preload();
        print('Ad failed to show: $error');
        completer.complete(); 
      },
    );

    _interstitialAd!.show();
    await completer.future;
    return;
  }

  // No ad ready — silently continue and preload for next time
  print('No ad ready (no fill or still loading); continuing without ad.');
  preload();
}
}
