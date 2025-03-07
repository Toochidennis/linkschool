import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/custom_input_field.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final String networkImage =
      'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';
  late double opacity;

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'What is Punctuality?',
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
                      height: 100, // Increased height to accommodate the layout
                      color: Colors.blue.shade100,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2, // Takes up 75% of the container
                            child: Image.network(
                              networkImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          const Expanded(
                            flex: 2, // Takes up 25% of the container
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.link, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'https://jdidlf.com.ng...',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        networkImage,
                        fit: BoxFit.cover,
                        height: 100,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CustomCommentInput(
                controller: _commentController,
                hintText: 'Add a comment...',
                onSendPressed: () {
                  // Handle send comment
                  if (_commentController.text.isNotEmpty) {
                    // Add your comment logic here
                    _commentController.clear();
                  }
                },
                onChanged: (value) {
                  // Handle text changes if needed
                },
                // Optional: Customize the appearance
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
      ),
    );
  }
}
