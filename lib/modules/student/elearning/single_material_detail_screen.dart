import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/model/student/single_elearningcontentmodel.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/student/elearning/attachment_preview_screen.dart';
import 'package:linkschool/modules/student/elearning/pdf_reader.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/custom_toaster.dart';
import '../../common/widgets/portal/attachmentItem.dart';
import '../../model/student/comment_model.dart';
import '../../providers/student/student_comment_provider.dart';
import '../../services/api/service_locator.dart';

class SingleMaterialDetailScreen extends StatefulWidget {
  final int? syllabusId;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final int? itemId;
  final List<Map<String, dynamic>>? syllabusClasses;
  final SingleElearningContentData? childContent;

  const SingleMaterialDetailScreen(
      {super.key,
      required this.childContent,
      this.syllabusId,
      this.courseId,
      this.levelId,
      this.classId,
      this.courseName,
      this.syllabusClasses,
      this.itemId});

  @override
  State<SingleMaterialDetailScreen> createState() =>
      _SingleMaterialDetailScreen();
}

class _SingleMaterialDetailScreen extends State<SingleMaterialDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<StudentComment> comments = [];
  bool _isAddingComment = false;
  bool _isEditing = false;
  StudentComment? _editingComment;
  late double opacity;
  final String networkImage =
      'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

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
    locator<StudentCommentProvider>()
        .fetchComments(widget.childContent!.id.toString());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !locator<StudentCommentProvider>().isLoading &&
          locator<StudentCommentProvider>().hasNext) {
        Provider.of<StudentCommentProvider>(context, listen: false)
            .fetchComments(widget.childContent!.id.toString());
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
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
        builder: (context) =>
            AttachmentPreviewScreen(attachments: _attachments),
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          _buildDescription(),
          _buildAttachments(),
          _buildDivider(),
          _buildCommentSection(),
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
          widget.childContent?.title ?? "No Title",
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
    if (widget.childContent == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text(
                "Loading your material",
                style: TextStyle(color: AppColors.paymentBtnColor1),
              ),
            ],
          ),
        ),
      );
    }
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
          color: Colors.white,
          child: _buildInstructionsTab(),
        ),
        bottomNavigationBar: SafeArea(
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
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _commentFocusNode.requestFocus();
                        });
                      });
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _buildCommentInput()),
                  ),
          ),
        ));
  }

  Widget _buildAttachmentOption(
      String text, String iconPath, VoidCallback onTap) {
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
                  style: AppTextStyles.normal600(
                      fontSize: 18.0, color: Colors.black),
                ),
              ),
              ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    commentList.length + (commentProvider.isLoading ? 1 : 0),
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
    final provider =
        Provider.of<StudentCommentProvider>(context, listen: false);
    return Row(
      children: [
        Expanded(
            child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.paymentBtnColor1, width: 1.0),
            ),
          ),
          child: TextField(
            controller: _commentController,
            focusNode: _commentFocusNode,
            decoration: const InputDecoration(
              hintText: 'Post a comment...',
              border: InputBorder.none,
            ),
          ),
        )),
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
      final comment = updatedComment ??
          {
            "content_title": widget.childContent?.title,
            "user_id": creatorId,
            "user_name": creatorName,
            "comment": _commentController.text,
            "level_id": widget.childContent?.classes[0].id,
            "course_id": 25,
            "course_name": "widget.courseName",
            "term": academicTerm,
            if (_isEditing == true && _editingComment != null)
              "content_id": widget.childContent?.id
                  .toString(), // Use the ID of the comment being edited
          };

      try {
        print(" See o seee creator id $creatorId");
//
        final commentProvider =
            Provider.of<StudentCommentProvider>(context, listen: false);
        final contentId = _editingComment?.id;
        if (_isEditing) {
          comment['content_id'];
          print("printed Comment $comment");
          await commentProvider.UpdateComment(comment, contentId.toString());
        } else {
          await commentProvider.createComment(
              comment, widget.childContent!.id.toString());
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
        CustomToaster.toastError(context, 'Error',
            _isEditing ? 'Failed to update comment' : 'Failed to add comment');
      }
    }
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey.withOpacity(0.5)),
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
              widget.childContent!.description,
              style:
                  AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    final attachments = widget.childContent!.contentFiles;
    if (attachments.isEmpty) {
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

  Widget _buildAttachmentItem(dynamic attachment) {
    print("this is aaa${attachment['file_name']}");
    final rawFileName = attachment['file_name'] ?? 'Unknown file';
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
          if (fileType == 'pdf') {
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
        }
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 6.0),
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
    if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', '3gp']
        .contains(extension)) {
      return 'video';
    }
    if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      return 'pdf';
    }

    if (['.com', '.org', '.net', '.edu', 'http', 'https'].contains(extension) ||
        fileName.startsWith('http')) {
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

  Widget _buildPreviewContent(
      String fileType, String fileUrl, String fileName) {
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
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        );
      case 'video':
        return VideoThumbnailWidget(url: fileUrl);
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
    super.key,
    required this.url,
    required this.type,
    required this.fileName,
  });

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
        if (_videoController!.value.position ==
            _videoController!.value.duration) {
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
      if (mounted &&
          _videoController != null &&
          _videoController!.value.isPlaying) {
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
    if (_showControls &&
        _videoController != null &&
        _videoController!.value.isPlaying) {
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
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
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
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
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
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
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
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
      ],
    );
  }
}
