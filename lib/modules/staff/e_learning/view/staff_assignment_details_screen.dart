import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/View/mark_assignment.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/pdf_reader.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/comment_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/comment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_assignment_screen.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../common/widgets/portal/attachmentItem.dart' show AttachmentItem;
class StaffAssignmentDetailsScreen extends StatefulWidget {
  final Assignment assignment ;
  final int? syllabusId;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final int? itemId;
  final List<Map<String, dynamic>>? syllabusClasses;
  
  const StaffAssignmentDetailsScreen(
      {super.key, required this.assignment, this.syllabusId, this.courseId, this.levelId, this.classId, this.courseName, this.syllabusClasses, this.itemId});

  @override
  _StaffAssignmentDetailsScreenState createState() =>
      _StaffAssignmentDetailsScreenState();
}
 class _StaffAssignmentDetailsScreenState extends State<StaffAssignmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FocusNode _commentFocusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
  if (mounted) setState(() {});
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
              // final attachments = widget.assignment.attachments;
       

               switch (result) {
                case 'edit':
                  // Handle edit action
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffAssignmentScreen(
              syllabusId: widget.syllabusId,
              classId: widget.classId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              courseName: widget.courseName,
              syllabusClasses: widget.syllabusClasses,
              itemId:widget.itemId,
              editMode: true,
              assignmentToEdit: AssignmentFormData(
                id: widget.assignment.id,
                title: widget.assignment.title,
                description: widget.assignment.description,
                selectedClass: widget.assignment.selectedClass,
                attachments: widget.assignment.attachments,
                dueDate: widget.assignment.dueDate,
                topic: widget.assignment.topic,
                marks: widget.assignment.marks,
              ),
              onSave: (assignment) {
                //_loadSyllabusContents();
              },
            ),
                    ),
                  );
                  break;
                case 'delete':
                final id = widget.itemId;
                  // Handle delete action
                  deleteAssignment(id.toString());
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
       color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInstructionsTab(),

            AnswersTabWidget(itemId: widget.itemId.toString(),)
          ],
        ),
      ),
bottomNavigationBar: _tabController.index == 0
        ? SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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


    Future<void> deleteAssignment(id) async {
                    try {
                   final provider =locator<DeleteSyllabusProvider>();
                   await provider.deleteAssignment(widget.itemId.toString());
                   CustomToaster.toastSuccess(context, 'Success', 'Assignment deleted successfully');
                   Navigator.of(context).pop();
                  } catch (e) {
                    print('Error deleting assignment: $e');
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
    return const Center(child: Text('No attachment available'));
  }
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: AppTextStyles.normal600(
              fontSize: 18.0, color: AppColors.eLearningTxtColor1),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 1.2,
          ),
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            return _buildAttachmentItem(attachments[index]);
          },
        ),
      ],
    ),
  );
}

Widget _buildAttachmentItem(AttachmentItem attachment) {
final rawFileName = attachment.fileName ?? 'Unknown file';
final fileType = _getFileType(rawFileName);
final fileUrl = "https://linkskool.net/$rawFileName";

// Extract only the actual file name (remove the path)
final fileName = rawFileName.split('/').last;
  return GestureDetector(
    onTap: () {
      if (fileType == 'image' || fileType == 'video') {
        _showFullScreenMedia(fileUrl, fileType);
      } else {
        // For all other files including PDF, open in external app
        //fileUrl
        if(fileType == 'pdf'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerPage(url: fileUrl),
            ),
          );
        } else {_launchUrl(fileName);
      }}
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getFileColor(fileType).withOpacity(0.3),
          width: 1.5,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                color: _getFileColor(fileType).withOpacity(0.1),
              ),
              child: _buildPreviewContent(fileType, fileUrl, fileName),
            ),
          ),
        if (fileType == "pdf" || fileType == "url") 
  Expanded(
    flex: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Text(
        fileName.length > 17 ? fileName.substring(0, 17) : fileName,
        style: AppTextStyles.normal500(
          fontSize: 14.0,
          color: Colors.black,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    ),
  ),

        ],
      ),
    ),
  );
}

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

