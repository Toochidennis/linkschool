import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class CustomToaster {

  static void toastSuccess(BuildContext context, String title, String message) {
    MotionToast.success(
      // icon: Icons.check_circle, // Success icon
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, 
      animationType: AnimationType.slideInFromTop,
      contentPadding: const EdgeInsets.all(10), 

    ).show(context);
  }

  static void toastWarning(BuildContext context, String title, String message) {
    MotionToast.warning(
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, 
      animationType: AnimationType.slideInFromTop,
      contentPadding: const EdgeInsets.all(10), 
    ).show(context);
  }

  static void toastInfo(BuildContext context, String title, String message) {
    MotionToast.info(
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, // Change to top, center, or bottom
      animationType: AnimationType.slideInFromTop,
      contentPadding: const EdgeInsets.all(10), 
    ).show(context);
  }

  static void toastError(BuildContext context, String title, String message) {
    MotionToast.error(
      title: Text(title, style: TextStyle(color: Colors.white)),
      description: Text(message, style: TextStyle(color: Colors.white)),
      position: MotionToastPosition.top, // Change to top, center, or bottom
      animationType: AnimationType.slideInFromTop,
      contentPadding: const EdgeInsets.all(10), // // Adjust animation direction
    ).show(context);
  }
}
