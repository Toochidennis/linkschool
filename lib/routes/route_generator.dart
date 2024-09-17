import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/dashboard_switcher.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/portal/e-learning/View/question/question_editor_screen.dart';
// import 'package:linkschool/modules/portal/e-learning/View/question/short_question.dart';
import 'package:linkschool/modules/portal/e-learning/View/question/view_question_screen.dart';
// import 'package:linkschool/modules/portal/e-learning/question_screen.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const DashboardSwitcher());
      case '/view-question':
        // Validation of correct data type
        if (args is Question) {
          return MaterialPageRoute(
            builder: (_) => ViewQuestionScreen(question: args),
          );
        }
        // If args is not of the correct type, return an error page
        return _errorRoute();
      case '/short-answer-question':
        return MaterialPageRoute(builder: (_) => QuestionEditorScreen(questionType: 'short_answer'),);
      case '/multiple-choice-question':
        return MaterialPageRoute(builder: (_) => const QuestionEditorScreen(questionType: 'multiple_choice'));
      case '/section-question':
        return MaterialPageRoute(builder: (_) => const QuestionEditorScreen(questionType: 'section'),);
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}