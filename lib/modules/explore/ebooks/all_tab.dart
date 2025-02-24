import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/explore/e_library/e_library_ebooks/book_page.dart';

import '../../common/app_colors.dart';
import '../../common/text_styles.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    final readingItems = [
      _buildContinueReadingItem(
        coverImage: 'assets/images/book_1.png',
        bookTitle: 'Purple Hibiscus',
        authorName: 'Chimamanda N. Adichie',
        bookProgress: 0.2,
      ),
      _buildContinueReadingItem(
        coverImage: 'assets/images/book_2.png',
        bookTitle: 'Doom of Aliens',
        authorName: 'K. S. Jenson',
        bookProgress: 0.5,
      ),
    ];

    final suggestedItems = [
      _buildSuggestedForYouItem(
        coverImage: 'assets/images/book_4.png',
        bookTitle: 'Sugar Girl',
        authorName: 'UBE Reader Boosters',
      ),
      _buildSuggestedForYouItem(
        coverImage: 'assets/images/book_5.png',
        bookTitle: 'Things Fall Apart',
        authorName: 'Chinua Achebe',
      ),
      _buildSuggestedForYouItem(
        coverImage: 'assets/images/book_3.png',
        bookTitle: 'Americanah',
        authorName: 'Chimamanda N. Adichie',
      ),
    ];

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
                  return readingItems[index];
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
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MybookPage(),)),
                    child: suggestedItems[index]);
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
                  return suggestedItems[index];
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
                  child: Image.asset(
                    coverImage,
                    fit: BoxFit.cover,
                    height: 180,
                    width: 130,
                  ),
                ),
                const SizedBox(height: 4.0),
                LinearProgressIndicator(
                  value: bookProgress,
                  // Adjust the value (0.5 means 50% progress)
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
                  child: Image.asset(
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
