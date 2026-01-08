import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/explore/courses/course_provider.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'course_content_screen.dart';

class ExploreCourses extends StatefulWidget {
  const ExploreCourses({Key? key}) : super(key: key);

  @override
  State<ExploreCourses> createState() => _ExploreCoursesState();
}

class _ExploreCoursesState extends State<ExploreCourses> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch categories and courses when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreCourseProvider>().fetchCategoriesAndCourses();
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Fetch categories and courses when the widget is initialized
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<CourseProvider>().fetchCategoriesAndCourses();
  //   });
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper method to get category color based on category name
  Color _getCategoryColor(String categoryName) {
    final colors = {
      'Animation and Storytelling': const Color(0xFF6366F1),
      'Graphic Design and Visual Arts': const Color(0xFFEC4899),
      'Web Development': const Color(0xFF10B981),
      'Programming and Software Development': const Color(0xFF8B5CF6),
      'Artifical Intelligence': const Color(0xFFEF4444),
      'Animation and Creative Media': const Color(0xFFF59E0B),
      'Engineering and Technology': const Color(0xFF06B6D4),
      'Mobile App Development': const Color(0xFF06B6D4),
    };
    return colors[categoryName] ?? const Color(0xFF6366F1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ExploreCourseProvider>(
        builder: (context, courseProvider, child) {
          // Show loading indicator
          if (courseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFA500),
              ),
            );
          }

          // Show error message
          if (courseProvider.errorMessage.isNotEmpty) {
            return Center(
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
                    courseProvider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      courseProvider.fetchCategoriesAndCourses();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (courseProvider.categories.isEmpty) {
            return const Center(
              child: Text(
                'No courses available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          // Show categories and courses
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Loop through each category and display its courses
                ...courseProvider.categories.map((category) {
                  if (category.courses.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Card as Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: _buildCategoryHeaderCard(category),
                      ),

                      const SizedBox(height: 12),

                      // Courses Horizontal List
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: category.courses.length,
                          itemBuilder: (context, index) {
                            return _buildCompactCourseCard(
                                category.courses[index], category);
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeaderCard(CategoryModel category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildCompactCourseCard(CourseModel course, CategoryModel category) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseContentScreen(
                courseTitle: course.courseName,
                courseDescription: course.description,
                provider: category.name,
                courseId: course.id,
                categoryId: category.id,
                providerSubtitle: 'Powered By Digital Dreams',
                category: course.category.toUpperCase(),
                categoryColor: _getCategoryColor(course.category),
              ),
            ),
          );
        },
        child: Container(
          width: 240,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.network(
                      course.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 120,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFFFFA500),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    // Category badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(course.category),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Course Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      Text(
                        course.courseName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Expanded(
                        child: Text(
                          course.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Provider
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFA500), Color(0xFFFF6B00)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'B',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Powered By Digital Dreams',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Take Course Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 32,
                      //   child: OutlinedButton(
                      //     onPressed: () {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text('Starting ${course['title']} course...'),
                      //           duration: const Duration(seconds: 2),
                      //         ),
                      //       );
                      //     },
                      //     style: OutlinedButton.styleFrom(
                      //       side: const BorderSide(color: Color(0xFFFFA500), width: 1.5),
                      //       padding: EdgeInsets.zero,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     child: const Text(
                      //       'Take Course',
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.w700,
                      //         color: Color(0xFFFFA500),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
