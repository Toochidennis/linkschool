import 'package:flutter/material.dart';
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
  int _selectedButtonIndex = 0;

  final buttonLabels = [
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
        height: double.infinity,
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'What do you want to\nread today?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search',
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                        color: Color.fromRGBO(139, 139, 139, 1),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: AppColors.textFieldLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                        gapPadding: 4.0,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: List.generate(buttonLabels.length, (index) {
                    return BooksButtonItem(
                      text: buttonLabels[index],
                      isSelected: _selectedButtonIndex == index,
                      onPressed: () {
                        setState(() {
                          _selectedButtonIndex = index;
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16.0),
              const SizedBox(
                width: double.maxFinite,
                height: 1024,
                child: CustomTabController(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
