import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'course_detail_screen.dart';

class ExploreCourses extends StatefulWidget {
  const ExploreCourses({Key? key}) : super(key: key);

  @override
  State<ExploreCourses> createState() => _ExploreCoursesState();
}

class _ExploreCoursesState extends State<ExploreCourses> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Sample categories data
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'AI Storytelling Bootcamp',
      'icon': Icons.auto_stories,
      'color': const Color(0xFFE0E0E0),
      'badgeText': 'Free',
      'badgeColor': const Color(0xFFFFCDD2),
      'coursesCount': 1,
    },
    {
      'name': 'AI Explorers Bootcamp',
      'icon': Icons.explore,
      'color': const Color(0xFFFFF9C4),
      'badgeText': 'Free',
      'badgeColor': const Color(0xFFFFCDD2),
      'coursesCount': 1,
    },
    {
      'name': 'Kids Coding BootCamp',
      'icon': Icons.code,
      'color': const Color(0xFFE1BEE7),
      'badgeText': 'Paid',
      'badgeColor': const Color(0xFFFFCDD2),
      'coursesCount': 7,
    },
    {
      'name': 'Kids Weekend CodeLab',
      'icon': Icons.laptop_mac,
      'color': const Color(0xFFE0E0E0),
      'badgeText': 'Paid',
      'badgeColor': const Color(0xFFFFCDD2),
      'coursesCount': 3,
    },
  ];

  // Sample courses data with random images
  final List<Map<String, dynamic>> _allCourses = [
    {
      'title': 'Scratch Programming',
      'category': 'ANIMATION AND STORYTELLING',
      'categoryColor': const Color(0xFF6366F1),
      'description':
          'An engaging way to explore coding concepts through colorful blocks, where creativity meets logic in building games, stories, and animations—perfect for young minds taking their first steps into programming.',
      'provider': 'Kids Coding BootCamp',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=1',
      'categoryIndex': 0,
    },
    {
      'title': 'Graphics Design',
      'category': 'GRAPHIC DESIGN AND VISUAL ARTS',
      'categoryColor': const Color(0xFFEC4899),
      'description':
          'A creative blend of visuals and ideas that communicate messages through color, shape, and layout—turning imagination into beautiful designs.',
      'provider': 'Kids Coding BootCamp',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=2',
      'categoryIndex': 1,
    },
    {
      'title': 'Web Development',
      'category': 'WEB DEVELOPMENT',
      'categoryColor': const Color(0xFF10B981),
      'description':
          'The craft of shaping digital experiences - bringing ideas to life on the web through structure, style, and interactivity.',
      'provider': 'Kids Coding BootCamp',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=3',
      'categoryIndex': 2,
    },
    {
      'title': 'Python Programming',
      'category': 'PROGRAMMING AND SOFTWARE DEVELOPMENT',
      'categoryColor': const Color(0xFF8B5CF6),
      'description':
          'A powerful and versatile language that\'s perfect for beginners and professionals alike: unlock the potential to build apps, automate tasks, and explore data science with ease.',
      'provider': 'Kids Coding bootCamp',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=4',
      'categoryIndex': 2,
    },
    {
      'title': 'Game Development',
      'category': 'ANIMATION AND STORYTELLING',
      'categoryColor': const Color(0xFFF59E0B),
      'description':
          'Create immersive worlds and interactive experiences through code, design, and creativity.',
      'provider': 'Kids Coding BootCamp',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=5',
      'categoryIndex': 3,
    },
    {
      'title': 'Mobile App Development',
      'category': 'PROGRAMMING AND SOFTWARE DEVELOPMENT',
      'categoryColor': const Color(0xFF06B6D4),
      'description':
          'Build powerful mobile applications for iOS and Android platforms using modern frameworks.',
      'provider': 'Kids Weekend CodeLab',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=6',
      'categoryIndex': 3,
    },
    {
      'title': 'AI & Machine Learning',
      'category': 'AI EXPLORERS BOOTCAMP',
      'categoryColor': const Color(0xFFEF4444),
      'description':
          'Explore artificial intelligence and machine learning concepts to build smart applications.',
      'provider': 'AI Explorers Bootcamp',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=7',
      'categoryIndex': 1,
    },
    {
      'title': 'Creative Writing with AI',
      'category': 'AI STORYTELLING',
      'categoryColor': const Color(0xFF8B5CF6),
      'description':
          'Learn to craft compelling stories and narratives using AI-powered tools and techniques.',
      'provider': 'AI Storytelling Bootcamp',
      'providerSubtitle': 'Powered By Digital Dreams',
      'imageUrl': 'https://picsum.photos/400/300?random=8',
      'categoryIndex': 0,
    },
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    return _allCourses
        .where((course) => course['categoryIndex'] == _selectedCategoryIndex)
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Categories Section Header
            // const Padding(
            //   padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            //   child: Text(
            //     'Categories',
            //     style: TextStyle(
            //       fontSize: 24,
            //       fontWeight: FontWeight.w700,
            //       color: Colors.black87,
            //     ),
            //   ),
            // ),

            // Loop through each category and display its courses
            ...List.generate(_categories.length, (categoryIndex) {
              final category = _categories[categoryIndex];
              final categoryCourses = _allCourses
                  .where((course) => course['categoryIndex'] == categoryIndex)
                  .toList();

              if (categoryCourses.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Card as Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildCategoryHeaderCard(categoryIndex, category),
                  ),

                  const SizedBox(height: 12),

                  // Courses Horizontal List
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categoryCourses.length,
                      itemBuilder: (context, index) {
                        return _buildCompactCourseCard(categoryCourses[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeaderCard(int index, Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category['name'] as String,
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

  Widget _buildCompactCourseCard(Map<String, dynamic> course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              courseTitle: course['title'] as String,
              courseDescription: course['description'] as String,
              provider: course['provider'] as String,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.network(
                  course['imageUrl'] as String,
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
                          color: const Color(0xFF6366F1),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: course['categoryColor'] as Color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course['category'] as String,
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
                    course['title'] as String,
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
                      course['description'] as String,
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
                              course['provider'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              course['providerSubtitle'] as String,
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