import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/add_material_screen.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/comment_model.dart';
import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;
import 'package:linkschool/modules/providers/admin/e_learning/comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../common/widgets/portal/attachmentItem.dart';

class AdminMaterialDetailsScreen extends StatefulWidget {
  final custom.Material material;
  final int? syllabusId;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final int? itemId;
  final List<Map<String, dynamic>>? syllabusClasses;
  

  const AdminMaterialDetailsScreen({
    super.key,
    required this.material,
    this.syllabusId,
    this.courseId,
    this.levelId,
    this.classId,
    this.courseName,
    this.itemId,
    this.syllabusClasses,
  });

  @override
  _AdminMaterialDetailsScreenState createState() => _AdminMaterialDetailsScreenState();
}

class _AdminMaterialDetailsScreenState extends State<AdminMaterialDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final FocusNode _commentFocusNode = FocusNode();
  List<Comment> comments = [];
  bool _isAddingComment = false;
  bool _isEditing = false;
  Comment? _editingComment;
  late double opacity;
  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';
 String? creatorName;
    int? creatorId;
  int? academicTerm;
  String? academicYear;

  @override
   void initState() {
  super.initState();
  _loadUserData();
  if (mounted) setState(() {

  });
  _tabController = TabController(length: 2, vsync: this);
  locator<CommentProvider>().fetchComments(widget.itemId.toString());
  _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !locator<CommentProvider>().isLoading &&
        locator<CommentProvider>().hasNext) {
      Provider.of<CommentProvider>(context, listen: false)
          .fetchComments(widget.itemId.toString());
    }
  });
  // Add listener to handle tab changes
  _tabController.addListener(_handleTabChange);
}

void _handleTabChange() {
  if (_tabController.indexIsChanging && mounted) {
    setState(() {
      // Reset comment input state when switching tabs
      _isAddingComment = false;
      _isEditing = false;
      _editingComment = null;
      _commentController.clear();
      _commentFocusNode.unfocus();
    });
  }
}

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

   Future<void> _loadUserData() async {
  

    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      if (storedUserData != null) {
        final processedData = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};

        setState(() {
          creatorId = profile['staff_id'] as int?;
          creatorName = profile['name']?.toString();
          academicYear = settings['year']?.toString();
         academicTerm = settings['term'] as int?;
        });
      }
    print('Creator ID: $creatorId');
    print('Creator Name: $creatorName');
    print('Academic Year: $academicYear');
    print('Academic Term: $academicTerm');
    } catch (e) {
      print('Error loading user data: $e');
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
          'Material',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.paymentTxtColor1),
            onSelected: (String result) {
               print('mmmmmmmmmmmmmmmm ${widget.material.title}');
               switch (result) {
                  case 'edit':
                  
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMaterialScreen(

              itemId: widget.itemId,
              syllabusId: widget.syllabusId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              classId: widget.classId,
              courseName: widget.courseName,
               editMode: true,
              syllabusClasses: widget.syllabusClasses,
              materialToEdit: custom.Material(
                title: widget.material.title,
                description: widget.material.description,
                selectedClass: widget.material.selectedClass,
                startDate: widget.material.startDate,
                endDate: widget.material.endDate,
                topic: widget.material.topic,
                attachments: widget.material.attachments,
                duration: widget.material.duration,
                marks: widget.material.marks,
              ), onSave: (material) {
              
              },
            ),
                      ),
                    );
                    break;
                  case 'delete':
                    deleteMaterial(widget.itemId);
                    break;
                }

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
      ),
      body: Container(
      color: Colors.white,
        child: _buildInstructionsTab(),
      ),
      bottomNavigationBar: _tabController.index == 0
        ? SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom ,
                left: 8.0,
                right: 8.0,
                top: 8.0,
              ),
              child: _isAddingComment
                  ? _buildCommentInput()
                  : InkWell(
                      onTap: () {
                        setState(() {
                          _isAddingComment = true;
                          // Ensure focus is requested after the state update
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _commentFocusNode.requestFocus();
                          });
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Add class comment',
                          style: AppTextStyles.normal500(
                              fontSize: 16.0, color: AppColors.paymentTxtColor1),
                        ),
                      ),
                    ),
            ),
          )
        : null,
      );
     
  }


      Future<void> deleteMaterial(id) async {
                    try {
                   final provider =locator<DeleteSyllabusProvider>();
                   await provider.deleteMaterial(id.toString());
                   CustomToaster.toastSuccess(context, 'Success', 'Material deleted successfully');
                   Navigator.of(context).pop();
                  } catch (e) {
                    print('Error deleting material: $e');
                  }
                  }

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDueDate(),
          _buildDivider(),
          _buildTitle(),
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
            DateFormat('E, dd MMM yyyy (hh:mm a)').format(widget.material.endDate),
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
          widget.material.title,
          style: AppTextStyles.normal600(
            fontSize: 20.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
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
              widget.material.description,
              style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
  final attachments = widget.material.attachments;
  if (attachments == null || attachments.isEmpty) {
    return const Center(child: Text('No attachment available'));
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
  // Safe image detection
  final isImage = (attachment.fileName?.toLowerCase().endsWith('.jpg') ?? false) ||
      (attachment.fileName?.toLowerCase().endsWith('.jpeg') ?? false) ||
      (attachment.fileName?.toLowerCase().endsWith('.png') ?? false) ||
      (attachment.fileName?.toLowerCase().endsWith('.gif') ?? false) ||
      (attachment.iconPath?.contains('material.svg') ?? false) ||
      (attachment.iconPath?.contains('photo') ?? false) || (attachment.iconPath?.contains('image') ?? false);

  if (isImage) {
    final imageUrl = "https://linkskool.net/${attachment.fileName ?? ''}";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 100, // keep the larger preview from the first snippet
          errorBuilder: (context, error, stackTrace) => Container(
            height: 100,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  } else {
    // Not an image: show placeholder and file/link name
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.blue,
          width: 2.0,
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
               image: DecorationImage(
                  image: NetworkImage(networkImage),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            
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
                      attachment.fileName ?? 'Unknown file',
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
  return Consumer<CommentProvider>(
    builder: (context, commentProvider, child) {
      final commentList = commentProvider.comments;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (commentProvider.isLoading && commentList.isEmpty)
          Skeletonizer(
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Show 5 skeleton items
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                  ),
                  title: Container(
                    height: 16,
                    color: Colors.grey.shade300,
                  ),
                  subtitle: Container(
                    height: 14,
                    color: Colors.grey.shade300,
                  ),
                );
              },
            ),
          ),
          if (commentList.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Class comments',
                style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
              ),
            ),
            ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentList.length + (commentProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == commentList.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildCommentItem(commentList[index]);
              },
            ),
            if (commentProvider.error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  commentProvider.message!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            _buildDivider(),
          ],
       
        ],
      );
    },
  );
}


  Widget _buildCommentInput() {
    final provider = Provider.of<CommentProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
           focusNode: _commentFocusNode,
              decoration: const InputDecoration(
                hintText: 'Type your comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          provider.isLoading
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                  color: AppColors.paymentTxtColor1,
                ),
        ],
      ),
    );
  }

