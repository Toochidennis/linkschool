import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkschool/modules/explore/courses/discussions/discusssion_modal.dart';
import 'package:linkschool/modules/model/explore/cohorts/discussion_model.dart';
import 'package:linkschool/modules/providers/explore/courses/discussion_provider.dart';
import 'package:linkschool/modules/explore/courses/forum/topic_detail_screen.dart';
import 'package:provider/provider.dart';

class DiscussionScreen extends StatelessWidget {
  final String cohortId;
  final int? authorId;
  final int? programId;
  final int? courseId;

  const DiscussionScreen({
    super.key,
    required this.cohortId,
    this.authorId,
    this.programId,
    this.courseId,
  });

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      final parsed = DateTime.parse(normalized);
      return DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscussionProvider>();
    final discussions = provider.discussions;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFA500)),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadDiscussions(cohortId: cohortId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA500),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          color: const Color(0xFFF9FAFB),
          child: discussions.isEmpty
              ? const Center(
                  child: Text(
                    'No discussions yet',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 15,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                      provider.loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount:
                        discussions.length + (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= discussions.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFA500),
                            ),
                          ),
                        );
                      }

                      final discussion = discussions[index];
                      return _DiscussionCard(
                        discussion: discussion,
                        dateLabel: _formatDate(discussion.createdAt),
                        authorId: authorId,
                        programId: programId,
                        courseId: courseId,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: provider,
                                child: TopicDetailScreen(
                                  topicId: discussion.id.toString(),
                                  cohortId: cohortId,
                                  authorId: authorId,
                                  programId: programId,
                                  courseId: courseId,
                                ),
                              ),
                            ),
                          );
                        },
                        onEdit:
                            (authorId != null && discussion.authorId == authorId)
                                ? () => showCreateDiscussionModal(
                                    context,
                                    authorId: authorId,
                                    cohortId: cohortId,
                                    provider: provider,
                                    programId: programId,
                                    courseId: courseId,
                                    initialDiscussion: discussion,
                                  )
                                : null,
                        onDelete:
                            (authorId != null && discussion.authorId == authorId)
                                ? () => provider.deleteDiscussion(
                                    cohortId: cohortId,
                                    discussionId: discussion.id.toString(),
                                    authorId: authorId!,
                                  )
                                : null,
                      );
                    },
                  ),
                ),
        ),

        // ── FAB ─────────────────────────────────────────────────────────────
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () => showCreateDiscussionModal(
              context,
              authorId: authorId,
              cohortId: cohortId,
              provider: provider,
              programId: programId,
              courseId: courseId,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ── Reply overlay (X / Twitter style) ────────────────────────────────────────
void _showReplyOverlay(
  BuildContext context,
  DiscussionItem discussion, {
  required int? authorId,
  required int? programId,
  required int? courseId,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (_, __, ___) => _ReplyOverlay(
        discussion: discussion,
        provider: context.read<DiscussionProvider>(),
        authorId: authorId,
        programId: programId,
        courseId: courseId,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        );
      },
    ),
  );
}

class _ReplyOverlay extends StatefulWidget {
  final DiscussionItem discussion;
  final DiscussionProvider provider;
  final int? authorId;
  final int? programId;
  final int? courseId;

  const _ReplyOverlay({
    required this.discussion,
    required this.provider,
    required this.authorId,
    required this.programId,
    required this.courseId,
  });

  @override
  State<_ReplyOverlay> createState() => _ReplyOverlayState();
}

