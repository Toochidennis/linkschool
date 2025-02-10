import 'package:flutter/material.dart';
import 'package:linkschool/modules/E_library/e_games/gameCard.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/e_library/e_games/gamesTab.dart';
// import 'package:linkschool/modules/explore/games/games_home.dart';

// import 'package:linkschool/modules/E_library/e_games/gameCard.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/e_library/e_games/gamesTab.dart';
// import 'package:linkschool/modules/explore/games/games_home.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key, required this.height});
  final double height;

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
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

  final categories = [
    _buildCategoriesCard(
      subjectName: 'English',
      examIcon: "english",
      backgroundColor: AppColors.videoColor1,
    ),
    _buildCategoriesCard(
      subjectName: 'Mathematics',
      examIcon: "maths",
      backgroundColor: AppColors.videoColor2,
    ),
    _buildCategoriesCard(
      subjectName: 'Chemistry',
      examIcon: "chemistry",
      backgroundColor: AppColors.videoColor3,
    ),
    _buildCategoriesCard(
      subjectName: 'Physics',
      examIcon: "physics",
      backgroundColor: AppColors.videoColor4,
    ),
    _buildCategoriesCard(
      subjectName: 'Further Maths',
      examIcon: "further_maths",
      backgroundColor: AppColors.videoColor5,
    ),
    _buildCategoriesCard(
      subjectName: 'Biology',
      examIcon: "biology",
      backgroundColor: AppColors.videoColor6,
    ),
    _buildCategoriesCard(
      subjectName: 'Geography',
      examIcon: "geography",
      backgroundColor: AppColors.videoColor7,
    ),
    _buildCategoriesCard(
      subjectName: 'Agric',
      examIcon: "agric",
      backgroundColor: AppColors.videoColor8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.examCard,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Container(
                      height: 100,
                      width: 100,
                      child: categories[index],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  headingWithAdvert(
                    tag: 'Video',
                    title: 'Continue watching',
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Old user',
                      style: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.text2Light),
                    ),
                  )
                ],
              ),
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
            ],
          ),
        )),
      ),
    );
  }
}

class buildForYou extends StatelessWidget {
  buildForYou({
    super.key,
    required this.gameItems,
  });

  final List<Widget> gameItems;

 

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
       

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: headingWithAdvert(
            tag: 'Video',
            title: 'Continue watching',
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
                backgroundImage: NetworkImage(
                  'profileImageUrl',
                ),
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

Widget _buildCategoriesCard({
  required String subjectName,
  required String examIcon,
  required Color backgroundColor,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 60,
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          image: DecorationImage(
            image: AssetImage('assets/icons/$examIcon.png'),
            fit: BoxFit.contain,
          ),
        ),
        
      ),
      const SizedBox(height: 8.0),
      Text(
        subjectName,
        style: AppTextStyles.normal500(fontSize: 12.0, color: Colors.black),
      )
    ],
  );
}
