import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/E_lib_vids.dart';
import 'package:linkschool/modules/model/explore/home/video_model.dart';
import 'package:linkschool/modules/services/explore/watch_history_service.dart';
import 'package:linkschool/modules/model/explore/videos/dashboard_video_model.dart';
import 'package:linkschool/modules/explore/videos/watch_video.dart';

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  List<Video> _watchHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchHistory();
  }

  Future<void> _loadWatchHistory() async {
    setState(() => _isLoading = true);
    final history = await WatchHistoryService.getWatchHistory();
    setState(() {
      _watchHistory = history;
      _isLoading = false;
    });
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Watch History'),
        content: const Text(
            'Are you sure you want to clear all watch history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await WatchHistoryService.clearWatchHistory();
      _loadWatchHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Watch history cleared'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeVideo(String videoUrl) async {
    await WatchHistoryService.removeFromWatchHistory(videoUrl);
    _loadWatchHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from watch history'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Watch History',
          style: AppTextStyles.normal600(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_watchHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearAllHistory,
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _watchHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Watch History',
                        style: AppTextStyles.normal600(
                          fontSize: 18,
                          color: Colors.grey[600]!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Videos you watch will appear here',
                        style: AppTextStyles.normal400(
                          fontSize: 14,
                          color: Colors.grey[500]!,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _watchHistory.length,
                  itemBuilder: (context, index) {
                    final video = _watchHistory[index];
                    return Dismissible(
                      key: Key(video.url),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _removeVideo(video.url);
                      },
                      child: _buildVideoCard(video),
                    );
                  },
                ),
    );
  }

  Widget _buildVideoCard(Video video) {
    return InkWell(
      onTap: () async {
        // Convert video to DashboardVideoModel and navigate to player
        final index = _watchHistory.indexOf(video);
        final DashboardVideoModel currentVideo = DashboardVideoModel(
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
      child: Container(
        height: 130,
        padding: const EdgeInsets.only(
          left: 16.0,
          top: 16.0,
          right: 8.0,
          bottom: 18,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.newsBorderColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    video.thumbnail,
                    fit: BoxFit.cover,
                    height: 80,
                    width: 108,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 108,
                        color: Colors.grey[300],
                        child: const Icon(Icons.video_library),
                      );
                    },
                  ),
                ),
                Positioned(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.normal500(
                      fontSize: 16.0,
                      color: AppColors.videoColor9,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Watched',
                        style: AppTextStyles.normal400(
                          fontSize: 12.0,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showVideoOptions(video);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoOptions(Video video) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Remove from history',
                style: AppTextStyles.normal500(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeVideo(video.url);
              },
            ),
          ],
        ),
      ),
    );
  }
}
