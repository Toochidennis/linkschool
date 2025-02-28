import 'package:flutter/material.dart';
import 'package:linkschool/modules/e_library/elibrary_ebooks/book_page.dart';
// import 'package:linkschool/modules/E_library/elibrary-ebooks/book_page.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:provider/provider.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
// import 'book_page.dart';

class AllTab extends StatelessWidget {
  final int selectedCategoryIndex;

  const AllTab({super.key, required this.selectedCategoryIndex});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<EbookProvider>(context);
    final books = bookProvider.ebooks;
    final categories = bookProvider.categories;
    final selectedCategory = categories[selectedCategoryIndex];

    // Filter books based on the selected category
    final filteredBooks = books
        .where((book) => book.categories.contains(selectedCategory))
        .toList();

    final readingItems = filteredBooks.map((book) {
      return _buildContinueReadingItem(
        coverImage: book.thumbnail,
        bookTitle: book.title,
        authorName: book.author,
        bookProgress: 0.2, // Adjust based on actual progress
      );
    }).toList();

    final suggestedItems = filteredBooks.map((book) {
      return _buildSuggestedForYouItem(
        coverImage: book.thumbnail,
        bookTitle: book.title,
        authorName: book.author,
      );
    }).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Continue reading',
              style: AppTextStyles.normal500(
                fontSize: 16.0,
                color: AppColors.booksButtonTextColor,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 260,
            margin: const EdgeInsets.only(right: 16.0),
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppColors.text6Light))),
            child: ListView.builder(
                itemCount: readingItems.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final continueReading = bookProvider.ebooks[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MybookPage(suggestedbook: continueReading)),
                    ),
                    child: readingItems[index],
                  );
                }),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
        SliverToBoxAdapter(
          child: Constants.headingWithSeeAll600(
            title: 'Suggested for you',
            titleSize: 18.0,
            titleColor: AppColors.text2Light,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 250,
            margin: const EdgeInsets.only(right: 16.0),
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppColors.text6Light))),
            child: ListView.builder(
                itemCount: suggestedItems.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final suggestbook = bookProvider.ebooks[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MybookPage(suggestedbook: suggestbook)),
                    ),
                    child: suggestedItems[index],
                  );
                }),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
        SliverToBoxAdapter(
          child: Constants.headingWithSeeAll600(
            title: 'You might also like',
            titleSize: 18.0,
            titleColor: AppColors.text2Light,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 250,
            margin: const EdgeInsets.only(right: 16.0),
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppColors.text6Light))),
            child: ListView.builder(
                itemCount: suggestedItems.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final suggestedBook = bookProvider.ebooks[index];
                  return GestureDetector(
                    onTap: () => (Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MybookPage(suggestedbook: suggestedBook)))),
                    child: suggestedItems[index],
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueReadingItem({
    required String coverImage,
    required String bookTitle,
    required String authorName,
    required double bookProgress,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    coverImage,
                    fit: BoxFit.cover,
                    height: 180,
                    width: 130,
                  ),
                ),
                const SizedBox(height: 4.0),
                LinearProgressIndicator(
                  value: bookProgress,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 4.0),
                Text(
                  bookTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal500(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal500(
                    fontSize: 12.0,
                    color: AppColors.text5Light,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedForYouItem({
    required String coverImage,
    required String bookTitle,
    required String authorName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    coverImage,
                    fit: BoxFit.cover,
                    height: 180,
                    width: 130,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  bookTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal500(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  authorName,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal500(
                    fontSize: 12.0,
                    color: AppColors.text5Light,
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
