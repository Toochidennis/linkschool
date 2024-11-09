import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/result/behaviour_settings_screen.dart';

class SelectTopicScreen extends StatefulWidget {
  final String callingScreen;
  final VoidCallback? onTopicCreated;

  const SelectTopicScreen({
    Key? key,
    required this.callingScreen,
    this.onTopicCreated,
  }) : super(key: key);

  @override
  State<SelectTopicScreen> createState() => _SelectTopicScreenState();
}

class _SelectTopicScreenState extends State<SelectTopicScreen> {
  late final String callingScreen;
  late final VoidCallback? onTopicCreated;
  List<String> topics = ['Punctuality', 'Reproduction', 'Grammar'];
  String? selectedTopic;
  late double opacity;

  @override
  void initState() {
    super.initState();
    callingScreen = widget.callingScreen;
    onTopicCreated = widget.onTopicCreated;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Select topic',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomSaveElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedTopic ?? 'No Topic');
              },
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomInputField(
                hintText: 'Add new Topic',
                onSubmitted: _addTopic,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TopicsList(
                  topics: topics,
                  selectedTopic: selectedTopic,
                  onSelect: _selectTopic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTopic(String topic) {
    setState(() {
      topics.add(topic);
      selectedTopic = topic;
      if (onTopicCreated != null) {
        onTopicCreated!();
      }
    });
  }

  void _selectTopic(String topic) {
    setState(() {
      selectedTopic = topic;
    });
  }
}

class TopicsList extends StatelessWidget {
  final List<String> topics;
  final String? selectedTopic;
  final Function(String) onSelect;

  const TopicsList({
    Key? key,
    required this.topics,
    required this.selectedTopic,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return TopicItem(
          topic: topics[index],
          isSelected: topics[index] == selectedTopic,
          onSelect: onSelect,
        );
      },
    );
  }
}

class TopicItem extends StatelessWidget {
  final String topic;
  final bool isSelected;
  final Function(String) onSelect;

  const TopicItem({
    Key? key,
    required this.topic,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(topic),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/e_learning/topic_icon1.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(topic),
              ),
              if (isSelected)
                SvgPicture.asset(
                  'assets/icons/result/check.svg',
                  width: 24,
                  height: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}