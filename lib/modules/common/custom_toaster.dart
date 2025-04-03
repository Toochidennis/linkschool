import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class CustomToaster {
  // void showToast({
  //   required String message,
  //   Toast toastLength = Toast.LENGTH_LONG,
  //   ToastGravity gravity = ToastGravity.TOP,
  //   Color backgroundColor = Colors.black54,
  //   Color textColor = Colors.white,
  //   double fontSize = 16.0,
  // }) {
  //   Fluttertoast.showToast(
  //     msg: message,
  //     toastLength: toastLength, // Toast duration: SHORT or LONG
  //     gravity: gravity, // Position: TOP, CENTER, or BOTTOM
  //     backgroundColor: backgroundColor, // Background color
  //     textColor: textColor, // Text color
  //     fontSize: fontSize, // Font size
  //   );
  // }

  // succesToaster

  // void successToast({
  //   required String message,
  //   Toast toastLength = Toast.LENGTH_LONG,
  //   ToastGravity gravity = ToastGravity.TOP,
  //   Color backgroundColor = Colors.green,
  //   Color textColor = Colors.white,
  //   double fontSize = 16.0,
  // }) {
  //   Fluttertoast.showToast(
  //     msg: message,
  //     toastLength: toastLength, // Toast duration: SHORT or LONG
  //     gravity: gravity, // Position: TOP, CENTER, or BOTTOM
  //     backgroundColor: backgroundColor, // Background color
  //     textColor: textColor, // Text color
  //     fontSize: fontSize, // Font size
  //   );
  // }

  // using snack Bar

// void showWaringToast(BuildContext context, String message, {
//   IconData icon = Icons.info,
//   Color backgroundColor = Colors.black54,
//   Color textColor = Colors.white,
//   double fontSize = 16.0,
// }) {
//   final snackBar = SnackBar(
//     content: Row(
//       children: [
//         Icon(icon, color: textColor), // Icon added
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             message,
//             style: TextStyle(color: textColor, fontSize: fontSize),
//           ),
//         ),
//       ],
//     ),
//     backgroundColor: backgroundColor,
//     behavior: SnackBarBehavior.floating, // Floating Snackbar
//     margin: const EdgeInsets.only(bottom: 760, left: 16, right: 16),
//     duration: const Duration(seconds: 2),
//      shape: RoundedRectangleBorder( // Border radius added
//       borderRadius: BorderRadius.circular(50),
//     ),
//   );

//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }

  static void toastSuccess(BuildContext context, String title, String message) {
    MotionToast.success(
      // icon: Icons.check_circle, // Success icon
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, // Change to top, center, or bottom
      animationType: AnimationType.fromTop,
      contentPadding: const EdgeInsets.all(10), // Adjust animation direction
      // width: 300,
      // primaryColor: Colors.green, // Success color
    ).show(context);
  }

  static void toastWarning(BuildContext context, String title, String message) {
    MotionToast.warning(
      // icon: Icons.check_circle, // Success icon
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, // Change to top, center, or bottom
      animationType: AnimationType.fromTop,
      contentPadding: const EdgeInsets.all(10), //// Adjust animation direction
      // width: 300,
      // primaryColor: Colors.green, // Success color
    ).show(context);
  }

  static void toastInfo(BuildContext context, String title, String message) {
    MotionToast.info(
      // icon: Icons.check_circle, // Success icon
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, // Change to top, center, or bottom
      animationType: AnimationType.fromTop,
      contentPadding: const EdgeInsets.all(10), //// Adjust animation direction
      // width: 300,
      // primaryColor: Colors.green, // Success color
    ).show(context);
  }

  static void toastError(BuildContext context, String title, String message) {
    MotionToast.error(
      // icon: Icons.check_circle, // Success icon
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, // Change to top, center, or bottom
      animationType: AnimationType.fromTop,
      contentPadding: const EdgeInsets.all(10), // // Adjust animation direction
      // width: 300,
      // primaryColor: Colors.green, // Success color
    ).show(context);
  }
}
