import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/study_ad_manager.dart';

class StudyTopicActionsScreen extends StatefulWidget {
  final String topicTitle;
  final VoidCallback onPracticeTap;
  final String? subject;
  final List<String>? topics;
  final List<int>? topicIds;
  final int? courseId;
  final int? examTypeId;

  const StudyTopicActionsScreen({
    super.key,
    required this.topicTitle,
    required this.onPracticeTap,
    this.subject,
    this.topics,
    this.topicIds,
    this.courseId,
    this.examTypeId,
  });

  @override
  State<StudyTopicActionsScreen> createState() =>
      _StudyTopicActionsScreenState();
}

class _StudyTopicActionsScreenState extends State<StudyTopicActionsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;
  int _bannerAdUnitIndex = 0;

  late final AnimationController _entryController;
  late final AnimationController _fxController;

  late final Animation<double> _headingIn;
  late final Animation<double> _videoIn;
  late final Animation<double> _textIn;
  late final Animation<double> _practiceIn;
  bool _isNavigatingAway = false;
  bool _shouldShowAdOnResume = false;

  List<String> get _bannerAdUnitIds {
    const unset = '__SET_VIA_DART_DEFINE__';
    return [
      EnvConfig.homeBannerAdKey,
      EnvConfig.discussionBannerAdKey,
      EnvConfig.gamifyBannerAdKey,
      EnvConfig.googleBannerAdsApiKey,
    ].where((id) => id.isNotEmpty && id != unset).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StudyAdManager.instance.warmUpStudyAds(context);
    _loadBannerAd();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    _headingIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    );
    _videoIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 0.62, curve: Curves.easeOutCubic),
    );
    _textIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.34, 0.78, curve: Curves.easeOutCubic),
    );
    _practiceIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerAd?.dispose();
    _entryController.dispose();
    _fxController.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final ids = _bannerAdUnitIds;
    if (ids.isEmpty) return;

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: ids[_bannerAdUnitIndex],
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _bannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;

          final ids = _bannerAdUnitIds;
          if (_bannerAdUnitIndex < ids.length - 1) {
            setState(() {
              _bannerAdUnitIndex++;
              _bannerAdLoaded = false;
              _bannerAd = null;
            });
            _loadBannerAd();
            return;
          }

          setState(() {
            _bannerAd = null;
            _bannerAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  Widget _buildInlineBannerAd() {
    final ad = _bannerAd;
    if (!_bannerAdLoaded || ad == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway && isCurrentRoute) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        _shouldShowAdOnResume = false;
        if (!isCurrentRoute) return;
        StudyAdManager.instance.showAppOpenIfEligible(context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: widget.topicTitle,
        showBackgroundIllustration: false,
      ),
      body: Container(
        decoration: Constants.customStudyBoxDecoration(context),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _fxController,
                  builder: (context, _) {
                    final t = _fxController.value;
                    final pulseA = 1 + (math.sin(t * 2 * math.pi) * 0.05);
                    final pulseB = 1 + (math.cos(t * 2 * math.pi) * 0.06);

                    return Stack(
                      children: [
                        Positioned(
                          top: -50,
                          right: -30,
                          child: Transform.scale(
                            scale: pulseA,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4EA5FF)
                                    .withValues(alpha: 0.11),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -70,
                          left: -45,
                          child: Transform.scale(
                            scale: pulseB,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2AC6A3)
                                    .withValues(alpha: 0.09),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        CustomPaint(
                          painter: _LearningParticlesPainter(progress: t),
                          size: Size.infinite,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                _StaggeredReveal(
                  animation: _headingIn,
                  offsetY: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFECF3FF),
                          Color(0xFFF8FBFF),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFDCE8FF),
                      ),
                    ),
                    child: Text(
                      'Choose how you want to learn.',
                      style: AppTextStyles.normal700(
                        fontSize: 20,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _StaggeredReveal(
                  animation: _videoIn,
                  offsetY: 28,
                  child: _TopicActionCard(
                    title: 'Video',
                    description: 'Watch quick concept videos',
                    icon: Icons.ondemand_video_rounded,
                    colorA: const Color(0xFF005EEA),
                    colorB: const Color(0xFF49A3FF),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Video lessons will be available soon.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _StaggeredReveal(
                  animation: _textIn,
                  offsetY: 32,
                  child: _TopicActionCard(
                    title: 'Study Text',
                    description: 'Read focused topic notes',
                    icon: Icons.menu_book_rounded,
                    colorA: const Color(0xFF067A66),
                    colorB: const Color(0xFF20C7A6),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Study text for this topic is coming soon.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _StaggeredReveal(
                  animation: _practiceIn,
                  offsetY: 36,
                  child: _TopicActionCard(
                    title: 'Practice',
                    description: 'Solve questions and improve speed',
                    icon: Icons.fact_check_rounded,
                    colorA: const Color(0xFFF57C00),
                    colorB: const Color(0xFFFFB14A),
                    onTap: () {
                      _isNavigatingAway = true;
                      widget.onPracticeTap();
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _buildInlineBannerAd(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredReveal extends StatelessWidget {
  final Animation<double> animation;
  final double offsetY;
  final Widget child;

  const _StaggeredReveal({
    required this.animation,
    required this.offsetY,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * offsetY),
            child: child,
          ),
        );
      },
    );
  }
}

class _LearningParticlesPainter extends CustomPainter {
  final double progress;

  const _LearningParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const points = <Offset>[
      Offset(0.16, 0.12),
      Offset(0.35, 0.22),
      Offset(0.72, 0.16),
      Offset(0.82, 0.34),
      Offset(0.18, 0.48),
      Offset(0.64, 0.56),
      Offset(0.86, 0.62),
      Offset(0.28, 0.74),
      Offset(0.54, 0.82),
      Offset(0.78, 0.9),
    ];

    const colors = <Color>[
      Color(0xFF69B5FF),
      Color(0xFF2BC8A4),
      Color(0xFFFFB35A),
      Color(0xFF8D9DFF),
      Color(0xFF6BD4FF),
    ];

    for (var i = 0; i < points.length; i++) {
      final seed = i * 0.73;
      final driftY = math.sin((progress * 2 * math.pi) + seed) * 8;
      final driftX = math.cos((progress * 2 * math.pi * 0.8) + seed) * 6;
      final base = points[i];

      final dx = (base.dx * size.width) + driftX;
      final dy = (base.dy * size.height) + driftY;
      final radius =
          2.4 + (math.sin((progress * 2 * math.pi) + seed) + 1) * 0.9;

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.26)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LearningParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TopicActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color colorA;
  final Color colorB;
  final VoidCallback onTap;

  const _TopicActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.colorA,
    required this.colorB,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          height: 134,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorA, colorB],
            ),
            boxShadow: [
              BoxShadow(
                color: colorA.withValues(alpha: 0.32),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -22,
                top: -36,
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -18,
                bottom: -38,
                child: Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.normal700(
                              fontSize: 21,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.normal500(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.94),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Start',
                        style: AppTextStyles.normal700(
                          fontSize: 11,
                          color: colorA,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
