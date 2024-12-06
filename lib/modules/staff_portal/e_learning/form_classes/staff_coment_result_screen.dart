import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/staff_portal/e_learning/form_classes/staff_input_result_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/form_classes/staff_view_result_screen.dart';


class StaffCommentResultScreen extends StatefulWidget {
  const StaffCommentResultScreen({super.key});

  @override
  State<StaffCommentResultScreen> createState() => _StaffCommentResultScreenState();
}

class _StaffCommentResultScreenState extends State<StaffCommentResultScreen> {
  late double opacity;


  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Comment on result',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two containers per row
              crossAxisSpacing: 16.0, // Space between columns
              mainAxisSpacing: 16.0, // Space between rows
              childAspectRatio: 3, // Adjust height relative to width
            ),
            itemCount: courseList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showBottomSheet(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(
                      colors: gradientColors[index % gradientColors.length],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book, color: Colors.white, size: 32.0),
                      const SizedBox(width: 8.0),
                      Text(
                        courseList[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Input result'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffInputResultScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('View result'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffViewResultScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Placeholder data for courses
final List<String> courseList = [
  'Civic Education',
  'Mathematics',
  'English',
  'Biology',
  'Physics',
  'Chemistry',
  'Economics',
  'Literature',
  'History',
  'Geography',
];

// Gradient colors for the course cards
final List<List<Color>> gradientColors = [
  [Colors.blue, Colors.lightBlue],
  [Colors.green, Colors.teal],
  [Colors.indigo, Colors.blueAccent],
  [Colors.purple, Colors.deepPurple],
];