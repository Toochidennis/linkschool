import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/e_library/E_lib_vids.dart';
import 'package:linkschool/modules/explore/videos/see_all_screen.dart';
import 'package:linkschool/modules/explore/videos/watch_history_screen.dart';
import 'package:linkschool/modules/model/explore/home/video_model.dart';
import 'package:linkschool/modules/services/explore/watch_history_service.dart';
import 'package:provider/provider.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../../providers/explore/subject_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../e_library/e_lib_subject_detail.dart';

class VideosDashboard extends StatefulWidget {
  final bool showAppBar;
  const VideosDashboard({super.key, this.showAppBar = true});

  @override
  State<VideosDashboard> createState() => _VideosDashboardState();
}

class _VideosDashboardState extends State<VideosDashboard> {
  List<Video> _watchHistory = [];
  bool _isLoadingHistory = false;
  String _selectedLevel = 'Primary 5';

  // Available grade levels
  final List<String> _gradeLevels = [
    'Primary 1',
    'Primary 2',
    'Primary 3',
    'Primary 4',
    'Primary 5',
    'Primary 6',
    'JS 1',
    'JS 2',
    'JS 3',
    'SS 1',
    'SS 2',
    'SS 3 WAEC',
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => E_lib_vids(video: video),
        ),
      );
      
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
    if (name.contains('CHEMISTRY') || name.contains('CHEM')) return Color(0xFFFFB84D);
    if (name.contains('BIOLOGY') || name.contains('BIO')) return Color(0xFF5CB85C);
    if (name.contains('PHYSICS') || name.contains('PHY')) return Color(0xFF6C5CE7);
    if (name.contains('ECONOMICS') || name.contains('ECO')) return Color(0xFFE74C3C);
    if (name.contains('GEOGRAPHY') || name.contains('GEO')) return Color(0xFF3498DB);
    if (name.contains('HISTORY')) return Color(0xFF9B59B6);
    if (name.contains('LITERATURE') || name.contains('LIT')) return Color(0xFF1ABC9C);
    if (name.contains('GOVERNMENT') || name.contains('GOV')) return Color(0xFFE67E22);
    if (name.contains('COMMERCE') || name.contains('COM')) return Color(0xFF2ECC71);
    if (name.contains('ACCOUNTING') || name.contains('ACC')) return Color(0xFFF39C12);
    return Color(0xFF2C3E50); // Default dark color
  }

  // Helper method to get icon for each subject
  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toUpperCase();
    if (name.contains('MATH')) return Icons.functions;
    if (name.contains('ENGLISH')) return Icons.import_contacts;
    if (name.contains('CHEMISTRY') || name.contains('CHEM')) return Icons.water_drop;
    if (name.contains('BIOLOGY') || name.contains('BIO')) return Icons.spa;
    if (name.contains('PHYSICS') || name.contains('PHY')) return Icons.bolt;
    if (name.contains('ECONOMICS') || name.contains('ECO')) return Icons.show_chart;
    if (name.contains('GEOGRAPHY') || name.contains('GEO')) return Icons.language;
    if (name.contains('HISTORY')) return Icons.auto_stories;
    if (name.contains('LITERATURE') || name.contains('LIT')) return Icons.auto_stories;
    if (name.contains('GOVERNMENT') || name.contains('GOV')) return Icons.gavel;
    if (name.contains('COMMERCE') || name.contains('COM')) return Icons.store;
    if (name.contains('ACCOUNTING') || name.contains('ACC')) return Icons.account_balance_wallet;
    if (name.contains('COMPUTER') || name.contains('ICT')) return Icons.computer;
    if (name.contains('ARTS') || name.contains('ART')) return Icons.palette;
    if (name.contains('MUSIC')) return Icons.music_note;
    return Icons.menu_book; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        final allVideos = subjectProvider.subjects
            .expand((subject) => subject.categories)
            .expand((category) => category.videos)
            .toList();

        final recommendationVideos = allVideos.length > 6
            ? allVideos.sublist(0, 6)
            : allVideos;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
         automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.black87),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.black87),
                onPressed: () {},
              ),
            ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Kamso',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
                _loadWatchHistory();
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        _selectedLevel,
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

                // Report & Analysis Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.assessment, color: Colors.blue, size: 20),
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
                    ),
                  ),
                ),

                // Subject Cards Grid (2x3) - Real subjects
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subject = subjectProvider.subjects[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ELibSubjectDetail(subject: subject),
                              ),
                            );
                          },
                          child: _buildSubjectCard({
                            'name': subject.name,
                            'color': _getSubjectColor(subject.name),
                           // 'icon': _getSubjectIcon(subject.name),
                          }),
                        );
                      },
                      childCount: subjectProvider.subjects.length > 6 ? 6 : subjectProvider.subjects.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Recommended Videos Section
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

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Recommended Videos Horizontal List
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendationVideos.length,
                      itemBuilder: (context, index) {
                        final video = recommendationVideos[index];
                        return GestureDetector(
                          onTap: () => _onVideoTap(video),
                          child: _buildRecommendedVideoCard(video),
                        );
                      },
                    ),
                  ),
                ),

               // const SliverToBoxAdapter(child: SizedBox(height: 24)),

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

                  // Watch History Vertical List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final video = _watchHistory[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _onVideoTap(video),
                              child: _buildWatchHistoryListItem(video),
                            ),
                          );
                        },
                        childCount: _watchHistory.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  // New widget methods matching the design
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  Widget _buildWatchHistoryListItem(Video video) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Stack(
              children: [
                Image.network(
                  video.thumbnail,
                  height: 90,
                  width: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 90,
                      width: 120,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.grey[600],
                        size: 32,
                      ),
                    );
                  },
                ),
                // Play button overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 90,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                    ),
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
                ),
                // Duration badge
              //  if (video. != null)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.title!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  //if (video.description != null)
                    Text(
                      video.title!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
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
          ),
          
          // More options
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {
                // Show options menu
              },
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
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _gradeLevels.length,
                  itemBuilder: (context, index) {
                    final level = _gradeLevels[index];
                    final isSelected = level == _selectedLevel;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isSelected 
                            ? Color(0xFFFF6B35) 
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedLevel = level;
                            });
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
                                    level,
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
              
              // Continue button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF6C5CE7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A90E2).withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'CONTINUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}

