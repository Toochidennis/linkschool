import 'package:flutter/material.dart';
import 'package:linkschool/ui/books/books_button_item.dart';
import 'package:linkschool/ui/books/custom_tab_controller.dart';

import '../../common/app_colors.dart';
import '../dashboard/common/constants.dart';

class BooksHome extends StatefulWidget {
  const BooksHome({super.key});

  @override
  State<BooksHome> createState() => _BooksHomeState();
}

class _BooksHomeState extends State<BooksHome> with TickerProviderStateMixin {
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
    final Brightness brightness = Theme.of(context).brightness;
    var opacity = brightness == Brightness.light ? 0.1 : 0.15;
    TabController _tabContrller = TabController(length: 2, vsync: this);

    return Theme(
      data: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          flexibleSpace: FlexibleSpaceBar(
              background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          )),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Image.asset(
              'assets/icons/arrow_back.png',
              color: AppColors.primaryLight,
              width: 34.0,
              height: 34.0,
            ),
          ),
        ),
        body: Container(
          height: double.infinity,
          decoration: customBoxDecoration(context),
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

                Container(
                  width: double.maxFinite,
                  height: 600,
                  child: CustomTabController()
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
