import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../model/explore/courses/course_model.dart';
import '../../model/explore/courses/program_courses_model.dart';
import '../../providers/explore/courses/enrollment_provider.dart';
import '../../providers/explore/courses/program_courses_provider.dart';
import 'course_content_screen.dart';
import 'course_description_screen.dart';
import 'course_selection_screen.dart';
import 'course_waiting_screen.dart';

class ExploreCoursesSeeAllScreen extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final String? categorySlug;
  final int? profileId;
  final int categoryId;

  const ExploreCoursesSeeAllScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryId,
    this.categorySlug,
    this.profileId,
  });

  @override
  State<ExploreCoursesSeeAllScreen> createState() =>
      _ExploreCoursesSeeAllScreenState();
}

class _ExploreCoursesSeeAllScreenState
    extends State<ExploreCoursesSeeAllScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.categorySlug != null && widget.categorySlug!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_fetchCourses());
      });
    }
  }

  Future<void> _fetchCourses() async {
    final slug = widget.categorySlug?.trim() ?? '';
    if (slug.isEmpty) return;
    await context.read<ProgramCoursesProvider>().fetchBySlug(slug);
  }

  Future<void> _openCourseSelection(String slug) async {
    final targetSlug = slug.trim();
    if (targetSlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program slug is required to enroll.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CourseSelectionScreen(
          slug: targetSlug,
          returnToExploreCourses: true,
        ),
      ),
    );

    if (result == true && mounted) {
      await _fetchCourses();
    }
  }

  Future<void> _handleCourseTap(
      BuildContext context, CourseModel course) async {
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final categoryLabel = widget.categoryName;
    final courseCategoryId = course.programId ?? widget.categoryId;
    final imageUrl = course.imageUrl.startsWith('https')
        ? course.imageUrl
        : 'https://linkskool.net/${course.imageUrl}';

    bool isEnrolled = course.isEnrolled;
    if (!isEnrolled && widget.profileId != null && course.cohortId != null) {
      try {
        isEnrolled = await enrollmentProvider.checkPaymentStatus(
          cohortId: course.cohortId!.toString(),
          profileId: widget.profileId!,
        );
      } catch (_) {
        isEnrolled = course.isEnrolled;
      }
    }

    if (isEnrolled) {
      final cohortStart = course.cohortStartDate != null
          ? DateTime.tryParse(course.cohortStartDate!)
          : null;

      if (cohortStart != null && DateTime.now().isBefore(cohortStart)) {
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseWaitingScreen(
              slug: course.slug ?? '',
              providerSubtitle: 'Powered By Digital Dreams',
              category: categoryLabel.toUpperCase(),
              categoryColor: widget.categoryColor,
              categoryId: courseCategoryId,
              isFree: course.isFree,
              trialExpiryDate: course.trialExpiryDate,
              profileId: widget.profileId,
              trialType: course.trialType,
              trialValue: course.trialValue,
              lessonsTaken: course.lessonsTaken,
              cohortCost: course.cost.toInt(),
            ),
          ),
        );
        return;
      }

      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseContentScreen(
            lessonImage: imageUrl,
            cohortId: course.cohortId.toString(),
            isFree: course.isFree,
            trialExpiryDate: course.trialExpiryDate,
            courseTitle: course.courseName,
            courseDescription: course.description,
            provider: categoryLabel,
            courseId: course.id,
            courseName: course.courseName,
            categoryId: courseCategoryId,
            providerSubtitle: 'Powered By Digital Dreams',
            category: categoryLabel.toUpperCase(),
            categoryColor: widget.categoryColor,
            profileId: widget.profileId,
            trialType: course.trialType,
            trialValue: course.trialValue,
            lessonsTaken: course.lessonsTaken,
            cohortCost: course.cost.toInt(),
          ),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDescriptionScreen(
          profileId: widget.profileId,
          course: course,
          categoryName: categoryLabel,
          categoryId: courseCategoryId,
          provider: categoryLabel,
          cohortId: course.cohortId.toString(),
          isFree: course.isFree,
          trialExpiryDate: course.trialExpiryDate,
          providerSubtitle: 'Powered By Digital Dreams',
          categoryColor: widget.categoryColor,
          hasEnrolled: isEnrolled,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgramCoursesProvider>(
      builder: (context, provider, _) {
        final displayCourses = provider.courses;
        final title = provider.program?.name.isNotEmpty == true
            ? provider.program!.name
            : widget.categoryName;

        if (provider.isLoading && displayCourses.isEmpty) {
          return Scaffold(
            appBar: Constants.customAppBar(
              context: context,
              showBackButton: true,
              title: '$title Courses',
            ),
            backgroundColor: const Color(0xFFF7F8FC),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (displayCourses.isEmpty && provider.errorMessage.isNotEmpty) {
          return Scaffold(
            appBar: Constants.customAppBar(
              context: context,
              showBackButton: true,
              title: '$title Courses',
            ),
            backgroundColor: const Color(0xFFF7F8FC),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.errorMessage,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return _buildScaffold(
          context: context,
          title: '$title Courses',
          courses: displayCourses,
          program: provider.program,
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required String title,
    required List<CourseModel> courses,
    required ProgramModel? program,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: title,
      ),
      body: Column(
        children: [
          _buildHeroCard(program),
          Expanded(
            child: courses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 56,
                          color: widget.categoryColor.withValues(alpha: 0.85),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No courses available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This category does not have any courses yet.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      const Text(
                        'Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...courses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final course = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == courses.length - 1 ? 0 : 12,
                          ),
                          child: _buildCourseCard(
                            context: context,
                            course: course,
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ProgramModel? program) {
    final shortName = (program?.shortname ?? '').trim();
    final fallbackName = (program?.name ?? widget.categoryName).trim();
    final heroTitle = shortName.isNotEmpty
        ? shortName
        : (fallbackName.isNotEmpty ? fallbackName : 'Programme');
    final heroDescription = (program?.description ?? '').trim().isNotEmpty
        ? program!.description.trim()
        : 'Pick your preferred course and continue to enrollment.';
    final targetSlug = (program?.slug ?? widget.categorySlug ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
      color: const Color(0xFF1F2A67),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              shortName.isNotEmpty ? shortName.toUpperCase() : 'PROGRAM',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enroll in $heroTitle',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            heroDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFD7D4FF),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: targetSlug.isEmpty
                  ? null
                  : () async {
                      await _openCourseSelection(targetSlug);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
                disabledBackgroundColor: const Color(0xFFF9D28A),
                foregroundColor: const Color(0xFF1F2937),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                shadowColor: const Color(0x30FFA500),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Enroll Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

  Widget _buildCourseCard({
    required BuildContext context,
    required CourseModel course,
  }) {
    final imageUrl = course.imageUrl.startsWith('https')
        ? course.imageUrl
        : 'https://linkskool.net/${course.imageUrl}';

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleCourseTap(context, course),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 96,
                      height: 76,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade500,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 50, top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.courseName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            course.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _badge(
                course.isEnrolled ? 'Enrolled' : 'Open',
                course.isEnrolled
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
