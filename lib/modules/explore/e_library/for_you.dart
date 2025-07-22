import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/cbt.dart';
import 'package:linkschool/modules/explore/e_library/e_games/gamesTab.dart';
import 'package:linkschool/modules/explore/e_library/e_lib_vids.dart';
import 'package:linkschool/modules/explore/e_library/e_library_ebooks/library_e_book.dart';
import 'package:linkschool/modules/explore/videos/videos_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../model/explore/home/book_model.dart';
import '../../model/explore/home/game_model.dart';
import '../../model/explore/home/video_model.dart';
import '../../providers/explore/for_you_provider.dart';
import '../games/game_card.dart';



class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key, required this.height});
  final double height;

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ForYouProvider>(context, listen: false).fetchForYouData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.paymentTxtColor1,
        title: SvgPicture.asset('assets/icons/linkskool-logo.svg'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/notifications.svg',
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          )
        ],
        elevation: 0,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: DefaultTabController(
          length: 5,
          child: Column(
            children: [
              TabBar(
                indicatorColor: AppColors.text2Light,
                labelColor: AppColors.text2Light,
                tabs: [
                  Tab(child: FittedBox(child: Text('For you', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light)))),
                  Tab(child: FittedBox(child: Text('CBT', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light)))),
                  Tab(child: FittedBox(child: Text('E-books', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light)))),
                  Tab(child: FittedBox(child: Text('Games', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light)))),
                  Tab(child: Flexible(child: Text('Videos', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light)))),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(child: ForYouContent()),
                    Expanded(child: E_CBTDashboard()),
                    Expanded(child: LibraryEbook()),
                    Expanded(child: GamesTab()),
                    Expanded(child: VideosDashboard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForYouContent extends StatelessWidget {
  const ForYouContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForYouProvider>(
      builder: (context, forYouProvider, child) {
        print('Is Loading: ${forYouProvider.isLoading}'); // Debug log
        return Skeletonizer(
          enabled: forYouProvider.isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoriesSection(),
              _buildContinueWatchingSection(forYouProvider.videos),
              _buildGamesSection(forYouProvider.games),
              _buildBooksSection(forYouProvider.books),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      _buildCategoriesCard(subjectName: 'Agric', examIcon: "Agric"),
      _buildCategoriesCard(subjectName: 'BECE', examIcon: "BECE"),
      _buildCategoriesCard(subjectName: 'GCE', examIcon: "GCE"),
      _buildCategoriesCard(subjectName: 'IELTS', examIcon: "IELTS"),
      _buildCategoriesCard(subjectName: 'JAMB', examIcon: "JAMB"),
      _buildCategoriesCard(subjectName: 'NECO', examIcon: "NECO"),
      _buildCategoriesCard(subjectName: 'SATs', examIcon: "SATs"),
      _buildCategoriesCard(subjectName: 'WEAC', examIcon: "WEAC"),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
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
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: categories,
        ),
      ),
    );
  }

  Widget _buildContinueWatchingSection(List<Video> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headingWithAdvert(tag: 'Video', title: 'Continue watching'),
        SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.isEmpty ? 3 : videos.length,
            itemBuilder: (context, index) => _ContinueWatching(video: videos.isEmpty ? Video.empty() : videos[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildGamesSection(List<Game> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        headingWithAdvert(tag: "Game", title: 'Game Everyone is playing'),
        SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: games.isEmpty ? 3 : games.length,
            itemBuilder: (context, index) {
              final game = games.isEmpty ? Game.empty() : games[index];
              return GameCard(
                game: game,
                beginColor: AppColors.gamesColor1,
                endColor: AppColors.gamesColor2,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBooksSection(List<Book> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        blueHeading(tag: 'E-book', title: 'Suggested for you'),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.isEmpty ? 3 : books.length,
            itemBuilder: (context, index) => _books(book: books.isEmpty ? Book.empty() : books[index]),
          ),
        ),
      ],
    );
  }
}


Widget _buildCategoriesCard({required String subjectName, required String examIcon}) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/icons/exams/$examIcon.png',
            fit: BoxFit.contain,
            width: 60,
            height: 60,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          subjectName,
          style: AppTextStyles.normal500(fontSize: 12.0, color: Colors.black),
        )
      ],
    ),
  );
}

class _ContinueWatching extends StatelessWidget {
  final Video video;

  const _ContinueWatching({required this.video});

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}

class _books extends StatelessWidget {
  final Book book;