void _showFullScreenMedia(String url, String type) {
    if (type == 'pdf') {
      // For PDFs, directly open in external app since we removed native_pdf_renderer
      _launchUrl(url);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenMediaViewer(
            url: url,
            type: type,
            fileName: url.split('/').last,
          ),
        ),
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

 Widget _buildPreviewContent(String fileType, String fileUrl, String fileName) {
    switch (fileType) {
      case 'image':
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          child: Image.network(
            fileUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 40,
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        );
   
       case 'video':
  return FutureBuilder<String?>(
    future: VideoThumbnail.thumbnailFile(
      video: fileUrl,
      imageFormat: ImageFormat.PNG,
      maxHeight: 200,
      quality: 50,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError || snapshot.data == null) {
        return const Icon(Icons.videocam, size: 50, color: Colors.blue);
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(snapshot.data!), fit: BoxFit.cover),
          const Center(
            child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
          ),
        ],
      );
    },
  );

      case 'pdf':
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 50,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
           
          ],
        );
      case 'url':
        return Center(
          child: Icon(
            Icons.link,
            size: 40,
            color: _getFileColor(fileType),
          ),
        );
      default:
        return Center(
          child: Icon(
            _getFileIcon(fileType),
            size: 40,
            color: _getFileColor(fileType),
          ),
        );
    }
  }

  


   IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'presentation':
        return Icons.slideshow;
      case 'archive':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

   Color _getFileColor(String fileType) {
    switch (fileType) {
      case 'image':
        return Colors.blue[700]!;
      case 'video':
        return Colors.blue[700]!;
      case 'pdf':
        return Colors.blue[700]!;
      case 'document':
        return Colors.blue[700]!;
      case 'spreadsheet':
        return Colors.blue[700]!;
      case 'presentation':
        return Colors.blue[700]!;
      case 'archive':
        return Colors.blue[700]!;
      default:
        return Colors.blue[700]!;
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
                  commentProvider.message ?? 'Failed to load comments',
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
                  
                  if (comment.userId == creatorId)
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
      "content_title": widget.assignment.title,
      "user_id": creatorId,
      "user_name": creatorName,
      "comment": _commentController.text,
      "level_id": widget.levelId,
      "course_id": widget.courseId,
      "course_name": widget.courseName,
      "term": academicTerm,
         if (_isEditing == true && _editingComment != null)
        "content_id": widget.itemId.toString() , 
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
            contentTitle: widget.assignment.title,
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
    "content_title": widget.assignment.title,
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

  
}
}




class AnswersTabWidget extends StatefulWidget {
  final String itemId;
  const AnswersTabWidget({
    super.key,
    required this.itemId,
  });

  @override
  _AnswersTabWidgetState createState() => _AnswersTabWidgetState();
}

class _AnswersTabWidgetState extends State<AnswersTabWidget> {
  String _selectedCategory = 'SUBMITTED';

