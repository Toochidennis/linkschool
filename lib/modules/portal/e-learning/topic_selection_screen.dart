
import 'package:flutter/material.dart';




class TopicSelectionScreen extends StatefulWidget {
  final String initialTopic;
  final Function(String) onSave;

  TopicSelectionScreen({required this.initialTopic, required this.onSave});

  @override
  _TopicSelectionScreenState createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  late String selectedTopic;

  @override
  void initState() {
    super.initState();
    selectedTopic = widget.initialTopic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select topic'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSave(selectedTopic);
              Navigator.of(context).pop();
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Add your list of topics here
          ListTile(
            title: Text('Rule of BODMAS'),
            onTap: () {
              setState(() {
                selectedTopic = 'Rule of BODMAS';
              });
            },
            trailing: selectedTopic == 'Rule of BODMAS' ? Icon(Icons.check) : null,
          ),
          // Add more ListTiles for other topics
        ],
      ),
    );
  }
}
