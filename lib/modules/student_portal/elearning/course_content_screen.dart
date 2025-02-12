import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/student_portal/elearning/assignment_detail_screen.dart';
import 'package:linkschool/modules/student_portal/elearning/material_screen.dart';

class CourseContentScreen extends StatefulWidget {
  const CourseContentScreen({super.key});

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  bool _isPunctualityExpanded = false;
  bool _isProductionExpanded = false;
  bool _isCapitalismExpanded = false;
  bool _isSocialismExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 16),
              const ContentRow(
                iconPath: 'assets/icons/student/quiz_icon.svg',
                title: 'Quiz: Human Rights',
                subtitle: 'Created on 25 June, 2015 08:52am',
                titleColor: AppColors.paymentTxtColor1,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignmentDetailsScreen(),
                    ),
                  );
                },
                child: const ContentRow(
                  iconPath: 'assets/icons/student/assignment_icon.svg',
                  title: 'Assignment: Honesty',
                  subtitle: 'Created on 25 June, 2015 08:52am',
                  titleColor: AppColors.paymentTxtColor1,
                ),
              ),
              const SizedBox(height: 24),
              buildPunctualitySection(),
              buildProductionSection(),
              buildCapitalismSection(),
              buildPubertySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPunctualitySection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isPunctualityExpanded = !_isPunctualityExpanded;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  const Text(
                    'Punctuality',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.paymentTxtColor1,
                    ),
                  ),
                  const Spacer(),
                  // Expand/collapse arrow
                  RotatedBox(
                    quarterTurns: _isPunctualityExpanded ? 2 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/student/dropdown_icon.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.paymentTxtColor1,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade400),
          // Dropdown Content
          if (_isPunctualityExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  // Row 1: What is Punctuality
                  buildContentRowWithIconAndProgress(
                    iconPath: 'assets/icons/student/title_icon.svg',
                    title: 'Continue Reading',
                    description:
                        'What is Punctuality? \n...trbfbft qwvohcujs hqouchsjas qjbg...',
                    progressBarPercentage: 75,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterialScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: buildContentRowWithIconAndProgress(
                      iconPath: 'assets/icons/student/loading_icon.svg',
                      title: 'Assignment',
                      description: 'Due date: 25 June, 2015 08:52am',
                      progressBarPercentage:
                          30, // Adjust this value as required
                      onTap: () {
                        // Navigate or handle tap for Assignment row
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Row 3: First C.A
                  buildContentRowWithSubtitle(
                    'assets/icons/student/check_icon.svg',
                    'First C.A',
                    'Created on 25 June, 2015 08:52am',
                  ),
                  const SizedBox(height: 16),
                  // Row 4: Second C.A
                  buildContentRowWithBadge(
                    'assets/icons/student/check_icon.svg',
                    'Second C.A',
                    'Created on 25 June, 2015 08:52am',
                    badgeText: 'Submitted',
                    badgeColor: AppColors.studentCtnColor5,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildProductionSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isProductionExpanded = !_isProductionExpanded;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  const Text(
                    'Production',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.paymentTxtColor1,
                    ),
                  ),
                  const Spacer(),
                  // Expand/collapse arrow
                  RotatedBox(
                    quarterTurns: _isProductionExpanded ? 2 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/student/dropdown_icon.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.paymentTxtColor1,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade400),
          // Dropdown Content
          if (_isProductionExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  // Row 1: What is Punctuality
                  buildContentRowWithIconAndProgress(
                    iconPath: 'assets/icons/student/title_icon.svg',
                    title: 'Continue Reading',
                    description:
                        'What is Production? \n...trbfbft qwvohcujs hqouchsjas qjbg...',
                    progressBarPercentage: 75,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterialScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: buildContentRowWithIconAndProgress(
                      iconPath: 'assets/icons/student/loading_icon.svg',
                      title: 'Assignment',
                      description: 'Due date: 25 June, 2015 08:52am',
                      progressBarPercentage:
                          75, // Adjust this value as required
                      onTap: () {
                        // Navigate or handle tap for Assignment row
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Row 3: First C.A
                  buildContentRowWithSubtitle(
                    'assets/icons/student/check_icon.svg',
                    'First C.A',
                    'Created on 25 June, 2015 08:52am',
                  ),
                  const SizedBox(height: 16),
                  // Row 4: Second C.A
                  buildContentRowWithBadge(
                    'assets/icons/student/check_icon.svg',
                    'Second C.A',
                    'Created on 25 June, 2015 08:52am',
                    badgeText: 'Submitted',
                    badgeColor: AppColors.studentCtnColor5,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCapitalismSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isCapitalismExpanded = !_isCapitalismExpanded;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  const Text(
                    'Capitalism',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.paymentTxtColor1,
                    ),
                  ),
                  const Spacer(),
                  // Expand/collapse arrow
                  RotatedBox(
                    quarterTurns: _isCapitalismExpanded ? 2 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/student/dropdown_icon.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.paymentTxtColor1,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade400),
          // Dropdown Content
          if (_isCapitalismExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  // Row 1: What is Punctuality
                  buildContentRowWithIconAndProgress(
                    iconPath: 'assets/icons/student/title_icon.svg',
                    title: 'Continue Reading',
                    description:
                        'What is Capitalism? \n...trbfbft qwvohcujs hqouchsjas qjbg...',
                    progressBarPercentage: 75,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterialScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: buildContentRowWithIconAndProgress(
                      iconPath: 'assets/icons/student/loading_icon.svg',
                      title: 'Assignment',
                      description: 'Due date: 25 June, 2015 08:52am',
                      progressBarPercentage:
                          75, // Adjust this value as required
                      onTap: () {
                        // Navigate or handle tap for Assignment row
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Row 3: First C.A
                  buildContentRowWithSubtitle(
                    'assets/icons/student/check_icon.svg',
                    'First C.A',
                    'Created on 25 June, 2015 08:52am',
                  ),
                  const SizedBox(height: 16),
                  // Row 4: Second C.A
                  buildContentRowWithBadge(
                    'assets/icons/student/check_icon.svg',
                    'Second C.A',
                    'Created on 25 June, 2015 08:52am',
                    badgeText: 'Submitted',
                    badgeColor: AppColors.studentCtnColor5,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPubertySection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isSocialismExpanded = !_isSocialismExpanded;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  const Text(
                    'Socialism',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.paymentTxtColor1,
                    ),
                  ),
                  const Spacer(),
                  // Expand/collapse arrow
                  RotatedBox(
                    quarterTurns: _isSocialismExpanded ? 2 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/student/dropdown_icon.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.paymentTxtColor1,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade400),
          // Dropdown Content
          if (_isSocialismExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  // Row 1: What is Punctuality
                  buildContentRowWithIconAndProgress(
                    iconPath: 'assets/icons/student/title_icon.svg',
                    title: 'Continue Reading',
                    description:
                        'What is Socialism? \n...trbfbft qwvohcujs hqouchsjas qjbg...',
                    progressBarPercentage: 75,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterialScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: buildContentRowWithIconAndProgress(
                      iconPath: 'assets/icons/student/loading_icon.svg',
                      title: 'Assignment',
                      description: 'Due date: 25 June, 2015 08:52am',
                      progressBarPercentage:
                          75, // Adjust this value as required
                      onTap: () {
                        // Navigate or handle tap for Assignment row
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Row 3: First C.A
                  buildContentRowWithSubtitle(
                    'assets/icons/student/check_icon.svg',
                    'First C.A',
                    'Created on 25 June, 2015 08:52am',
                  ),
                  const SizedBox(height: 16),
                  // Row 4: Second C.A
                  buildContentRowWithBadge(
                    'assets/icons/student/check_icon.svg',
                    'Second C.A',
                    'Created on 25 June, 2015 08:52am',
                    badgeText: 'Submitted',
                    badgeColor: AppColors.studentCtnColor5,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/student/header_background.svg',
                fit: BoxFit.cover,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Agricultural Science',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '2018/2019 Session',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'First Term',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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

  Widget buildContentRow(
    String iconPath,
    String title,
    String subtitle, [
    VoidCallback? onTap,
    List<ExpandedContentRow>? additionalContent,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, height: 32, width: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${title.split(':')[0]}: ',
                          style: const TextStyle(
                              color: AppColors.paymentTxtColor1,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: title.split(':').length > 1
                              ? title.split(':')[1].trim()
                              : '',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (additionalContent != null) ...additionalContent,
          ],
        ),
      ),
    );
  }

  Widget buildContentRowWithSubtitle(
      String iconPath, String title, String subtitle) {
    return Row(
      children: [
        SvgPicture.asset(iconPath, height: 32, width: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildContentRowWithBadge(
      String iconPath, String title, String subtitle,
      {required String badgeText, required Color badgeColor}) {
    return Row(
      children: [
        SvgPicture.asset(iconPath, height: 32, width: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badgeText,
            style: const TextStyle(
              color: AppColors.paymentBtnColor1,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildContentRowWithIconAndProgress({
    required String iconPath,
    required String title,
    required String description,
    required int progressBarPercentage,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // SVG Icon
          SvgPicture.asset(
            iconPath,
            height: 32,
            width: 32,
          ),
          const SizedBox(width: 12),
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (e.g., "Continue Reading")
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.paymentTxtColor1,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Description Text
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress Bar
                LinearProgressIndicator(
                  value: progressBarPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedContentRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final int progressBarPercentage;
  final String? badgeText;
  final Color? badgeColor;

  const ExpandedContentRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.progressBarPercentage,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.paymentTxtColor1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressBarPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          if (badgeText != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ContentRow extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final Color titleColor;

  const ContentRow({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, height: 32, width: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${title.split(':')[0]}: ',
                        style: TextStyle(
                            color: titleColor, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: title.split(':').length > 1
                            ? title.split(':')[1].trim()
                            : '',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}