  const _books({required this.book});

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
                style: AppTextStyles.normal600(fontSize: 16, color: AppColors.libText),
              ),
              Text(
                book.author,
                style: AppTextStyles.normal400(fontSize: 14, color: AppColors.libtitle),
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

  const headingWithAdvert({super.key, required this.tag, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(tag, style: AppTextStyles.normal400(fontSize: 12, color: AppColors.libtitle)),
          Icon(Icons.circle, size: 4, color: AppColors.libtitle),
          SizedBox(width: 10),
          Text(title, style: AppTextStyles.normal500(fontSize: 16, color: AppColors.libText))
        ],
      ),
    );
  }
}

class blueHeading extends StatelessWidget {
  final String tag;
  final String title;

  const blueHeading({super.key, required this.tag, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(tag, style: AppTextStyles.normal500(fontSize: 14, color: AppColors.libtitle)),
          Icon(Icons.circle, size: 8, color: AppColors.libtitle),
          SizedBox(width: 10),
          Text(title, style: AppTextStyles.normal700(fontSize: 18, color: AppColors.titleColor))
        ],
      ),
    );
  }
}



// class ForYouContent extends StatelessWidget {
//   const ForYouContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ForYouProvider>(
//       builder: (context, forYouProvider, child) {
//         if (forYouProvider.isLoading) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildCategoriesSection(),
//             _buildContinueWatchingSection(forYouProvider.videos),
//             _buildGamesSection(forYouProvider.games),
//             _buildBooksSection(forYouProvider.books),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCategoriesSection() {
//     final categories = [
//       _buildCategoriesCard(subjectName: 'Agric', examIcon: "Agric"),
//       _buildCategoriesCard(subjectName: 'BECE', examIcon: "BECE"),
//       _buildCategoriesCard(subjectName: 'GCE', examIcon: "GCE"),
//       _buildCategoriesCard(subjectName: 'IELTS', examIcon: "IELTS"),
//       _buildCategoriesCard(subjectName: 'JAMB', examIcon: "JAMB"),
//       _buildCategoriesCard(subjectName: 'NECO', examIcon: "NECO"),
//       _buildCategoriesCard(subjectName: 'SATs', examIcon: "SATs"),
//       _buildCategoriesCard(subjectName: 'WEAC', examIcon: "WEAC"),
//     ];

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16, top: 16),
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: AppColors.examCard,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 0),
//             ),
//           ],
//         ),
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           children: categories,
//         ),
//       ),
//     );
//   }

//   Widget _buildContinueWatchingSection(List<Video> videos) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         headingWithAdvert(tag: 'Video', title: 'Continue watching'),
//         SizedBox(height: 8),
//         SizedBox(
//           height: 180,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: videos.length,
//             itemBuilder: (context, index) => _ContinueWatching(video: videos[index]),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGamesSection(List<Game> games) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 25),
//         headingWithAdvert(tag: "Game", title: 'Game Everyone is playing'),
//         SizedBox(height: 8),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: games.length,
//             itemBuilder: (context, index) {
//               final game = games[index];
//               return GameCard(
//                 game: game,
//                 beginColor: AppColors.gamesColor1,
//                 endColor: AppColors.gamesColor2,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBooksSection(List<Book> books) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 25),
//         blueHeading(tag: 'E-book', title: 'Suggested for you'),
//         SizedBox(
//           height: 250,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: books.length,
//             itemBuilder: (context, index) => _books(book: books[index]),
//           ),
//         ),
//       ],
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// // import 'package:linkschool/modules/explore/e_library/E_lib_detail.dart';

// import 'package:linkschool/modules/explore/e_library/cbt.dart';
// import 'package:linkschool/modules/explore/e_library/e_library_ebooks/library_e_book.dart';
// import 'package:linkschool/modules/explore/games/game_card.dart';
// import 'package:linkschool/modules/explore/e_library/e_games/gamesTab.dart';
// import 'package:linkschool/modules/explore/videos/videos_dashboard.dart';
// // import 'package:linkschool/modules/explore/e_library/elibrary-ebooks/library_ebook.dart';

// class ForYouScreen extends StatefulWidget {
//   const ForYouScreen({super.key, required this.height});
//   final double height;

//   @override
//   State<ForYouScreen> createState() => _ForYouScreenState();
// }

