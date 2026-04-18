import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

const String _unsetEnvValue = '__SET_VIA_DART_DEFINE__';

bool _isDiscussionAdUnitConfigured(String adUnitId) =>
    adUnitId.isNotEmpty && adUnitId != _unsetEnvValue;

List<String> discussionBannerAdUnitIds() {
  final units = <String>[];
  for (final adUnitId in [
    EnvConfig.discussionBannerAdKey,
    EnvConfig.homeBannerAdKey,
    EnvConfig.googleBannerAdsApiKey,
  ]) {
    if (_isDiscussionAdUnitConfigured(adUnitId) && !units.contains(adUnitId)) {
      units.add(adUnitId);
    }
  }
  return units;
}

class DiscussionSponsoredAdCard extends StatelessWidget {
  final List<String> adUnitIds;

  const DiscussionSponsoredAdCard({
    super.key,
    required this.adUnitIds,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.text2Light.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFFFFFFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Center(
                child: _CompactBannerAd(adUnitIds: adUnitIds),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscussionInlineBannerAd extends StatefulWidget {
  final List<String> adUnitIds;
  final AdSize size;

  const DiscussionInlineBannerAd({
    super.key,
    required this.adUnitIds,
    required this.size,
  });

  @override
  State<DiscussionInlineBannerAd> createState() =>
      _DiscussionInlineBannerAdState();
}

class _DiscussionInlineBannerAdState extends State<DiscussionInlineBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;
  int _activeAdUnitIndex = 0;

  String get _activeAdUnitId => widget.adUnitIds[_activeAdUnitIndex];

  void _loadAd() {
    _ad?.dispose();
    _ad = BannerAd(
      adUnitId: _activeAdUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _ad = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;

          debugPrint(
            'Discussion detail banner failed (${error.code}) on $_activeAdUnitId: ${error.message}',
          );

          if (_activeAdUnitIndex < widget.adUnitIds.length - 1) {
            setState(() {
              _activeAdUnitIndex++;
              _ad = null;
              _isLoaded = false;
            });
            _loadAd();
            return;
          }

          setState(() {
            _ad = null;
            _isLoaded = false;
          });
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant DiscussionInlineBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitIds.join('|') != widget.adUnitIds.join('|') ||
        oldWidget.size != widget.size) {
      _activeAdUnitIndex = 0;
      _isLoaded = false;
      _loadAd();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_isLoaded || ad == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

class _CompactBannerAd extends StatefulWidget {
  final List<String> adUnitIds;

  const _CompactBannerAd({
    required this.adUnitIds,
  });

  @override
  State<_CompactBannerAd> createState() => _CompactBannerAdState();
}

class _CompactBannerAdState extends State<_CompactBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;
  bool _hasNoFillAcrossUnits = false;
  int _activeAdUnitIndex = 0;
  int _retryAttempt = 0;

  String get _activeAdUnitId => widget.adUnitIds[_activeAdUnitIndex];

  void _loadAd() {
    _ad?.dispose();
    _ad = BannerAd(
      adUnitId: _activeAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _ad = ad as BannerAd;
            _isLoaded = true;
            _hasNoFillAcrossUnits = false;
            _retryAttempt = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;

          debugPrint(
            'Discussion banner failed (${error.code}) on $_activeAdUnitId: ${error.message}',
          );

          if (_activeAdUnitIndex < widget.adUnitIds.length - 1) {
            setState(() {
              _activeAdUnitIndex++;
              _ad = null;
              _isLoaded = false;
            });
            _loadAd();
            return;
          }

          setState(() {
            _ad = null;
            _isLoaded = false;
            _hasNoFillAcrossUnits = true;
          });

          final retryDelaySeconds = (_retryAttempt + 1) * 8;
          _retryAttempt++;
          Future<void>.delayed(Duration(seconds: retryDelaySeconds), () {
            if (!mounted) return;
            _activeAdUnitIndex = 0;
            _loadAd();
          });
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant _CompactBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitIds.join('|') != widget.adUnitIds.join('|')) {
      _activeAdUnitIndex = 0;
      _retryAttempt = 0;
      _isLoaded = false;
      _hasNoFillAcrossUnits = false;
      _loadAd();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_isLoaded || ad == null) {
      return SizedBox(
        width: 320,
        height: 50,
        child: Center(
          child: Text(
            _hasNoFillAcrossUnits
                ? 'No sponsor card available right now'
                : 'Loading sponsor card...',
            style: AppTextStyles.normal600(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
