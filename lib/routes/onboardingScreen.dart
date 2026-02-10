import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'app_navigation_flow.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingData {
  final String gifPath;
  final String title;
  final String description;
  final Color accentColor;

  OnboardingData({
    required this.gifPath,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  _OnboardingscreenState createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      gifPath: 'assets/images/gif/Happy_student.gif',
      title: 'Welcome to LinkSkool',
      description:
          'Take a step towards making your school better. We are here to support you on your journey to paperless learning.',
      accentColor: const Color(0xFF2D63FF),
    ),
    OnboardingData(
      gifPath: 'assets/images/gif/Online_learning.gif',
      title: 'Learn Anywhere, Anytime',
      description:
          'Access educational content, read e-books and watch academic videos from the comfort of your device.',
      accentColor: const Color(0xFF2D63FF),
    ),
    OnboardingData(
      gifPath: 'assets/images/gif/Webinar.gif',
      title: 'Take CBT Exams with Ease',
      description:
          'Practice and take Computer Based Tests anytime. Get instant results, track your performance, and improve your scores.',
      accentColor: const Color(0xFF2D63FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    try {
      final userBox = Hive.box('userData');
      await userBox.put('hasSeenOnboarding', true);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AppNavigationFlow()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AppNavigationFlow()),
          (route) => false,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
    _fadeController.reset();
    _scaleController.reset();
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = currentPage == _onboardingData.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _onboardingData[currentPage].accentColor.withOpacity(0.1),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button at top right
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.normal500(
                          fontSize: 16,
                          color: AppColors.text5Light,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                      _onboardingData[index],
                      size,
                    );
                  },
                ),
              ),

              // Bottom section with indicator and button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _onboardingData.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor:
                            _onboardingData[currentPage].accentColor,
                        dotColor: Colors.grey.shade300,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        spacing: 6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Next/Get Started button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isLastPage ? size.width - 48 : 60,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isLastPage
                            ? _completeOnboarding
                            : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _onboardingData[currentPage].accentColor,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: _onboardingData[currentPage]
                              .accentColor
                              .withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isLastPage ? 16 : 30),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isLastPage
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: AppTextStyles.normal700(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
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

  Widget _buildOnboardingPage(OnboardingData data, Size size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GIF Container with decorative elements
              Container(
                height: size.height * 0.35,
                width: size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: data.accentColor.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Image.asset(
                      data.gifPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: data.accentColor.withOpacity(0.1),
                          child: Icon(
                            Icons.school_rounded,
                            size: 80,
                            color: data.accentColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title with animated decoration
              Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative background element
                  Positioned(
                    child: Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: data.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Text(
                    data.title,
                    style: AppTextStyles.normal700(
                      fontSize: 28,
                      color: AppColors.titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                data.description,
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: AppColors.text5Light,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
