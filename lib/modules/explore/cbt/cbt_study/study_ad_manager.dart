import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/ads/cbt_scoped_ad_manager.dart';

class StudyAdManager {
  StudyAdManager._();

  static final StudyAdManager instance = StudyAdManager._();

  final CbtScopedAdManager _delegate = CbtScopedAdManager(
    label: 'StudyAdManager',
    appOpenAdUnitId: EnvConfig.studyAdOpenKey,
    interstitialAdUnitId: EnvConfig.studyInterstitialKey,
    rewardedAdUnitId: EnvConfig.studyRewardKey,
    allowAppOpenForPaid: true,
  );

  bool get isPresentingFullscreenAd => _delegate.isPresentingFullscreenAd;

  Future<void> preloadAll(BuildContext context) =>
      _delegate.preloadAll(context);

  Future<void> warmUpStudyAds(BuildContext context) => preloadAll(context);

  Future<bool> showAppOpenIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 3),
  }) {
    return _delegate.showAppOpenIfEligible(
      context: context,
      waitForLoad: waitForLoad,
    );
  }

  Future<bool> showIfEligible({
    required BuildContext context,
    required CbtScopedAdTrigger trigger,
    Duration waitForLoad = const Duration(milliseconds: 900),
  }) {
    return _delegate.showIfEligible(
      context: context,
      trigger: trigger,
      waitForLoad: waitForLoad,
    );
  }

  Future<bool> showInterstitialIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(milliseconds: 900),
  }) {
    return _delegate.showInterstitialIfEligible(
      context: context,
      waitForLoad: waitForLoad,
    );
  }

  Future<bool> showRewardedIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 2),
  }) {
    return _delegate.showRewardedIfEligible(
      context: context,
      waitForLoad: waitForLoad,
    );
  }

  Future<bool> showRewardedForPaywall({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 2),
  }) {
    return _delegate.showRewardedForPaywall(
      context: context,
      waitForLoad: waitForLoad,
    );
  }
}
