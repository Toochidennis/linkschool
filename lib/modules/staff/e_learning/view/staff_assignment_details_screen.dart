import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/comment_model.dart';

import '../../../common/widgets/portal/attachmentItem.dart' show AttachmentItem;

class StaffAssignmentDetailsScreen extends StatefulWidget {
  final Assignment assignment ;
  const StaffAssignmentDetailsScreen(
      {super.key, required this.assignment});

  @override
  _StaffAssignmentDetailsScreenState createState() =>
      _StaffAssignmentDetailsScreenState();
}
 class _StaffAssignmentDetailsScreenState extends State<StaffAssignmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  bool _isAddingComment = false;
  late double opacity;
  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this as TickerProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Assignment',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.paymentTxtColor1),
            onSelected: (String result) {
              final attachments = widget.assignment.attachments;
              print('${attachments}');
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Instructions',
                style: AppTextStyles.normal600(
                    fontSize: 18, color: AppColors.paymentTxtColor1),
              ),
            ),
            Tab(
              child: Text(
                'Student work',
                style: AppTextStyles.normal600(
                    fontSize: 18, color: AppColors.paymentTxtColor1),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInstructionsTab(),
            const Center(child: Text('Student work content')),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDueDate(),
          _buildDivider(),
          _buildTitle(),
          _buildGrade(),
          _buildDivider(),
          _buildDescription(),
          _buildDivider(),
          _buildAttachments(),
          _buildDivider(),
          _buildCommentSection(),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey.withOpacity(0.5)),
    );
  }

  Widget _buildDueDate() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, bottom: 16.0, right: 16.0, left: 16.0),
      child: Row(
        children: [
          Text(
            'Due: ',
            style: AppTextStyles.normal600(
                fontSize: 16.0, color: AppColors.eLearningTxtColor1),
          ),
          Text(
            DateFormat('E, dd MMM yyyy (hh:mm a)').format(widget.assignment.dueDate),
            style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.paymentTxtColor1, width: 2.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.assignment.title,
          style: AppTextStyles.normal600(
            fontSize: 20.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
      ),
    );
  }

  Widget _buildGrade() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Grade : ',
            style: AppTextStyles.normal600(
                fontSize: 16.0, color: AppColors.eLearningTxtColor1),
          ),
          Text(
            widget.assignment.marks,
            style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Description : ',
            style: AppTextStyles.normal600(
                fontSize: 16.0, color: AppColors.eLearningTxtColor1),
          ),
          Expanded(
            child: Text(
              widget.assignment.description,
              style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    final attachments = widget.assignment.attachments;
    if (attachments == null || attachments.isEmpty) {
      return Center(child: Text('no attachment available'),);
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: List.generate(attachments.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: index < attachments.length - 1 ? 16.0 : 0),
              child: _buildAttachmentItem(attachments[index]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAttachmentItem(AttachmentItem attachment) {
    // Detect image by file extension or type
    final isImage = attachment.fileName!.toLowerCase().endsWith('.jpg') ||
        attachment.fileName!.toLowerCase().endsWith('.jpeg') ||
        attachment.fileName!.toLowerCase().endsWith('.png') ||
        attachment.fileName!.toLowerCase().endsWith('.gif') ||
        attachment.iconPath!.contains('material.svg') ||
        attachment.iconPath!.contains('photo');

    if (isImage) {
      // Build the full URL if needed
      final imageUrl = "https://linkskool.net/api/v3/portal/${attachment.fileName}";

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 100,
          errorBuilder: (context, error, stackTrace) => Image.network(
            networkImage,
            fit: BoxFit.cover,
            height: 100,
          ),
        ),
      );
    } else {
      // Not an image: show default image and file/link name
      return Container(
        height: 100,
        color: Colors.blue.shade100,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Image.network(
                networkImage,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachment.fileName!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Class comments',
              style:
                  AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
            ),
          ),
          ...comments.map(_buildCommentItem),
          _buildDivider(),
        ],
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isAddingComment
              ? _buildCommentInput()
              : InkWell(
                  onTap: () {
                    setState(() {
                      _isAddingComment = true;
                    });
                  },
                  child: Text(
                    'Add class comment',
                    style: AppTextStyles.normal500(
                        fontSize: 16.0, color: AppColors.paymentTxtColor1),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.paymentTxtColor1,
        child: Text(
          comment.author[0].toUpperCase(),
          style: AppTextStyles.normal500(
              fontSize: 18, color: AppColors.backgroundLight),
        ),
      ),
      title: Row(
        children: [
          Text(comment.author,
              style: AppTextStyles.normal600(
                  fontSize: 16.0, color: AppColors.backgroundDark)),
          const SizedBox(width: 8),
          Text(
            DateFormat('d MMMM').format(comment.date),
            style: AppTextStyles.normal400(fontSize: 14.0, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Text(
        comment.text,
        style:
            AppTextStyles.normal500(fontSize: 16, color: AppColors.text4Light),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Type your comment...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _addComment,
          color: AppColors.paymentTxtColor1,
        ),
      ],
    );
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add(Comment(
          author: 'Joe Onwe',
          text: _commentController.text,
          date: DateTime.now(),
        ));
        _commentController.clear();
        _isAddingComment = false;
      });
    }
  }
}


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/comment_model.dart';

// import '../../../common/widgets/portal/attachmentItem.dart' show AttachmentItem;

// class StaffAssignmentDetailsScreen extends StatefulWidget {
//   final Assignment assignment ;
//   const StaffAssignmentDetailsScreen(
//       {super.key, required this.assignment});

//   @override
//   _StaffAssignmentDetailsScreenState createState() =>
//       _StaffAssignmentDetailsScreenState();
// }

// class _StaffAssignmentDetailsScreenState
//     extends State<StaffAssignmentDetailsScreen> {
//   final TextEditingController _commentController = TextEditingController();
//   List<Comment> comments = [];
//   bool _isAddingComment = false;
//   late double opacity;
//   final String networkImage =
//       'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final Brightness brightness = Theme.of(context).brightness;
//     // opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//             widget.assignment.title,
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(
//               Icons.more_vert,
//               color: AppColors.paymentTxtColor1,
//             ),
//             onSelected: (String result) {
//                final attachments = widget.assignment.attachments; 
//                print('${attachments}');
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'edit',
//                 child: Text('Edit'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'delete',
//                 child: Text('Delete'),
//               ),
//             ],
//           ),
//         ],
//         backgroundColor: AppColors.backgroundLight,
//         // flexibleSpace: Container(
//         //   decoration: BoxDecoration(
//         //     image: DecorationImage(
//         //       image: AssetImage('assets/images/background.png'),
//         //       fit: BoxFit.cover,
//         //       opacity: opacity,
//         //     ),
//         //   ),
//         // ),
//       ),
//       body: _buildInstructionsTab(),
//     );
//   }

//   Widget _buildInstructionsTab() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildDueDate(),
//           _buildDivider(),
//           _buildTitle(),
//           _buildGrade(),
//           _buildDivider(),
//           _buildDescription(),
//           _buildDivider(),
//           _buildAttachments(),
//           _buildDivider(),
//           _buildCommentSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Divider(color: Colors.grey.withOpacity(0.5)),
//     );
//   }

//   Widget _buildDueDate() {
//     final DateTime dueDate =
//         DateTime.now().add(const Duration(days: 5, hours: 2));
//     return Padding(
//       padding: const EdgeInsets.only(
//           top: 20.0, bottom: 16.0, right: 16.0, left: 16.0),
//       child: Row(
//         children: [
//           Text(
//             'Due: ',
//             style: AppTextStyles.normal600(
//                 fontSize: 16.0, color: AppColors.eLearningTxtColor1),
//           ),
//           Text(
//             DateFormat('E, dd MMM yyyy (hh:mm a)').format(widget.assignment.dueDate),
//             style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTitle() {
//     const String title = 'Mid-Term Assignment';
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: AppColors.paymentTxtColor1, width: 2.0),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Text(
//           title,
//           style: AppTextStyles.normal600(
//             fontSize: 20.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGrade() {
//     const String marks = "85/100";
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Text(
//             'Grade : ',
//             style: AppTextStyles.normal600(
//                 fontSize: 16.0, color: AppColors.eLearningTxtColor1),
//           ),
//           Text(
//             widget.assignment.marks,
//             style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDescription() {
//     const String description = "Complete the mid-term review on chapters 1-3.";
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Text(
//             'Description : ',
//             style: AppTextStyles.normal600(
//                 fontSize: 16.0, color: AppColors.eLearningTxtColor1),
//           ),
//           Expanded(
//             child: Text(
//               widget.assignment.description,
//               style:
//                   AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }


//   Widget _buildAttachments() {
//   final attachments = widget.assignment.attachments; // List<AttachmentItem>
//   if (attachments.isEmpty) {
//     print(attachments);
//     return const SizedBox.shrink();
   
//   }
//   return Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Row(
//       children: List.generate(attachments.length, (index) {
//         return Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(right: index < attachments.length - 1 ? 16.0 : 0),
//             child: _buildAttachmentItem(attachments[index]),
//           ),
//         );
//       }),
//     ),
//   );
// }

//   // Widget _buildAttachments() {
//   //   const List<Map<String, String>> attachments = [
//   //     {
//   //       "type": "image",
//   //       "url":
//   //           "https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86"
//   //     },
//   //     {"type": "link", "url": "https://jdidlf.com.ng..."},
//   //   ];
//   //   return Padding(
//   //     padding: const EdgeInsets.all(16.0),
//   //     child: Row(
//   //       children: [
//   //         Expanded(
//   //           child: _buildAttachmentItem(attachments[0]),
//   //         ),
//   //         const SizedBox(width: 16),
//   //         Expanded(
//   //           child: _buildAttachmentItem(attachments[1]),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Widget _buildAttachmentItem(Map<String, String> attachment) {
//   //   if (attachment["type"] == "image") {
//   //     return ClipRRect(
//   //       borderRadius: BorderRadius.circular(8),
//   //       child: Image.network(
//   //         attachment["url"]!,
//   //         fit: BoxFit.cover,
//   //         height: 100,
//   //       ),
//   //     );
//   //   } else {
//   //     return Container(
//   //       height: 100,
//   //       color: Colors.blue.shade100,
//   //       child: Column(
//   //         children: [
//   //           Expanded(
//   //             flex: 2,
//   //             child: Image.network(
//   //               networkImage,
//   //               fit: BoxFit.cover,
//   //               width: double.infinity,
//   //             ),
//   //           ),
//   //           Expanded(
//   //             flex: 2,
//   //             child: Padding(
//   //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//   //               child: Row(
//   //                 children: [
//   //                   const Icon(Icons.link, color: Colors.blue),
//   //                   const SizedBox(width: 8),
//   //                   Expanded(
//   //                     child: Text(
//   //                       attachment["url"]!,
//   //                       overflow: TextOverflow.ellipsis,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   }
//   // }

//  Widget _buildAttachmentItem(AttachmentItem attachment) {
//   // Detect image by file extension or type
//   final isImage = attachment.fileName!.toLowerCase().endsWith('.jpg') ||
//                   attachment.fileName!.toLowerCase().endsWith('.jpeg') ||
//                   attachment.fileName!.toLowerCase().endsWith('.png') ||
//                   attachment.fileName!.toLowerCase().endsWith('.gif') ||
//                   attachment.iconPath!.contains('material.svg') || // your mapping for images
//                   attachment.iconPath!.contains('photo');

//   if (isImage) {
//     // Build the full URL if needed
//     final imageUrl ="https://linkskool.net/api/v3/portal/${attachment.fileName}";

//         print(imageUrl);

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: Image.network(
//         imageUrl,
//         fit: BoxFit.cover,
//         height: 100,
//         errorBuilder: (context, error, stackTrace) =>
//             Image.network(
//               networkImage,
//               fit: BoxFit.cover,
//               height: 100,
//             ),
//       ),
//     );
//   } else {
//     // Not an image: show default image and file/link name
//     return Container(
//       height: 100,
//       color: Colors.blue.shade100,
//       child: Column(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Image.network(
//               networkImage,
//               fit: BoxFit.cover,
//               height: 100,
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Row(
//                 children: [
//                   const Icon(Icons.link, color: Colors.blue),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       attachment.fileName!,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//   Widget _buildCommentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (comments.isNotEmpty) ...[
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Class comments',
//               style:
//                   AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
//             ),
//           ),
//           ...comments.map(_buildCommentItem),
//           _buildDivider(),
//         ],
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: _isAddingComment
//               ? _buildCommentInput()
//               : InkWell(
//                   onTap: () {
//                     setState(() {
//                       _isAddingComment = true;
//                     });
//                   },
//                   child: Text(
//                     'Add class comment',
//                     style: AppTextStyles.normal500(
//                         fontSize: 16.0, color: AppColors.paymentTxtColor1),
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCommentItem(Comment comment) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: AppColors.paymentTxtColor1,
//         child: Text(
//           comment.author[0].toUpperCase(),
//           style: AppTextStyles.normal500(
//               fontSize: 18, color: AppColors.backgroundLight),
//         ),
//       ),
//       title: Row(
//         children: [
//           Text(comment.author,
//               style: AppTextStyles.normal600(
//                   fontSize: 16.0, color: AppColors.backgroundDark)),
//           const SizedBox(width: 8),
//           Text(
//             DateFormat('d MMMM').format(comment.date),
//             style: AppTextStyles.normal400(fontSize: 14.0, color: Colors.grey),
//           ),
//         ],
//       ),
//       subtitle: Text(
//         comment.text,
//         style:
//             AppTextStyles.normal500(fontSize: 16, color: AppColors.text4Light),
//       ),
//     );
//   }

//   Widget _buildCommentInput() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: _commentController,
//             decoration: const InputDecoration(
//               hintText: 'Type your comment...',
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.send),
//           onPressed: _addComment,
//           color: AppColors.paymentTxtColor1,
//         ),
//       ],
//     );
//   }

//   void _addComment() {
//     if (_commentController.text.isNotEmpty) {
//       setState(() {
//         comments.add(Comment(
//           author: 'Joe Onwe',
//           text: _commentController.text,
//           date: DateTime.now(),
//         ));
//         _commentController.clear();
//         _isAddingComment = false;
//       });
//     }
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/admin_assignment_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/comment_model.dart';

// class StaffAssignmentDetailsScreen extends StatefulWidget {
//   const StaffAssignmentDetailsScreen({super.key, required Assignment assignment});

//   @override
//   _StaffAssignmentDetailsScreenState createState() => _StaffAssignmentDetailsScreenState();
// }

// class _StaffAssignmentDetailsScreenState extends State<StaffAssignmentDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _commentController = TextEditingController();
//   List<Comment> comments = [];
//   bool _isAddingComment = false;
//   late double opacity;
//   final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Assignment',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: AppColors.paymentTxtColor1,),
//             onSelected: (String result) {
//               // Handle menu item selection
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'edit',
//                 child: Text('Edit'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'delete',
//                 child: Text('Delete'),
//               ),
//             ],
//           ),
//         ],
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
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(
//               child: Text(
//                 'Instructions',
//                 style: AppTextStyles.normal600(
//                     fontSize: 18, color: AppColors.paymentTxtColor1),
//               ),
//             ),
//             Tab(
//               child: Text(
//                 'Student work',
//                 style: AppTextStyles.normal600(
//                     fontSize: 18, color: AppColors.paymentTxtColor1),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildInstructionsTab(),
//             const Center(child: Text('Student work content')),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInstructionsTab() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildDueDate(),
//           _buildDivider(),
//           _buildTitle(),
//           _buildGrade(),
//           _buildDivider(),
//           _buildDescription(),
//           _buildDivider(),
//           _buildAttachments(),
//           _buildDivider(),
//           _buildCommentSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Divider(color: Colors.grey.withOpacity(0.5)),
//     );
//   }

//   Widget _buildDueDate() {
//     final DateTime dueDate = DateTime.now().add(const Duration(days: 5, hours: 2));
//     return Padding(
//       padding: const EdgeInsets.only(
//           top: 20.0, bottom: 16.0, right: 16.0, left: 16.0),
//       child: Row(
//         children: [
//           Text(
//             'Due: ',
//             style: AppTextStyles.normal600(
//                 fontSize: 16.0, color: AppColors.eLearningTxtColor1),
//           ),
//           Text(
//             DateFormat('E, dd MMM yyyy (hh:mm a)').format(dueDate),
//             style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTitle() {
//     const String title = 'Mid-Term Assignment';
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: AppColors.paymentTxtColor1, width: 2.0),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Text(
//           title,
//           style: AppTextStyles.normal600(
//             fontSize: 20.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGrade() {
//     const String marks = "85/100";
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Text(
//             'Grade : ',
//             style: AppTextStyles.normal600(
//                 fontSize: 16.0, color: AppColors.eLearningTxtColor1),
//           ),
//           Text(
//             marks,
//             style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDescription() {
//     const String description = "Complete the mid-term review on chapters 1-3.";
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Text(
//             'Description : ',
//             style: AppTextStyles.normal600(
//                 fontSize: 16.0, color: AppColors.eLearningTxtColor1),
//           ),
//           Expanded(
//             child: Text(
//               description,
//               style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttachments() {
//     const List<Map<String, String>> attachments = [
//       {"type": "image", "url": "https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86"},
//       {"type": "link", "url": "https://jdidlf.com.ng..."},
//     ];
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildAttachmentItem(attachments[0]),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: _buildAttachmentItem(attachments[1]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttachmentItem(Map<String, String> attachment) {
//     if (attachment["type"] == "image") {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Image.network(
//           attachment["url"]!,
//           fit: BoxFit.cover,
//           height: 100,
//         ),
//       );
//     } else {
//       return Container(
//         height: 100,
//         color: Colors.blue.shade100,
//         child: Column(
//           children: [
//             Expanded(
//               flex: 2,
//               child: Image.network(
//                 networkImage,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.link, color: Colors.blue),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         attachment["url"]!,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _buildCommentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (comments.isNotEmpty) ...[
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Class comments',
//               style:
//                   AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
//             ),
//           ),
//           ...comments.map(_buildCommentItem),
//           _buildDivider(),
//         ],
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: _isAddingComment
//               ? _buildCommentInput()
//               : InkWell(
//                   onTap: () {
//                     setState(() {
//                       _isAddingComment = true;
//                     });
//                   },
//                   child: Text(
//                     'Add class comment',
//                     style: AppTextStyles.normal500(
//                         fontSize: 16.0, color: AppColors.paymentTxtColor1),
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCommentItem(Comment comment) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: AppColors.paymentTxtColor1,
//         child: Text(
//           comment.author[0].toUpperCase(),
//           style: AppTextStyles.normal500(
//               fontSize: 18, color: AppColors.backgroundLight),
//         ),
//       ),
//       title: Row(
//         children: [
//           Text(comment.author,
//               style: AppTextStyles.normal600(
//                   fontSize: 16.0, color: AppColors.backgroundDark)),
//           const SizedBox(width: 8),
//           Text(
//             DateFormat('d MMMM').format(comment.date),
//             style: AppTextStyles.normal400(fontSize: 14.0, color: Colors.grey),
//           ),
//         ],
//       ),
//       subtitle: Text(
//         comment.text,
//         style:
//             AppTextStyles.normal500(fontSize: 16, color: AppColors.text4Light),
//       ),
//     );
//   }

//   Widget _buildCommentInput() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: _commentController,
//             decoration: const InputDecoration(
//               hintText: 'Type your comment...',
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.send),
//           onPressed: _addComment,
//           color: AppColors.paymentTxtColor1,
//         ),
//       ],
//     );
//   }

//   void _addComment() {
//     if (_commentController.text.isNotEmpty) {
//       setState(() {
//         comments.add(Comment(
//           author: 'Joe Onwe',
//           text: _commentController.text,
//           date: DateTime.now(),
//         ));
//         _commentController.clear();
//         _isAddingComment = false;
//       });
//     }
//   }
// }