import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
import 'package:linkschool/modules/explore/e_library/e_library_ebooks/book_page.dart';
import 'package:linkschool/modules/explore/e_library/e_library_ebooks/library_e_book.dart';
import 'package:linkschool/modules/explore/games/games_home.dart';
import 'package:linkschool/modules/explore/home/library_videos.dart';
import 'package:linkschool/modules/model/explore/home/book_model.dart';
import 'package:linkschool/modules/model/explore/home/game_model.dart';
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';
import 'package:linkschool/modules/services/explore/watch_history_service.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/explore/e_library/e_lib_vids.dart'; // Import the E_lib_vids screen
import '../../model/explore/home/video_model.dart';
import '../../providers/explore/for_you_provider.dart';
import '../games/game_card.dart';
// Import the MybookPage

class ElibraryDashboard extends StatefulWidget {
  const ElibraryDashboard({super.key, required this.height});
  final double height;

  @override
  _ElibraryDashboardState createState() => _ElibraryDashboardState();
}

class _ElibraryDashboardState extends State<ElibraryDashboard> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  List<Video> _watchHistory = [];
  bool _isLoadingHistory = false;
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ForYouProvider>(context, listen: false).fetchForYouData());
    _loadWatchHistory();
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
    // Add to watch history before navigating
    await WatchHistoryService.addToWatchHistory(video);
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => E_lib_vids(video: video),
      ),
    ).then((_) {
      // Reload watch history when returning
      _loadWatchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AppColors.text2Light,
                    labelColor: AppColors.text2Light,
                    tabs: [
                      Tab(
                          child: FittedBox(
                              child: Text('For you',
                                  style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.text2Light)))),
                      Tab(
                          child: FittedBox(
                              child: Text('CBT',
                                  style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.text2Light)))),
                      Tab(
                          child: FittedBox(
                              child: Text('E-books',
                                  style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.text2Light)))),
                      Tab(
                          child: FittedBox(
                              child: Text('Games',
                                  style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.text2Light)))),
                      Tab(
                          child: Flexible(
                              child: Text('Videos',
                                  style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.text2Light)))),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Consumer<ForYouProvider>(
                            builder: (context, forYouProvider, child) {
                              return Skeletonizer(
                                enabled: forYouProvider.isLoading,
                                child: Column(
                                  children: [
                                    // Continue watching section
                                    headingWithAdvert(
                                        tag: 'Video',
                                        title: 'Continue watching'),
                                    SizedBox(height: 8),
                                    _isLoadingHistory
                                        ? SizedBox(
                                            height: 180,
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          )
                                        : _watchHistory.isEmpty
                                            ? Container(
                                                height: 180,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.history,
                                                      size: 48,
                                                      color: Colors.grey[400],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'No watch history yet',
                                                      style: AppTextStyles.normal400(
                                                        fontSize: 14,
                                                        color: Colors.grey[600]!,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(
                                                height: 180,
                                                child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: _watchHistory.length,
                                                  itemBuilder: (context, index) =>
                                                      _ContinueWatching(
                                                    video: _watchHistory[index],
                                                    context: context,
                                                    onTap: () => _onVideoTap(_watchHistory[index]),
                                                  ),
                                                ),
                                              ),
                                    SizedBox(height: 25),
                                    // Games section
                                    headingWithAdvert(
                                        tag: "Games",
                                        title: 'Game Everyone is playing'),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        itemCount: forYouProvider.games.isEmpty
                                            ? 3
                                            : forYouProvider.games.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          final game =
                                              forYouProvider.games.isEmpty
                                                  ? Game.empty()
                                                  : forYouProvider.games[index];
                                          return GameCard(
                                            game: game,
                                            beginColor: AppColors.gamesColor1,
                                            endColor: AppColors.gamesColor2,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Books section
                                    blueHeading(
                                        tag: 'E-book',
                                        title: 'Suggested for you'),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: SizedBox(
                                        height: 280,
                                        width: double.infinity,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              forYouProvider.books.isEmpty
                                                  ? 3
                                                  : forYouProvider.books.length,
                                          itemBuilder: (context, index) {
                                            final book = forYouProvider
                                                    .books.isEmpty
                                                ? Book.empty()
                                                : forYouProvider.books[index];
                                            return _books(
                                              book:
                                                  book, // Pass the book object
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // CBT section
                                  
                                    SizedBox(height: 80),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                          CBTDashboard(showAppBar: false),
                        Expanded(
                          child: LibraryEbook(),
                        ),
                        Expanded(
                          child: GamesDashboard(
                            showAppBar: false,
                          ),
                        ),
                        Expanded(
                          child: ElibraryVidoes(
                            showAppBar: false,
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
}

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
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(4.0),
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
          SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: AppTextStyles.normal600(
                      fontSize: 18, color: AppColors.backgroundDark),
                ),
                if (subjectyear != null)
                  Text(
                    subjectyear,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                if (showProgressIndicator)
                  Container(
                    width: double.infinity,
                    height: 4,
                    color: Colors.grey,
                    child: LinearProgressIndicator(
                      value: 0.5,
                      color: AppColors.progressBarLight,
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

class _books extends StatelessWidget {
  final Book book;

  const _books({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (book.title.isNotEmpty) {
          // Convert Book to Ebook
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
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 173,
                width: 114,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    book.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 173,
                        width: 114,
                        color: AppColors.videoColor9.withAlpha(50),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white.withOpacity(0.7),
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 114,
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: 0.5,
                  color: AppColors.text2Light,
                ),
              ),
              Text(
                book.title,
                style: AppTextStyles.normal600(
                    fontSize: 16, color: AppColors.libText),
              ),
              Text(
                book.author,
                style: AppTextStyles.normal400(
                    fontSize: 14, color: AppColors.libtitle),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
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
          Text(tag,
              style: AppTextStyles.normal400(
                  fontSize: 12, color: AppColors.libtitle)),
          Icon(
            Icons.circle,
            size: 4,
            color: AppColors.libtitle,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style:
                AppTextStyles.normal500(fontSize: 16, color: AppColors.libText),
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
          Text(tag,
              style: AppTextStyles.normal500(
                  fontSize: 14, color: AppColors.libtitle)),
          Icon(
            Icons.circle,
            size: 8,
            color: AppColors.libtitle,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.normal700(
                fontSize: 18, color: AppColors.titleColor),
          )
        ],
      ),
    );
  }
}

Widget _ContinueWatching({
  required Video video,
  required BuildContext context,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap ?? () {
      if (video.title.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => E_lib_vids(video: video),
          ),
        );
      }
    },
    child: Container(
      height: 147,
      width: 150,
      margin: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              video.thumbnail,
              fit: BoxFit.cover,
              height: 90,
              width: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 90,
                  width: 150,
                  color: AppColors.videoColor9.withAlpha(50),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal600(
                fontSize: 14.0,
                color: AppColors.backgroundDark,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
