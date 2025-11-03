import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/explore/ebooks/all_tab.dart';

class LibraryEbook extends StatefulWidget {
  const LibraryEbook({super.key});

  @override
  State<LibraryEbook> createState() => _LibraryEbookState();
}

class _LibraryEbookState extends State<LibraryEbook> {
  int _selectedBookCategoriesIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EbookProvider>(context, listen: false).fetchBooks());
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<EbookProvider>(context);
    final categories = bookProvider.categories;

    return Scaffold(
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: bookProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.text2Light,
                  strokeWidth: 3.0,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header + Categories
                    Padding(
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
                          const SizedBox(height: 16.0),
                          _buildCategoryButtons(categories),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                    // Tabs
                    _buildTabController(),
                  ],
                ),
              ),
      ),
    );
  }

  /// *Builds the Styled Book Category Buttons*
  Widget _buildCategoryButtons(List<String> categories) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.start,
      children: List.generate(categories.length, (index) {
        bool isSelected = _selectedBookCategoriesIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBookCategoriesIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.bgXplore3
                  : AppColors.booksButtonColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              categories[index].toUpperCase(),
              style: AppTextStyles.normal600(
                fontSize: 18.0,
                color: isSelected
                    ? AppColors.text6Light
                    : AppColors.booksButtonTextColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// *Builds the Tab Controller with Tabs*
  Widget _buildTabController() {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
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
              height: MediaQuery.of(context).size.height * 0.7,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AllTab(selectedCategoryIndex: _selectedBookCategoriesIndex),
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
      ),
    );
  }
}

