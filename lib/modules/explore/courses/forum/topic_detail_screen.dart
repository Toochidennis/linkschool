import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:linkschool/modules/model/explore/cohorts/discussion_model.dart';
import 'package:linkschool/modules/providers/explore/courses/discussion_provider.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────
//  ATTACHMENT MODEL
// ─────────────────────────────────────────────
enum AttachmentType { image  }

class ReplyAttachment {
  final AttachmentType type;
  final File? imageFile;

  const ReplyAttachment({
    required this.type,
    this.imageFile,
   
  });
}

Future<List<Map<String, dynamic>>> _buildImageFilesPayload(
  ReplyAttachment? attachment, {
  String oldFileName = '',
}) async {
  if (attachment?.imageFile == null) return [];
  final file = attachment!.imageFile!;
  final bytes = await file.readAsBytes();
  final base64 = base64Encode(bytes);
  final name = file.path.split(Platform.pathSeparator).last;
  return [
    {
      'file_name': name,
     'file': base64,
      'type': 'image',
     'old_file_name': oldFileName,
    },
  ];
}

// ─────────────────────────────────────────────
//  MAIN TOPIC DETAIL SCREEN
// ─────────────────────────────────────────────
class TopicDetailScreen extends StatefulWidget {
  final String topicId;
  final String cohortId;
  final int? authorId;
  final int? programId;
  final int? courseId;
  const TopicDetailScreen({
    super.key,
    required this.topicId,
    required this.cohortId,
    this.authorId,
    this.programId,
    this.courseId,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  ReplyAttachment? _attachment;
  int? _editingPostId;
  int? _editingParentPostId;
  String? _editingImageUrl;
  String? _editingOldFileName;


  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<DiscussionProvider>()
          .loadDiscussionDetail(
            discussionId: widget.topicId,
            authorId: widget.authorId,
          );
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitReply(DiscussionProvider provider) async {
    final text = _replyController.text.trim();
    if (text.isEmpty && _attachment == null) return;
    if (_editingPostId != null) {
      final files = await _buildImageFilesPayload(
        _attachment,
        oldFileName: _editingOldFileName ?? '',
      );
      final payload = {
        if (_editingParentPostId != null)
          'parent_post_id': _editingParentPostId,
        'body': text,
        'author_id': widget.authorId ?? 0,
        'program_id': widget.programId ?? 0,
        'course_id': widget.courseId ?? 0,
        'files': files.isEmpty
            ? []
            : [
                {
                  'file_name': files.first['file_name'],
                  'file': files.first['file'],
                  'old_file_name': _editingOldFileName ?? '',
                  'type': 'image',
                },
              ],
      };
      final ok = await provider.updatePost(
        cohortId: widget.cohortId,
        discussionId: widget.topicId,
        postId: _editingPostId.toString(),
        payload: payload,
      );
      if (!ok) return;
      _replyController.clear();
      _focusNode.unfocus();
      setState(() {
        _attachment = null;
        _editingPostId = null;
        _editingParentPostId = null;
        _editingImageUrl = null;
        _editingOldFileName = null;
      });
      return;
    }
    final files = await _buildImageFilesPayload(_attachment);
    final payload = {
      'body': text,
      'author_id': widget.authorId ?? 0,
      'program_id': widget.programId ?? 0,
      'course_id': widget.courseId ?? 0,
      'files': files,
    };
    final ok = await provider.createDiscussionPost(
      cohortId: widget.cohortId,
      discussionId: widget.topicId,
      payload: payload,
    );
    if (!ok) return;
    _replyController.clear();
    _focusNode.unfocus();
    setState(() {
      _attachment = null;
      _editingPostId = null;
    });
  }

  void _beginEdit(DiscussionPost post) {
    setState(() {
      _editingPostId = post.id;
      _editingParentPostId = post.parentPostId;
      _editingImageUrl = post.primaryImageUrl.isNotEmpty
          ? post.primaryImageUrl
          : null;
      _editingOldFileName =
          post.images.isNotEmpty ? post.images.first.fileName : null;
      _attachment = null;
      _replyController.text = post.body;
      _replyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _replyController.text.length),
      );
    });
    _focusNode.requestFocus();
  }

