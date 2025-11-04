import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
import 'package:linkschool/modules/explore/e_library/e_library_ebooks/library_e_book.dart';
import 'package:linkschool/modules/explore/games/games_home.dart';
import 'package:linkschool/modules/explore/videos/videos_dashboard.dart';
import 'package:linkschool/modules/model/explore/home/book_model.dart';
import 'package:linkschool/modules/model/explore/home/game_model.dart';
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

class _ElibraryDashboardState extends State<ElibraryDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ForYouProvider>(context, listen: false).fetchForYouData());
  }

  @override
  Widget build(BuildContext context) {
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
                                    SizedBox(
                                      height: 180,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: forYouProvider.videos.isEmpty
                                            ? 3
                                            : forYouProvider.videos.length,
                                        itemBuilder: (context, index) =>
                                            _ContinueWatching(
                                          video: forYouProvider.videos.isEmpty
                                              ? Video.empty()
                                              : forYouProvider.videos[index],
                                          context: context,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    // Games section
                                    headingWithAdvert(
                                        tag: "Game",
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
                                        height: 250,
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
                                    blueHeading(
                                        tag: 'CBT',
                                        title: 'Continue taking tests'),
                                    Divider(height: 20),
                                    Column(
                                      children: [
                                        subjectCard(
                                          subjectIcon: 'maths',
                                          subjectName: 'Mathematics',
                                          cardColor: AppColors.cbtCardColor1,
                                          showProgressIndicator: true,
                                        ),
                                        Divider(),
                                        subjectCard(
                                          subjectIcon: 'english',
                                          subjectName: 'English Language',
                                          cardColor: AppColors.cbtCardColor2,
                                          showProgressIndicator: true,
                                        ),
                                        Divider(),
                                        subjectCard(
                                          subjectIcon: 'chemistry',
                                          subjectName: 'Chemistry',
                                          cardColor: AppColors.cbtCardColor3,
                                          showProgressIndicator: true,
                                        ),
                                        Divider(),
                                        subjectCard(
                                          subjectIcon: 'physics',
                                          subjectName: 'Physics',
                                          subjectyear: '2001-2014',
                                          cardColor: AppColors.cbtCardColor4,
                                        ),
                                        Divider(),
                                        subjectCard(
                                          cardColor: AppColors.cbtCardColor5,
                                          subjectIcon: 'further_maths',
                                          subjectName: 'Further Mathematics',
                                          subjectyear: '2001-2023',
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 150),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                            child: CBTDashboard(
                          showAppBar: false,
                        )),
                        Expanded(
                          child: LibraryEbook(),
                        ),
                        Expanded(
                          child: GamesDashboard(
                            showAppBar: false,
                          ),
                        ),
                        Expanded(
                          child: VideosDashboard(
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
      // onTap: () {
      //   if (book.title.isNotEmpty) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => MybookPage(suggestedbook: book),
      //       ),
      //     );
      //   }
      // },
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
                  image: DecorationImage(
                    image: NetworkImage(book.thumbnail),
                    fit: BoxFit.cover,
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

Widget _ContinueWatching(
    {required Video video, required BuildContext context}) {
  return GestureDetector(
    onTap: () {
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
          Image.network(
            video.thumbnail,
            fit: BoxFit.cover,
            height: 90,
            width: 150,
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
