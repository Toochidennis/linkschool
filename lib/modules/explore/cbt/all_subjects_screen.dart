import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/ads/ad_manager.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/explore/components/year_picker_dialog.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';
import 'package:provider/provider.dart';

class AllSubjectsScreen extends StatefulWidget {
  const AllSubjectsScreen({super.key});

  @override
  State<AllSubjectsScreen> createState() => _AllSubjectsScreenState();
}

class _AllSubjectsScreenState extends State<AllSubjectsScreen>
    with WidgetsBindingObserver {
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoaded = false;
  bool _shouldShowAdOnResume = false;
  bool _pendingShowAppOpenAd = false;
  bool _allowAppOpenAds = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAppOpenAdEligibility();
  }

  Future<void> _initAppOpenAdEligibility() async {
    final allowed = await AdManager.instance.shouldShowCbtOpenAds(context);
    if (!mounted) return;
    setState(() {
      _allowAppOpenAds = allowed;
    });
    if (allowed) {
      _loadAppOpenAd();
    }
  }

  void _loadAppOpenAd() {
    if (!_allowAppOpenAds) return;
    AppOpenAd.load(
      adUnitId: EnvConfig.cbtAdsOpenApiKey,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          if (mounted) {
            setState(() {
              _isAppOpenAdLoaded = true;
            });
          } else {
            _isAppOpenAdLoaded = true;
          }

          if (_pendingShowAppOpenAd) {
            _pendingShowAppOpenAd = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showAppOpenAd();
              }
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AllSubjectsScreen CBT app open ad failed to load: $error');
          _appOpenAd = null;
          _pendingShowAppOpenAd = false;
          if (mounted) {
            setState(() {
              _isAppOpenAdLoaded = false;
            });
          } else {
            _isAppOpenAdLoaded = false;
          }
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (!_allowAppOpenAds) return;
    if (!_isAppOpenAdLoaded || _appOpenAd == null) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        ad.dispose();
        _appOpenAd = null;
        if (mounted) {
          setState(() {
            _isAppOpenAdLoaded = false;
          });
        } else {
          _isAppOpenAdLoaded = false;
        }
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        debugPrint('AllSubjectsScreen CBT app open ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        if (mounted) {
          setState(() {
            _isAppOpenAdLoaded = false;
          });
        } else {
          _isAppOpenAdLoaded = false;
        }
        _loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _shouldShowAdOnResume = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _shouldShowAdOnResume) {
      _shouldShowAdOnResume = false;
      if (!_allowAppOpenAds) return;
      if (_isAppOpenAdLoaded && _appOpenAd != null) {
        _showAppOpenAd();
      } else {
        _pendingShowAppOpenAd = true;
        _loadAppOpenAd();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: 'All Subjects',
      ),
      body: Consumer<CBTProvider>(
        builder: (context, provider, child) {
          final subjects = provider.currentBoardSubjects;
          
          return Container(
            decoration: Constants.customBoxDecoration(context),
            child: subjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.subject,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No subjects available',
                          style: AppTextStyles.normal600(
                            fontSize: 18,
                            color: AppColors.text7Light,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return _buildSubjectCard(context, subject, provider);
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, SubjectModel subject, CBTProvider provider) {
    // Get year range
    final yearModels = provider.getYearModelsForSubject(subject.name);
    final yearDisplay = yearModels.isNotEmpty
        ? '${yearModels.first.year} - ${yearModels.last.year}'
        : 'N/A';

    return GestureDetector(
      onTap: () async {
        final canUseNetwork = await NetworkDialog.ensureOnline(context);
        if (!canUseNetwork) return;
        if (yearModels.isNotEmpty) {
          YearPickerDialog.show(
            context,
            title: 'Choose Year',
            yearModels: yearModels,
            subject: subject.name,
            subjectIcon: provider.getSubjectIcon(subject.name),
            cardColor: provider.getSubjectColor(subject.name),
            subjectList: provider.getOtherSubjects(subject.name),
            subjectId: subject.id,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No years available for this subject'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.cbtColor5)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              decoration: BoxDecoration(
                color: subject.cardColor ?? AppColors.cbtCardColor1,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/${subject.subjectIcon ?? 'default'}.png',
                  width: 24.0,
                  height: 24.0,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.subject, color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    yearDisplay,
                    style: AppTextStyles.normal600(
                      fontSize: 12.0,
                      color: AppColors.text9Light,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
