import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/custom_input_field.dart';

import '../../common/widgets/portal/attachmentItem.dart'; // Import the custom input

class Comment {
  final String name;
  final String date;
  final String text;

  Comment({required this.name, required this.date, required this.text});
}

class AttachmentPreviewScreen extends StatefulWidget {
  final List<AttachmentItem> attachments;

  const AttachmentPreviewScreen({super.key, required this.attachments});

  @override
  State<AttachmentPreviewScreen> createState() => _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
  late double opacity;
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
   final List<AttachmentItem> _attachments = [];

  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add(Comment(
          name: 'Johnson Mike', 
          date: '03 Jan', 
          text: _commentController.text
        ));
        _commentController.clear();
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Add attachment',
                style: AppTextStyles.normal600(
                    fontSize: 20, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildAttachmentOption(
                  'Insert link',
                  'assets/icons/student/link1.svg',
                  _showInsertLinkDialog),
              _buildAttachmentOption(
                  'Upload file', 'assets/icons/e_learning/upload_file.svg', _uploadFile),
              _buildAttachmentOption(
                  'Take photo', 'assets/icons/e_learning/take_photo.svg', _takePhoto),
              _buildAttachmentOption(
                  'Record Video', 'assets/icons/e_learning/record_video.svg', _recordVideo),
            ],
          ),
        );
      },
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
          'Your work',
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
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
              const SizedBox(height: 16),
              // Two-column attachment layout
             const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              // Custom Comment Input Field
              CustomCommentInput(
                controller: _commentController,
                hintText: 'Leave a comment for your teacher',
                onSendPressed: _addComment,
                onChanged: (value) {
                  // Optional: Add any additional logic for text changes
                },
              ),
              const SizedBox(height: 16),

              // Comments section
              if (_comments.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Class comments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // Person icon in gray circle
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                radius: 20,
                                child: const Icon(Icons.person, color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          comment.date,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(comment.text),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              
              const Spacer(), // This will push the remaining buttons to the bottom
              
              // Add work and Submit buttons
              ElevatedButton(
                onPressed: () {
                  // Show attachment options again
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.eLearningBtnColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add work', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              
              // Change Submit to TextButton
              TextButton(
                onPressed: () {
                  // Handle submit
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.eLearningBtnColor1,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInsertLinkDialog() {
    TextEditingController linkController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Insert Link',
            style: AppTextStyles.normal600(
                fontSize: 20, color: AppColors.backgroundDark),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: linkController,
            decoration: InputDecoration(
              fillColor: Colors.grey[100],
              filled: true,
              hintText: 'Enter link here',
              prefixIcon: SvgPicture.asset(
                'assets/icons/e_learning/link3.svg',
                width: 24,
                height: 24,
                fit: BoxFit.scaleDown,
              ),
              border: const UnderlineInputBorder(),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryLight),
              ),
            ),
          ),
          actions: [
            CustomOutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              text: 'Cancel',
              borderColor: AppColors.eLearningBtnColor3.withOpacity(0.4),
              textColor: AppColors.eLearningBtnColor3,
            ),
            CustomSaveElevatedButton(
              onPressed: () {
                if (linkController.text.isNotEmpty) {
                  _addAttachment(
                      linkController.text, 'assets/icons/e_learning/link3.svg');
                }
                Navigator.of(context).pop();
              },
              text: 'Save',
            ),
          ],
        );
      },
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

Future<void> _uploadFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    String fileName = result.files.single.name;
    _addAttachment(fileName, 'assets/icons/e_learning/upload.svg');
    // _navigateToAttachmentPreview();
  }
}

Future<void> _takePhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
  if (photo != null) {
    _addAttachment('Photo: ${photo.name}', 'assets/icons/e_learning/camera.svg');
    // _navigateToAttachmentPreview();
  }
}


  Future<void> _recordVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      _addAttachment('Video: ${video.name}', 'assets/icons/e_learning/video.svg');
    }
  }

  void _addAttachment(String content, String iconPath) {
    setState(() {
      _attachments.add(AttachmentItem(fileName: content, fileContent: '', iconPath: iconPath));
    });
  }
}




// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/assignment_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class Comment {
//   final String name;
//   final String date;
//   final String text;

//   Comment({required this.name, required this.date, required this.text});
// }

// class AttachmentPreviewScreen extends StatefulWidget {
//   final List<AttachmentItem> attachments;

//   const AttachmentPreviewScreen({Key? key, required this.attachments}) : super(key: key);

//   @override
//   State<AttachmentPreviewScreen> createState() => _AttachmentPreviewScreenState();
// }

// class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
//   late double opacity;
//   final TextEditingController _commentController = TextEditingController();
//   final List<Comment> _comments = [];

//   final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

//   void _addComment() {
//     if (_commentController.text.isNotEmpty) {
//       setState(() {
//         _comments.add(Comment(
//           name: 'Johnson Mike', 
//           date: '03 Jan', 
//           text: _commentController.text
//         ));
//         _commentController.clear();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.eLearningBtnColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Your work',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.eLearningBtnColor1,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Attachments',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.eLearningBtnColor1,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Two-column attachment layout
//               Expanded(
//                 flex: 1,
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 1.5,
//                   ),
//                   itemCount: widget.attachments.length,
//                   itemBuilder: (context, index) {
//                     final item = widget.attachments[index];
//                     return Card(
//                       child: ListTile(
//                         leading: Image.asset(
//                           item.iconPath,
//                           width: 32,
//                           height: 32,
//                         ),
//                         title: Text(
//                           item.content,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.close, color: Colors.red),
//                           onPressed: () {
//                             // Handle attachment removal
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               // const SizedBox(height: 16),
              
//               // Comment input field - MOVED UP
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _commentController,
//                       decoration: InputDecoration(
//                         hintText: 'Leave a comment for your teacher',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     onPressed: _addComment,
//                     icon: const Icon(Icons.send, color: Colors.blue),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Comments section
//               if (_comments.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Class comments',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.eLearningBtnColor1,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: _comments.length,
//                       itemBuilder: (context, index) {
//                         final comment = _comments[index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Row(
//                             children: [
//                               // Person icon in gray circle
//                               CircleAvatar(
//                                 backgroundColor: Colors.grey.shade300,
//                                 radius: 20,
//                                 child: const Icon(Icons.person, color: Colors.grey),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           comment.name,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           comment.date,
//                                           style: TextStyle(
//                                             color: Colors.grey.shade600,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Text(comment.text),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ),
              
//               const Spacer(), // This will push the remaining buttons to the bottom
              
//               // Add work and Submit buttons
//               ElevatedButton(
//                 onPressed: () {
//                   // Show attachment options again
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.eLearningBtnColor1,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: const Text('Add work', style: TextStyle(fontSize: 16, color: Colors.white)),
//               ),
//               const SizedBox(height: 8),
              
//               // Change Submit to TextButton
//               TextButton(
//                 onPressed: () {
//                   // Handle submit
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: AppColors.eLearningBtnColor1,
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }