import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/e_library/E_lib_vids.dart';
import 'package:linkschool/modules/explore/videos/see_all_screen.dart';
import 'package:linkschool/modules/explore/videos/watch_history_screen.dart';
import 'package:linkschool/modules/explore/videos/watch_video.dart';
import 'package:linkschool/modules/explore/videos/course_videos_screen.dart';
import 'package:linkschool/modules/model/explore/home/video_model.dart';
import 'package:linkschool/modules/model/explore/home/subject_model2.dart';
import 'package:linkschool/modules/model/explore/home/level_model.dart';
import 'package:linkschool/modules/model/explore/videos/dashboard_video_model.dart';
import 'package:linkschool/modules/services/explore/watch_history_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../../providers/explore/subject_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../e_library/e_lib_subject_detail.dart';

class VideosDashboard extends StatefulWidget {
  final bool showAppBar;
  final int? levelId;
  final String? levelName;

  const VideosDashboard({
    super.key,
    this.showAppBar = true,
    this.levelId,
    this.levelName,
  });

  @override
  State<VideosDashboard> createState() => _VideosDashboardState();
}

class _VideosDashboardState extends State<VideosDashboard> {
  List<Video> _watchHistory = [];
  bool _isLoadingHistory = false;
  LevelModel? _selectedLevel;
  int? _currentLevelId;

  // Section visibility states
  final bool _showRecommendedVideos = true;
  final bool _showWatchHistory = true;
  final bool _showSubjects = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure provider methods are called after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Fetch levels first
        Provider.of<SubjectProvider>(context, listen: false).fetchLevels();

