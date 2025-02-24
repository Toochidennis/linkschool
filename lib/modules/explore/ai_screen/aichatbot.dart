import "package:flutter/material.dart";
import "package:linkschool/modules/common/constants.dart";
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';


class Aichatbot extends StatefulWidget {
  const Aichatbot({super.key});

  @override
  _AichatbotState createState() => _AichatbotState();
}

class _AichatbotState extends State<Aichatbot> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '1', firstName: 'User');
  final _bot = const types.User(id: '2', firstName: 'Bot');

  @override
  void initState() {
    super.initState();
    _addBotMessage("Welcome to LiveChat! What do you need help with today?");
  }

  void _addBotMessage(String text) {
    final message = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    _getBotResponse(message.text);
  }

  void _getBotResponse(String query) {
    Future.delayed(Duration(seconds: 1), () {
      String response;
      if (query.toLowerCase().contains("m4 macbook")) {
        response = "It costs approximately 2.5 million naira to get an M4 MacBook with 16GB RAM, depending on the vendor.";
      } else {
        response = "I'm not sure about that. Can you ask something else?";
      }
      _addBotMessage(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(context: context, title: 'Ask our Ai anything', centerTitle: true),
      body:Container(
        decoration: Constants.customBoxDecoration(context),
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      )
    );
  }
}


