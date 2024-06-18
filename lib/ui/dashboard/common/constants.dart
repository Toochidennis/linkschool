import 'package:flutter/material.dart';

BoxDecoration customBoxDecoration(BuildContext context) {
  final Brightness brightness = Theme.of(context).brightness;
  var opacity = brightness == Brightness.light ? 0.1 : 0.15;

  return BoxDecoration(
    image: DecorationImage(
      image: const AssetImage('assets/images/background.png'),
      fit: BoxFit.cover,
      opacity: opacity,
    ),
  );
}