        // If levelId is provided from navigation, fetch dashboard data
        if (widget.levelId != null) {
          _currentLevelId = widget.levelId;
          Provider.of<SubjectProvider>(context, listen: false)
              .fetchDashboardData(widget.levelId!);
          // Set selected level name if provided
          if (widget.levelName != null) {
            _selectedLevel = LevelModel(
              id: widget.levelId!,
              name: widget.levelName!,
              rank: 0,
            );
          }
        } else {
          // Check if there's a saved level in shared preferences
          final prefs = await SharedPreferences.getInstance();
          final savedLevelId = prefs.getInt('selected_level_id');
          final savedLevelName = prefs.getString('selected_level_name');

          if (savedLevelId != null && savedLevelName != null) {
            // Load saved level
            setState(() {
              _currentLevelId = savedLevelId;
              _selectedLevel = LevelModel(
                id: savedLevelId,
                name: savedLevelName,
                rank: 0,
              );
            });
            Provider.of<SubjectProvider>(context, listen: false)
                .fetchDashboardData(savedLevelId);
          } else {
            // No saved level, load default subjects
            Provider.of<SubjectProvider>(context, listen: false)
                .fetchSubjects();
          }
        }
      }
    });
    _loadWatchHistory();
  }

  Future<void> _loadWatchHistory() async {
    setState(() => _isLoadingHistory = true);
    final history = await WatchHistoryService.getWatchHistory(limit: 10);
    if (mounted) {
      setState(() {
        _watchHistory = history;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _onVideoTap(Video video) async {
    // Add to watch history before navigating
    await WatchHistoryService.addToWatchHistory(video);

    // Navigate to video player
    if (mounted) {
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => E_lib_vids(video: video),
      //   ),
      // );

      // Reload watch history when returning
      _loadWatchHistory();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _navigateToWatchHistory() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WatchHistoryScreen(),
        )).then((_) {
      // Reload watch history when returning
      _loadWatchHistory();
    });
  }

  // Helper method to get color for each subject
  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toUpperCase();
    if (name.contains('MATH')) return Color(0xFFFF6B35);
    if (name.contains('ENGLISH')) return Color(0xFF4A90E2);
    if (name.contains('CHEMISTRY') || name.contains('CHEM'))
      return Color(0xFFFFB84D);
    if (name.contains('BIOLOGY') || name.contains('BIO'))
      return Color(0xFF5CB85C);
    if (name.contains('PHYSICS') || name.contains('PHY'))
      return Color(0xFF6C5CE7);
    if (name.contains('ECONOMICS') || name.contains('ECO'))
      return Color(0xFFE74C3C);
    if (name.contains('GEOGRAPHY') || name.contains('GEO'))
      return Color(0xFF3498DB);
    if (name.contains('HISTORY')) return Color(0xFF9B59B6);
    if (name.contains('LITERATURE') || name.contains('LIT'))
      return Color(0xFF1ABC9C);
    if (name.contains('GOVERNMENT') || name.contains('GOV'))
      return Color(0xFFE67E22);
    if (name.contains('COMMERCE') || name.contains('COM'))
      return Color(0xFF2ECC71);
    if (name.contains('ACCOUNTING') || name.contains('ACC'))
      return Color(0xFFF39C12);
    return Color(0xFF2C3E50); // Default dark color
  }

  // Helper method to get icon for each subject
  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toUpperCase();
    if (name.contains('MATH')) return Icons.functions;
    if (name.contains('ENGLISH')) return Icons.import_contacts;
    if (name.contains('CHEMISTRY') || name.contains('CHEM'))
      return Icons.water_drop;
    if (name.contains('BIOLOGY') || name.contains('BIO')) return Icons.spa;
    if (name.contains('PHYSICS') || name.contains('PHY')) return Icons.bolt;
    if (name.contains('ECONOMICS') || name.contains('ECO'))
      return Icons.show_chart;
    if (name.contains('GEOGRAPHY') || name.contains('GEO'))
      return Icons.language;
    if (name.contains('HISTORY')) return Icons.auto_stories;
    if (name.contains('LITERATURE') || name.contains('LIT'))
      return Icons.auto_stories;
    if (name.contains('GOVERNMENT') || name.contains('GOV')) return Icons.gavel;
    if (name.contains('COMMERCE') || name.contains('COM')) return Icons.store;
    if (name.contains('ACCOUNTING') || name.contains('ACC'))
      return Icons.account_balance_wallet;
    if (name.contains('COMPUTER') || name.contains('ICT'))
      return Icons.computer;
    if (name.contains('ARTS') || name.contains('ART')) return Icons.palette;
    if (name.contains('MUSIC')) return Icons.music_note;
    return Icons.menu_book; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        // Use dashboard data when levelId is provided, otherwise use old subjects data
        final bool useDashboardData = widget.levelId != null;
        final isLoading = useDashboardData
            ? subjectProvider.isLoadingDashboard
            : subjectProvider.isLoading;

        // Get recommended videos based on data source
        final List<dynamic> recommendationVideos = useDashboardData
            ? (subjectProvider.dashboardData?.recommended ?? [])
            : subjectProvider.subjects
                .expand((subject) => subject.categories)
                .expand((category) => category.videos)
                .toList();

        // Get courses/subjects based on data source
        final List<dynamic> courses = useDashboardData
            ? (subjectProvider.dashboardData?.courses ?? [])
            : subjectProvider.subjects;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (mounted) {
                if (_currentLevelId != null) {
                  await Provider.of<SubjectProvider>(context, listen: false)
                      .fetchDashboardData(_currentLevelId!);
                } else {
                  await Provider.of<SubjectProvider>(context, listen: false)
                      .fetchSubjects();
                }
                await _loadWatchHistory();
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Grade Level Dropdown Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _showGradeLevelBottomSheet();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4A90E2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: Color(0xFF4A90E2),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Choose Grade',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedLevel?.name ?? 'Select Grade',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Recommended Videos Section
                if (recommendationVideos.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF4A90E2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Color(0xFF4A90E2),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recommended videos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (recommendationVideos.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Recommended Videos Horizontal List
                if (recommendationVideos.isNotEmpty)
                  SliverToBoxAdapter(
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )
                        : recommendationVideos.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Center(
                                  child: Text(
                                    'No videos available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recommendationVideos.length,
                                  itemBuilder: (context, index) {
                                    if (useDashboardData) {
                                      // Using dashboard video model
                                      final video = recommendationVideos[index]
                                          as DashboardVideoModel;
                                      return GestureDetector(
                                        onTap: () {
                                          // Navigate to video player with recommended videos
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VideoWatchScreen(
                                                initialVideo: video,
                                                relatedVideos:
                                                    recommendationVideos.cast<
                                                        DashboardVideoModel>(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildDashboardVideoCard(video),
                                      );
                                    } else {
                                      // Using old video model
                                      final video =
                                          recommendationVideos[index] as Video;
                                      return GestureDetector(
                                        onTap: () => _onVideoTap(video),
                                        child:
                                            _buildRecommendedVideoCard(video),
                                      );
                                    }
                                  },
                                ),
                              ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Recently Watched Topics Section
                if (_watchHistory.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF5CB85C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: Color(0xFF5CB85C),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recently watched topics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _navigateToWatchHistory,
                            child: Text(
                              'See all',
                              style: TextStyle(
                                color: Color(0xFF4A90E2),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Watch History Horizontal List
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _watchHistory.length,
                        itemBuilder: (context, index) {
                          final video = _watchHistory[index];
                          return GestureDetector(
                            onTap: () async {
                              print(
                                  'Watch history video tapped: ${video.title}');

                              // Convert watch history to DashboardVideoModel format
                              final DashboardVideoModel currentVideo =
                                  DashboardVideoModel(
                                id: index,
                                title: video.title,
                                videoUrl: video.url,
                                thumbnailUrl: video.thumbnail,
                                courseId: 0,
                                levelId: 0,
                                courseName: '',
                                levelName: '',
                                syllabusName: '',
                                syllabusId: 0,
                                description: video.description ?? '',
                                authorName: '',
                              );

                              // Convert all watch history videos to DashboardVideoModel
                              final List<DashboardVideoModel> allHistoryVideos =
                                  _watchHistory.map((v) {
                                final idx = _watchHistory.indexOf(v);
                                return DashboardVideoModel(
                                  id: idx,
                                  title: v.title,
                                  videoUrl: v.url,
                                  thumbnailUrl: v.thumbnail,
                                  courseId: 0,
                                  levelId: 0,
                                  courseName: '',
                                  levelName: '',
                                  syllabusName: '',
                                  syllabusId: 0,
                                  description: v.description ?? '',
                                  authorName: '',
                                );
                              }).toList();

                              print(
                                  'Navigating to player with ${allHistoryVideos.length} videos');

                              // Navigate to video player
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoWatchScreen(
                                    initialVideo: currentVideo,
                                    relatedVideos: allHistoryVideos,
                                  ),
                                ),
                              );

                              // Reload watch history when returning
                              _loadWatchHistory();
                            },
                            child: _buildWatchHistoryListItem(video),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // Subjects Section Header
                if (courses.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.school,
                                    color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Subjects',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Subject Cards List - Real subjects
                if (courses.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: isLoading
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (useDashboardData) {
                                  // Using dashboard courses
                                  final course =
                                      courses[index] as DashboardCourseModel;
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigate to course videos screen (syllabus organized)
                                      if (_currentLevelId != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CourseVideosScreen(
                                              courseId: course.id.toString(),
                                              levelId:
                                                  _currentLevelId.toString(),
                                              courseName: course.courseName,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _buildSubjectListCard({
                                        'name': course.courseName,
                                        'color':
                                            _getSubjectColor(course.courseName),
                                        'icon':
                                            _getSubjectIcon(course.courseName),
                                      }),
                                    ),
                                  );
                                } else {
                                  // Using old subjects structure
                                  final subject =
                                      courses[index] as SubjectModel2;
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => ELibSubjectDetail(subject: subject),
                                      //   ),
                                      // );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _buildSubjectListCard({
                                        'name': subject.name,
                                        'color': _getSubjectColor(subject.name),
                                        'icon': _getSubjectIcon(subject.name),
                                      }),
                                    ),
                                  );
                                }
                              },
                              childCount:
                                  courses.length > 6 ? 6 : courses.length,
                            ),
                          ),
                  ),

                if (courses.isEmpty && !isLoading)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No courses available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  // New widget methods matching the design
  Widget _buildSubjectListCard(Map<String, dynamic> subject) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (subject['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              subject['icon'] as IconData,
              color: subject['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Subject name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to explore',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            subject['color'],
            (subject['color'] as Color).withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (subject['color'] as Color).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle pattern
          Positioned(
            right: -15,
            top: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: -25,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 2,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Icon in the center
                // Center(
                //   child: Icon(
                //     subject['icon'],
                //     color: Colors.white,
                //     size: 24,
                //   ),
                // ),
                const SizedBox(width: 10),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        subject['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist',
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Explore topic',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedVideoCard(Video video) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  video.thumbnail,
                  height: 100,
                  width: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 160,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '12:45',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Color(0xFF4A90E2),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardVideoCard(DashboardVideoModel video) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  video.thumbnailUrl ?? '',
                  height: 100,
                  width: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 160,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Color(0xFF4A90E2),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            video.courseName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchHistoryListItem(Video video) {
    return Container(
      width: 340,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail section
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Stack(
              children: [
                // Thumbnail image
                Image.network(
                  video.thumbnail,
                  height: 120,
                  width: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: 140,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.video_library_outlined,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    );
                  },
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // Play button
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF5CB85C),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Video details section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  // Description or category
                  if (video.description != null &&
                      video.description!.isNotEmpty)
                    Text(
                      video.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 8),
                  // Watched badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF5CB85C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 12,
                          color: Color(0xFF5CB85C),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Watched',
                          style: TextStyle(
                            color: Color(0xFF5CB85C),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildWatchHistoryHorizontalCard(Video video) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                Image.network(
                  video.thumbnail,
                  height: 120,
                  width: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: 280,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    );
                  },
                ),
                // Dark overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Color(0xFF5CB85C),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Video details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Recently watched',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
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

  void _showGradeLevelBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<SubjectProvider>(
          builder: (context, provider, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Choose Grade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Grade levels list
                  Flexible(
                    child: provider.isLoadingLevels
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : provider.levels.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'No levels available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: provider.levels.length,
                                itemBuilder: (context, index) {
                                  final level = provider.levels[index];
                                  final isSelected =
                                      _selectedLevel?.id == level.id;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Material(
                                      color: isSelected
                                          ? Color(0xFFFF6B35)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () async {
                                          setState(() {
                                            _selectedLevel = level;
                                            _currentLevelId = level.id;
                                          });

                                          // Save to shared preferences
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.setInt(
                                              'selected_level_id', level.id);
                                          await prefs.setString(
                                              'selected_level_name',
                                              level.name);

                                          // Fetch dashboard data for selected level
                                          Provider.of<SubjectProvider>(context,
                                                  listen: false)
                                              .fetchDashboardData(level.id);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.grey[400]!,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  level.name,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),

                  // Continue button (removed since selection now auto-triggers)
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
