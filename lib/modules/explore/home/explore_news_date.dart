import 'package:flutter/material.dart';

class TimeAgoWidget extends StatelessWidget {
  final String? postedDate; // Example: "2024-02-15T12:00:00.000Z"

  const TimeAgoWidget({Key? key, required this.postedDate}) : super(key: key);

  String getTimeAgo() {
    try {
      DateTime dop = DateTime.parse(postedDate!);
      Duration difference = DateTime.now().difference(dop);

      if (difference.inSeconds < 60)
        return '${difference.inSeconds} seconds ago';
      if (difference.inMinutes < 60)
        return '${difference.inMinutes} minutes ago';
      if (difference.inHours < 24) return '${difference.inHours} hours ago';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${(difference.inDays / 7).floor()} weeks ago';
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(getTimeAgo(),
        style: TextStyle(fontSize: 16, color: Colors.black));
  }
}
