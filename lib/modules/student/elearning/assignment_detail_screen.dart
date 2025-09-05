import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/model/student/comment_model.dart';

import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/student/elearning/pdf_reader.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/custom_toaster.dart';
import '../../common/widgets/portal/attachmentItem.dart';
import '../../model/student/elearningcontent_model.dart';
import '../../providers/student/student_comment_provider.dart';
import 'attachment_preview_screen.dart';

class AssignmentDetailsScreen extends StatefulWidget {

  final ChildContent childContent;
  final String title;
  final int id;

  const AssignmentDetailsScreen({super.key, required this.childContent, required this.title, required this.id});

  @override
  State<AssignmentDetailsScreen> createState() => _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen> {

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

  @override
  void dispose() {
    _commentController.dispose();
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

  void _navigateToAttachmentPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => AttachmentPreviewScreen(attachments: _attachments, childContent: widget.childContent,title: widget.title, id: widget.id),
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
          'Assignment',
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
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Due: ${DateFormat("EEEE, d MMMM, y  h:mma").format(DateTime.parse(widget.childContent.endDate ?? ""))}',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.childContent.description}',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 12),

              Divider(color: Colors.blue),
              const SizedBox(height: 12),

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
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.childContent.contentFiles?.length ?? 0,
                            itemBuilder: (context, index) {
                              final file = widget.childContent.contentFiles![index];
                              if (file.type == "url") {
                                // Case 1: URL → clickable link
                                return Column(
                                  children: [
                                    Container(
                                      height: 100, // Increased height to accommodate the layout
                                      color: Colors.blue.shade100,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () async {
                                            final uri = Uri.parse(file.file);
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.link, color: Colors.blue),
                                              SizedBox(width: 8,),
                                              Text(
                                                overflow: TextOverflow.ellipsis,
                                                file.file,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                  ],
                                );
                              }

                              else if (file.type == "image" || file.type == "photo" ) {
                                // Case 2: Image → render image
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Image.network(
                                        "https://linkskool.net/${file.file}",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Text("Failed to load image"),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                  ],
                                );
                              }
                              else if (file.type == "pdf" ) {

                                return Column(
                                  children: [
                                    IconButton(onPressed: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PdfViewerPage(url:"https://linkskool.net/${file.fileName}"),
                                        ),
                                      );
                                    }, icon:  Icon(Icons.picture_as_pdf, size: 36)),                                      const SizedBox(height: 10),
                                    const SizedBox(height: 10),

                                  ],
                                );
                              }
                              else {
                                // Case 3: Unknown type → show error
                                return Column(
                                  children: [
                                    const Text(
                                      "Error rendering content",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 10),

                                  ],
                                );

                              }
                            },
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              ),
              const Spacer(),
              const SizedBox(height: 12),

              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 12),

              ElevatedButton(
                // onPressed: _showAttachmentOptions,
                onPressed: _navigateToAttachmentPreview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.eLearningBtnColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add work', style: TextStyle(fontSize: 16, color: AppColors.backgroundLight)),
              ),
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
    return Consumer<StudentCommentProvider>(
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
    return ListTile(
      minTileHeight: 20,
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
    final provider = Provider.of<StudentCommentProvider>(context, listen: false);
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
        "content_title": widget.childContent.title,
        "user_id": creatorId,
        "user_name": creatorName,
        "comment": _commentController.text,
        "level_id": widget.childContent.classes?[0].id,
        "course_id": 25,
        "course_name": "widget.courseName",
        "term": academicTerm,
        if (_isEditing == true && _editingComment != null)
          "content_id": widget.childContent.id.toString() , // Use the ID of the comment being edited
      };

      try {
        print(" See o seee creator id ${creatorId}");
//
        final commentProvider = Provider.of<StudentCommentProvider>(context, listen: false);
        final contentId = _editingComment?.id;
        if (_isEditing) {
          comment['content_id'];
          print("printed Comment $comment");
          await commentProvider.UpdateComment(comment,contentId.toString());
          CustomToaster.toastSuccess(context, 'Success', 'Comment updated successfully');
        } else {

          await commentProvider.createComment(comment, widget.childContent.id.toString());
          CustomToaster.toastSuccess(context, 'Success', 'Comment added successfully');
        }

        await commentProvider.fetchComments(widget.childContent.id.toString());
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
              contentTitle: widget.childContent.title,
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





