import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  style: TextStyle(color: Colors.white, fontSize: 16)),
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
      height: 560,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 56.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Anti-corruption in the world',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'What is the reason for corruption in Nigeria?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ..._buildOptions(),
        ],
      ),
    );
  }

  List<Widget> _buildOptions() {
    final options = [
      'Poverty',
      'Greed',
      'Lack of strong institutions',
      'All of the above'
    ];
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () => _selectOption(index),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getOptionColor(index),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _selectedOption,
                  onChanged: (value) => _selectOption(value!),
                  activeColor: AppColors.eLearningBtnColor1,
                ),
                Text(option),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Color _getOptionColor(int index) {
    if (_selectedOption == index && _isAnswered) {
      return _isCorrect
          ? AppColors.eLearningBtnColor6
          : AppColors.eLearningBtnColor7;
    }
    return Colors.transparent;
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOption = index;
      _isAnswered = true;
      _isCorrect = index == 3;
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
