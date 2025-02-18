import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int? _selectedOption;
  final bool _isAnswered = false;
  final bool _isCorrect = false;
  final bool _selected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eLearningBtnColor1,
      appBar: AppBar(
        backgroundColor: AppColors.eLearningBtnColor1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: const Text('2nd Continuous Assessment',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            Row(
              children: [
                Image(image: AssetImage('assets/icons/alarm_clock.png')),
                const SizedBox(width: 8),
                Text('58:22',
                    style: AppTextStyles.normal700(
                        fontSize: 32, color: Colors.white)),
              ],
            ),
            _buildProgressSection(),
            const SizedBox(height: 16),
            _buildQuestionCard(),
            const SizedBox(height: 16),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      width: 400,
      height: 65,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.eLearningContColor1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('02 of 15',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
              SizedBox(width: 8),
              Text('Completed',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: const LinearProgressIndicator(
              value: 2 / 15,
              backgroundColor: AppColors.eLearningContColor2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.eLearningContColor3),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: 400,
      height: 458,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2nd Continuous Assessment Test',
            style:AppTextStyles.normal700(fontSize: 18, color: AppColors.attBorderColor1),
          ),
          const SizedBox(height: 8),
         Text(
            'What is the reason for corruption in Nigeria?',
            style: AppTextStyles.normal700(fontSize: 22, color: AppColors.text3Light)
          ),
          const SizedBox(height: 16),
          ..._buildOptions(),
        ],
      ),
    );
  }

  List<Widget> _buildOptions() {
    final options = [
      'Balablu',
      'Balablu',
      'Balablu',
      'Balablu'
    ];
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      return Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () => _selectOption(index),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _getOptionColor(index),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedOption == index
                        ? AppColors.attCheckColor2
                        : Colors.grey,
                    width: 1,
                  )),
              child: Container(
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _selectedOption,
                      onChanged: (value) => _selectOption(value!),
                      activeColor: AppColors.attCheckColor2,
                    ),
                    Text(option,style:AppTextStyles.normal600(fontSize: 16, color: AppColors.text3Light) ,),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Color _getOptionColor(int index) {
    if (_selectedOption == index) {
      return AppColors
          .eLearningBtnColor6; // Light green background when selected
    }
    return Colors.transparent;
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOption = index;
    });
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Handle previous
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child:
                const Text('Previous', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle next
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningBtnColor5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Next', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