void _addComment([Map<String, dynamic>? updatedComment]) async {
  if (_commentController.text.isNotEmpty) {
    final comment = updatedComment ?? {
      "content_title": widget.material.title,
      "user_id": creatorId,
      "user_name": creatorName,
      "comment": _commentController.text,
      "level_id": widget.levelId,
      "course_id": widget.courseId,
      "course_name": widget.courseName,
      "term": academicTerm,
         if (_isEditing == true && _editingComment != null)
        "content_id": widget.itemId.toString() , // Use the ID of the comment being edited
    };

    try {
      final commentProvider = Provider.of<CommentProvider>(context, listen: false);
      final contentId = _editingComment?.id;
      if (_isEditing) {
        comment['content_id'];
        print("printed Comment $comment");
        await commentProvider.UpdateComment(comment,contentId.toString());
        CustomToaster.toastSuccess(context, 'Success', 'Comment updated successfully');
      } else {
      
        await commentProvider.createComment(comment, widget.itemId.toString());
        CustomToaster.toastSuccess(context, 'Success', 'Comment added successfully');
      }

      await commentProvider.fetchComments(widget.itemId.toString());
      setState(() {
        _isAddingComment = false;
        _isEditing = false;
        _editingComment = null;
        _commentController.clear();
        if (!_isEditing) {
          comments.add(Comment(
            author: creatorName ?? 'Unknown',
            date: DateTime.now(),
            text: _commentController.text,
            contentTitle: widget.material.title,
            userId: creatorId,
            levelId: widget.levelId,
            courseId: widget.courseId,
            courseName: widget.courseName,
            term: academicTerm,
          ));
        }
      });
    } catch (e) {
      CustomToaster.toastError(context, 'Error', _isEditing ? 'Failed to update comment' : 'Failed to add comment');
    }
  }
}

