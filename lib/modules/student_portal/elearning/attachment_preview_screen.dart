import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin_portal/e_learning/assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/custom_input_field.dart'; // Import the custom input

class Comment {
  final String name;
  final String date;
  final String text;

  Comment({required this.name, required this.date, required this.text});
}

class AttachmentPreviewScreen extends StatefulWidget {
  final List<AttachmentItem> attachments;

  const AttachmentPreviewScreen({Key? key, required this.attachments}) : super(key: key);

  @override
  State<AttachmentPreviewScreen> createState() => _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
  late double opacity;
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];

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
              Expanded(
                flex: 1,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: widget.attachments.length,
                  itemBuilder: (context, index) {
                    final item = widget.attachments[index];
                    return Card(
                      child: ListTile(
                        leading: Image.asset(
                          item.iconPath,
                          width: 32,
                          height: 32,
                        ),
                        title: Text(
                          item.content,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            // Handle attachment removal
                          },
                        ),
                      ),
                    );
                  },
                ),
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