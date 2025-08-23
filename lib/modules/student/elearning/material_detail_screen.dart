import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';

import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/student/elearning/attachment_preview_screen.dart';

import '../../common/widgets/portal/attachmentItem.dart';
import '../../model/student/elearningcontent_model.dart';

class MaterialDetailScreen extends StatefulWidget {
  final ChildContent childContent;

  const MaterialDetailScreen({super.key, required this.childContent});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreen();
}

class _MaterialDetailScreen extends State<MaterialDetailScreen> {
  late double opacity;
  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

  final TextEditingController _commentController = TextEditingController();
  final List<AttachmentItem> _attachments = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }



  void _navigateToAttachmentPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttachmentPreviewScreen(attachments: _attachments),
      ),
    );
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
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Material',
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
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Due: ${widget.childContent.endDate}',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.childContent.description}',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 24),
              Text(
                'Grade:${widget.childContent.grade} marks',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Attachment section
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(String text, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        color: AppColors.backgroundLight,
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 16),
            Text(text,
                style: AppTextStyles.normal400(
                    fontSize: 16, color: AppColors.backgroundDark)),
          ],
        ),
      ),
    );
  }
}
