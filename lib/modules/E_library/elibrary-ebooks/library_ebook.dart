import 'package:flutter/material.dart';
import 'package:linkschool/modules/E_library/books_button_item.dart';
import 'package:linkschool/modules/explore/ebooks/all_tab.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/search_bar.dart';
import '../../common/text_styles.dart';

class LibraryEbook extends StatefulWidget {
  const LibraryEbook({super.key});

  @override
  State<LibraryEbook> createState() => _LibraryEbookState();
}

//TickerProviderStateMixin

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
    return Container(
      padding: EdgeInsets.only(top: 30),
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
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
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
          ),
        ],
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
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            unselectedLabelColor: const Color.fromRGBO(90, 90, 90, 1),
            labelColor: AppColors.text2Light,
            labelStyle: AppTextStyles.normal600(
              fontSize: 16.0,
              color: AppColors.text2Light,
            ),
            indicatorColor: AppColors.text2Light,
            tabs: const [Tab(text: 'All'), Tab(text: 'Library')],
          ),
          Expanded(
            child: TabBarView(
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
