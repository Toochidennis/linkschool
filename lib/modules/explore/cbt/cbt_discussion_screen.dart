import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class CbtDiscussionScreen extends StatefulWidget {
  final String boardName;

  const CbtDiscussionScreen({
    super.key,
    required this.boardName,
  });

  @override
  State<CbtDiscussionScreen> createState() => _CbtDiscussionScreenState();
}

class _CbtDiscussionScreenState extends State<CbtDiscussionScreen>
    with WidgetsBindingObserver {
  static const String _unsetEnvValue = '__SET_VIA_DART_DEFINE__';

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoaded = false;
  bool _shouldShowAdOnResume = false;
  bool _isNavigatingAway = false;

  final List<_DiscussionNoticeItem> _noticeItems = const [
    _DiscussionNoticeItem(
      title: 'CBT alerts will show here',
      subtitle:
          'Exam reminders, important updates, and quick notices for your study flow will appear in this space.',
      icon: Icons.notifications_active_rounded,
      accentColor: Color(0xFF2563EB),
      badge: 'Soon',
    ),
    _DiscussionNoticeItem(
      title: 'Keep track of important announcements',
      subtitle:
          'We are preparing a cleaner notification-style feed so you can catch updates without digging through screens.',
      icon: Icons.campaign_rounded,
      accentColor: Color(0xFF0F9D58),
      badge: 'Preview',
    ),
    _DiscussionNoticeItem(
      title: 'Need a quick heads-up?',
      subtitle:
          'This page will surface useful CBT activity and prompts tied to your exam journey.',
      icon: Icons.info_outline_rounded,
      accentColor: Color(0xFFF59E0B),
      badge: 'Upcoming',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInterstitialAd();
    _loadAppOpenAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
    super.dispose();
  }

  bool _isAdUnitConfigured(String adUnitId) =>
      adUnitId.isNotEmpty && adUnitId != _unsetEnvValue;

  List<String> get _bannerAdUnitIds {
    final units = <String>[];
    for (final adUnitId in [
      EnvConfig.homeBannerAdKey,
      EnvConfig.discussionBannerAdKey,
    ]) {
      if (_isAdUnitConfigured(adUnitId) && !units.contains(adUnitId)) {
        units.add(adUnitId);
      }
    }
    return units;
  }

  void _loadInterstitialAd() {
    final adUnitId = EnvConfig.discussionInterstitialAdKey;
    if (!_isAdUnitConfigured(adUnitId)) return;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          if (!mounted) return;
          setState(() {
            _isInterstitialAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          if (!mounted) return;
          setState(() {
            _isInterstitialAdLoaded = false;
          });
        },
      ),
    );
  }

  void _loadAppOpenAd() {
    final adUnitId = EnvConfig.discussionAdsOpenKey;
    if (!_isAdUnitConfigured(adUnitId)) return;

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd?.dispose();
          _appOpenAd = ad;
          if (!mounted) return;
          setState(() {
            _isAppOpenAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          if (!mounted) return;
          setState(() {
            _isAppOpenAdLoaded = false;
          });
        },
      ),
    );
  }

  void _showAppOpenAd() {
    final ad = _appOpenAd;
    if (!_isAppOpenAdLoaded || ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
    );

    ad.show();
  }

  Future<void> _handleBackNavigation() async {
    final ad = _interstitialAd;
    if (_isInterstitialAdLoaded && ad != null) {
      _isNavigatingAway = true;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );
      ad.show();
      return;
    }

    _isNavigatingAway = true;
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        _showAppOpenAd();
        _shouldShowAdOnResume = false;
      }
      _isNavigatingAway = false;
    }
  }

  Widget _buildAdsStrip() {
    final adUnitIds = _bannerAdUnitIds;
    if (adUnitIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = adUnitIds
        .map(
          (adUnitId) => _CompactSponsoredAdCard(adUnitId: adUnitId),
        )
        .toList();

    if (items.length == 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: items.first,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: CarouselSlider(
        items: items,
        options: CarouselOptions(
          height: 118,
          padEnds: false,
          viewportFraction: 0.92,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 15),
          enableInfiniteScroll: items.length > 1,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CBT Discussion',
                  style: AppTextStyles.normal700(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A lighter notification-style space for ${widget.boardName} updates and quick heads-up.',
                  style: AppTextStyles.normal400(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.eLearningBtnColor1,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Recent Updates',
            style: AppTextStyles.normal700(
              fontSize: 18,
              color: AppColors.text4Light,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(_DiscussionNoticeItem item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              color: item.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.normal700(
                          fontSize: 15,
                          color: AppColors.text4Light,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.badge,
                        style: AppTextStyles.normal600(
                          fontSize: 11,
                          color: item.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.subtitle,
                  style: AppTextStyles.normal400(
                    fontSize: 13,
                    color: AppColors.text7Light,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        appBar: AppBar(
          backgroundColor: AppColors.eLearningBtnColor1,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _handleBackNavigation,
          ),
          title: Text(
            'CBT Discussion',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildAdsStrip(),
            _buildHeaderCard(),
            _buildSectionLabel(),
            ..._noticeItems.map(_buildNoticeCard),
          ],
        ),
      ),
    );
  }
}

class _CompactSponsoredAdCard extends StatelessWidget {
  final String adUnitId;

  const _CompactSponsoredAdCard({
    required this.adUnitId,
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
                child: _CompactBannerAd(adUnitId: adUnitId),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Sponsored',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactBannerAd extends StatefulWidget {
  final String adUnitId;

  const _CompactBannerAd({
    required this.adUnitId,
  });

  @override
  State<_CompactBannerAd> createState() => _CompactBannerAdState();
}

class _CompactBannerAdState extends State<_CompactBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
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
          setState(() {
            _ad = null;
            _isLoaded = false;
          });
        },
      ),
    )..load();
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
      return Container(
        width: 320,
        height: 50,
        alignment: Alignment.center,
        child: Text(
          'Loading sponsor card...',
          style: AppTextStyles.normal600(
            fontSize: 13,
            color: Colors.grey.shade600,
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

class _DiscussionNoticeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String badge;

  const _DiscussionNoticeItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badge,
  });
}