  void _previewNetworkImage(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewLocalImage(File file) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReplyThread(BuildContext context, DiscussionPost reply) {
      if (reply.depth >= 5) return;
    final provider = context.read<DiscussionProvider>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: ReplyThreadScreen(
          topicId: widget.topicId,
          cohortId: widget.cohortId,
          authorId: widget.authorId,
          programId: widget.programId,
          courseId: widget.courseId,
          replyId: reply.id.toString(),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscussionProvider>();
    final discussion = provider.activeDiscussion;
    final isDiscussionLocked = discussion?.isLocked ?? false;

    if (provider.isDetailLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFA500)),
        ),
      );
    }

    if (provider.detailError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          ),
          title: const Text(
            'Forum',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  provider.detailError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadDiscussionDetail(
                    discussionId: widget.topicId,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (discussion == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Discussion not found.',
            style: TextStyle(
              fontFamily: 'Urbanist',
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        ),
        title: const Text('Forum',
          style: TextStyle(fontFamily: 'Urbanist', fontSize: 18,
            fontWeight: FontWeight.w800, color: Color(0xFF111827))),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () { },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _OriginalPost(discussion: discussion),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text('REPLIES',
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 12,
                        fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF),
                        letterSpacing: 0.8)),
                  ),
                  if (provider.postTree.isEmpty)
                    const _EmptyReplies()
                  else
                    ...provider.postTree.map((reply) => _ReplyRow(
                      topicId: discussion.id.toString(),
                      cohortId: widget.cohortId,
                      authorId: widget.authorId ?? 0,
                      reply: reply,
                      previewNetworkImage: () =>
                          _previewNetworkImage(reply.primaryImageUrl),
                      previewLocalImage: _previewLocalImage,
                      onTap: () => _openReplyThread(context, reply),
                      onEdit: (!isDiscussionLocked &&
                              widget.authorId != null &&
                              reply.authorId == widget.authorId)
                          ? () => _beginEdit(reply)
                          : null,
                      onDelete: (!isDiscussionLocked &&
                              widget.authorId != null &&
                              reply.authorId == widget.authorId)
                          ? () => context.read<DiscussionProvider>().deletePost(
                                cohortId: widget.cohortId,
                                postId: reply.id.toString(),
                                authorId: widget.authorId!,
                              )
                          : null,
                    )),
                ],
              ),
            ),
          ),
          if (_editingImageUrl != null && _attachment == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _previewNetworkImage(_editingImageUrl!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _editingImageUrl!,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _editingImageUrl = null;
                        _editingOldFileName = null;
                      });
                    },
                    icon: const Icon(Icons.close, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ),
          _RichReplyBar(
            controller: _replyController,
            focusNode: _focusNode,
            isFocused: _isFocused,
            attachment: _attachment,
            isLocked: isDiscussionLocked,
           
            onSubmit: isDiscussionLocked ? null : () => _submitReply(provider),
            onAttachmentChanged: (a) => setState(() => _attachment = a),
           
           
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REPLY THREAD SCREEN
// ─────────────────────────────────────────────
class ReplyThreadScreen extends StatefulWidget {
  final String topicId;
  final String replyId;
  final String cohortId;
  final int? authorId;
  final int? programId;
  final int? courseId;
  const ReplyThreadScreen({
    super.key,
    required this.topicId,
    required this.replyId,
    required this.cohortId,
    this.authorId,
    this.programId,
    this.courseId,
  });

  @override
  State<ReplyThreadScreen> createState() => _ReplyThreadScreenState();
}

class _ReplyThreadScreenState extends State<ReplyThreadScreen> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  ReplyAttachment? _attachment;
  late final int _replyId;
  int? _editingPostId;
  int? _editingParentPostId;
  String? _editingImageUrl;
  String? _editingOldFileName;


  @override
  void initState() {
    super.initState();
    _replyId = int.tryParse(widget.replyId) ?? 0;
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DiscussionProvider>().loadPostReplies(
            postId: widget.replyId,
            authorId: widget.authorId,
          );
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitReply(DiscussionProvider provider) async {
    final text = _replyController.text.trim();
    if (text.isEmpty && _attachment == null) return;
    if (_editingPostId != null) {
      final files = await _buildImageFilesPayload(
        _attachment,
        oldFileName: _editingOldFileName ?? '',
      );
      final payload = {
        if (_editingParentPostId != null)
          'parent_post_id': _editingParentPostId,
        'body': text,
        'author_id': widget.authorId ?? 0,
        'program_id': widget.programId ?? 0,
        'course_id': widget.courseId ?? 0,
        'files': files.isEmpty
            ? []
            : [
                {
                  'file_name': files.first['file_name'],
                  'file': files.first['file'],
                  'old_file_name': _editingOldFileName ?? '',
                  'type': 'image',
                },
              ],
      };
      final ok = await provider.updatePost(
        cohortId: widget.cohortId,
        discussionId: widget.topicId,
        postId: _editingPostId.toString(),
        payload: payload,
      );
      if (!ok) return;
      _replyController.clear();
      _focusNode.unfocus();
      setState(() {
        _attachment = null;
        _editingPostId = null;
        _editingParentPostId = null;
        _editingImageUrl = null;
        _editingOldFileName = null;
      });
      return;
    }
    final files = await _buildImageFilesPayload(_attachment);
    final payload = {
      'parent_post_id': _replyId,
      'body': text,
      'author_id': widget.authorId ?? 0,
      'program_id': widget.programId ?? 0,
      'course_id': widget.courseId ?? 0,
      'files': files,
    };
    final ok = await provider.createPostReply(
      cohortId: widget.cohortId,
      discussionId: widget.topicId,
      postId: widget.replyId,
      payload: payload,
    );
    if (!ok) return;
    _replyController.clear();
    _focusNode.unfocus();
    setState(() {
      _attachment = null;
      _editingPostId = null;
    });
  }

  void _beginEdit(DiscussionPost post) {
    setState(() {
      _editingPostId = post.id;
      _editingParentPostId = post.parentPostId;
      _editingImageUrl = post.primaryImageUrl.isNotEmpty
          ? post.primaryImageUrl
          : null;
      _editingOldFileName =
          post.images.isNotEmpty ? post.images.first.fileName : null;
      _attachment = null;
      _replyController.text = post.body;
      _replyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _replyController.text.length),
      );
    });
    _focusNode.requestFocus();
  }

  void _previewNetworkImage(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewLocalImage(File file) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNestedThread(BuildContext context, DiscussionPost reply) {
    final provider = context.read<DiscussionProvider>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: ReplyThreadScreen(
          topicId: widget.topicId,
          cohortId: widget.cohortId,
          authorId: widget.authorId,
          programId: widget.programId,
          courseId: widget.courseId,
          replyId: reply.id.toString(),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscussionProvider>();
    final reply = provider.activePost;
    final isDiscussionLocked = provider.activeDiscussion?.isLocked ?? false;

    if (provider.isPostRepliesLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFA500)),
        ),
      );
    }

    if (provider.postRepliesError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0,
          leading: IconButton(onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827))),
          title: const Text('Thread',
            style: TextStyle(fontFamily: 'Urbanist', fontSize: 18,
              fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  provider.postRepliesError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadPostReplies(
                    postId: widget.replyId,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (reply == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)))),
        body: const Center(child: Text('This comment is no longer available.',
          style: TextStyle(fontFamily: 'Urbanist', color: Color(0xFF6B7280)))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827))),
        title: const Text('Thread',
          style: TextStyle(fontFamily: 'Urbanist', fontSize: 18,
            fontWeight: FontWeight.w800, color: Color(0xFF111827))),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () { },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _ParentReplyPost(
                    topicId: widget.topicId,
                    cohortId: widget.cohortId,
                    authorId: widget.authorId ?? 0,
                    reply: reply,
                    previewNetworkImage: () =>
                        _previewNetworkImage(reply.primaryImageUrl),
                    previewLocalImage: _previewLocalImage,
                    onEdit: (!isDiscussionLocked &&
                            widget.authorId != null &&
                            reply.authorId == widget.authorId)
                        ? () => _beginEdit(reply)
                        : null,
                    onDelete: (!isDiscussionLocked &&
                            widget.authorId != null &&
                            reply.authorId == widget.authorId)
                        ? () => context.read<DiscussionProvider>().deletePost(
                              cohortId: widget.cohortId,
                              postId: reply.id.toString(),
                              authorId: widget.authorId!,
                            )
                        : null,
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text('REPLIES',
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 12,
                        fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF),
                        letterSpacing: 0.8)),
                  ),
                  if (provider.postReplies.isEmpty)
                    const _EmptyReplies()
                  else
                    ...provider.postReplies.map((nested) => _ReplyRow(
                      topicId: widget.topicId,
                      cohortId: widget.cohortId,
                      authorId: widget.authorId ?? 0,
                      reply: nested,
                      previewNetworkImage: () =>
                          _previewNetworkImage(nested.primaryImageUrl),
                      previewLocalImage: _previewLocalImage,
                      onTap: () => _openNestedThread(context, nested),
                      onEdit: (widget.authorId != null &&
                              nested.authorId == widget.authorId)
                          ? () => _beginEdit(nested)
                          : null,
                      onDelete: (widget.authorId != null &&
                              nested.authorId == widget.authorId)
                          ? () => context.read<DiscussionProvider>().deletePost(
                                cohortId: widget.cohortId,
                                postId: nested.id.toString(),
                                authorId: widget.authorId!,
                              )
                          : null,
                    )),
                ],
              ),
            ),
          ),
          if (_editingImageUrl != null && _attachment == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _previewNetworkImage(_editingImageUrl!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _editingImageUrl!,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _editingImageUrl = null;
                        _editingOldFileName = null;
                      });
                    },
                    icon: const Icon(Icons.close, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ),
          _RichReplyBar(
            controller: _replyController,
            focusNode: _focusNode,
            isFocused: _isFocused,
            attachment: _attachment,
            isLocked: isDiscussionLocked,
            
            hintText: 'Reply to ${reply.author?.fullName ?? 'user'}...',
            onSubmit: isDiscussionLocked ? null : () => _submitReply(provider),
            onAttachmentChanged: (a) => setState(() => _attachment = a),
            
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RICH REPLY BAR
// ─────────────────────────────────────────────
class _RichReplyBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final VoidCallback? onSubmit;
  final ReplyAttachment? attachment;
  final bool isLocked;
 
  final String hintText;
  final ValueChanged<ReplyAttachment?> onAttachmentChanged;



  const _RichReplyBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onSubmit,
    required this.attachment,
    required this.isLocked,

    required this.onAttachmentChanged,

    this.hintText = ' your reply...',
  });

  Future<void> _pickImage() async {
    if (isLocked) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onAttachmentChanged(ReplyAttachment(type: AttachmentType.image, imageFile: File(picked.path)));
    }
  }

  Future<void> _pickCamera() async {
    if (isLocked) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      onAttachmentChanged(ReplyAttachment(type: AttachmentType.image, imageFile: File(picked.path)));
    }
  }



  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attachment preview
          if (attachment != null)
            _AttachmentPreview(attachment: attachment!, onRemove: () => onAttachmentChanged(null)),

          // Input row
          Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 10, MediaQuery.of(context).padding.bottom + 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
               
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 120),
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              enabled: !isLocked,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              style: const TextStyle(fontFamily: 'Urbanist', fontSize: 15, color: Color(0xFF111827)),
                              decoration: InputDecoration(
                                hintText: isLocked
                                    ? 'Discussion is locked'
                                    : hintText,
                                hintStyle: const TextStyle(fontFamily: 'Urbanist', fontSize: 15, color: Color(0xFF9CA3AF)),
                                border: InputBorder.none, isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                        _ToolbarBtn(
                          icon: Icons.image_outlined,
                          tooltip: 'Photo',
                          onTap: isLocked ? () {} : _pickImage,
                          isActive: !isLocked,
                        ),
                        _ToolbarBtn(
                          icon: Icons.camera_alt_outlined,
                          tooltip: 'Camera',
                          onTap: isLocked ? () {} : _pickCamera,
                          isActive: !isLocked,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isLocked ? null : onSubmit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? const Color(0xFFE5E7EB)
                          : isFocused
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(isLocked ? 'Locked' : 'Reply',
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isLocked
                            ? const Color(0xFF9CA3AF)
                            : isFocused
                                ? Colors.white
                                : const Color(0xFF2563EB))),
                  ),
                ),
              ],
            ),
          ),

          // Toolbar
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, MediaQuery.of(context).padding.bottom + 4),
            child: Row(
              children: [
                const Spacer(),
                // Character counter hint
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (_, val, __) {
                    final len = val.text.length;
                    final color = len > 240
                        ? Colors.red
                        : len > 200
                            ? Colors.orange
                            : const Color(0xFFD1D5DB);
                    return len > 180
                        ? Text('${280 - len}',
                            style: TextStyle(fontFamily: 'Urbanist', fontSize: 12,
                              fontWeight: FontWeight.w600, color: color))
                        : const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Emoji picker
          // if (showEmoji)
          //   SizedBox(
          //     height: 280,
          //     child: EmojiPicker(
          //       onEmojiSelected: (_, emoji) => onEmojiSelected(emoji.emoji),
          //       config: const Config(
          //         emojiViewConfig: EmojiViewConfig(backgroundColor: Color(0xFFF9FAFB)),
          //         categoryViewConfig: CategoryViewConfig(
          //           indicatorColor: Color(0xFFEC4899),
          //           iconColorSelected: Color(0xFFEC4899),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ATTACHMENT PREVIEW
// ─────────────────────────────────────────────
class _AttachmentPreview extends StatelessWidget {
  final ReplyAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.attachment, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildPreview(),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    switch (attachment.type) {
      case AttachmentType.image:
        return Image.file(attachment.imageFile!,
          height: 180, width: double.infinity, fit: BoxFit.cover);
      
    }
  }
}

class _ReplyImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final VoidCallback? onTap;

  const _ReplyImage({
    required this.imageUrl,
    this.height = 180,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: imageUrl.startsWith('file://')
          ? Image.file(
              File(imageUrl.replaceFirst('file://', '')),
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            )
          : Image.network(
              imageUrl,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

// ─────────────────────────────────────────────
//  TOOLBAR BUTTON
// ─────────────────────────────────────────────
class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _ToolbarBtn({
    required this.icon, required this.tooltip,
    required this.onTap, this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22,
            color: isActive ? const Color(0xFFEC4899) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  POLL OPTION FIELD
// ─────────────────────────────────────────────
class _PollOptionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PollOptionField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Urbanist', color: Color(0xFF6B7280)),
        filled: true, fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ORIGINAL POST
// ─────────────────────────────────────────────
class _OriginalPost extends StatelessWidget {
  final DiscussionItem discussion;
  const _OriginalPost({required this.discussion});

  void _previewImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Center(
                    child: imageUrl.startsWith('file://')
                        ? Image.file(
                            File(imageUrl.replaceFirst('file://', '')),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DiscussionProvider>();
    final authorName = discussion.author?.fullName.isNotEmpty == true
        ? discussion.author!.fullName
        : 'Unknown';
    final avatarLabel = discussion.author?.initials.isNotEmpty == true
        ? discussion.author!.initials
        : 'U';
    final imageUrl = discussion.primaryImageUrl;
    final repliesCount = provider.posts.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: const Color(0xFFFDE68A),
            child: Text(avatarLabel, style: const TextStyle(fontFamily: 'Urbanist',
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(authorName, style: const TextStyle(fontFamily: 'Urbanist',
              fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text(discussion.createdAt, style: const TextStyle(fontFamily: 'Urbanist',
              fontSize: 12, color: Color(0xFF9CA3AF))),
          ])),
        ]),
        const SizedBox(height: 14),
        //Text(discussion.title, style: const TextStyle(fontFamily: 'Urbanist', fontSize: 20,
        //  fontWeight: FontWeight.w800, color: Color(0xFF111827), height: 1.3)),
        const SizedBox(height: 8),
        Text(discussion.body, style: const TextStyle(fontFamily: 'Urbanist', fontSize: 15,
          fontWeight: FontWeight.w500, color: Color(0xFF374151), height: 1.6)),
        if (imageUrl.isNotEmpty) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _previewImage(context, imageUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.startsWith('file://')
                  ? Image.file(
                      File(imageUrl.replaceFirst('file://', '')),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(children: [
          _StatChip(icon: Icons.chat_bubble_outline, label: '$repliesCount',
            color: const Color(0xFF6B7280)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  PARENT REPLY POST
// ─────────────────────────────────────────────
class _ParentReplyPost extends StatelessWidget {
  final String topicId;
  final String cohortId;
  final int authorId;
  final DiscussionPost reply;
  final VoidCallback previewNetworkImage;
  final void Function(File file) previewLocalImage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _ParentReplyPost({
    required this.topicId,
    required this.cohortId,
    required this.authorId,
    required this.reply,
    required this.previewNetworkImage,
    required this.previewLocalImage,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DiscussionProvider>();
    final authorName = reply.author?.fullName.isNotEmpty == true
        ? reply.author!.fullName
        : 'Unknown';
    final avatarLabel = reply.author?.initials.isNotEmpty == true
        ? reply.author!.initials
        : 'U';
    final imageUrl = reply.primaryImageUrl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: const Color(0xFFFDE68A),
            child: Text(avatarLabel, style: const TextStyle(fontFamily: 'Urbanist',
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(authorName, style: const TextStyle(fontFamily: 'Urbanist',
              fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text(reply.createdAt, style: const TextStyle(fontFamily: 'Urbanist',
              fontSize: 12, color: Color(0xFF9CA3AF))),
          ])),
        ]),
        const SizedBox(height: 14),
        if (reply.body.isNotEmpty)
          Text(reply.body, style: const TextStyle(fontFamily: 'Urbanist', fontSize: 16,
            fontWeight: FontWeight.w500, color: Color(0xFF374151), height: 1.6)),
        if (imageUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ReplyImage(
            imageUrl: imageUrl,
            onTap: () => imageUrl.startsWith('file://')
                ? previewLocalImage(File(imageUrl.replaceFirst('file://', '')))
                : previewNetworkImage(),
          ),
        ],
        const SizedBox(height: 16),
        Row(children: [
          _StatChip(icon: reply.isLiked ? Icons.favorite : Icons.favorite_border,
            label: '${reply.likesCount}', color: const Color(0xFFEC4899),
            onTap: () => provider.togglePostLike(
              cohortId: cohortId,
              postId: reply.id,
              authorId: authorId,
              isLiked: reply.isLiked,
            )),
          const SizedBox(width: 8),
          _StatChip(icon: Icons.chat_bubble_outline, label: '${reply.replyCount}',
            color: const Color(0xFF6B7280)),
          const Spacer(),
          if (onEdit != null || onDelete != null)
            _CommentOptionsMenu(
              onEdit: onEdit,
              onDelete: onDelete,
            ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  REPLY ROW
// ─────────────────────────────────────────────
class _ReplyRow extends StatelessWidget {
  final String topicId;
  final String cohortId;
  final int authorId;
  final DiscussionPost reply;
  final VoidCallback previewNetworkImage;
  final void Function(File file) previewLocalImage;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _ReplyRow({
    required this.topicId,
    required this.cohortId,
    required this.authorId,
    required this.reply,
    required this.previewNetworkImage,
    required this.previewLocalImage,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DiscussionProvider>();
    final hasNested = reply.replyCount > 0;
    final authorName = reply.author?.fullName.isNotEmpty == true
        ? reply.author!.fullName
        : 'Unknown';
    final avatarLabel = reply.author?.initials.isNotEmpty == true
        ? reply.author!.initials
        : 'U';
    final imageUrl = reply.primaryImageUrl;
    final bool maxDepthReached = reply.depth >= 5;


    return InkWell(
       onTap: maxDepthReached ? null : onTap,
      splashColor: Colors.transparent,
      highlightColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 36, child: Column(children: [
              CircleAvatar(radius: 18, backgroundColor: const Color(0xFFFDE68A),
                child: Text(avatarLabel, style: const TextStyle(fontFamily: 'Urbanist',
                  fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87))),
              if (hasNested) Container(width: 2, height: 30,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(1))),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(authorName, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14,
                    fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
                const SizedBox(width: 5),
                Text('· ${reply.createdAt}', style: const TextStyle(fontFamily: 'Urbanist',
                  fontSize: 12, color: Color(0xFF9CA3AF))),
              ]),
              const SizedBox(height: 5),
              if (reply.body.isNotEmpty)
                Text(reply.body, maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14,
                    fontWeight: FontWeight.w500, color: Color(0xFF374151), height: 1.5)),
              if (imageUrl.isNotEmpty) ...[
                if (reply.body.isNotEmpty) const SizedBox(height: 10),
                _ReplyImage(
                  imageUrl: imageUrl,
                  height: 156,
                  onTap: () => imageUrl.startsWith('file://')
                      ? previewLocalImage(
                          File(imageUrl.replaceFirst('file://', '')))
                      : previewNetworkImage(),
                ),
              ],
              const SizedBox(height: 10),
              Row(children: [
                _ActionButton(
                  icon: reply.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: reply.likesCount > 0 ? '${reply.likesCount}' : '',
                  color: const Color(0xFFEC4899),
                  onTap: () => provider.togglePostLike(
                    cohortId: cohortId,
                    postId: reply.id,
                    authorId: authorId,
                    isLiked: reply.isLiked,
                  )),
                const SizedBox(width: 20),
               if (!maxDepthReached)
  _ActionButton(
    icon: Icons.chat_bubble_outline,
    label: hasNested
      ? '${reply.replyCount} repl${reply.replyCount == 1 ? 'y' : 'ies'}'
      : 'Reply',
    color: const Color(0xFF6B7280),
    onTap: onTap),
                const Spacer(),
                if (onEdit != null || onDelete != null)
                  _CommentOptionsMenu(
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
              ]),
              const SizedBox(height: 14),
            ])),
          ]),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
        ]),
      ),
    );
  }
}

class _EmptyReplies extends StatelessWidget {
  const _EmptyReplies();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      child: Center(child: Column(children: [
        Icon(Icons.chat_bubble_outline, size: 40, color: Color(0xFFE5E7EB)),
        SizedBox(height: 12),
        Text('No replies yet', style: TextStyle(fontFamily: 'Urbanist',
          fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
        SizedBox(height: 4),
        Text('Be the first to reply!', style: TextStyle(fontFamily: 'Urbanist',
          fontSize: 13, color: Color(0xFFD1D5DB))),
      ])),
    );
  }
}

// ─────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────
class _CommentOptionsMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CommentOptionsMenu({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Comment options',
      icon: const Icon(
        Icons.more_horiz,
        color: Color(0xFF6B7280),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 10),
                Text('Edit comment'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
                SizedBox(width: 10),
                Text(
                  'Delete comment',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatChip({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontFamily: 'Urbanist', fontSize: 13,
            fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Urbanist', fontSize: 13,
            fontWeight: FontWeight.w600, color: color)),
        ],
      ]),
    );
  }
}