class _ReplyOverlayState extends State<_ReplyOverlay> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  File? _imageFile;
  String? _imageBase64;
  String? _imageFileName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Auto-open keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _authorName =>
      widget.discussion.author?.fullName.isNotEmpty == true
          ? widget.discussion.author!.fullName
          : 'Unknown';

  String get _initials =>
      widget.discussion.author?.initials.isNotEmpty == true
          ? widget.discussion.author!.initials
          : 'U';

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
    );
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final name = picked.path.split(Platform.pathSeparator).last;

    setState(() {
      _imageFile = file;
      _imageBase64 = base64Encode(bytes);
      _imageFileName = name;
    });
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _imageBase64 = null;
      _imageFileName = null;
    });
  }

  List<Map<String, dynamic>> _buildFilesPayload() {
    if (_imageFile == null || _imageBase64 == null || _imageBase64!.isEmpty) {
      return [];
    }

    final fileName = _imageFileName ?? 'photo.jpg';
    return [
      {
        'file_name': fileName,
        'file': _imageBase64,
        'type': 'image',
        'old_file_name': '',
      },
    ];
  }

  Future<void> _submitReply() async {
    final body = _controller.text.trim();
    final files = _buildFilesPayload();

    if (body.isEmpty && files.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'body': body,
        'author_id': widget.authorId ?? widget.discussion.authorId,
        'program_id': widget.programId ?? 0,
        'course_id': widget.courseId ?? 0,
        'files': files,
      };

      final ok = await widget.provider.createDiscussionPost(
        cohortId: widget.discussion.cohortId.toString(),
        discussionId: widget.discussion.id.toString(),
        payload: payload,
      );

      if (!mounted || !ok) return;

      await widget.provider.loadDiscussions(
        cohortId: widget.discussion.cohortId.toString(),
        silent: true,
      );

      _controller.clear();
      _removeImage();
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        size: 22, color: Color(0xFF111827)),
                  ),
                  const Spacer(),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, value, __) {
                      final active = value.text.trim().isNotEmpty;
                      return TextButton(
                        onPressed: (active || _imageFile != null) && !_isSubmitting
                            ? _submitReply
                            : null,
                        style: TextButton.styleFrom(
                          backgroundColor: (active || _imageFile != null)
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFBFDBFE),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Reply',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: avatar + thread line
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFFDE68A),
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Thread line
                        Container(
                          width: 2,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: const Color(0xFFE5E7EB),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Right: "Replying to" + input
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Replying to ',
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                              children: [
                                TextSpan(
                                  text: '@$_authorName',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_imageFile != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _imageFile!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Attached image',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _imageFileName ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _removeImage,
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xFF111827),
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Post your reply',
                              hintStyle: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFFD1D5DB),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Toolbar pinned above keyboard ──────────────────────────────
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                top: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 14,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _toolbarBtn(
                        icon: Icons.image_outlined,
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                      _toolbarBtn(
                        icon: Icons.photo_camera_outlined,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: const Color(0xFF2563EB)),
      splashRadius: 20,
    );
  }
}

// ── Discussion card ───────────────────────────────────────────────────────────
class _DiscussionCard extends StatelessWidget {
  final DiscussionItem discussion;
  final String dateLabel;
  final int? authorId;
  final int? programId;
  final int? courseId;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DiscussionCard({
    required this.discussion,
    required this.dateLabel,
    required this.authorId,
    required this.programId,
    required this.courseId,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final authorName = discussion.author?.fullName.isNotEmpty == true
        ? discussion.author!.fullName
        : 'Unknown';
    final initials = discussion.author?.initials.isNotEmpty == true
        ? discussion.author!.initials
        : 'U';
    final imageUrl = discussion.primaryImageUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFFDE68A),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dateLabel,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (discussion.isPinned)
                      _statusChip('Pinned', const Color(0xFF2563EB)),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        tooltip: 'Discussion options',
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
                                  Text('Edit discussion'),
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
                                    'Delete discussion',
                                    style: TextStyle(color: Color(0xFFDC2626)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                if (discussion.body.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    discussion.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 15,
                      height: 1.4,
                        fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
                if (imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: imageUrl.startsWith('file://')
                        ? Image.file(
                            File(imageUrl.replaceFirst('file://', '')),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          )
                        : Image.network(
                            imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(
                    height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),

                // ── Bottom action row ──
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${discussion.postsCount} Comments',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: authorId == null
                          ? null
                          : () => context.read<DiscussionProvider>().discussionLike(
                                cohortId: discussion.cohortId.toString(),
                                discussionId: discussion.id,
                                authorId: authorId!,
                                isLiked: discussion.isLiked,
                              ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF2563EB),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              discussion.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 14,
                              color: const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${discussion.likesCount}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (!discussion.isLocked)
                      GestureDetector(
                        onTap: () => _showReplyOverlay(
                          context,
                          discussion,
                          authorId: authorId,
                          programId: programId,
                          courseId: courseId,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF2563EB),
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.comment,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Comment',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
