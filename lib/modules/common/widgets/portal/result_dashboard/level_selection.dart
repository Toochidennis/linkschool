// lib/widgets/level_selection.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/select_class_button.dart';
import 'package:linkschool/modules/portal/e-learning/empty_syllabus_screen.dart';
import 'package:linkschool/modules/portal/result/class_detail/class_detail_screen.dart';


class LevelSelection extends StatefulWidget {
  // const LevelSelection({Key? key}) : super(key: key);
  final bool isSecondScreen;
  final List<String> subjects;

  const LevelSelection({
    Key? key,
    this.isSecondScreen = false,
    this.subjects = const [],
  }) : super(key: key);

  @override
  State<LevelSelection> createState() => _LevelSelectionState();
}

class _LevelSelectionState extends State<LevelSelection> {
  String _selectedLevel = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLevelBox('BASIC ONE', 'assets/images/result/bg_box1.svg'),
        _buildLevelBox('BASIC TWO', 'assets/images/result/bg_box2.svg'),
        _buildLevelBox('JSS ONE', 'assets/images/result/bg_box3.svg'),
        _buildLevelBox('JSS TWO', 'assets/images/result/bg_box4.svg'),
        _buildLevelBox('JSS THREE', 'assets/images/result/bg_box5.svg'),
        const SizedBox(height: 100,)
      ],
    );
  }

  Widget _buildLevelBox(String levelText, String backgroundImagePath) {
    return GestureDetector(
      onTap: () => _toggleOverlay(levelText),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              SvgPicture.asset(
                backgroundImagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      levelText,
                      style: AppTextStyles.normal700P(
                          fontSize: 20.0,
                          color: AppColors.backgroundLight,
                          height: 1.04),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: 148,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.backgroundLight, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextButton(
                        onPressed: () => _toggleOverlay(levelText),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View level performance',
                          style: AppTextStyles.normal700P(
                              fontSize: 12,
                              color: AppColors.backgroundLight,
                              height: 1.2),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
// lib/widgets/level_selection.dart (continued)
            ],
          ),
        ),
      ),
    );
  }

  void _toggleOverlay(String level) {
    setState(() {
      _selectedLevel = level;
      if (widget.isSecondScreen) {
        _showCourseSelectionDialog();
      } else {
        _showClassSelectionDialog();
      }
    });
  }

  void _showClassSelectionDialog() {
    final classes = [
      'A',
      'B',
      'C',
      'D',
      'E',
    ];
    final levelPrefix = _selectedLevel.split(' ')[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Select Class',
                  style: AppTextStyles.normal600(
                      fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: SelectClassButton(
                          text: '$levelPrefix ${classes[index]}',
                          onTap: () {
                            Navigator.of(context).pop();
                            _navigateToClassDetail(
                                '$levelPrefix ${classes[index]}');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCourseSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Select Course',
                  style: AppTextStyles.normal600(
                      fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.builder(
                    itemCount: widget.subjects.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: _buildSubjectButton(widget.subjects[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectButton(String subject) {
    return ElevatedButton(
      onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmptySyllabusScreen(),
      ),
    );
        
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        // onPrimary: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        subject,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _navigateToClassDetail(String className) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClassDetailScreen(className: className),
      ),
    );
  }
}
