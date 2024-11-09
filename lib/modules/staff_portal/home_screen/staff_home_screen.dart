import 'package:flutter/material.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Portal'),
      ),
      body: const Center(
        child: Text('This is the Staff Portal screen.'),
      ),
    );
  }
}