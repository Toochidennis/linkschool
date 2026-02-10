import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:provider/provider.dart';

enum AdTrigger {
  topicStart,
  questionFailure,
  topicCompletion,
  resultNavigation,
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
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isLoaded = false;
          _isLoading = false;
        },
      ),
    );
  }

  Future<void> showIfEligible({
    required BuildContext context,
    required AdTrigger trigger,
  }) async {
    final tier = await _getTier(context);
    if (!_shouldShow(tier, trigger)) return;
    await _showInterstitialOrContinue();
  }

  Future<AdTier> _getTier(BuildContext context) async {
    final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
    if (userProvider.hasPaid == true) return AdTier.paid;

    final trialExpired = await CbtSubscriptionService().isTrialExpired();
    return trialExpired ? AdTier.freeAds : AdTier.freeTrial;
  }

  bool _shouldShow(AdTier tier, AdTrigger trigger) {
    if (tier == AdTier.paid) return false;

    if (tier == AdTier.freeTrial) {
      return  trigger == AdTrigger.topicCompletion ||
          trigger == AdTrigger.resultNavigation;
    }

    // freeAds
    return trigger == AdTrigger.topicStart ||
        trigger == AdTrigger.questionFailure ||
        trigger == AdTrigger.topicCompletion ||
        trigger == AdTrigger.resultNavigation;
  }

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
          preload();
          completer.complete();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _interstitialAd = null;
          _isLoaded = false;
          _isShowing = false;
          preload();
          completer.complete();
        },
      );

      _interstitialAd!.show();
      await completer.future;
      return;
    }

    // If ad not ready, load for next time and continue immediately.
    preload();
  }
}
