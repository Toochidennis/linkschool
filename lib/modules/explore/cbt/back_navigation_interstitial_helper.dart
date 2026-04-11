import 'package:flutter/material.dart';
import 'package:linkschool/main.dart';

typedef InterstitialPresenter = Future<bool> Function(BuildContext context);

Future<void> popThenShowInterstitial({
  required VoidCallback popNavigation,
  required InterstitialPresenter showInterstitial,
  Duration postPopDelay = const Duration(milliseconds: 40),
}) async {
  popNavigation();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (postPopDelay > Duration.zero) {
      await Future<void>.delayed(postPopDelay);
    }

    final targetContext = appNavigatorKey.currentState?.overlay?.context ??
        appNavigatorKey.currentContext;
    if (targetContext == null || !targetContext.mounted) {
      return;
    }

    await showInterstitial(targetContext);
  });
}
