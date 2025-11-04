import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onTimeUp;

  const TimerWidget({
    super.key,
    required this.initialSeconds,
    required this.onTimeUp,
  });

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remainingTimeInSeconds;
  Timer? _timer;
  bool _isTimerStopped = false;

  @override
  void initState() {
    super.initState();
    _remainingTimeInSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0 && !_isTimerStopped) {
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
        timer.cancel();
        if (_remainingTimeInSeconds <= 0) {
          widget.onTimeUp();
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerStopped = true;
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/e_learning/stopwatch_icon.svg',
          width: 29,
          height: 29,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(_remainingTimeInSeconds),
          style: const TextStyle(color: Colors.white, fontSize: 32),
        ),
      ],
    );
  }
}
