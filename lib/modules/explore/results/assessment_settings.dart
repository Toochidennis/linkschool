import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';

class AssessmentSettingScreen extends StatefulWidget {
  const AssessmentSettingScreen({super.key});

  @override
  _AssessmentSettingScreenState createState() =>
      _AssessmentSettingScreenState();
}

class _AssessmentSettingScreenState extends State<AssessmentSettingScreen> {
  String? _selectedLevel;
  final _assessmentNameController = TextEditingController();
  final _assessmentScoreController = TextEditingController();
  final List<String> levels = [
    'Primary One',
    'Junior Secondary School One (JSS1)',
    'Junior Secondary School Two (JSS2)',
    'Junior Secondary School Three (JSS3)',
    'Senior Secondary School One (SS1)',
    'Senior Secondary School Two (SS2)',
    'Senior Secondary School Three (SS3)'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child:
                Text('Assessment Settings', style: AppTextStyles.appBarTitle)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Level', style: AppTextStyles.label),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    offset: Offset(0, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                ),
                items: levels.map((String level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLevel = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              // color: AppColors.backgroundLight,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              elevation: 3,
              shadowColor: AppColors.shadowColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Assessment name:',
                              style: AppTextStyles.inputLabel),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _assessmentNameController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.cardBorder),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Text('Assessment score:',
                              style: AppTextStyles.inputLabel),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _assessmentScoreController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.cardBorder),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add your functionality here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryLight,
                            fixedSize: const Size(100, 30),
                            shape:  RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text(
                            'Add +',
                            style: AppTextStyles.normal6Light,
                          ),
                        ),
                      ),
                    ],
                  ),

              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save settings functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  minimumSize: const Size(262, 40), // Fixed width and height
                  padding: const EdgeInsets.all(0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0), // Border radius
                    side: const BorderSide(
                        color: AppColors.primaryLight), // Border color
                  ),
                ),
                child: const Text(
                  'Save settings',
                  style: AppTextStyles.normal6Light,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
