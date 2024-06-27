import 'package:flutter/material.dart';

import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../books/all_tab_item_1.dart';
import 'all_tab_item_2.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    const historyItems1 = [
      AllTabItem1(
        coverImage: 'assets/images/book_1.png',
        bookTitle: 'Purple Hibiscus',
        authorName: 'Chimamanda N. Adichie',
        bookProgress: 0.2,
      ),
      AllTabItem1(
        coverImage: 'assets/images/book_2.png',
        bookTitle: 'Doom of Aliens',
        authorName: 'K. S. Jenson',
        bookProgress: 0.5,
      ),
    ];

    const historyItems2 = [
      AllTabItem2(
        coverImage: 'assets/images/book_4.png',
        bookTitle: 'Sugar Girl',
        authorName: 'UBE Reader Boosters',
      ),
      AllTabItem2(
        coverImage: 'assets/images/book_5.png',
        bookTitle: 'Things Fall Apart',
        authorName: 'Chinua Achebe',
      ),
      AllTabItem2(
        coverImage: 'assets/images/book_3.png',
        bookTitle: 'Americanah',
        authorName: 'Chimamanda N. Adichie',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0),
          child: Text(
            'Continue reading',
            style: AppTextStyles.normal500(
              fontSize: 16.0,
              color: AppColors.booksButtonTextColor,
            ),
          ),
        ),
        Container(
          height: 260,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.text6Light))),
          child: ListView.builder(
              itemCount: historyItems1.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return historyItems1[index];
              }),
        ),
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Suggested for you',
                style: AppTextStyles.title3Light,
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 250,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.text6Light))),
          child: ListView.builder(
              itemCount: historyItems2.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return historyItems2[index];
              }),
        ),
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You might also like',
                style: AppTextStyles.title3Light,
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 250,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.text6Light))),
          child: ListView.builder(
              itemCount: historyItems2.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return historyItems2[index];
              }),
        ),
      ],
    );
  }

  Widget _buildContinueReadingItem({
    required String coverImage,
    required String bookTitle,
    required String authorName,
    required double bookProgress,
}){
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
}