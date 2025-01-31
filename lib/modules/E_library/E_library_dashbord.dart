import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/modules/E_library/cbt.dart';
import 'package:linkschool/modules/E_library/gameCard.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/search_bar.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class ElibraryDashboard extends StatefulWidget {
  const ElibraryDashboard({super.key, required this.height});
  final double height;

  @override
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
                        Tab(text: 'for you'),
                        Tab(text: 'CBT'),
                        Tab(text: 'E-books'),
                        Tab(text: 'Games'),
                        Tab(text: 'Videos'),
                      ]),
                  Expanded(
                      child: TabBarView(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          CustomSearchBar(),
                          headingWithAdvert(
                            tag: 'Video',
                            title: 'Continue watching',
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
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
                          SizedBox(
                            height: 5,
                          ),
                          headingWithAdvert(
                              tag: "game", title: 'game Everyone is playing'),
                          SizedBox(
                            height: 10,
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
                            height: 10,
                          ),
                          blueHeading(
                              tag: 'E-book', title: 'Suggested for you'),
                          Container(
                            height: 250,
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
      subjectyear: '2001-2014',
      cardColor: AppColors.cbtCardColor1,
    ),
    Divider(),
    subjectCard(
      subjectIcon: 'english',
      subjectName: 'English Language',
      subjectyear: '2001-2014',
      cardColor: AppColors.cbtCardColor2,
    ),
     Divider(),
   subjectCard(
      subjectIcon: 'chemistry',
      subjectName: 'Chemistry',
      subjectyear: '2001-2014',
      cardColor: AppColors.cbtCardColor3,
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
      subjectIcon:'further_maths',
      subjectName: 'Further Mathematics',
      subjectyear: '2001-2023',

    )
                          ],
                        ),
                         
                          SizedBox(
                            height: 150,
                          )
                        ]),
                      ),
                    ),
                    Expanded(child: CBT_Dashboard()),
                    Center(
                      child: Text('Page for Cbt'),
                    ),
                    Center(
                      child: Text('page for E_book'),
                    ),
                    Center(
                      child: Text('page for game Games'),
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




  Widget subjectCard({
    required String subjectIcon,
    required String subjectName,
    required Color cardColor,
    final String? subjectyear,
    bool showProgressIndicator = false,
  }) {
    return Container(
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
              color:cardColor,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style:AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundDark),
                ),
                Text(
                  subjectyear!,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey),
                ),

        
              ],
            ),
          ),
        ],
      ),
    );
  }


class _books extends StatelessWidget {
  final String image;
  final String bookName;
  final String editor;

  const _books({
    super.key,
    required this.image,
    required this.bookName,
    required this.editor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: 120,
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
            width: 120,
            child: new LinearProgressIndicator(
              minHeight: 5,
              value: 40,
              color: AppColors.text2Light,
            ),
          ),
          Text(
            bookName,
            style:
                AppTextStyles.normal600(fontSize: 16, color: AppColors.libText),
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
    return Row(
      children: [
        Text(tag,
            style: AppTextStyles.normal400(
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
          style:
              AppTextStyles.normal700(fontSize: 18, color: AppColors.libText),
        )
      ],
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
    return Row(
      children: [
        Text(tag,
            style: AppTextStyles.normal400(
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
    );
  }
}

Widget _ContinueWatching() {
  return Container(
    height: 180,
    width: 180,
    margin: const EdgeInsets.only(left: 16.0),
    child: Column(
      children: [
        Image.asset(
          'assets/images/video_1.png',
          fit: BoxFit.cover,
          height: 100, // Adjust the height of the image as needed
          width: double.infinity,
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Mastering the Act of Video editing',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.normal500(
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
                backgroundImage: NetworkImage('profileImageUrl'),
                radius: 10.0,
              ),
              const SizedBox(width: 4.0),
              Text(
                'Toochi Dennis',
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
