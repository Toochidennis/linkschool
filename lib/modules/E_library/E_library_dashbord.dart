import 'package:flutter/material.dart';
import 'package:linkschool/modules/e_library/e_lib_detail.dart';
import 'package:linkschool/modules/e_library/cbt.dart';
import 'package:linkschool/modules/e_library/elibrary-ebooks/library_ebook.dart';
import 'package:linkschool/modules/e_library/e_games/gameCard.dart';
import 'package:linkschool/modules/e_library/foryou.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/e_library/e_games/gamesTab.dart';
import 'package:linkschool/modules/explore/games/games_home.dart';

class ElibraryDashboard extends StatefulWidget {
  const ElibraryDashboard({super.key, required this.height});
  final double height;

  @override
  // ignore: library_private_types_in_public_api
  _ElibraryDashboardState createState() => _ElibraryDashboardState();
}

class _ElibraryDashboardState extends State<ElibraryDashboard> {
  final List<Widget> gameItems = [
    GameCard(
      game: 'assets/images/games_1.png',
      gameTitle: 'Overwatch',
      platform: 'Cross-platform',
      rating: 4.5,
      beginColor: AppColors.gamesColor1,
      endColor: AppColors.gamesColor2,
    ),
    GameCard(
      game: 'assets/images/games_2.png',
      gameTitle: 'Boarder lands',
      platform: 'Cross-platform',
      rating: 4.5,
      beginColor: AppColors.gamesColor3,
      endColor: AppColors.gamesColor4,
    ),
    GameCard(
      game: 'assets/images/games_3.png',
      gameTitle: 'Overwatch',
      platform: 'Cross-platform',
      rating: 4.5,
      beginColor: AppColors.gamesColor5,
      endColor: AppColors.gamesColor6,
    ),
    GameCard(
      game: 'assets/images/games_1.png',
      gameTitle: 'Overwatch',
      platform: 'Cross-platform',
      rating: 4.5,
      beginColor: AppColors.gamesColor7,
      endColor: AppColors.gamesColor8,
    ),
    GameCard(
      game: 'assets/images/games_2.png',
      gameTitle: 'Overwatch',
      platform: 'Cross-platform',
      rating: 4.5,
      beginColor: AppColors.gamesColor1,
      endColor: AppColors.gamesColor2,
    )
  ];

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
                                  style:
                                      AppTextStyles.normal600(fontSize: 14))),
                        ),
                        Tab(
                          child: FittedBox(
                              child: Text('CBT',
                                  style:
                                      AppTextStyles.normal600(fontSize: 14))),
                        ),
                        Tab(
                          child: FittedBox(
                              child: Text('E-books',
                                  style:
                                      AppTextStyles.normal600(fontSize: 14))),
                        ),
                        Tab(
                          child: FittedBox(
                              child: Text('Games',
                                  style:
                                      AppTextStyles.normal600(fontSize: 14))),
                        ),
                        Tab(
                          child: Flexible(
                              child: Text('Videos',
                                  style:
                                      AppTextStyles.normal600(fontSize: 14))),
                        ),
                      ]),
                  Expanded(
                      child: TabBarView(children: [
                    buildForYou(gameItems: gameItems, height: widget.height),
                    Expanded(child: E_CBTDashboard()),
                    Expanded(
                      child: LibraryEbook(),
                    ),
                    Expanded(
                      child: GamesTab(),
                    ),
                    Expanded(
                      child: VideoDisplay(),
                    ),
                   
                  ]))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class buildForYou extends StatelessWidget {
  const buildForYou({
    super.key,
    required this.gameItems,
    required this.height,
  });

  final List<Widget> gameItems;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headingWithAdvert(
                tag: 'Video',
                title: 'Continue watching',
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForYouScreen(height: height)));
                },
                child: Text(
                  'new user',
                  style: AppTextStyles.normal600(
                      fontSize: 16, color: AppColors.text2Light),
                ),
              )
            ],
          ),
        ),

        // SizedBox(
        //   height: 8,
        // ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ContinueWatching(),
                _ContinueWatching(),
                _ContinueWatching(),
                _ContinueWatching(),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 25,
        ),
        headingWithAdvert(tag: "Game", title: 'Game Everyone is playing'),
        SizedBox(
          height: 8,
        ),
        Container(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.only(right: 16.0),
            itemCount: gameItems.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return gameItems[index];
            },
          ),
        ),
        SizedBox(
          height: 5,
        ),
        blueHeading(tag: 'E-book', title: 'Suggested for you'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 250,
            width: double.infinity,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _books(
                  image: 'assets/images/book_1.png',
                  bookName: "Sugar Girl",
                  editor: 'UBE Reader Boosters',
                ),
                _books(
                  image: 'assets/images/book_2.png',
                  bookName: "Sugar Girl",
                  editor: 'UBE Reader Boosters',
                ),
                _books(
                  image: 'assets/images/book_3.png',
                  bookName: "Sugar Girl",
                  editor: 'UBE Reader Boosters',
                ),
                _books(
                  image: 'assets/images/book_4.png',
                  bookName: "Sugar Girl",
                  editor: 'UBE Reader Boosters',
                ),
              ],
            ),
          ),
        ),
        blueHeading(
          tag: 'CBT',
          title: 'Continue taking tests',
        ),
        Divider(
          height: 20,
        ),
        Column(
          children: [
            subjectCard(
                subjectIcon: 'maths',
                subjectName: 'Mathematics',
                cardColor: AppColors.cbtCardColor1,
                showProgressIndicator: true),
            Divider(),
            subjectCard(
                subjectIcon: 'english',
                subjectName: 'English Language',
                cardColor: AppColors.cbtCardColor2,
                showProgressIndicator: true),
            Divider(),
            subjectCard(
                subjectIcon: 'chemistry',
                subjectName: 'Chemistry',
                cardColor: AppColors.cbtCardColor3,
                showProgressIndicator: true),
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
            )
          ],
        ),
        SizedBox(
          height: 150,
        )
      ]),
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
  final String image;
  final String bookName;
  final String editor;

  const _books({
    // ignore: unused_element
    super.key,
    required this.image,
    required this.bookName,
    required this.editor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                image: AssetImage(image),
                fit: BoxFit.cover,
              )),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              width: 114,
              child: new LinearProgressIndicator(
                minHeight: 5,
                value: 0.5,
                color: AppColors.text2Light,
              ),
            ),
            Text(
              bookName,
              style: AppTextStyles.normal600(
                  fontSize: 16, color: AppColors.libText),
            ),
            Text(
              editor,
              style: AppTextStyles.normal400(
                  fontSize: 14, color: AppColors.libtitle),
            ),
            SizedBox(
              height: 20,
            ),
          ],
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
          SizedBox(
            width: 10,
          ),
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
          SizedBox(
            width: 10,
          ),
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

Widget _ContinueWatching() {
  return Container(
    height: 147,
    width: 150,
    margin: const EdgeInsets.only(left: 16.0),
    child: Column(
      children: [
        Image.asset(
          'assets/images/video_1.png',
          fit: BoxFit.cover,
          height: 90,
          width: 150,
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Mastering the Act of Video editing',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.normal600(
              fontSize: 14.0,
              color: AppColors.backgroundDark,
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              const CircleAvatar(
                // backgroundImage: NetworkImage(
                //   'profileImageUrl',
                // ),
                backgroundColor: AppColors.videoColor9,
                child: const Icon(Icons.person_2_rounded,
                    size: 13.0, color: Colors.white),
                radius: 8.0,
              ),
              const SizedBox(width: 4.0),
              Text(
                'Dennis Toochi ',
                style: AppTextStyles.normal500(
                  fontSize: 12.0,
                  color: AppColors.videoColor9,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
