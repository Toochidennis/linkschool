import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'course_content_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linkschool/modules/providers/explore/courses/cohort_provider.dart';
import 'package:linkschool/modules/providers/explore/courses/enrollment_provider.dart';
import 'package:linkschool/modules/services/explore/courses/cohort_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';

class CourseDescriptionScreen extends StatefulWidget {
  final CourseModel course;
  final String provider;
  final String providerSubtitle;
  final String categoryName;
  final int categoryId;
  final Color categoryColor;
  final String cohortId;
  final int? profileId;

  const CourseDescriptionScreen({
    super.key,
    required this.course,
    required this.provider,
    required this.categoryName,
    required this.categoryId,
    required this.cohortId,
    this.providerSubtitle = 'Powered By Digital Dreams',
    this.categoryColor = const Color(0xFF6366F1),
    this.profileId,
  });

  @override
  State<CourseDescriptionScreen> createState() => _CourseDescriptionScreenState();
}

class _CourseDescriptionScreenState extends State<CourseDescriptionScreen> {
  late CohortProvider _cohortProvider;

  @override
  void initState() {
    super.initState();
    _cohortProvider = CohortProvider(CohortService());
    _cohortProvider.loadCohort(widget.cohortId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CohortProvider>(
      create: (_) => _cohortProvider,
      child: Consumer<CohortProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFA500),
                ),
              ),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load course details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.loadCohort(widget.cohortId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final cohort = provider.cohort!;
          final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // 1. App Bar with Image
                    SliverAppBar(
                      expandedHeight: 250,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      iconTheme: const IconThemeData(color: Colors.white),
                      leading: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.4),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: () {
                                String url = cohort.imageUrl.isNotEmpty ? cohort.imageUrl : widget.course.imageUrl;
                                return url.startsWith('https') ? url : "https://linkskool.net/$url";
                              }(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFFA500),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Gradient overlay for better text visibility (optional)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: widget.categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.categoryName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: widget.categoryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Course Title
                            Text(
                              cohort.courseName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Provider Info
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFA500), Color(0xFFFF6B00)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'B',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.provider,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      widget.providerSubtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 24),

                            // Description
                            const Text(
                              'About this course',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              cohort.description,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // What you'll learn (Objectives placeholder)
                        // What you'll learn (Objectives placeholder)
const Text(
  "What you'll learn",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  ),
),
const SizedBox(height: 16),
if (cohort.benefits.isNotEmpty)
  Html(
    data: cohort.benefits,
    style: {
      "li": Style(
        padding: HtmlPaddings.only(bottom: 12),
        margin: Margins.zero,
        listStyleType: ListStyleType.none,
      ),
      "ul": Style(
        padding: HtmlPaddings.zero,
        margin: Margins.zero,
      ),
      "p": Style(
        padding: HtmlPaddings.zero,
        margin: Margins.zero,
      ),
    },
    extensions: [
      TagExtension(
        tagsToExtend: {"li"},
        builder: (extensionContext) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    extensionContext.innerHtml.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  )
else ...[
  _buildObjectiveItem("Master the fundamentals of ${cohort.title}"),
  _buildObjectiveItem("Key concepts and practical applications"),
  _buildObjectiveItem("Industry-relevant skills and best practices"),
  if (widget.course.slogan.isNotEmpty)
    _buildObjectiveItem(widget.course.slogan),
],
                            const SizedBox(height: 100), // Space for bottom button
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 3. Floating Enroll Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: enrollmentProvider.isLoading ? null : () async {
                          if (widget.course.isEnrolled) {
                            // Already enrolled, navigate to content
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseContentScreen(
                                  cohortId: widget.cohortId,
                                  courseTitle: cohort.title,
                                  courseDescription: cohort.description,
                                  provider: widget.provider,
                                  courseId: widget.course.id,
                                  categoryId: widget.categoryId,
                                  providerSubtitle: widget.providerSubtitle,
                                  category: widget.course.category.toUpperCase(),
                                  categoryColor: widget.categoryColor,
                                  profileId: widget.profileId,
                                ),
                              ),
                            );
                          } else {
                            
                            final enrollmentData = {
                              "profile_id": widget.profileId ?? 0,
                              "course_id": widget.course.id ?? 0,
                              "course_name": widget.course.courseName,
                              "program_id": widget.categoryId ?? 0, 
                              "enrollment_type": widget.course.isFree ? "free" : "paid",
                              "cohort_name": cohort.title,
                            };

                            try {
                              await enrollmentProvider.enrollUser(enrollmentData, widget.cohortId);

                              // Success, show message and navigate
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enrolled successfully!')),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseContentScreen(
                                      cohortId: widget.cohortId,
                                      courseTitle: cohort.title,
                                      courseDescription: cohort.description,
                                      provider: widget.provider,
                                      courseId: widget.course.id,
                                      categoryId: widget.categoryId,
                                      providerSubtitle: widget.providerSubtitle,
                                      category: widget.course.category.toUpperCase(),
                                      categoryColor: widget.categoryColor,
                                      profileId: widget.profileId,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Enrollment failed: $e')),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: enrollmentProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                'Enroll Now ${cohort.cost}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildObjectiveItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Color(0xFF10B981), // Green color for checks
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