Widget _buildCommentItem(Comment comment) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.paymentTxtColor1,
          child: Text(
            comment.author[0].toUpperCase(),
            style: AppTextStyles.normal500(
              fontSize: 16,
              color: AppColors.backgroundLight,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Comment Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + date + actions
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          comment.author,
                          style: AppTextStyles.normal600(
                            fontSize: 15,
                            color: AppColors.backgroundDark,
                          ),
                        ),

                        SizedBox(width:8,),
                    
                        Text(
                      DateFormat('d MMM, HH:mm').format(comment.date),
                      style: AppTextStyles.normal400(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                      ],
                    ),
                  ),
                  

                  // Popup menu button for actions
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.primaryLight,),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editComment(comment);
                      } else if (value == 'delete') {
                        _deleteComment(comment);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),

              Text(
                comment.text,
                style: AppTextStyles.normal500(
                  fontSize: 14,
                  color: AppColors.text4Light,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _deleteComment(Comment comment)async{
   final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    print('Setting up delete for comment ID: ${comment.id}');
    final commentId = comment.id.toString() ?? "";
    try{
       await commentProvider.DeleteComment(commentId);
       CustomToaster.toastSuccess(context, 'Success', 'Comment updated successfully');
  }catch(e){
    CustomToaster.toastError(context, 'Error',  'Failed to delete comment');
  }
   
}



 void _editComment(Comment comment) {
  if(comment.text.isEmpty) {
    CustomToaster.toastError(context, 'Error', 'Comment text cannot be empty');
    return;
  }
  print('Setting up edit for comment ID: ${comment.id}');
  
   _editingComment = comment;
  _commentController.text = comment.text;
  final updatedComment = {
    "content_title": widget.material.title,
    "user_id": creatorId,
    "user_name": creatorName,
    "comment": _commentController.text,
    "level_id": widget.levelId,
    "course_id": widget.courseId,
    "course_name": widget.courseName,
    "term": academicTerm,
    "comment_id": comment.id, // Assuming comment.id is the ID of the comment to update
  };
  print('Editing comment: ${updatedComment['comment']} with ID: ${comment.id}');

  setState(() {
    _isAddingComment = true;
    _isEditing = true;
    _commentFocusNode.requestFocus();
  });

  print('Edit setup complete. _isEditing: $_isEditing, _editingComment.id: ${_editingComment?.id}');
}


}



// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/comment_model.dart';
// import 'package:linkschool/modules/model/e-learning/material_model.dart'
//     as custom;

// import '../../../common/widgets/portal/attachmentItem.dart';

// class StaffMaterialDetailsScreen extends StatefulWidget {
//   final custom.Material material;

//   const StaffMaterialDetailsScreen({
//     super.key,
//     required this.material,
//   });

//   @override
//   StaffMaterialDetailsScreenState createState() => StaffMaterialDetailsScreenState();
// }

// class StaffMaterialDetailsScreenState
//     extends State<StaffMaterialDetailsScreen> {
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
//           "Quiz ",
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
//               final attachments = widget.material.attachments;
//               print('${attachments}');
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
//             DateFormat('E, dd MMM yyyy (hh:mm a)')
//                 .format(widget.material.endDate),
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
//           widget.material.title,
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
//             widget.material.marks,
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
//               widget.material.description,
//               style:
//                   AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttachments() {
//     final attachments = widget.material.attachments; // List<AttachmentItem>
//     if (attachments == null || attachments.isEmpty) {
//       print(attachments);
//       return const SizedBox.shrink();
//     }
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: List.generate(attachments.length, (index) {
//           return Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(
//                   right: index < attachments.length - 1 ? 16.0 : 0),
//               child: _buildAttachmentItem(attachments[index]),
//             ),
//           );
//         }),
//       ),
//     );
//   }

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

//   Widget _buildAttachmentItem(AttachmentItem attachment) {
//     // Detect image by file extension or type
//     final isImage = attachment.fileName!.toLowerCase().endsWith('.jpg') ||
//         attachment.fileName!.toLowerCase().endsWith('.jpeg') ||
//         attachment.fileName!.toLowerCase().endsWith('.png') ||
//       attachment.fileName!.toLowerCase().endsWith('.gif') ||
//         attachment.iconPath!
//             .contains('material.svg') || // your mapping for images
//         attachment.iconPath!.contains('photo');

//     if (isImage) {
//       // Build the full URL if needed
//       final imageUrl =
//           "https://linkskool.net/api/v3/portal/${attachment.fileName}";

//       print(imageUrl);

//       return ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           height: 100,
//           errorBuilder: (context, error, stackTrace) => Image.network(
//             networkImage,
//             fit: BoxFit.cover,
//             height: 100,
//           ),
//         ),
//       );
//     } else {
//       // Not an image: show default image and file/link name
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
//                 height: 100,
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
//                         attachment.fileName!,
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


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';

// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/comment_model.dart';
// import '../../../common/widgets/portal/attachmentItem.dart';

// class StaffMaterialDetailsScreen extends StatefulWidget {
//   final custom.Material material;

//   const StaffMaterialDetailsScreen({
//     super.key,
//     required this.material,
//   });

//   @override
//   StaffMaterialDetailsScreenState createState() => StaffMaterialDetailsScreenState();
// }

// class StaffMaterialDetailsScreenState
//     extends State<StaffMaterialDetailsScreen> {
//   late TabController _tabController;
//   final TextEditingController _commentController = TextEditingController();
//   List<Comment> comments = [];
//   bool _isAddingComment = false;
//   late double opacity;
//   final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

//   @override
//   void initState() {
//     super.initState();
//     // _tabController = TabController(length: 2, vsync: this);
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




// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/comment_model.dart';
// import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;


// class StaffMaterialDetailsScreen extends StatefulWidget {
//   const StaffMaterialDetailsScreen({super.key, required custom.Material material});

//   @override
//   _StaffMaterialDetailsScreenState createState() => _StaffMaterialDetailsScreenState();
// }

// class _StaffMaterialDetailsScreenState extends State<StaffMaterialDetailsScreen>
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
//           'Material',
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