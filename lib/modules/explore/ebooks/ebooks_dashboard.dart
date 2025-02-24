import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/explore/home/e_book_provider.dart';
import 'package:provider/provider.dart';

import '../../common/app_colors.dart';
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

//TickerProviderStateMixin

class _EbooksDashboardState extends State<EbooksDashboard> {
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
    final bookProvider = Provider.of<BookProvider>(context);
    return Scaffold(
      appBar: Constants.customAppBar(context: context, showBackButton: true),
      body: Container(
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
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
            CustomSearchBar(),
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
            const SizedBox(height: 16.0),
            Expanded(child: _buildTabController()),
          ],
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
