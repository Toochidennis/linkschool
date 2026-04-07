import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../common/constants.dart';
import '../../model/explore/courses/course_model.dart';
import '../../providers/explore/courses/enrollment_provider.dart';
import '../../providers/explore/courses/program_courses_provider.dart';
import 'course_content_screen.dart';
import 'course_description_screen.dart';
import 'course_waiting_screen.dart';

class ExploreCoursesSeeAllScreen extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final String? categorySlug;
  final int? profileId;
  final int categoryId;
  final List<CourseModel>? initialCourses;

  const ExploreCoursesSeeAllScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryId,
    this.categorySlug,
    this.profileId,
    this.initialCourses,
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
    // If courses are provided directly (e.g., Enrolled Courses bucket), skip API call
    if (widget.initialCourses != null && widget.initialCourses!.isNotEmpty) {
      return;
    }
    
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

  Future<void> _handleCourseTap(
    BuildContext context,
    CourseModel course,
  ) async {
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final categoryLabel = widget.categoryName;
    final courseCategoryId = course.programId ?? widget.categoryId;
    final imageUrl = course.imageUrl.startsWith('https')
        ? course.imageUrl
        : 'https://linkskool.net/${course.imageUrl}';

    bool isEnrolled = course.isEnrolled;
    if (!isEnrolled &&
        widget.profileId != null &&
        course.cohortId != null) {
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
    // If courses are provided directly (e.g., Enrolled Courses), don't use provider
    if (widget.initialCourses != null && widget.initialCourses!.isNotEmpty) {
      return _buildScaffold(
        context: context,
        title: '${widget.categoryName} Courses',
        courses: widget.initialCourses!,
      );
    }

    return Consumer<ProgramCoursesProvider>(
      builder: (context, provider, _) {
        final displayCourses = provider.courses;
        final title = provider.program?.name?.isNotEmpty == true
            ? provider.program!.name
            : widget.categoryName;

        if (provider.isLoading && displayCourses.isEmpty) {
          return Scaffold(
            appBar: Constants.customAppBar(
              context: context,
              showBackButton: true,
              title: '$title Courses',
            ),
            body: Container(
              decoration: Constants.customBoxDecoration(context),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (displayCourses.isEmpty && provider.errorMessage.isNotEmpty) {
          return Scaffold(
            appBar: Constants.customAppBar(
              context: context,
              showBackButton: true,
              title: '$title Courses',
            ),
            body: Container(
              decoration: Constants.customBoxDecoration(context),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        if (displayCourses.isEmpty && !provider.isLoading) {
          return _buildScaffold(
            context: context,
            title: '$title Courses',
            courses: const [],
          );
        }

        return _buildScaffold(
          context: context,
          title: '$title Courses',
          courses: displayCourses,
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required String title,
    required List<CourseModel> courses,
  }) {
    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: title,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
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
                 
                  const SizedBox(height: 16),
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
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleCourseTap(context, course),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
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
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _badge(
                    course.isEnrolled ? 'Enrolled' : 'Open',
                    course.isEnrolled
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoChip(course.priceLabel, Colors.black87),
                      if (course.hasTrial) _infoChip(course.trialLabel, Colors.orange),
                      if (course.lessonsTaken != null)
                        _infoChip('${course.lessonsTaken} lessons taken', Colors.blueGrey),
                    ],
                  ),
                ],
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

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
