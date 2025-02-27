import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:provider/provider.dart';
// import 'package:linkschool/modules/E_library/books_button_item.dart';
import 'package:linkschool/modules/explore/ebooks/all_tab.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
// import '../providers/explore/home/e_book_provider.dart'; // Import the EbookProvider

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
    // Fetch books data when the widget is initialized
    final bookProvider = Provider.of<EbookProvider>(context, listen: false);
    bookProvider.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<EbookProvider>(context);
    final categories = bookProvider.categories;

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the entire screen with a SingleChildScrollView
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    const SizedBox(
                        height:
                            16.0), // Add spacing between title and categories
                    _buildCategoryButtons(
                        categories), // Styled category buttons
                    const SizedBox(height: 16.0),
                  ],
                ),
              ), // Add spacing before the TabBar
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
      spacing: 12.0, // Space between buttons horizontally
      runSpacing: 12.0, // Space between rows of buttons
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
                  ? AppColors.ebookCart
                  : AppColors.booksButtonColor, // Selected color
              borderRadius: BorderRadius.circular(6), // Rounded corners
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
              height: MediaQuery.of(context).size.height *
                  0.7, // Adjust height dynamically
              child: TabBarView(
                physics:
                    const NeverScrollableScrollPhysics(), // Disable horizontal scrolling
                children: [
                  AllTab(
                      selectedCategoryIndex:
                          _selectedBookCategoriesIndex), // Pass selected category index
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
