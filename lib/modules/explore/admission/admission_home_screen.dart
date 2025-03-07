import 'package:flutter/material.dart';

import 'admission_detail_screen.dart';

class AdmissionHomeScreen extends StatelessWidget {
  const AdmissionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to SchoolProfilePage when button is pressed
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SchoolProfileScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'View School Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}