  @override
  void initState() {
    super.initState();
    // Fetch assignments on init using the provider
     if (mounted) setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final markProvider = Provider.of<MarkAssignmentProvider>(context, listen: false);
      markProvider.fetchAssignment(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkAssignmentProvider>(
      builder: (context, markProvider, _) {
        final isLoading = markProvider.isLoading;
        final error = markProvider.error;
        final assignmentData = markProvider.assignmentData;

      return Scaffold(
  body: Container(
     decoration: Constants.customBoxDecoration(context),
    child: Column(
      children: [
        _buildNavigationRow(assignmentData),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: Text(
                        error,
                        style: AppTextStyles.normal500(fontSize: 16, color: Colors.red),
                      ),
                    )
                  : _selectedCategory == 'SUBMITTED'
                      ? _buildSubmittedContent(assignmentData)
                      : _buildListContent(_selectedCategory, assignmentData),
        ),
      ],
    ),
  ),
  floatingActionButton: _selectedCategory == 'MARKED'
      ? FloatingActionButton(
        backgroundColor: AppColors.primaryLight,
          onPressed: ()async {
              try {
    final provider = locator<MarkAssignmentProvider>();

    // grab all marked assignments from your state
    final markedAssignments = assignmentData!['marked'] ?? [];

    for (var assignment in markedAssignments) {
       final contentId = assignment['content_id'].toString();       // content id
  final publish = assignment['published'].toString() ?? "";
  print("llllllll$assignment");
  print("llllllll$contentId");
  print("llllllll$publish");

      await provider.returnAssignment(
      publish,
      contentId
      );

        CustomToaster.toastSuccess(
      context,
      'Success',
      'Marks published successfully',
    );
    }}catch(e){
      print(e);
          CustomToaster.toastError(
      context,
      'Success',
      'Marks published $e',
    
    );
    }
    },
          child: const Icon(Icons.publish,color: Colors.white,),
        )
      : null,
);
      },
    );
  }

  Widget _buildNavigationRow(Map<String, dynamic>? assignmentData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavigationContainer('SUBMITTED', assignmentData),
          _buildNavigationContainer('UNMARKED', assignmentData),
          _buildNavigationContainer('MARKED', assignmentData),
        ],
      ),
    );
  }

  Widget _buildNavigationContainer(String text, Map<String, dynamic>? assignmentData) {
    bool isSelected = _selectedCategory == text;
    int itemCount = _getItemCount(text, assignmentData);

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = text),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 89,
          height: 30,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(171, 190, 255, 1)
                : const Color.fromRGBO(224, 224, 224, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryLight : Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isSelected && itemCount > 0)
                Positioned(
                  right: 0,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(244, 67, 54, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1), fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedContent(Map<String, dynamic>? assignmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildListContent('SUBMITTED', assignmentData),
        ),
      ],
    );
  }

  Widget _buildListContent(String category, Map<String, dynamic>? assignmentData) {
    if (assignmentData == null) {
      return Center(
        child: Text(
          'No $category assignments',
          style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundDark),
        ),
      );
    }

    List<dynamic> assignments = [];
    switch (category) {
      case 'SUBMITTED':
        assignments = (assignmentData['submitted'] as List<dynamic>?) ?? [];
        break;
      case 'UNMARKED':
        assignments = (assignmentData['unmarked'] as List<dynamic>?) ?? [];
        break;
      case 'MARKED':
        assignments = (assignmentData['marked'] as List<dynamic>?) ?? [];
        break;
      default:
        assignments = [];
    }

    if (assignments.isEmpty) {
      return Center(
        child: Text(
          'No $category assignments',
          style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundDark),
        ),
      );
    }

    return ListView.separated(
      itemCount: assignments.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        var assignmentJson = assignments[index] as Map<String, dynamic>;

        // Defensive extraction of fields from assignmentJson
        final String studentName = assignmentJson['student_name']?.toString() ?? 'Unknown';
        final String score = assignmentJson['score']?.toString() ?? '';
        final String markingScore = assignmentJson['marking_score']?.toString() ?? '';
        final List<dynamic> files = assignmentJson['files'] is List ? assignmentJson['files'] : [];
        final String dateStr = assignmentJson['date']?.toString() ?? '';
      final String Publish = assignmentJson['publish']?.toString() ?? '';
        DateTime? date;
        try {
          date = DateTime.parse(dateStr);
        } catch (_) {
          date = null;
        }

        return GestureDetector(
          onTap: () {
            // Navigate to QuizResultsScreen with assignment data
          if(category == 'MARKED') {
            
              CustomToaster.toastInfo(context, 'Info', 'This assignment has already been marked.');
              return;
          }
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AssignmentGradingScreen(
      itemId: widget.itemId,
      assignmentTitle: assignmentJson['assignment_title']?.toString() ?? 'yyyyy',
      files: files,
      maxScore: int.tryParse(markingScore) ?? 0,
      studentName: studentName,
      assignmentId: assignmentJson['id']?.toString() ?? '',
      currentScore: int.tryParse(score) ?? 0,
      turnedInAt: date ?? DateTime.now(),
      onGraded: (){
        final provider = Provider.of<MarkAssignmentProvider>(context, listen: false);
        provider.fetchAssignment(widget.itemId); // refresh from provider
        final commentProvider = Provider.of<CommentProvider>(context, listen: false);
  commentProvider.fetchComments(widget.itemId);
      },
    ),
  ),

).then((value) {
  setState(() {
    final provider = Provider.of<MarkAssignmentProvider>(context, listen: false);
    provider.fetchAssignment(widget.itemId); // refresh from provider
  });
});

          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundLight),
              ),
            ),
            title: Text(
              studentName,
              style: AppTextStyles.normal600(fontSize: 16, color: Colors.black87),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  'Score: ${score.isNotEmpty ? score : "N/A"}/${markingScore.isNotEmpty ? markingScore : "N/A"}',
                  style: AppTextStyles.normal500(fontSize: 14, color: Colors.grey[600]!),
                ),
                const SizedBox(height: 2),
                Text(
                  'Files: ${files.length} attached',
                  style: AppTextStyles.normal500(fontSize: 14, color: Colors.grey[600]!),
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date != null ? DateFormat('MMM dd').format(date) : 'Invalid date',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  date != null ? DateFormat('HH:mm').format(date) : '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getItemCount(String category, Map<String, dynamic>? assignmentData) {
    if (assignmentData == null) return 0;
    switch (category) {
      case 'SUBMITTED':
        return (assignmentData['submitted'] as List<dynamic>?)?.length ?? 0;
      case 'UNMARKED':
        return (assignmentData['unmarked'] as List<dynamic>?)?.length ?? 0;
      case 'MARKED':
        return (assignmentData['marked'] as List<dynamic>?)?.length ?? 0;
      default:
        return 0;
    }
  }
}




class FullScreenMediaViewer extends StatefulWidget {
  final String url;
  final String type;
  final String fileName;

  const FullScreenMediaViewer({
    Key? key,
    required this.url,
    required this.type,
    required this.fileName,
  }) : super(key: key);

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'video') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.url);
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      aspectRatio: _videoController!.value.aspectRatio,
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.fileName,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: widget.type == 'video'
            ? (_chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized)
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(color: Colors.white)
            : Image.network(
                widget.url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 100,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              ),
      ),
    );
  }
}


class VideoThumbnailWidget extends StatefulWidget {
  final String url;
  const VideoThumbnailWidget({super.key, required this.url});

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final thumb = await VideoThumbnail.thumbnailData(
        video: widget.url,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        quality: 300,
      );
      if (mounted) setState(() => _thumbnail = thumb);
    } catch (e) {
      debugPrint("Error generating video thumbnail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbnail == null) {
      return Container(
        width: 100,
        height: 140,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            _thumbnail!,
            width:double.infinity,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
      ],
    );
  }
}
