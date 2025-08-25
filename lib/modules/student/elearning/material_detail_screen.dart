import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';

import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/student/elearning/attachment_preview_screen.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/custom_toaster.dart';
import '../../common/widgets/portal/attachmentItem.dart';
import '../../common/widgets/portal/student/custom_input_field.dart';
import '../../model/student/comment_model.dart';
import '../../model/student/elearningcontent_model.dart';
import '../../providers/student/comment_provider.dart';
import '../../services/api/service_locator.dart';

class MaterialDetailScreen extends StatefulWidget {
  final int? syllabusId;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final int? itemId;
  final List<Map<String, dynamic>>? syllabusClasses;
  final ChildContent childContent;

  const MaterialDetailScreen({super.key, required this.childContent, this.syllabusId, this.courseId, this.levelId, this.classId, this.courseName, this.syllabusClasses, this.itemId});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreen();
}

class _MaterialDetailScreen extends State<MaterialDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<StudentComment> comments = [];
  bool _isAddingComment = false;
  bool _isEditing = false;
  StudentComment? _editingComment;
  late double opacity;
  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';


  final List<AttachmentItem> _attachments = [];
  String? creatorName;
  int? creatorId;
  int? academicTerm;
  String? academicYear;
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    locator<CommentProvider>().fetchComments(widget.childContent.id.toString());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9 &&
          !locator<CommentProvider>().isLoading &&
          locator<CommentProvider>().hasNext) {

        Provider.of<CommentProvider>(context, listen: false)
            .fetchComments(widget.childContent.id.toString());
      }
    });

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
          creatorId = profile['student_id'] as int?;
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
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
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
              const SizedBox(height: 16),
          SingleChildScrollView(
            child:  _buildCommentSection(),
          )

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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isAddingComment
                  ? _buildCommentInput()
                  : InkWell(
                onTap: () => setState(() => _isAddingComment = true),
                child: Text(
                  'Add class comment',
                  style: AppTextStyles.normal500(
                      fontSize: 16.0, color: AppColors.paymentTxtColor1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildCommentItem(StudentComment comment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
                  children: [
                    Expanded(
                      child: Text(
                        comment.author,
                        style: AppTextStyles.normal600(
                          fontSize: 15,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 1),

                // Comment text
                Text(
                  comment.text,
                  style: AppTextStyles.normal500(
                    fontSize: 14,
                    color: AppColors.text4Light,
                  ),
                ),
                Row(

                  children: [
                    Text(
                      DateFormat('d MMM, HH:mm').format(comment.date),
                      style: AppTextStyles.normal400(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),


                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    final provider = Provider.of<CommentProvider>(context, listen: false);
    return Row(
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
    );
  }

  void _addComment([Map<String, dynamic>? updatedComment]) async {
    if (_commentController.text.isNotEmpty) {
      final comment = updatedComment ?? {
        "content_title": widget.childContent?.title,
        "user_id": creatorId,
        "user_name": creatorName,
        "comment": _commentController.text,
        "level_id": widget.childContent?.classes?[0].id,
        "course_id": 25,
        "course_name": "widget.courseName",
        "term": academicTerm,
        if (_isEditing == true && _editingComment != null)
          "content_id": widget.childContent?.id.toString() , // Use the ID of the comment being edited
      };

      try {
        print(" See o seee creator id ${creatorId}");
//
        final commentProvider = Provider.of<CommentProvider>(context, listen: false);
        final contentId = _editingComment?.id;
        if (_isEditing) {
          comment['content_id'];
          print("printed Comment $comment");
          await commentProvider.UpdateComment(comment,contentId.toString());
          CustomToaster.toastSuccess(context, 'Success', 'Comment updated successfully');
        } else {

          await commentProvider.createComment(comment, widget.childContent!.id.toString());
          CustomToaster.toastSuccess(context, 'Success', 'Comment added successfully');
        }

        await commentProvider.fetchComments(widget.childContent!.id.toString());
        setState(() {
          _isAddingComment = false;
          _isEditing = false;
          _editingComment = null;
          _commentController.clear();
          if (!_isEditing) {
            comments.add(StudentComment(
              author: creatorName ?? 'Unknown',
              date: DateTime.now(),
              text: _commentController.text,
              contentTitle: widget.childContent?.title,
              userId: creatorId,
              levelId: "71",
              courseId: "25",
              courseName: "Computer science",
              term: academicTerm,
            ));
          }
        });
      } catch (e) {
        CustomToaster.toastError(context, 'Error', _isEditing ? 'Failed to update comment' : 'Failed to add comment');
      }
    }
  }
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey.withOpacity(0.5)),
    );
  }
}
