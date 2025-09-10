import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/custom_input_field.dart';
import 'package:linkschool/modules/model/student/assignment_submissions_model.dart';
import 'package:linkschool/modules/services/student/assignment_submission_service.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/buttons/custom_long_elevated_button.dart';
import '../../common/custom_toaster.dart';
import '../../common/widgets/portal/attachmentItem.dart';
import '../../model/student/comment_model.dart';
import '../../model/student/elearningcontent_model.dart';
import '../../providers/student/comment_provider.dart';
import '../../services/api/service_locator.dart'; // Import the custom input



class AttachmentPreviewScreen extends StatefulWidget {
  final int? syllabusId;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final int? itemId;
  final List<Map<String, dynamic>>? syllabusClasses;
  final List<AttachmentItem> attachments;
  final ChildContent? childContent;
  final String ?title;
  final int? id;

  const AttachmentPreviewScreen({super.key, required this.attachments, this.childContent,  this.syllabusId, this.courseId, this.levelId, this.classId, this.courseName, this.syllabusClasses, this.itemId, this.title,this.id});

  @override
  State<AttachmentPreviewScreen> createState() => _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
    final TextEditingController _commentController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    List<StudentComment> comments = [];
    bool _isAddingComment = true;
    bool _isEditing = false;
    StudentComment? _editingComment;
  late double opacity;
   final List<AssignmentFile> _attachments = [];

  final String networkImage = 'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';
  String? creatorName;
  int? creatorId;
  int? academicTerm;
  String? academicYear;
    final FocusNode _commentFocusNode = FocusNode();

    @override
    void initState() {
      super.initState();
      _loadUserData();
      locator<CommentProvider>().fetchComments(widget.childContent!.id.toString());
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
            !locator<CommentProvider>().isLoading &&
            locator<CommentProvider>().hasNext) {

          Provider.of<CommentProvider>(context, listen: false)
              .fetchComments(widget.childContent!.id.toString());
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
    getuserdata(){
      final userBox = Hive.box('userData');
      print(userBox.get('userData'));
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      return data;
    }

    @override
    void dispose() {
      _commentController.dispose();
      _scrollController.dispose();
      _commentFocusNode.dispose();
      super.dispose();
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
          /*    _buildAttachmentOption(
                  'Insert link',
                  'assets/icons/student/link1.svg',
                  _showInsertLinkDialog),*/
              _buildAttachmentOption(
                  'Upload file', 'assets/icons/e_learning/upload_file.svg', _uploadFile),
        /*      _buildAttachmentOption(
                  'Take photo', 'assets/icons/e_learning/take_photo.svg', _takePhoto),
              _buildAttachmentOption(
                  'Record Video', 'assets/icons/e_learning/record_video.svg', _recordVideo),*/
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
              Column(
                children: [
                  ..._attachments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attachment = entry.value;
                    return _buildAttachmentItem(attachment, isFirst: index == 0);
                  }),
                  const SizedBox(height: 8.0),
                  _buildAddMoreButton(),
                ],
              ),
              const SizedBox(height: 16),
              // Two-column attachment layout
             const SizedBox(height: 24),
              // Custom Comment Input Field
                           // Comments section
              SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommentSection(),
                      ])),
              Padding(
                  padding: const EdgeInsets.all(0.0),
                  child:
                  _buildCommentInput()

              ),
              const Spacer(), // This will push the remaining buttons to the bottom

              // Add work and Submit buttons
              const SizedBox(height: 8),

              // Change Submit to TextButton
              TextButton(
                onPressed: () async {
                  AssignmentSubmissionService service = AssignmentSubmissionService();
                  final List<Map<String, dynamic>> files = _attachments.map((attachment) {
                    return {
                      "file_name": attachment.fileName,
                      "type": "pdf",
                      "file": attachment.file ,
                    };
                  }).toList();
                  Map<String, dynamic> assignmentPayload = {
                    "assignment_id": widget.childContent?.id,
                    "student_id": getuserdata()['profile']['id'] ?? 0,
                    "student_name":getuserdata()['profile']['name'] ,
                    "files": files,
                  "mark": 0,
                    "score": 0,
                    "level_id": getuserdata()['profile']['level_id'],
                    "course_id": widget.id,
                    "class_id": getuserdata()['profile']['class_id'],
                    "course_name":widget.title,
                    "class_name": widget.childContent!.classes?[0].name,
                    "term": getuserdata()['settings']['term'],
                    "year": int.parse(getuserdata()['settings']['year']),
                    "_db": "aalmgzmy_linkskoo_practice"
                  };

                  bool success = await service.submitAssignment(AssignmentSubmission.fromJson(assignmentPayload));
//
                  if (success) {

                    final userBox = Hive.box('userData');
                    final List<dynamic> assignmentssubmitted = userBox.get('assignments', defaultValue: []);
                    final int? assignmentId = widget.childContent!.id;
                    assignmentssubmitted.add(assignmentId);
                    userBox.put('assignments', assignmentssubmitted);
                    _Assignmentsubmissionpop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to submit assignment.")),
                    );
                  }
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
                  _addAttachment(linkController.text,'assets/icons/e_learning/link3.svg','link','Link: ${linkController.text}' );
                  print("AAQASSSS ${widget.attachments}");
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
  FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
  if (result!=null){
    PlatformFile plat = result.files.first;

    String? extension = plat.extension;
if (plat.bytes!=null){
    String base64String = base64Encode(plat.bytes!);
    if (result != null) {

    String fileName = result.files.single.name;

    setState(() {
//
      _attachments.add(
        AssignmentFile(
          fileName: result.files.single.name,
          file: base64String,
          type: extension!,
        ),
      );
    });
    // _navigateToAttachmentPreview();
  }
}

  }

}

