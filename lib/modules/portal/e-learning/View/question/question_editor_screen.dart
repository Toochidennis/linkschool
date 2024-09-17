import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';


class QuestionEditorScreen extends StatefulWidget {
  final String questionType;

  const QuestionEditorScreen({Key? key, required this.questionType}) : super(key: key);

  @override
  _QuestionEditorScreenState createState() => _QuestionEditorScreenState();
}


class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  bool _showAttachmentOptions = false;
  late double opacity;

  @override
  void initState() {
    super.initState();
    if (widget.questionType == 'multiple_choice') {
      _addOption();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(widget.questionType == 'short_answer' ? 'Short Answer' : 'Multiple Choice'),
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
              onPressed: _saveQuestion,
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Question'),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'e.g., What is your name?',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _showAttachmentOptionsOverlay,
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/e_learning/attachment_icon.svg'),
                      const SizedBox(width: 8),
                      const Text('Add attachment'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.questionType == 'short_answer')
                  _buildShortAnswerSection()
                else
                  _buildMultipleChoiceSection(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Set score ', style: TextStyle(fontSize: 16)),
                    Text('(optional)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortAnswerSection() {
    return Row(
      children: [
        SvgPicture.asset('assets/icons/short_answer_icon.svg'),
        const SizedBox(width: 8),
        const Text('Short answer'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Show options for short answer
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildMultipleChoiceSection() {
    return Column(
      children: [
        ..._optionControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Row(
            children: [
              Radio(value: index, groupValue: -1, onChanged: (value) {}),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Option ${index + 1}',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showOptionMenu(index);
                },
              ),
              const Divider(),
            ],
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add option'),
          onPressed: _addOption,
        ),
      ],
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _showAttachmentOptionsOverlay() {
    setState(() {
      _showAttachmentOptions = true;
    });
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Insert link'),
                onTap: () {
                  // Handle insert link
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload a file'),
                onTap: () {
                  // Handle file upload
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  // Handle take photo
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionMenu(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Attach file'),
                onTap: () {
                  // Handle attach file
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  _deleteOption(index);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
    });
  }

  void _saveQuestion() {
    final questionData = {
      'type': widget.questionType,
      'question': _questionController.text,
      'options': widget.questionType == 'multiple_choice'
          ? _optionControllers.map((controller) => controller.text).toList()
          : null,
    };
    Navigator.of(context).pop(questionData);
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}