// class _ForYouScreenState extends State<ForYouScreen> {
//   final List<Widget> gameItems = [
//     GameCard(
//       gameImage: 'assets/images/games_1.png',
//       gameTitle: 'Overwatch',
//       platform: 'Cross-platform',
//       rating: 4.5,
//       beginColor: AppColors.gamesColor1,
//       endColor: AppColors.gamesColor2,
//     ),
//     GameCard(
//       gameImage: 'assets/images/games_2.png',
//       gameTitle: 'Boarder lands',
//       platform: 'Cross-platform',
//       rating: 4.5,
//       beginColor: AppColors.gamesColor3,
//       endColor: AppColors.gamesColor4,
//     ),
//     GameCard(
//       gameImage: 'assets/images/games_3.png',
//       gameTitle: 'Overwatch',
//       platform: 'Cross-platform',
//       rating: 4.5,
//       beginColor: AppColors.gamesColor5,
//       endColor: AppColors.gamesColor6,
//     ),
//     GameCard(
//       gameImage: 'assets/images/games_1.png',
//       gameTitle: 'Overwatch',
//       platform: 'Cross-platform',
//       rating: 4.5,
//       beginColor: AppColors.gamesColor7,
//       endColor: AppColors.gamesColor8,
//     ),
//     GameCard(
//       gameImage: 'assets/images/games_2.png',
//       gameTitle: 'Overwatch',
//       platform: 'Cross-platform',
//       rating: 4.5,
//       beginColor: AppColors.gamesColor1,
//       endColor: AppColors.gamesColor2,
//     )
//   ];

//   final categories = [
//     _buildCategoriesCard(
//       subjectName: 'Agric',
//       examIcon: "Agric",
//     ),
//     _buildCategoriesCard(
//       subjectName: 'BECE',
//       examIcon: "BECE",
//     ),
//     _buildCategoriesCard(
//       subjectName: 'GCE',
//       examIcon: "GCE",
//     ),
//     _buildCategoriesCard(
//       subjectName: 'IELTS',
//       examIcon: "IELTS",
//     ),
//     _buildCategoriesCard(
//       subjectName: 'JAMB',
//       examIcon: "JAMB",
//     ),
//     _buildCategoriesCard(
//       subjectName: 'NECO',
//       examIcon: "NECO",
//     ),
//     _buildCategoriesCard(
//       subjectName: 'SATs',
//       examIcon: "SATs",
//     ),
//     _buildCategoriesCard(
//       subjectName: 'WEAC',
//       examIcon: "WEAC",
//     ),
//   ];

