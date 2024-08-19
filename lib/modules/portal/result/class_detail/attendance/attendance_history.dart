import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'dart:math';

class AttendanceHistoryScreen extends StatefulWidget {
  final String date;
  const AttendanceHistoryScreen({Key? key, required this.date}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final List<String> names = [
    'Ada', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace', 'Toochukwu',
  ];
  final colors = [AppColors.videoColor7, AppColors.attHistColor1];
  final random = Random();
  late List<bool> _isChecked;
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _isChecked = List<bool>.filled(names.length, true);
    _isSelected = List<bool>.filled(names.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          widget.date,
          style: AppTextStyles.normal600(
            fontSize: 18,
            color: AppColors.primaryLight,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundDark,
            width: 34.0,
            height: 34.0,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          final circleColor = colors[random.nextInt(colors.length)];
          return GestureDetector(
            onTap: () {
              setState(() {
                _isSelected[index] = !_isSelected[index];
              });
            },
            child: Container(
              color: _isSelected[index]
                  ? const Color.fromRGBO(239, 227, 255, 1)
                  : Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: circleColor,
                            child: Text(
                              name[0],
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isChecked[index] ? Icons.check_circle : Icons.check_circle_outline,
                            color: _isChecked[index] ? Colors.green : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isChecked[index] = !_isChecked[index];
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}