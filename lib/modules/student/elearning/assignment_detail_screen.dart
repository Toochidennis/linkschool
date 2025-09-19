import 'dart:convert';
import 'dart:typed_data';

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
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDueDate(),
          _buildDescription(),

          _buildSpecDivider(),

          Text(
            'Grade:${widget.childContent.grade} marks',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          _buildAttachments(),
        ],
      ),
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
              DateFormat('E, dd MMM yyyy (hh:mm a)').format(DateTime.parse(widget.childContent.endDate!))
,
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

      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.childContent.title!,
          style: AppTextStyles.normal600(
            fontSize: 20.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
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
      body:Container(
        color: Colors.white,
        child: _buildInstructionsTab(),

      ),
      bottomNavigationBar:  ElevatedButton(
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
  Widget _buildSpecDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(  color: AppColors.paymentTxtColor1, thickness: 2.0),
    );
  }
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            '',
            style: AppTextStyles.normal600(
                fontSize: 16.0, color: AppColors.eLearningTxtColor1),
          ),
          Expanded(
            child: Text(
              widget.childContent.description!,
              style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    final attachments = widget.childContent.contentFiles;
    if (attachments == null || attachments.isEmpty) {
      return const Center(child: Text('No attachment available'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

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

  Widget _buildAttachmentItem(ContentFile attachment) {
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
                builder: (_) => PdfViewerPage(
                  url: fileUrl,
                ),
              ),
            );;
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
        return  VideoThumbnailWidget(url: fileUrl);
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
  bool _isVideoInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'video') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.network(widget.url);
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
      _hideControlsAfterDelay();
      _videoController!.addListener(() {
        if (_videoController!.value.position == _videoController!.value.duration) {
          setState(() {
            _showControls = true;
          });
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _videoController != null && _videoController!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _videoController != null && _videoController!.value.isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              try {
                final Uri uri = Uri.parse(widget.url);
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not download file')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download failed')),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _buildMediaContent(),
      ),
    );
  }

  Widget _buildMediaContent() {
    switch (widget.type) {
      case 'image':
        return InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        );
      case 'video':
        if (!_isVideoInitialized || _videoController == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              if (_showControls) ...[
                Positioned(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                          _showControls = true;
                        } else {
                          _videoController!.play();
                          _hideControlsAfterDelay();
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      default:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: Colors.white,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Unsupported file type',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
    }
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
