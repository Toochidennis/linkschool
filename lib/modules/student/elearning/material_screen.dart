import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/custom_input_field.dart';
import 'package:linkschool/modules/model/student/elearningcontent_model.dart';


class MaterialScreen extends StatefulWidget {
  final ElearningContentData elearningContentData;

  const MaterialScreen({super.key, required this.elearningContentData });

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}


class _MaterialScreenState extends State<MaterialScreen> {
  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';
  late double opacity;

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget materialp(ElearningContentData edat) {
    final hasFiles = edat.children.any(
          (child) =>
      child.contentFiles != null && child.contentFiles!.isNotEmpty,
    );

    if (hasFiles) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'What is ${widget.elearningContentData.title}?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'The below attached materials must be studied ahead of the mid-term test.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 32),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      color: Colors.blue.shade100,
                      child: Column(
                        children: widget.elearningContentData.children
                            .expand((child) => child.contentFiles ?? [])
                            .map(
                              (file) =>
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (file.fileName.endsWith('.jpg') ||
                                      file.fileName.endsWith('.png'))
                                    Image.network(
                                      file.fileName,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error,
                                          stackTrace) =>
                                      const Icon(Icons.broken_image),
                                    ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.link,
                                            color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            file.fileName,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                        )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              const Spacer(),
              CustomCommentInput(
                controller: _commentController,
                hintText: 'Add a comment...',
                onSendPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    _commentController.clear();
                  }
                },
                onChanged: (value) {},
                borderColor: Colors.grey[300],
                focusedBorderColor: Colors.grey[400],
                hintTextColor: Colors.grey[400],
                sendIconColor: Colors.grey[400],
                fontSize: 14,
                iconSize: 20,
              ),
            ],
          ),
        ),
      );
    }
    else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'What is ${widget.elearningContentData.title}?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Review the following questions:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Iterate through children and their questions
              ...widget.elearningContentData.children.expand((child) => child.questions).map(
                    (q) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q: ${q.questionText}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (q.options.isEmpty) // Short Answer
                        Text(
                          'Answer: ${q.correct.text}',
                          style: const TextStyle(color: Colors.green),
                        )
                      else ...[ // Multiple Choice
                        const Text('Options:'),
                        ...q.options.map(
                              (opt) => Row(
                            children: [
                              Icon(
                                opt.order == q.correct.order ? Icons.check_circle : Icons.circle,
                                size: 16,
                                color: opt.order == q.correct.order ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(child: Text(opt.text)),
                            ],
                          ),
                        )
                      ],
                      const Divider(),
                    ],
                  ),
                ),
              ).toList(),

              const Spacer(),

              // Comment input
              CustomCommentInput(
                controller: _commentController,
                hintText: 'Add a comment...',
                onSendPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    _commentController.clear();
                  }
                },
                onChanged: (value) {},
                borderColor: Colors.grey[300],
                focusedBorderColor: Colors.grey[400],
                hintTextColor: Colors.grey[400],
                sendIconColor: Colors.grey[400],
                fontSize: 14,
                iconSize: 20,
              ),
            ],
          ),
        ),
      );
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
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          "Material",
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
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
              ),
            ],
          ),
        ),
      ),
      body:
      materialp(widget.elearningContentData),
    );
  }
}