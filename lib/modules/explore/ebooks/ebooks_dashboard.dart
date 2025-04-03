import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:provider/provider.dart';
// import 'ebook_provider.dart';
import '../../common/constants.dart';
import '../../common/search_bar.dart';
import '../../common/text_styles.dart';
import 'all_tab.dart';
import 'books_button_item.dart';

class EbooksDashboard extends StatefulWidget {
  const EbooksDashboard({super.key});

  @override
  State<EbooksDashboard> createState() => _EbooksDashboardState();
}

class _EbooksDashboardState extends State<EbooksDashboard> {
  int _selectedBookCategoriesIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch books data when the widget is initialized
    final bookProvider = Provider.of<EbookProvider>(context, listen: false);
    bookProvider.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<EbookProvider>(context);
    final categories = bookProvider.categories;

    return Scaffold(
      appBar: Constants.customAppBar(context: context, showBackButton: true),
      body: SingleChildScrollView(
        // physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.only(
            top: 30,
          ),
          decoration: Constants.customBoxDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'What do you want to\nread today?',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
              const CustomSearchBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: List.generate(categories.length, (index) {
                    return BooksButtonItem(
                      label: categories[index].toUpperCase(),
                      isSelected: _selectedBookCategoriesIndex == index,
                      onPressed: () {
                        setState(() {
                          _selectedBookCategoriesIndex = index;
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 15.5),
              SizedBox(
                  height: 1038.5,
                  // height: MediaQuery.of(context).size.height * 0.9,
                  child: _buildTabController()),
            ],
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
          Expanded(
              child: Column(
            children: [
              AllTab(selectedCategoryIndex: _selectedBookCategoriesIndex),
            ],
          )),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// import '../../common/app_colors.dart';
// import '../../common/constants.dart';
// import '../../common/search_bar.dart';
// import '../../common/text_styles.dart';
// import 'all_tab.dart';
// import 'books_button_item.dart';

// class EbooksDashboard extends StatefulWidget {
//   const EbooksDashboard({super.key});

//   @override
//   State<EbooksDashboard> createState() => _EbooksDashboardState();
// }

// //TickerProviderStateMixin

// class _EbooksDashboardState extends State<EbooksDashboard> {
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
//       appBar: Constants.customAppBar(context: context,showBackButton: true),
//       body: Container(
//         padding: EdgeInsets.only(top: 30),
//         decoration: Constants.customBoxDecoration(context),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 'What do you want to\nread today?',
//                 style: AppTextStyles.normal600(
//                   fontSize: 16.0,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             CustomSearchBar(),
           
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),

//               child: Wrap(
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
//             ),
//             const SizedBox(height: 16.0),
//             Expanded(child: _buildTabController()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabController() {
//     return DefaultTabController(
//       length: 2,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TabBar(
//             tabAlignment: TabAlignment.start,
//             isScrollable: true,
//             unselectedLabelColor: const Color.fromRGBO(90, 90, 90, 1),
//             labelColor: AppColors.text2Light,
//             labelStyle: AppTextStyles.normal600(
//               fontSize: 16.0,
//               color: AppColors.text2Light,
//             ),
//             indicatorColor: AppColors.text2Light,
//             tabs: const [Tab(text: 'All'), Tab(text: 'Library')],
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 const AllTab(),
//                 Container(
//                   color: Colors.orange,
//                   child: const Center(
//                     child: Text('Tab 2'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
