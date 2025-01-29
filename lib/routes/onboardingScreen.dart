import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'app_navigation_flow.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboardingscreen extends StatelessWidget {
  Onboardingscreen({super.key});
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    OnbordingItems(
        image: 'assets/images/onboardng-image/amico.svg',
        title: 'Welcome to LinkSkool',
        description:
            'Take a step towards making your school better. We are here to support you on your journey to paperless learning.'),
    OnbordingItems(
        image: 'assets/images/onboardng-image/amico.svg',
        title: 'Explore LinkSkool amazing features',
        description:
            'Take CBT’s, play games, read educative e-books and watch academic videos.'),
    OnbordingItems(
        image: 'assets/images/onboardng-image/amico.svg',
        title: 'Welcome to LinkSkool',
        description:
            'Take a step towards making your school better. We are here to support you on your journey to paperless learning.')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              child: SvgPicture.asset('assets/images/onboardng-image/Blur.svg',
                  fit: BoxFit.cover)),
          PageView.builder(
            itemCount: _pages.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                  child: SmoothPageIndicator(
                      effect: WormEffect(dotHeight: 10, dotWidth: 10),
                      controller: _pageController,
                      count: _pages.length))),
          Positioned(
              bottom: 40,
              right: 16,
              left: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppNavigationFlow()));
                  }, child: Text('Skip',style: TextStyle( fontSize: 20),)),
                  ElevatedButton(
                      onPressed: () {

                      }, 
                      child: Icon(Icons.arrow_forward,color: Colors.white,size: 25,),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        fixedSize: Size(50, 50),
                        shape: CircleBorder(),
                      ),)
                ],
              ))
        ],
      ),
    );
  }
}

Widget OnbordingItems({
  required image,
  required title,
  required description,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 200), child: SvgPicture.asset(image)),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: AppTextStyles.normal700(
                  fontSize: 25, color: AppColors.titleColor),
              textAlign: TextAlign.center,
            ),
            Center(
                child: Text(
              description,
              style: AppTextStyles.normal400(
                  fontSize: 18, color: AppColors.onboardingtext),
              textAlign: TextAlign.center,
            ))
          ],
        ),
      ],
    ),
  );
}
