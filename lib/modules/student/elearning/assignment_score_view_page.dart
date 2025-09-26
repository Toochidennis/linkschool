import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/student/elearning/pdf_reader.dart';
import 'package:linkschool/modules/student/elearning/resubmit_modal.dart';
import 'package:provider/provider.dart';

import 'package:linkschool/modules/model/student/submitted_assignment_model.dart';
import 'package:linkschool/modules/providers/student/marked_assignment_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/app_colors.dart';
import '../../common/custom_toaster.dart';
import '../../common/text_styles.dart';
import '../../model/student/assignment_submissions_model.dart';
import '../../model/student/comment_model.dart';
import '../../model/student/elearningcontent_model.dart';
import '../../providers/student/comment_provider.dart';


class AssignmentScoreView extends StatefulWidget {
  final int year;
  final int term;
  final List<String> attachedMaterials;
  final ChildContent childContent;

  const AssignmentScoreView({
    Key? key,
    required this.childContent,
    required this.year,
    required this.term,
    required this.attachedMaterials,

  }) : super(key: key);

  @override
  State<AssignmentScoreView> createState() => _AssignmentScoreViewState();
}

class _AssignmentScoreViewState extends State<AssignmentScoreView> {
  MarkedAssignmentModel? markedass;
  int? academicTerm;
  int? academicYear;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchMarkedAssignment();
    // Show the modal bottom sheet after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  _showAttachedMaterials();
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
          academicYear = settings['year'];
          academicTerm = settings['term'] ;
        });
      }

    } catch (e) {
      print('Error loading user data: $e');
    }

  }


  void _showAttachedMaterials() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,

      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.20,
        minChildSize: 0.15,
        maxChildSize: 0.6,
        builder: (context, scrollController) {
          return MaterialSheet(
            attachedMaterials: markedass?.files ??[],
            scrollController: scrollController,
          );
        },
      ),
    );
  }
  Future<void> fetchMarkedAssignment() async {
    final provider = Provider.of<MarkedAssignmentProvider>(context, listen: false);
    final data = await provider.fetchMarkedAssignment(widget.childContent.id!, widget.year , widget.term );

    setState(() {
      markedass = data;
      isLoading = false;
    });
  }
  void _showAddCommentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>  AddCommentModal( childContent: widget.childContent,title: widget.childContent.title, id: widget.childContent.id),
    );
  }

  void _showYourWorkModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>  YourWorkModal(childContent: widget.childContent, year: widget.year, term: widget.term, attachedMaterials: widget.attachedMaterials,),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Assignment'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  widget.childContent.title?? "No Title",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                 Text(
                  "${widget.childContent.grade} Points"  "",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _showAddCommentModal(context),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          color: Colors.blue,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Add class comment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),

          // Content Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.childContent.description ?? "",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Section
          GestureDetector(
              onVerticalDragEnd: (details) { // Use this callback instead.
                _showYourWorkModal(context);
              },
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(

                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child:
              Column(
                children: [
                  // Bottom line indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Your work section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your work',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:  Text(
                          widget.childContent.grade ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Assignment file
                  Container(
                    height: 60,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(

                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Colors.grey,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 16),
                         Expanded(
                          child: Text(
                            widget.childContent.contentFiles?.isNotEmpty == true
                                ? widget.childContent.contentFiles![0].fileName!.split('/').last
                                : "No file",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                         ),
                      ],
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

class YourWorkModal extends StatefulWidget {
  final int year;
  final int term;
  final List<String> attachedMaterials;
  final ChildContent childContent;

  const YourWorkModal({
    Key? key,
    required this.childContent,
    required this.year,
    required this.term,
    required this.attachedMaterials,

  }) : super(key: key);

  @override
  State<YourWorkModal> createState() => _YourWorkModalState();
}

class _YourWorkModalState extends State<YourWorkModal> {
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        CustomToaster.toastError(context, 'Error', 'Could not launch $url');
      }
    } catch (e) {
      CustomToaster.toastError(context, 'Error', 'Invalid URL: $url');
    }
  }
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Your work header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your work',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding:  EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child:  Text(
                               widget.childContent.grade ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Attachments section
                        const Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // File preview card
                        Column(
                          children: List.generate(
                            widget.childContent.contentFiles?.length ?? 0,
                                (index) {
                              final file = widget.childContent.contentFiles![index];

                              return GestureDetector(
                                onTap: (){
                                  final rawFileName = file.fileName ?? 'Unknown file';
                                  final fileType = _getFileType(rawFileName);
                                  final fileUrl = "https://linkskool.net/$rawFileName";

                                  final fileName = rawFileName.split('/').last;
                                  if(fileType == 'pdf'){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerPage(
                                          url: fileUrl,
                                        ),
                                      ),
                                    );
                                  } else {
                                    _launchUrl(fileName);
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // File preview container
                                    Container(
                                      width: double.infinity,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E5E5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.description,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // File name row
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Icon(
                                            Icons.description,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            file.fileName.split('/').last ?? "Unknown file", // <-- dynamic file name
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20), // space before next file
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Private comments section
                        const Text(
                          'Private comments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Add comment input
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Add comment to STANLEY ANDE...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.send,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),

                        // Bottom section
                        Column(
                          children: [
                            // Unsubmit button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text(
                                  'Unsubmit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Status message
                            const Text(
                              'Your teacher is not accepting work at this time',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddCommentModal extends StatefulWidget {
  final int? syllabusId;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final int? itemId;
  final List<Map<String, dynamic>>? syllabusClasses;
  final ChildContent? childContent;
  final String ?title;
  final int? id;

  const AddCommentModal({super.key,this.childContent,  this.syllabusId, this.courseId, this.levelId, this.classId, this.courseName, this.syllabusClasses, this.itemId, this.title,this.id});


  @override
  State<AddCommentModal> createState() => _AddCommentModalState();
}

class _AddCommentModalState extends State<AddCommentModal> {
  List<StudentComment> comments = [];
  bool _isAddingComment = true;
  bool _isEditing = false;
  StudentComment? _editingComment;
  late double opacity;

  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';
  String? creatorName;
  int? creatorId;
  int? academicTerm;
  String? academicYear;
  final FocusNode _commentFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

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

  void _addComment([Map<String, dynamic>? updatedComment]) async {
    if (_commentController.text.isNotEmpty) {
      final comment = updatedComment ?? {
        "content_title": widget.childContent?.title,
        "user_id": creatorId,
        "user_name": creatorName,
        "comment": _commentController.text,
        "level_id": widget.childContent?.classes?[0].id,
        "course_id": 25,
        "course_name": widget.childContent!.title?? "No couresname",
        "term": academicTerm,
        if (_isEditing == true && _editingComment != null)
          "content_id": widget.childContent?.id.toString() , // Use the ID of the comment being edited
      };

      try {
//
        final commentProvider = Provider.of<CommentProvider>(context, listen: false);
        final contentId = _editingComment?.id;
        if (_isEditing) {
          comment['content_id'];
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

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when modal opens
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Text(
                      'Add class comment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle post comment
                        _addComment();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: Consumer<CommentProvider>(
                  builder: (context, commentProvider, child) {
                    final commentList = commentProvider.comments;

                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Loading skeleton when first fetching
                            if (commentProvider.isLoading && commentList.isEmpty)
                              Skeletonizer(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 5,
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

                            // Comments available
                            if (commentList.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Class comments',
                                  style: AppTextStyles.normal600(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                  ),
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

                            // Input box styled like your example
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _commentController,
                                focusNode: _focusNode,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Add a class comment...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
              ,
            ],
          ),
        );
      },
    );
  }
}

String _getFileType(String? fileName) {
  if (fileName == null) return 'unknown';
  final extension = fileName.toLowerCase().split('.').last;
  if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
    return 'image';
  }
  if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', '3gp'].contains(extension)) {
    return 'video';
  }
  if (['pdf','doc', 'docx', 'txt', 'rtf'].contains(extension)) {
    return 'pdf';
  }

  if (['.com', '.org', '.net', '.edu', 'http', 'https'].contains(extension) || fileName.startsWith('http')) {
    return 'url';
  }
  if (['xls', 'xlsx', 'csv'].contains(extension)) {
    return 'spreadsheet';
  }
  if (['ppt', 'pptx'].contains(extension)) {
    return 'presentation';
  }
  if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
    return 'archive';
  }
  return 'unknown';
}
