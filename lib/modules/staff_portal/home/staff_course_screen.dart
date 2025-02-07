import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/staff_portal/home/staff_profile_screen.dart';

class StaffCoursesScreen extends StatefulWidget {
  const StaffCoursesScreen({super.key});

  @override
  State<StaffCoursesScreen> createState() => _StaffCoursesScreenState();
}

class _StaffCoursesScreenState extends State<StaffCoursesScreen> {
  late double opacity;
  final List<String> names = [
    'Tochukwu Dennis',
    'Tina Dennis',
    'Tochi Dennis',
    'Tolu Dennis',
    'Timothy Dennis',
    'Tade Dennis',
    'Tonia Dennis',
    'Tom Dennis',
    'Tony Dennis',
    'Tess Dennis',
  ];

  

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Courses',
            style: AppTextStyles.normal600(
                fontSize: 20, color: AppColors.paymentTxtColor1)),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset('assets/icons/arrow_back.png',
              color:AppColors.paymentTxtColor1, width: 34.0, height: 34.0),
        ),
        backgroundColor: AppColors.backgroundLight,
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
            ),
            // List of Names
            Expanded(
              child: ListView.separated(
                itemCount: names.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final name = names[index];
                  return ListTile(
                    onTap: () {
                      // Navigate to ProfileScreen with the selected name
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StaffProfileScreen(name: name),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: _getCircleColor(name),
                      child: Text(
                        name[0], // First letter of the name
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get a color based on the name
  Color _getCircleColor(String name) {
    // Generate a color based on the name (for variety)
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.yellow,
      Colors.cyan,
      Colors.pink,
    ];
    return colors[name.hashCode % colors.length];
  }
}

