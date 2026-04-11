import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/ads/cbt_scoped_ad_manager.dart';

class DiscussionAdManager {
  DiscussionAdManager._();

  static final DiscussionAdManager instance = DiscussionAdManager._();

  final CbtScopedAdManager _delegate = CbtScopedAdManager(
    label: 'DiscussionAdManager',
    appOpenAdUnitId: EnvConfig.discussionAdsOpenKey,
    interstitialAdUnitId: EnvConfig.discussionInterstitialAdKey,
    rewardedAdUnitId: '',
  );

  bool get isPresentingFullscreenAd => _delegate.isPresentingFullscreenAd;

  Future<void> preloadAll(BuildContext context) =>
      _delegate.preloadAll(context);

  Future<bool> showAppOpenIfEligible({
    required BuildContext context,
    Duration waitForLoad = const Duration(seconds: 3),
  }) {
    return _delegate.showAppOpenIfEligible(
      context: context,
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
}
