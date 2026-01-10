import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/videos/dashboard_video_model.dart';
import 'package:linkschool/modules/providers/explore/videos/video_provider.dart';
import 'package:linkschool/modules/explore/videos/watch_video.dart';

class CourseVideosScreen extends StatefulWidget {
  final String courseId;
  final String levelId;
  final String courseName;

  const CourseVideosScreen({
    super.key,
    required this.courseId,
    required this.levelId,
    required this.courseName,
  });

  @override
  State<CourseVideosScreen> createState() => _CourseVideosScreenState();
}

class _CourseVideosScreenState extends State<CourseVideosScreen> {
  bool _isLoading = false;
  final List<DashboardVideoModel> _allVideos = [];
  final Map<String, List<DashboardVideoModel>> _videosBySyllabus = {};

  @override
  void initState() {
    super.initState();
    _loadCourseVideos();
  }

  Future<void> _loadCourseVideos() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<CourseVideoProvider>(context, listen: false);
      await provider.loadCourseVideos(
        courseId: widget.courseId,
        levelId: widget.levelId,
      );

      if (provider.courses.isNotEmpty) {
        // Convert and flatten all videos from all courses and syllabi
        for (var course in provider.courses) {
          for (var syllabus in course.syllabi) {
            if (syllabus.videos.isNotEmpty) {
              // Convert VideoModel to DashboardVideoModel
              final convertedVideos = syllabus.videos.map((video) {
                return DashboardVideoModel(
                  id: syllabus.videos.indexOf(video),
                  title: video.title,
                  videoUrl: video.videoUrl,
                  thumbnailUrl: video.thumbnailUrl,
                  courseId: course.courseId,
                  levelId: 0,
                  courseName: course.courseName,
                  // levelName: course.levelName,
                  levelName: '',
                  syllabusName: syllabus.syllabusName,
                  syllabusId: syllabus.syllabusId,
                  description: video.description,
                  authorName: video.authorName,
                );
              }).toList();

              _allVideos.addAll(convertedVideos);
              _videosBySyllabus[syllabus.syllabusName] = convertedVideos;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading course videos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load videos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _playVideo(DashboardVideoModel video) {
    // Convert all videos to DashboardVideoModel format
    final List<DashboardVideoModel> allVideosFormatted = _allVideos.map((v) {
      return DashboardVideoModel(
        id: v.id,
        title: v.title,
        videoUrl: v.videoUrl,
        thumbnailUrl: v.thumbnailUrl,
        courseId: v.courseId,
        levelId: v.levelId,
        courseName: v.courseName,
        levelName: v.levelName,
        syllabusName: v.syllabusName,
        syllabusId: v.syllabusId,
        description: v.description,
        authorName: v.authorName,
      );
    }).toList();

    // Navigate to video player with all videos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoWatchScreen(
          initialVideo: video,
          relatedVideos: allVideosFormatted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.courseName,
          style: AppTextStyles.normal600(
            fontSize: 18,
            color: AppColors.backgroundDark,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.text2Light,
              ),
            )
          : _videosBySyllabus.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No videos available',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCourseVideos,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _videosBySyllabus.entries.map((entry) {
                      return _buildSyllabusSection(
                        entry.key,
                        entry.value,
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildSyllabusSection(
    String syllabusName,
    List<DashboardVideoModel> videos,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Syllabus header - matching video dashboard style
        // Replace your _buildSyllabusSection header section with this:

        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Add Expanded here to constrain the width
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.video_library_rounded,
                        color: const Color(0xFF6C5CE7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      // Add Expanded here too
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            syllabusName,
                            maxLines: 2,
                            // overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${videos.length} video${videos.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
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
        ),

        // Videos list
        ...videos.map((video) => _buildVideoCard(video)),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVideoCard(DashboardVideoModel video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Image.network(
                    video.thumbnailUrl ?? '',
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 90,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey[600],
                          size: 40,
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
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: AppColors.text2Light,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: AppTextStyles.normal600(
                        fontSize: 14,
                        color: AppColors.backgroundDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (video.description.isNotEmpty)
                      Text(
                        video.description,
                        style: AppTextStyles.normal400(
                          fontSize: 12,
                          color: Colors.grey[600]!,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.authorName.isNotEmpty
                                ? video.authorName
                                : 'Unknown',
                            style: AppTextStyles.normal400(
                              fontSize: 11,
                              color: Colors.grey[600]!,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow icon
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
