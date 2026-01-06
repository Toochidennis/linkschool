import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
import 'package:linkschool/modules/explore/e_library/e_library_ebooks/book_page.dart';
import 'package:linkschool/modules/explore/e_library/e_library_ebooks/library_e_book.dart';
import 'package:linkschool/modules/explore/games/games_home.dart';
import 'package:linkschool/modules/explore/home/library_videos.dart';
import 'package:linkschool/modules/explore/videos/videos_dashboard.dart';
import 'package:linkschool/modules/explore/ebooks/ebooks_dashboard.dart';
import 'package:linkschool/modules/model/explore/home/book_model.dart';
import 'package:linkschool/modules/model/explore/home/game_model.dart';
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';
import 'package:linkschool/modules/services/explore/watch_history_service.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/explore/e_library/e_lib_vids.dart';
import '../../model/explore/home/video_model.dart';
import '../../providers/explore/for_you_provider.dart';
import '../games/game_card.dart';

// Quick Action Item model for navigation cards
class QuickActionItem {
  final String label;
  final String subtitle;
  final String iconPath;
  final Color backgroundColor;
  final Color borderColor;
  final Widget destination;

  const QuickActionItem({
    required this.label,
    required this.subtitle,
    required this.iconPath,
    required this.backgroundColor,
    required this.borderColor,
    required this.destination,
  });
}

class ElibraryDashboard extends StatefulWidget {
  const ElibraryDashboard({super.key, required this.height});
  final double height;

  @override
  _ElibraryDashboardState createState() => _ElibraryDashboardState();
}