//   final bool _showSearchIcon = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: AppColors.paymentTxtColor1,
//         title: SvgPicture.asset('assets/icons/linkskool-logo.svg'),
//         actions: [
//           if (!_showSearchIcon)
//             IconButton(
//               icon: const Icon(Icons.search, color: Colors.white),
//               onPressed: () {
//                 // Handle search action
//               },
//             ),
//           IconButton(
//             onPressed: () {},
//             icon: SvgPicture.asset(
//               'assets/icons/notifications.svg',
//               colorFilter:
//                   const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//             ),
//           )
//         ],
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: DefaultTabController(
//             length: 5,
//             child: Column(
//               children: [
//                 TabBar(
//                     indicatorColor: AppColors.text2Light,
//                     labelColor: AppColors.text2Light,
//                     tabs: [
//                       Tab(
//                         child: FittedBox(
//                             child: Text('For you',
//                                 style:
//                                     AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light))),
//                       ),
//                       Tab(
//                         child: FittedBox(
//                             child: Text('CBT',
//                                 style:
//                                     AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light))),
//                       ),
//                       Tab(
//                         child: FittedBox(
//                             child: Text('E-books',
//                                 style:
//                                     AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light))),
//                       ),
//                       Tab(
//                         child: FittedBox(
//                             child: Text('Games',
//                                 style:
//                                     AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light))),
//                       ),
//                       Tab(
//                         child: Flexible(
//                             child: Text('Videos',
//                                 style:
//                                     AppTextStyles.normal600(fontSize: 14, color: AppColors.text2Light))),
//                       ),
//                     ]),
//                 Expanded(
//                   child: TabBarView(
//                     children: [
//                       SingleChildScrollView(
//                           child: newForYouScreen(
//                               categories: categories, gameItems: gameItems)),
//                       Expanded(child: E_CBTDashboard()),
//                       Expanded(
//                         child: LibraryEbook(),
//                       ),
//                       Expanded(
//                         child: GamesTab(),
//                       ),
//                       Expanded(
//                         child: VideosDashboard(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             )),
//       ),
//     );
//   }
// }

// class newForYouScreen extends StatelessWidget {
//   const newForYouScreen({
//     super.key,
//     required this.categories,
//     required this.gameItems,
//   });

//   final List<Widget> categories;
//   final List<Widget> gameItems;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 16, top: 16),
//           child: Container(
//             height: 100,
//             decoration: BoxDecoration(
//               color: AppColors.examCard,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 4,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ListView.builder(
//               itemCount: categories.length,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) => SizedBox(
//                 height: 50,
//                 width: 100,
//                 child: categories[index],
//               ),
//             ),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             headingWithAdvert(
//               tag: 'Video',
//               title: 'Continue watching',
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 'Old user',
//                 style: AppTextStyles.normal600(
//                     fontSize: 16, color: AppColors.text2Light),
//               ),
//             )
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: SizedBox(
//             height: 180,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _ContinueWatching(),
//                 _ContinueWatching(),
//                 _ContinueWatching(),
//                 _ContinueWatching(),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 25,
//         ),
//         headingWithAdvert(tag: "Game", title: 'Game Everyone is playing'),
//         SizedBox(
//           height: 8,
//         ),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             padding: const EdgeInsets.only(right: 16.0),
//             itemCount: gameItems.length,
//             scrollDirection: Axis.horizontal,
//             itemBuilder: (context, index) {
//               return gameItems[index];
//             },
//           ),
//         ),
//         SizedBox(
//           height: 5,
//         ),
//         blueHeading(tag: 'E-book', title: 'Suggested for you'),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: SizedBox(
//             height: 250,
//             width: double.infinity,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _books(
//                   image: 'assets/images/book_1.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//                 _books(
//                   image: 'assets/images/book_2.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//                 _books(
//                   image: 'assets/images/book_3.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//                 _books(
//                   image: 'assets/images/book_4.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class buildForYou extends StatelessWidget {
//   const buildForYou({
//     super.key,
//     required this.gameItems,
//   });

//   final List<Widget> gameItems;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: headingWithAdvert(
//             tag: 'Video',
//             title: 'Continue watching',
//           ),
//         ),
//         // SizedBox(
//         //   height: 8,
//         // ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: SizedBox(
//             height: 180,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _ContinueWatching(),
//                 _ContinueWatching(),
//                 _ContinueWatching(),
//                 _ContinueWatching(),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 25,
//         ),
//         headingWithAdvert(tag: "Game", title: 'Game Everyone is playing'),
//         SizedBox(
//           height: 8,
//         ),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             padding: const EdgeInsets.only(right: 16.0),
//             itemCount: gameItems.length,
//             scrollDirection: Axis.horizontal,
//             itemBuilder: (context, index) {
//               return gameItems[index];
//             },
//           ),
//         ),
//         SizedBox(
//           height: 5,
//         ),
//         blueHeading(tag: 'E-book', title: 'Suggested for you'),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: SizedBox(
//             height: 250,
//             width: double.infinity,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _books(
//                   image: 'assets/images/book_1.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//                 _books(
//                   image: 'assets/images/book_2.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//                 _books(
//                   image: 'assets/images/book_3.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//                 _books(
//                   image: 'assets/images/book_4.png',
//                   bookName: "Sugar Girl",
//                   editor: 'UBE Reader Boosters',
//                 ),
//               ],
//             ),
//           ),
//         ),
//         blueHeading(
//           tag: 'CBT',
//           title: 'Continue taking tests',
//         ),
//         Divider(
//           height: 20,
//         ),
//         Column(
//           children: [
//             subjectCard(
//                 subjectIcon: 'maths',
//                 subjectName: 'Mathematics',
//                 cardColor: AppColors.cbtCardColor1,
//                 showProgressIndicator: true),
//             Divider(),
//             subjectCard(
//                 subjectIcon: 'english',
//                 subjectName: 'English Language',
//                 cardColor: AppColors.cbtCardColor2,
//                 showProgressIndicator: true),
//             Divider(),
//             subjectCard(
//                 subjectIcon: 'chemistry',
//                 subjectName: 'Chemistry',
//                 cardColor: AppColors.cbtCardColor3,
//                 showProgressIndicator: true),
//             Divider(),
//             subjectCard(
//               subjectIcon: 'physics',
//               subjectName: 'Physics',
//               subjectyear: '2001-2014',
//               cardColor: AppColors.cbtCardColor4,
//             ),
//             Divider(),
//             subjectCard(
//               cardColor: AppColors.cbtCardColor5,
//               subjectIcon: 'further_maths',
//               subjectName: 'Further Mathematics',
//               subjectyear: '2001-2023',
//             )
//           ],
//         ),
//         SizedBox(
//           height: 150,
//         )
//       ]),
//     );
//   }
// }

// Widget subjectCard({
//   required String subjectIcon,
//   required String subjectName,
//   required Color cardColor,
//   final String? subjectyear,
//   bool showProgressIndicator = false,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//     child: Container(
//       height: 70,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(4.0),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: cardColor,
//               borderRadius: BorderRadius.circular(4.0),
//             ),
//             child: Center(
//               child: Image.asset(
//                 'assets/icons/$subjectIcon.png',
//                 width: 30,
//                 height: 30,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//           SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   subjectName,
//                   style: AppTextStyles.normal600(
//                       fontSize: 18, color: AppColors.backgroundDark),
//                 ),
//                 if (subjectyear != null)
//                   Text(
//                     subjectyear,
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 if (showProgressIndicator)
//                   Container(
//                     width: double.infinity,
//                     height: 4,
//                     color: Colors.grey,
//                     child: LinearProgressIndicator(
//                       value: 0.5,
//                       color: AppColors.progressBarLight,
//                     ),
//                   )
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// class _books extends StatelessWidget {
//   final String image;
//   final String bookName;
//   final String editor;

//   const _books({
//     // ignore: unused_element
//     super.key,
//     required this.image,
//     required this.bookName,
//     required this.editor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 8.0),
//       child: Container(
//         margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 173,
//               width: 114,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                 image: AssetImage(image),
//                 fit: BoxFit.cover,
//               )),
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             SizedBox(
//               width: 114,
//               child: LinearProgressIndicator(
//                 minHeight: 5,
//                 value: 0.5,
//                 color: AppColors.text2Light,
//               ),
//             ),
//             Text(
//               bookName,
//               style: AppTextStyles.normal600(
//                   fontSize: 16, color: AppColors.libText),
//             ),
//             Text(
//               editor,
//               style: AppTextStyles.normal400(
//                   fontSize: 14, color: AppColors.libtitle),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class headingWithAdvert extends StatelessWidget {
//   final String tag;
//   final String title;

//   const headingWithAdvert({
//     super.key,
//     required this.tag,
//     required this.title,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Row(
//         children: [
//           Text(tag,
//               style: AppTextStyles.normal400(
//                   fontSize: 12, color: AppColors.libtitle)),
//           Icon(
//             Icons.circle,
//             size: 4,
//             color: AppColors.libtitle,
//           ),
//           SizedBox(
//             width: 10,
//           ),
//           Text(
//             title,
//             style:
//                 AppTextStyles.normal500(fontSize: 16, color: AppColors.libText),
//           )
//         ],
//       ),
//     );
//   }
// }

// class blueHeading extends StatelessWidget {
//   final String tag;
//   final String title;

//   const blueHeading({
//     super.key,
//     required this.tag,
//     required this.title,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Row(
//         children: [
//           Text(tag,
//               style: AppTextStyles.normal500(
//                   fontSize: 14, color: AppColors.libtitle)),
//           Icon(
//             Icons.circle,
//             size: 8,
//             color: AppColors.libtitle,
//           ),
//           SizedBox(
//             width: 10,
//           ),
//           Text(
//             title,
//             style: AppTextStyles.normal700(
//                 fontSize: 18, color: AppColors.titleColor),
//           )
//         ],
//       ),
//     );
//   }
// }

// Widget _ContinueWatching() {
//   return Container(
//     height: 147,
//     width: 150,
//     margin: const EdgeInsets.only(left: 16.0),
//     child: Column(
//       children: [
//         Image.asset(
//           'assets/images/video_1.png',
//           fit: BoxFit.cover,
//           height: 90,
//           width: 150,
//         ),
//         const SizedBox(height: 4.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//           child: Text(
//             'Mastering the Act of Video editing',
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: AppTextStyles.normal600(
//               fontSize: 14.0,
//               color: AppColors.backgroundDark,
//             ),
//           ),
//         ),
//         const SizedBox(height: 4.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//           child: Row(
//             children: [
//               const CircleAvatar(
//                 backgroundImage: NetworkImage(
//                   'profileImageUrl',
//                 ),
//                 radius: 10.0,
//               ),
//               const SizedBox(width: 4.0),
//               Text(
//                 'Toochi Dennis',
//                 style: AppTextStyles.normal500(
//                   fontSize: 12.0,
//                   color: AppColors.videoColor9,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildCategoriesCard({
//   required String subjectName,
//   required String examIcon,
// }) {
//   return Padding(
//     padding: const EdgeInsets.only(top: 16),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               'assets/icons/exams/$examIcon.png',
//               fit: BoxFit.contain,
//             )),
//         const SizedBox(height: 8.0),
//         Text(
//           subjectName,
//           style: AppTextStyles.normal500(fontSize: 12.0, color: Colors.black),
//         )
//       ],
//     ),
//   );
// }