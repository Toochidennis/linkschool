import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/result/class_detail/student_result/course_result_screen.dart';
import 'package:linkschool/modules/admin_portal/result/class_detail/student_result/student_result.dart';

void showStudentResultOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (_, controller) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: controller,
                        itemCount: 4,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final studentNames = [
                            'Tochukwu Dennis',
                            'Vincent Rapheal',
                            'Victor Anya',
                            'Joseph Onwe'
                          ];
                          final studentName = studentNames[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors
                                  .primaries[index % Colors.primaries.length],
                              child: Text(
                                studentName[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(studentName),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentResultScreen(
                                    studentName: studentName,
                                    className: 'Student Result',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

void showTermOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final icons = [
                      'assets/icons/result/comment.svg',
                      'assets/icons/result/skill.svg',
                      'assets/icons/result/course.svg',
                      'assets/icons/result/composite_result.svg',
                    ];
                    final labels = [
                      'Comment on results',
                      'Skills and Behaviour',
                      'Course result',
                      'Composite result',
                    ];
                    final colors = [
                      AppColors.bgColor2,
                      AppColors.bgColor3,
                      AppColors.bgColor4,
                      AppColors.bgColor5,
                    ];
                    final iconColors = [
                      AppColors.iconColor1,
                      AppColors.iconColor2,
                      AppColors.iconColor3,
                      AppColors.iconColor4,
                    ];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            icons[index],
                            color: iconColors[index],
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      title: Text(labels[index]),
                      onTap: () {
                        if (labels[index] == 'Course result') {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseResultScreen(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
