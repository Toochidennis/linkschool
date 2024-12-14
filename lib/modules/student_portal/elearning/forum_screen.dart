import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';


class ForumScreen extends StatefulWidget {
  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Header with reduced height and left-aligned text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width, // Ensure full width
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          // This ensures the image fills the available space
                          child: SvgPicture.asset(
                            'assets/images/student/header_background.svg',
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Text Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            height: 100,
                            alignment: Alignment.centerLeft,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Agricultural Science',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '2018/2019 Session',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'First Term',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Section 2: Input Card (still visually attached to the header)
              Transform.translate(
                offset: const Offset(0, -2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.booksButtonColor,
                            radius: 16,
                            child: Icon(Icons.person,
                                color: Colors.grey[600], size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Share with your class...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section 3: Post Card
              buildPostCard(
                iconPath: 'assets/icons/student/note_icon.svg',
                title: 'What is Punctuality?',
                subtitle: '25 June, 2015 08:52am',
              ),
              const SizedBox(height: 16),

              // Section 4: Another Post Card
              buildPostCard(
                iconPath: 'assets/icons/student/assignment_icon.svg',
                title: 'Assignment',
                subtitle: '25 June, 2015 08:52am',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPostCard({
    required String iconPath,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  SvgPicture.asset(iconPath, height: 32, width: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.grey),

              // Comment Rows
              buildComment(
                avatarColor: AppColors.booksButtonColor,
                name: 'Tochukwu Dennis',
                date: '03 Jan',
                message:
                    'This is a mock data showing the info details of a post.',
              ),
              const SizedBox(height: 12),
              buildComment(
                avatarColor: AppColors.booksButtonColor,
                name: 'Tochukwu Dennis',
                date: '03 Jan',
                message:
                    'This is a mock data showing the info details of a post.',
              ),
              const SizedBox(height: 12),

              // Add Comment Field
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: UnderlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildComment({
    required Color avatarColor,
    required String name,
    required String date,
    required String message,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: avatarColor,
          radius: 16,
          child:  Icon(Icons.person, size: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Like',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Reply',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}