import 'package:flutter/material.dart';

class ExploreHome extends StatefulWidget {
  const ExploreHome({super.key});

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> {
  @override
  Widget build(BuildContext context) {
    // Get the current brightness to determine if the theme is light or dark
    var brightness = Theme.of(context).brightness;
    double backgroundOpacity = brightness == Brightness.dark ? 0.15 : 0.1;

    return Scaffold(
        body: Stack(
      children: [
        Opacity(
          opacity: backgroundOpacity, // Set opacity to 10%
          child: Image.asset(
            'assets/images/img.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Search'),
              ),
            )
          ],
        )
      ],
    ));
  }
}
