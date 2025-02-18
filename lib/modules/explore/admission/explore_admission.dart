import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/admission/admission_detail_screen.dart';
import 'package:linkschool/modules/explore/home/explore_home.dart';

class ExploreAdmission extends StatefulWidget {
  const ExploreAdmission({super.key, required this.height});

  final double height;

  @override
  State<ExploreAdmission> createState() => _ExploreAdmissionState();
}

class _ExploreAdmissionState extends State<ExploreAdmission> {
  final _schoolItem = [
    _SearchItems(
      title: 'SOLIS',
      formSales: 'Form for sale at ₦10,000.00',
      admissionDistance: '2km',
      admissionStatus: 'closed',
      image: 'assets/images/explore-images/school-logo.png',
    ),
    _SearchItems(
      title: 'Mount Carmel College, Enugu',
      formSales: 'Form for sale at ₦10,000.00',
      admissionDistance: '2km',
      admissionStatus: 'closed',
      image: 'assets/images/explore-images/ls-logo.png',
    ),
    _SearchItems(
      title: 'SOLIS',
      formSales: 'Form for sale at ₦10,000.00',
      admissionDistance: '2km',
      admissionStatus: 'closed',
      image: 'assets/images/explore-images/school-logo.png',
    ),
    _SearchItems(
      title: 'Mount Carmel College, Enugu',
      formSales: 'Form for sale at ₦10,000.00',
      admissionDistance: '2km',
      admissionStatus: 'closed',
      image: 'assets/images/explore-images/ls-logo.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // TabBar
                  Container(
                    child: TabBar(
                      indicatorColor: AppColors.text2Light,
                      labelColor: AppColors.text2Light,
                      tabs: const [
                        Tab(text: 'Top'),
                        Tab(text: 'Near me'),
                        Tab(text: 'Recommended'),
                      ],
                    ),
                  ),
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Top
                        ListView(
                          children: [
                            _TextIconRow(
                              text: ' Top rated Schools',
                              icon: Icons.arrow_forward,
                            ),
                            CarouselSlider(
                              items: [
                                _SchoolCard(
                                    context: context,
                                    schoolName: 'Daughters Of Divine Love',
                                    formPrice: '₦10,000.00',
                                    admissionStatus: 'Closed'),
                                _SchoolCard(
                                    context: context,
                                    schoolName: 'Daughters Of Divine Love',
                                    formPrice: '₦10,000.00',
                                    admissionStatus: 'Closed')
                              ],
                              options: CarouselOptions(
                                height: 220.0,
                                viewportFraction: 0.8,
                                padEnds: false,
                                autoPlay: true,
                                enableInfiniteScroll: false,
                                scrollDirection: Axis.horizontal,
                                
                              ),
                            ),
                            SizedBox(
                              height: 400,
                              child: Column(
                                children: [
                                  _TextIconRow(
                                    text: 'You might also like',
                                    icon: Icons.arrow_forward,
                                  ),
                                  CarouselSlider(
                                    items: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _schoolItem.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            child: _schoolItem[index],
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _schoolItem.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {},
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                ),
                                                child: _schoolItem[index],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    options: CarouselOptions(
                                      height: 350,
                                      viewportFraction: 0.9,
                                      enableInfiniteScroll: false,
                                      padEnds: true,
                                      autoPlay: false,
                                      scrollDirection: Axis.horizontal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                _TextIconRow(
                                  text: 'Based on your recent searches',
                                  icon: Icons.arrow_forward,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                _BasedOnSearches(
                                  context: context,
                                  schoolName: 'Daughters Of Divine Love',
                                  formPrice: '₦10,000.00',
                                  admissionStatus: 'Closed',
                                ),
                              ],
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                            Column(
                              children: [
                                _TextIconRow(
                                  text: 'Based on your recent searches',
                                  icon: Icons.arrow_forward,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _schoolItem.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      child: _schoolItem[index],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Tab 2: Near me
                        ListView(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _schoolItem.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  child: _schoolItem[index],
                                );
                              },
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'Search using Google Map',
                                    style: AppTextStyles.normal400(
                                        fontSize: 16,
                                        color: AppColors.admissionTitle),
                                  ),
                                ),
                                MapSection(),
                              ],
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _schoolItem.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  child: _schoolItem[index],
                                );
                              },
                            ),
                            _TextIconRow(
                              text: 'Based on your recent searches',
                              icon: Icons.arrow_forward,
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                            _BasedOnSearches(
                              context: context,
                              schoolName: 'Daughters Of Divine Love',
                              formPrice: '₦10,000.00',
                              admissionStatus: 'Closed',
                            ),
                          ],
                        ),
                        // Tab 3: Recommended
                        ListView(
                          children: const [
                            Center(child: Text('Recommended Content')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Widget: School Image
Widget _SchoolImage() {
  return ClipRRect(
    child: Image.asset(
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      fit: BoxFit.cover,
      height: 123,
      width: 328,
    ),
  );
}

// Reusable Widget: School Logo Image
Widget _SchoolLogoImage() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: Image.asset(
      'assets/images/explore-images/school-logo.png',
      fit: BoxFit.cover,
      height: 48,
      width: 48,
    ),
  );
}

// Reusable Widget: School Description
Widget _SchoolDescription({
  required String schoolName,
  required String formPrice,
  required String admissionStatus,
}) {
  return Padding(
    padding: const EdgeInsetsDirectional.all(10.0),
    child: Row(
      children: [
        _SchoolLogoImage(),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schoolName,
              style: AppTextStyles.normal600(
                  fontSize: 16, color: AppColors.text3Light),
            ),
            Text(
              'Form for sale at $formPrice',
              style: AppTextStyles.normal400(
                  fontSize: 16, color: AppColors.schoolform),
            ),
            Row(
              children: [
                Text(
                  'Admissions:',
                  style: AppTextStyles.normal400(
                      fontSize: 14, color: AppColors.text3Light),
                ),
                const SizedBox(width: 5),
                Text(
                  'open',
                  style: AppTextStyles.normal400(
                      fontSize: 14, color: AppColors.admissionopen),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

// Reusable Widget: Top Schools Card
Widget _SchoolCard({
  required BuildContext context,
  required String schoolName,
  required String formPrice,
  required String admissionStatus,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SchoolProfileScreen(),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _TopSchoolImage(),
          const SizedBox(height: 5),
          _TopSchoolDescription(
            schoolName: schoolName,
            formPrice: formPrice,
            admissionStatus: admissionStatus,
          ),
        ],
      ),
    ),
  );
}

Widget _TopSchoolImage() {
  return ClipRRect(
    child: Image.asset(
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      fit: BoxFit.cover,
      height: 123,
      width: 244,
    ),
  );
}

// Reusable Widget: School Logo Image
Widget _TopSchoolLogoImage() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: Image.asset(
      'assets/images/explore-images/school-logo.png',
      fit: BoxFit.cover,
      height: 48,
      width: 48,
    ),
  );
}

// Reusable Widget: School Description
Widget _TopSchoolDescription({
  required String schoolName,
  required String formPrice,
  required String admissionStatus,
}) {
  return Padding(
    padding: const EdgeInsetsDirectional.all(10.0),
    child: Row(
      children: [
        _TopSchoolLogoImage(),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schoolName,
              style: AppTextStyles.normal600(
                  fontSize: 16, color: AppColors.text3Light),
            ),
            Text(
              'Form for sale at $formPrice',
              style: AppTextStyles.normal400(
                  fontSize: 16, color: AppColors.schoolform),
            ),
            Row(
              children: [
                Text(
                  'Admissions:',
                  style: AppTextStyles.normal400(
                      fontSize: 14, color: AppColors.text3Light),
                ),
                const SizedBox(width: 5),
                Text(
                  'open',
                  style: AppTextStyles.normal400(
                      fontSize: 14, color: AppColors.admissionopen),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

// Reusable Widget: Based on Searches
Widget _BasedOnSearches({
  required BuildContext context,
  required String schoolName,
  required String formPrice,
  required String admissionStatus,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SchoolProfileScreen(),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        width: 328,
        height: 220,
        child: Column(
          children: [
            _SchoolImage(),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _SchoolDescription(
                schoolName: schoolName,
                formPrice: formPrice,
                admissionStatus: admissionStatus,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Reusable Widget: Text with Icon Row
Widget _TextIconRow({
  required String text,
  required IconData icon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,
            style: AppTextStyles.normal400(
                fontSize: 18, color: AppColors.admissionTitle)),
        Icon(icon),
      ],
    ),
  );
}

// Reusable Widget: Search Items
Widget _SearchItems({
  required String image,
  required String title,
  required String formSales,
  required String admissionDistance,
  required String admissionStatus,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 4.0,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Image(
            image: AssetImage(
              image,
            ),
            fit: BoxFit.cover,
            height: 50,
            width: 50,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.normal700(
                      fontSize: 16, color: AppColors.schooltext)),
              const SizedBox(height: 4),
              Text(formSales,
                  style: AppTextStyles.normal700(
                      fontSize: 16, color: AppColors.schoolform)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(admissionDistance,
                      style: AppTextStyles.normal700(
                          fontSize: 16, color: AppColors.schooltext)),
                  const SizedBox(width: 8),
                  Text(
                    admissionStatus,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
