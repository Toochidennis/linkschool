import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linkschool/common/search_bar.dart';
import 'package:linkschool/common/text_styles.dart';
import 'package:linkschool/ui/books/books_button_item.dart';
import 'package:linkschool/ui/books/custom_tab_controller.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';

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
            const Expanded(
              child: CustomTabController()
            ),
          ],
        ),
      ),
    );
  }
}
