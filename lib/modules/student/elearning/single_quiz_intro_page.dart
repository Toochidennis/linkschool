import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/model/student/single_elearningcontentmodel.dart';
import 'package:linkschool/modules/student/elearning/quiz_page.dart';
import 'package:linkschool/modules/student/elearning/single_quiz_page.dart';

import '../../common/app_colors.dart';

class SingleQuizIntroPage extends StatelessWidget {
  final SingleElearningContentData? childContent;

  const SingleQuizIntroPage({super.key, required this.childContent});
  String formatDueDate(SingleElearningContentData child) {
    if (child.settings!=null){
      try {
        final DateTime parsedDate = DateTime.parse(child.settings!.endDate);
        final String formatted = DateFormat('EEEE, dd MMMM yyyy  HH:mm').format(parsedDate);
        return '$formatted';
      } catch (e) {
        return 'Invalid date';
      }

    }
    else {
      try {
        final DateTime parsedDate = DateTime.parse(child.settings!.endDate  );
        final String formatted = DateFormat('EEEE, dd MMMM yyyy  HH:mm').format(parsedDate);
        return 'Due : $formatted';
      } catch (e) {
        return 'Invalid date';
      }
    }
  }

  String formatDuration(SingleElearningContentData child) {
    if (child.settings!=null){
      try {
        final int seconds = int.tryParse(child.settings!.duration) ?? 0;
        final int minutes = seconds % 60;

        return '$minutes minutes';
      } catch (e) {
        return 'Invalid Form';
      }

    }
    else {

      return 'Invalid Form';


    }
  }
  @override
  Widget build(BuildContext context) {
    if ( childContent == null) {
      print(childContent);
      return const Scaffold(
        body:  Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CircularProgressIndicator(),
              Text("Loading your  quiz" ,style: TextStyle(color: AppColors.paymentBtnColor1),),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor:  AppColors.paymentTxtColor1,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text("Quiz"),
        backgroundColor: AppColors.backgroundLight,
        actions: [
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar

              const SizedBox(height: 24),

              // Placeholder for question mark image
              Center(

                child: Image.asset(
                  'assets/icons/Illustration.png',
                  height: 180,
                ),
              ),
              const SizedBox(height: 32),

              // Card with quiz details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due date
                    Text(
                      "Due :  ${formatDueDate(childContent!)}",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quiz title
                    Text(
                      "${childContent?.settings!.title}",
                      style: TextStyle(
                        color: Color(0xFF1E50C1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    Row(
                      children: [
                        Text(
                          "Duration : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("${formatDuration(childContent!)}"),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Instructions
                    Row(
                      children: [
                        Text(
                          "Instructions : ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text("Answer all questions")),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Take Quiz Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          final userBox = Hive.box('userData');
                          final List<dynamic> quizzesTaken = userBox.get('quizzes', defaultValue: []);
                          final int quizId = childContent!.settings!.id;

                          if (quizzesTaken.contains(quizId)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Quiz Already Taken"),
                                content: Text("You've already taken this quiz."),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              ),
                            );
                          } else {
                            print("Qs${childContent!.questions}");
                            // Add quizId to Hive
                            quizzesTaken.add(quizId);
                            userBox.put('quizzes', quizzesTaken);
                            // Navigate to quiz screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SingleAssessmentScreen(
                                  childContent: childContent,
                                  questions: childContent!.questions,
                                  duration: Duration(minutes: int.tryParse(childContent!.settings!.duration) ?? 0),
                                  quizTitle: childContent!.settings!.title,
                                ),
                              ),
                            );
                          }
                        }
                        ,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.paymentTxtColor1,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Take Quiz",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