class _ElibraryDashboardState extends State<ElibraryDashboard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Video> _watchHistory = [];
  bool _isLoadingHistory = false;
  final ScrollController _scrollController = ScrollController();

  // Define quick action items that navigate to different screens
  late final List<QuickActionItem> _quickActions = [
    QuickActionItem(
      label: 'CBT',
      subtitle: 'Practice tests',
      iconPath: 'assets/icons/cbt.svg',
      backgroundColor: const Color(0xFF6C5CE7),
      borderColor: const Color(0xFF5B4ED1),
      destination: const CBTDashboard(),
    ),
    QuickActionItem(
      label: 'E-Books',
      subtitle: 'Read & learn',
      iconPath: 'assets/icons/e-books.svg',
      backgroundColor: const Color(0xFF00B894),
      borderColor: const Color(0xFF00A383),
      destination: const EbooksDashboard(),
    ),
    QuickActionItem(
      label: 'Videos',
      subtitle: 'Watch tutorials',
      iconPath: 'assets/icons/video.svg',
      backgroundColor: const Color(0xFFE17055),
      borderColor: const Color(0xFFD35843),
      destination: const VideosDashboard(),
    ),
    QuickActionItem(
      label: 'Games',
      subtitle: 'Fun learning',
      iconPath: 'assets/icons/games.svg',
      backgroundColor: const Color(0xFF0984E3),
      borderColor: const Color(0xFF0873C7),
      destination: const GamesDashboard(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ForYouProvider>(context, listen: false).fetchForYouData());
    _loadWatchHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWatchHistory() async {
    setState(() => _isLoadingHistory = true);
    final history = await WatchHistoryService.getWatchHistory(limit: 10);
    setState(() {
      _watchHistory = history;
      _isLoadingHistory = false;
    });
  }

  Future<void> _onVideoTap(Video video) async {
    await WatchHistoryService.addToWatchHistory(video);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => E_lib_vids(video: video),
      ),
    ).then((_) {
      _loadWatchHistory();
    });
  }

  void _navigateTo(Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: Constants.customBoxDecoration(context),
      padding: const EdgeInsets.only(bottom: 90.0),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

          // Library Section Header
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              icon: Icons.local_library_rounded,
              title: 'Library',
            ),
          ),

          // Quick Action Grid with unique design
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 12.0,
                crossAxisCount: 2,
                childAspectRatio: 1.9,
                crossAxisSpacing: 12.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _quickActions[index];
                  return _buildQuickActionCard(item);
                },
                childCount: _quickActions.length,
              ),
            ),
          ),

          // Recommendations Section Header
          // SliverToBoxAdapter(
          //   child: _buildSectionTitle(
          //     icon: Icons.auto_awesome_rounded,
          //     title: 'Recommendations',
          //   ),
          // ),

          // Featured Carousel
          // SliverToBoxAdapter(
          //   child: _buildFeaturedCarousel(),
          // ),

          //const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // For You Content
          SliverToBoxAdapter(
            child: Consumer<ForYouProvider>(
              builder: (context, forYouProvider, child) {
                return Skeletonizer(
                  enabled: forYouProvider.isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Continue Watching Section
                      if (_watchHistory.isNotEmpty) ...[
                        _buildSectionHeader(
                          icon: Icons.history_rounded,
                          title: 'Continue Watching',
                          subtitle: 'Pick up where you left off',
                        ),
                        const SizedBox(height: 12),
                        _buildContinueWatchingList(),
                        const SizedBox(height: 24),
                      ],

                      // Games Section
                      _buildSectionHeader(
                        icon: Icons.sports_esports_rounded,
                        title: 'Popular Games',
                        subtitle: 'Games everyone is playing',
                        onSeeAll: () => _navigateTo(const GamesDashboard()),
                      ),
                      const SizedBox(height: 12),
                      _buildGamesSection(forYouProvider),
                      const SizedBox(height: 24),

                      // E-Books Section
                      _buildSectionHeader(
                        icon: Icons.menu_book_rounded,
                        title: 'Recommended Books',
                        subtitle: 'Curated just for you',
                        onSeeAll: () => _navigateTo(const EbooksDashboard()),
                      ),
                      const SizedBox(height: 12),
                      _buildBooksSection(forYouProvider),

                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.text2Light.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.text2Light,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.normal600(
              fontSize: 20,
              color: AppColors.text2Light,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(QuickActionItem item) {
    return GestureDetector(
      onTap: () => _navigateTo(item.destination),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.backgroundColor,
              item.backgroundColor.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: item.backgroundColor.withOpacity(0.4),
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
                  // Icon in a glass container
                  Center(
                    child: SvgPicture.asset(
                      item.iconPath,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
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
                          item.subtitle,
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
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return CarouselSlider(
      items: [
        _buildFeaturedCard(
          title: 'CBT Practice',
          subtitle: 'Prepare for exams',
          imagePath: 'assets/images/millionaire.png',
          onTap: () => _navigateTo(const CBTDashboard()),
          gradient: [AppColors.exploreButton1Light, AppColors.gamesColor5],
        ),
        _buildFeaturedCard(
          title: 'Video Lessons',
          subtitle: 'Learn at your pace',
          imagePath: 'assets/images/millionaire.png',
          onTap: () => _navigateTo(const VideosDashboard()),
          gradient: [AppColors.exploreButton2Light, AppColors.gamesColor8],
        ),
        _buildFeaturedCard(
          title: 'E-Books Library',
          subtitle: 'Read anywhere',
          imagePath: 'assets/images/millionaire.png',
          onTap: () => _navigateTo(const EbooksDashboard()),
          gradient: [AppColors.exploreButton3Light, AppColors.gamesColor3],
        ),
      ],
      options: CarouselOptions(
        height: 180.0,
        padEnds: false,
        viewportFraction: 0.85,
        autoPlay: true,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _buildFeaturedCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.auto_awesome,
                size: 120,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Featured',
                      style: AppTextStyles.normal500(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: AppTextStyles.normal700(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.normal400(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explore',
                          style: AppTextStyles.normal600(
                            fontSize: 14,
                            color: gradient[0],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: gradient[0],
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
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.text2Light.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.text2Light,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.normal700(
                    fontSize: 18,
                    color: AppColors.backgroundDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.normal400(
                    fontSize: 12,
                    color: AppColors.text5Light,
                  ),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: AppColors.text2Light,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.text2Light,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingList() {
    if (_isLoadingHistory) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _watchHistory.length,
        itemBuilder: (context, index) => _buildContinueWatchingCard(
          video: _watchHistory[index],
          onTap: () => _onVideoTap(_watchHistory[index]),
        ),
      ),
    );
  }

  Widget _buildContinueWatchingCard({
    required Video video,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    video.thumbnail,
                    fit: BoxFit.cover,
                    height: 100,
                    width: 160,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 160,
                        decoration: BoxDecoration(
                          color: AppColors.videoColor9.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 4,
                backgroundColor: AppColors.text6Light,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.text2Light),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal600(
                fontSize: 14,
                color: AppColors.backgroundDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesSection(ForYouProvider forYouProvider) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount:
            forYouProvider.games.isEmpty ? 3 : forYouProvider.games.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final game = forYouProvider.games.isEmpty
              ? Game.empty()
              : forYouProvider.games[index];
          return GameCard(
            game: game,
            beginColor: AppColors.gamesColor1,
            endColor: AppColors.gamesColor2,
          );
        },
      ),
    );
  }

  Widget _buildBooksSection(ForYouProvider forYouProvider) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount:
            forYouProvider.books.isEmpty ? 3 : forYouProvider.books.length,
        itemBuilder: (context, index) {
          final book = forYouProvider.books.isEmpty
              ? Book.empty()
              : forYouProvider.books[index];
          return _BookCard(book: book);
        },
      ),
    );
  }
}

// Modern Book Card Widget
class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (book.title.isNotEmpty) {
          final ebook = Ebook(
            id: book.id,
            title: book.title,
            author: book.author,
            thumbnail: book.thumbnail,
            introduction: book.introduction,
            categories: book.categories,
            chapters: book.chapters,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MybookPage(suggestedbook: ebook),
            ),
          );
        }
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover with shadow and rounded corners
            Container(
              height: 180,
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      book.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.gamesColor9.withAlpha(100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  book.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.normal500(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Reading progress
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 4,
                backgroundColor: AppColors.text6Light,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.text2Light),
              ),
            ),
            const SizedBox(height: 8),
            // Book title
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal600(
                fontSize: 14,
                color: AppColors.backgroundDark,
              ),
            ),
            const SizedBox(height: 2),
            // Author
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal400(
                fontSize: 12,
                color: AppColors.text5Light,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Legacy widgets kept for backward compatibility
Widget subjectCard({
  required String subjectIcon,
  required String subjectName,
  required Color cardColor,
  final String? subjectyear,
  bool showProgressIndicator = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/$subjectIcon.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: AppTextStyles.normal600(
                      fontSize: 16, color: AppColors.backgroundDark),
                ),
                if (subjectyear != null)
                  Text(
                    subjectyear,
                    style: AppTextStyles.normal400(
                        fontSize: 14, color: AppColors.text5Light),
                  ),
                if (showProgressIndicator)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 4,
                        backgroundColor: AppColors.text6Light,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.progressBarLight),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class headingWithAdvert extends StatelessWidget {
  final String tag;
  final String title;

  const headingWithAdvert({
    super.key,
    required this.tag,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.text2Light.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: AppTextStyles.normal500(
                  fontSize: 12, color: AppColors.text2Light),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.normal600(
                fontSize: 16, color: AppColors.backgroundDark),
          )
        ],
      ),
    );
  }
}

class blueHeading extends StatelessWidget {
  final String tag;
  final String title;

  const blueHeading({
    super.key,
    required this.tag,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.text2Light.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: AppTextStyles.normal600(
                  fontSize: 12, color: AppColors.text2Light),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.normal700(
                fontSize: 18, color: AppColors.backgroundDark),
          )
        ],
      ),
    );
  }
}
