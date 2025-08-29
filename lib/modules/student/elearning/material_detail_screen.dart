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
import 'package:linkschool/modules/student/elearning/pdf_reader.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
          creatorId = profile['id'] as int?;
          creatorName = profile['name']?.toString();
          academicYear = settings['year']?.toString();
          academicTerm = settings['term'] as int?;
        });
      }

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
                '${widget.childContent.title}',
                style: AppTextStyles.normal600(
                  fontSize: 24.0,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),              const SizedBox(height: 16),

              const Divider(color: AppColors.eLearningBtnColor1),
              const SizedBox(height: 16),

              Text(
                '${widget.childContent.description}',
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400, color: Colors.black),
              ),

              const SizedBox(height: 24),
              // Attachment section
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        if (widget.childContent.contentFiles != null &&
                            widget.childContent.contentFiles!.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.childContent.contentFiles!.length,
                            itemBuilder: (context, index) {
                              final file = widget.childContent.contentFiles![index];

                              if (file.type == "url") {
                                // Case 1: URL → clickable link
                                return Column(
                                  children: [
                                    Container(
                                      height: 100,
                                      color: Colors.blue.shade100,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () async {
                                            final uri = Uri.parse(file.file);
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(Icons.link, color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  file.file,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,
                                                  ),
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

                              else if (file.type == "image" || file.type == "photo") {
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

                              else if (file.type == "pdf") {
                                return Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PdfViewerPage(
                                              url: "https://linkskool.net/${file.fileName}",
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.picture_as_pdf, size: 36),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }

                              else {
                                // Case 3: Unknown type
                                return Column(
                                  children: const [
                                    Text(
                                      "Error rendering content",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }
                            },
                          )
                        else
                          const Text(
                            "No content available",
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),
              const SizedBox(height: 16),
         _buildCommentSection(),
              Divider(color: Colors.grey.shade300),

_buildCommentInput()

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
            //  _buildDivider(),
            ],

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
              hintText: 'Post a comment...',
              border: InputBorder.none,             ),
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
        } else {

          await commentProvider.createComment(comment, widget.childContent!.id.toString());
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
