import 'package:flutter/material.dart';
import 'package:linkschool/common/search_bar.dart';
import 'package:linkschool/common/text_styles.dart';
import 'package:linkschool/ui/books/books_button_item.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';
import 'all_tab.dart';

class BooksHome extends StatefulWidget {
  const BooksHome({super.key});

  @override
  State<BooksHome> createState() => _BooksHomeState();
}

//TickerProviderStateMixin

class _BooksHomeState extends State<BooksHome> {
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
      appBar: Constants.customAppBar(context: context),
      body: Container(
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
            const CustomSearchBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: List.generate(bookCategories.length, (index) {
                  return BooksButtonItem(
                    text: bookCategories[index],
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
            Expanded(
              child: _buildTabController()
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabController(){
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            unselectedLabelColor: Colors.black.withOpacity(0.3),
            indicatorColor: AppColors.primaryLight,
            tabs: const [
              Tab(
                text: 'All',
              ),
              Tab(text: 'Library')
            ],
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
