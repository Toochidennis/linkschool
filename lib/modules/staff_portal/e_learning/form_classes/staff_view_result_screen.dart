import 'package:flutter/material.dart';

class StaffViewResultScreen extends StatelessWidget {
  const StaffViewResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Result'),
      ),
      body: const Center(child: Text('View Result Screen')),
    );
  }
}