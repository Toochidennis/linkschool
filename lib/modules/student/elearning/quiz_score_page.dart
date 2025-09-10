import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/submitted_quiz_model.dart';
import 'package:linkschool/modules/providers/student/marked_quiz_provider.dart';
import 'package:linkschool/modules/student/elearning/resubmit_modal.dart';
import 'package:provider/provider.dart';

import '../../common/app_colors.dart';
import '../../model/student/elearningcontent_model.dart';
import '../../providers/student/marked_assignment_provider.dart';

class QuizScorePage extends StatefulWidget {
  final int year;
  final int term;
  final ChildContent childContent;


  const QuizScorePage({
    Key? key,
    required this.childContent,
    required this.year,
    required this.term,

  }) : super(key: key);

  @override
  State<QuizScorePage> createState() => _AssignmentScorePageState();
}

class _AssignmentScorePageState extends State<QuizScorePage> {
  MarkedQuizModel? markedquiz;
  int? academicTerm;
  int? academicYear;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchMarkedQuiz();
    // Show the modal bottom sheet after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }
  Future<void> _loadUserData() async {


    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      if (storedUserData != null) {
        final processedData = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};

        setState(() {
          academicYear = int.parse(settings['year']);
          academicTerm = settings['term'] ;
        });
      }

    } catch (e) {
      print('Error loading user data: $e');
    }

  }

  Future<void> fetchMarkedQuiz() async {
    final provider = Provider.of<MarkedQuizProvider>(context, listen: false);
    final data = await provider.fetchMarkedQuiz(widget.childContent.settings!.id , widget.year , widget.term );

    setState(() {
      markedquiz = data;
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading || markedquiz== null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.childContent.settings?.title ?? "No Title", style: TextStyle(color: Colors.white), ),
        backgroundColor:  AppColors.paymentTxtColor1
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score Card
          Card(
            color: Colors.blue.shade50,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Score: ${markedquiz!.score}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Marked: ${markedquiz!.markingScore}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Date: ${markedquiz!.date}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Answers list
          ...markedquiz!.answers.map((ans) {
            final isCorrect = ans.answer.trim().toLowerCase() ==
                ans.correct.trim().toLowerCase();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(ans.question),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Answer: ${ans.answer}"),
                    Text("Correct Answer: ${ans.correct}"),
                  ],
                ),
                trailing: Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}