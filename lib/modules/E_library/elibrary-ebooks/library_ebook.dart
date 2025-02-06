import 'package:flutter/material.dart';
import 'package:linkschool/modules/E_library/books_button_item.dart';
import 'package:linkschool/modules/explore/ebooks/all_tab.dart';
// import 'package:linkschool/modules/explore/ebooks/custom_search_bar.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';

class LibraryEbook extends StatefulWidget {
  const LibraryEbook({super.key});

  @override
  State<LibraryEbook> createState() => _LibraryEbookState();
}

class _LibraryEbookState extends State<LibraryEbook> {
  int _selectedBookCategoriesIndex = 0;
  final bookCategories = [
    'Academic',
    'Science Fiction',
    'For WAEC',
    'Self-help',
    'Religious',
    'Literature'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap the entire screen with a SingleChildScrollView
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you want to\nread today?',
                  style: AppTextStyles.normal600(
                    fontSize: 24.0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.0), // Add spacing between title and categories
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: List.generate(bookCategories.length, (index) {
                    return BooksButtonItem(
                      label: bookCategories[index],
                      isSelected: _selectedBookCategoriesIndex == index,
                      onPressed: () {
                        setState(() {
                          _selectedBookCategoriesIndex = index;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 16.0), // Add spacing before the TabBar
                _buildTabController(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabController() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: false,
            unselectedLabelColor: const Color.fromRGBO(90, 90, 90, 1),
            labelColor: AppColors.text2Light,
            labelStyle: AppTextStyles.normal600(
              fontSize: 16.0,
              color: AppColors.text2Light,
            ),
            indicatorColor: AppColors.text2Light,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Library'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7, // Adjust height dynamically
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(), // Disable horizontal scrolling
              children: [
                const AllTab(),
                Container(
                  color: Colors.orange,
                  child: const Center(
                    child: Text('Tab 2'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/E_library/books_button_item.dart';
// import 'package:linkschool/modules/explore/ebooks/all_tab.dart';
// import 'package:linkschool/modules/explore/ebooks/custom_search_bar.dart';
// import '../../common/app_colors.dart';
// import '../../common/constants.dart';
// import '../../common/text_styles.dart';

// class LibraryEbook extends StatefulWidget {
//   const LibraryEbook({super.key});

//   @override
//   State<LibraryEbook> createState() => _LibraryEbookState();
// }

// class _LibraryEbookState extends State<LibraryEbook> {
//   int _selectedBookCategoriesIndex = 0;

//   final bookCategories = [
//     'Academic',
//     'Science Fiction',
//     'For WAEC',
//     'Self-help',
//     'Religious',
//     'Literature'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column( 
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 'What do you want to\nread today?',
//                 style: AppTextStyles.normal600(
//                   fontSize: 24.0,
//                   color: Colors.black,
//                 ),
//               ),
          
//               Wrap(
//                 spacing: 10.0,
//                 runSpacing: 10.0,
//                 children: List.generate(bookCategories.length, (index) {
//                   return BooksButtonItem(
//                     label: bookCategories[index],
//                     isSelected: _selectedBookCategoriesIndex == index,
//                     onPressed: () {
//                       setState(() {
//                         _selectedBookCategoriesIndex = index;
//                       });
//                     },
//                   );
//                 }),
//               ),
//               _buildTabController(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabController() {
//     return DefaultTabController(
//       length: 2,
//       child: Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             TabBar(
//               isScrollable: false, 
//               unselectedLabelColor: const Color.fromRGBO(90, 90, 90, 1),
//               labelColor: AppColors.text2Light,
//               labelStyle: AppTextStyles.normal600(
//                 fontSize: 16.0,
//                 color: AppColors.text2Light,
//               ),
//               indicatorColor: AppColors.text2Light,
//               tabs: const [
//                 Tab(text: 'All'),
//                 Tab(text: 'Library'),
//               ],
//             ),
//             Expanded( 
//               child: TabBarView(
//                 physics: NeverScrollableScrollPhysics(), 
//                 children: [
//                   const AllTab(),
//                   Container(
//                     color: Colors.orange,
//                     child: const Center(
//                       child: Text('Tab 2'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }