import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/student_portal/elearning/forum_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseTitle;
  const CourseDetailScreen({Key? key, required this.courseTitle}) : super(key: key);

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _selectedIndex = 0;

  static  final List<Widget> _screens = [
    CourseContentScreen(),
    ForumScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.courseTitle),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons//student/coursework_icon.svg', height: 20), // Replace with actual SVG path
            label: 'Coursework',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/student/forum_icon.svg', height: 20), // Replace with actual SVG path
            label: 'Forum',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class CourseContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            alignment: Alignment.center,
            color: Colors.blue,
            child: const Text(
              'Agricultural Science',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const ContentRow(
            iconPath: 'assets/icons/student/quiz_icon.svg',
            title: 'Quiz: Human Rights',
            subtitle: 'Created on 25 June, 2015 08:52am',
            titleColor: Colors.blue,
          ),
          const ContentRow(
            iconPath: 'assets/icons/student/assignment_icon.svg',
            title: 'Assignment: Honesty',
            subtitle: 'Created on 25 June, 2015 08:52am',
            titleColor: Colors.blue,
          ),
          const SizedBox(height: 24),
          
          // Section 2: Punctuality
          const Text(
            'Punctuality',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          Divider(color: Colors.grey.shade400),
          const ContentRow(
            iconPath: 'assets/icons/student/note_icon.svg',
            title: 'What is Punctuality?',
            subtitle: 'Created on 25 June, 2015 08:52am',
          ),
          const ContentRow(
            iconPath: 'assets/icons/student/quiz_icon.svg',
            title: 'First C.A',
            subtitle: 'Created on 25 June, 2015 08:52am',
          ),
          const ContentRow(
            iconPath: 'assets/icons/student/assignment_icon.svg',
            title: 'Assignment',
            subtitle: 'Created on 25 June, 2015 08:52am',
          ),
          const ContentRow(
            iconPath: 'assets/icons/student/quiz_icon.svg',
            title: 'Second C.A',
            subtitle: 'Created on 25 June, 2015 08:52am',
          ),
        ],
      ),
    );
  }
}

class ContentRow extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final Color titleColor;

  const ContentRow({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, height: 32, width: 32), // Replace with actual SVG path
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: title.split(':')[0] + ': ',
                        style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: title.split(':').length > 1 ? title.split(':')[1].trim() : '',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


