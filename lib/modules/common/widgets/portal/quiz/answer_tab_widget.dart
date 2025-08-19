import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/quiz/quiz_resultscreen.dart';

class AnswersTabWidget extends StatefulWidget {
  const AnswersTabWidget({super.key});

  @override
  _AnswersTabWidgetState createState() => _AnswersTabWidgetState();
}

class _AnswersTabWidgetState extends State<AnswersTabWidget> {
  String _selectedCategory = 'SUBMITTED';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNavigationRow(),
        Expanded(
          child: _selectedCategory == 'SUBMITTED'
              ? _buildSubmittedContent()
              : _buildListContent(_selectedCategory),
        ),
      ],
    );
  }

  Widget _buildNavigationRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavigationContainer('SUBMITTED'),
          _buildNavigationContainer('UNMARKED'),
          _buildNavigationContainer('MARKED'),
        ],
      ),
    );
  }

  Widget _buildNavigationContainer(String text) {
    bool isSelected = _selectedCategory == text;
    int itemCount = _getItemCount(text);

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = text),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 89,
          height: 30,
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromRGBO(171, 190, 255, 1) : const Color.fromRGBO(224, 224, 224, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryLight : Colors.black,
                  ),
                ),
              ),
              if (!isSelected && itemCount > 0)
                Positioned(
                  right: 0,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(244, 67, 54, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildListContent('SUBMITTED')),
        // const Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'NOT SUBMITTED',
            style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
          ),
        ),
        Expanded(child: _buildListContent('NOT SUBMITTED')),
      ],
    );
  }

  Widget _buildListContent(String category) {
    // This is a mock list
    List<Map<String, String>> items = [
      {'name': 'Jane Doe', 'progress': '9 of 15 questions answered', 'time': 'Yesterday'},
      {'name': 'Sam Smith', 'progress': '12 of 15 questions answered', 'time': 'Today'},
    ];

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        var item = items[index];
        return GestureDetector(
          onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (context) => QuizResultsScreen()));
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(item['name']![0], style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundLight),),
            ),
            title: Text(item['name']!),
            subtitle: Text(item['progress']!),
            trailing: Text(item['time']!),
          ),
        );
      },
    );
  }

  int _getItemCount(String category) {
    // Mock data.
    switch (category) {
      case 'SUBMITTED':
        return 5;
      case 'UNMARKED':
        return 3;
      case 'MARKED':
        return 2;
      default:
        return 0;
    }
  }
}