Future<void> _takePhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
  if (photo != null) {
    File imageFile = File(photo.path);

    // Convert to bytes
    List<int> imageBytes = await imageFile.readAsBytes();

    // Encode to Base64
    String base64Image = base64Encode(imageBytes);
    _addAttachment(base64Image,'assets/icons/e_learning/camera.svg','photo','Photo: ${photo.name}' );
    // _navigateToAttachmentPreview();
  }
}


  Future<void> _recordVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      File videoFile = File(video.path);

      // Read as bytes
      List<int> videoBytes = await videoFile.readAsBytes();

      // Encode to Base64
      String base64Video = base64Encode(videoBytes);
      _addAttachment(base64Video,'assets/icons/e_learning/video.svg','video','Video: ${video.name}' );

    }
  }

  void _addAttachment(String content, String iconPath, String type, String filename) {
    setState(() {
      print(_attachments);
      _attachments.add(AssignmentFile(type: type, file: content, fileName: filename));
    });
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
    Widget _buildAttachmentsSection() {
      return GestureDetector(
        onTap: _attachments.isEmpty ? _showAttachmentOptions : null,
        child: Container(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_attachments.isEmpty)
                Container(
                  width: double.infinity, // Same as minimumSize: Size(double.infinity, 50)
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.eLearningBtnColor1, // backgroundColor
                    borderRadius: BorderRadius.circular(8), // shape borderRadius
                  ),
                  alignment: Alignment.center, // centers the child
                  child: const Text(
                    'Add work',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )

              else
                Column(
                  children: [
                    ..._attachments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final attachment = entry.value;
                      return _buildAttachmentItem(attachment, isFirst: index == 0);
                    }),
                    const SizedBox(height: 8.0),
                    _buildAddMoreButton(),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    Widget _buildAttachmentItem(AssignmentFile attachment, {bool isFirst = false}) {
      return Container(
        margin: EdgeInsets.only(bottom: isFirst ? 0 : 8.0),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icons/e_learning/upload.svg",
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                attachment.fileName ?? "No filename",
                style: AppTextStyles.normal400(fontSize: 14.0, color: AppColors.primaryLight),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.red),
              onPressed: () {
                setState(() {
                  _attachments.remove(attachment);
                });
              },
            ),
          ],
        ),
      );
    }

    Widget _buildAddMoreButton() {
      return GestureDetector(
        onTap: _showAttachmentOptions,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            OutlinedButton(
              onPressed: _showAttachmentOptions,
              style: OutlinedButton.styleFrom(
                textStyle: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.backgroundLight),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                side: const BorderSide(color: AppColors.eLearningBtnColor1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('+ Add'),
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
    void _Assignmentsubmissionpop() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Image.asset(
                  'assets/icons/arrow_back.png',
                  color: AppColors.primaryLight,
                  width: 34.0,
                  height: 34.0,
                ),
              ),
              title: Text(
                'Quiz Completed',
                style: AppTextStyles.normal600(
                  fontSize: 24.0,
                  color: AppColors.primaryLight,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
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
              decoration: Constants.customBoxDecoration(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Good Job!',
                      style: AppTextStyles.normal600(
                          fontSize: 34, color: AppColors.eLearningContColor2),
                    ),
                    Text(
                      'Your quiz has been recorded and will be marked by your tutor soon.',
                      style: AppTextStyles.normal500(
                          fontSize: 18, color: AppColors.textGray),
                    ),
                    const SizedBox(
                      height: 48.0,
                    ),
                    CustomLongElevatedButton(
                      text: 'Back to Home',
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      backgroundColor: AppColors.eLearningContColor2,
                      textStyle: AppTextStyles.normal600(
                          fontSize: 22, color: AppColors.backgroundLight),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),

                  ],
                ),
              ),
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