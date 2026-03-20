import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkschool/modules/model/explore/cohorts/discussion_model.dart';
import 'package:linkschool/modules/providers/explore/courses/discussion_provider.dart';

// ─── Public helper to open the modal ────────────────────────────────────────
void showCreateDiscussionModal(
  BuildContext context, {
  int? authorId,
  required String cohortId,
  required DiscussionProvider provider,
  int? programId,
  int? courseId,
  DiscussionItem? initialDiscussion,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateDiscussionModal(
      authorId: authorId,
      cohortId: cohortId,
      provider: provider,
      programId: programId,
      courseId: courseId,
      initialDiscussion: initialDiscussion,
    ),
  );
}

// ─── Proper StatefulWidget modal (fixes image-disappearing bug) ──────────────
class _CreateDiscussionModal extends StatefulWidget {
  final int? authorId;
  final String cohortId;
  final DiscussionProvider provider;
  final int? programId;
  final int? courseId;
  final DiscussionItem? initialDiscussion;

  const _CreateDiscussionModal({
    required this.cohortId,
    required this.provider,
    this.authorId,
    this.programId,
    this.courseId,
    this.initialDiscussion,
  });

  @override
  State<_CreateDiscussionModal> createState() => _CreateDiscussionModalState();
}

class _CreateDiscussionModalState extends State<_CreateDiscussionModal>
    with SingleTickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────────

  late final TextEditingController _bodyCtrl;
  late final FocusNode _titleFocus;
  late final FocusNode _bodyFocus;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Image state (lives here — never reset by parent rebuilds) ────────────
  File? _imageFile;
  String? _imageBase64;
  String? _imageFileName;
  String? _existingImageUrl;

  // ── Other state ──────────────────────────────────────────────────────────
  bool _isPinned = false;
  bool _isLocked = false;
  bool _isSubmitting = false;
  bool get _isEdit => widget.initialDiscussion != null;

  // ── Design tokens ────────────────────────────────────────────────────────
  static const _blue = Color(0xFF2563EB);
  static const _blueSoft = Color(0xFFEFF6FF);
  static const _red = Color(0xFFDC2626);
  static const _border = Color(0xFFE5E7EB);
  static const _textDark = Color(0xFF111827);
  static const _textMid = Color(0xFF374151);
  static const _textSub = Color(0xFF6B7280);
  static const _bg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();

    final d = widget.initialDiscussion;

    _bodyCtrl = TextEditingController(text: d?.body ?? '');
    _titleFocus = FocusNode();
    _bodyFocus = FocusNode();
    _isPinned = d?.isPinned ?? false;
    _isLocked = d?.isLocked ?? false;
    _existingImageUrl = d?.primaryImageUrl.isNotEmpty == true
        ? d!.primaryImageUrl
        : null;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
 
    _bodyCtrl.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Image picker ─────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final name = picked.path.split(Platform.pathSeparator).last;
    setState(() {
      _imageFile = file;
      _imageBase64 = base64Encode(bytes);
      _imageFileName = name;
    });
    debugPrint('🖼️ Picked image: $name (${bytes.length} bytes)');
  }

  void _removeImage() => setState(() {
        _imageFile = null;
        _imageBase64 = null;
        _imageFileName = null;
      });

  void _previewExistingImage() {
    final url = _existingImageUrl;
    if (url == null || url.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
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
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    
    final body = _bodyCtrl.text.trim();
    final authorId = widget.authorId ?? 0;
    final programId = widget.programId ?? 0;
    final courseId = widget.courseId ?? 0;

    if ( body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' content are required.'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (authorId == 0 || programId == 0 || courseId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing author, program, or course id.'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      
      'body': body,
      'author_id': authorId,
      'program_id': programId,
      'course_id': courseId,
      'files': _imageFile == null
          ? []
          : [
              {
                'file_name': _imageFileName ?? '',
                'file': _imageBase64 ?? '',
                  'type': 'image',
                  
                'old_file_name': _imageFileName ?? '',
              },
            ],
      'is_locked': _isLocked ? 1 : 0,
      'is_pinned': _isPinned ? 1 : 0,
    };
    debugPrint('🧾 Create discussion payload: $payload');
    debugPrint(
      _imageFile == null
          ? '🖼️ No image attached'
          : '🖼️ Image attached: $_imageFileName',
    );

    final ok = _isEdit
        ? await widget.provider.updateDiscussion(
            cohortId: widget.cohortId,
            discussionId: widget.initialDiscussion!.id.toString(),
            payload: payload,
          )
        : await widget.provider.createDiscussion(
            cohortId: widget.cohortId,
            payload: payload,
          );

    setState(() => _isSubmitting = false);

    if (ok && mounted) Navigator.of(context).pop();
  }

  // ── Preview image dialog ─────────────────────────────────────────────────
  void _previewImage() {
    if (_imageFile == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.file(_imageFile!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ─────────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),

              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _blueSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isEdit ? Icons.edit_rounded : Icons.forum_rounded,
                      color: _blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit ? 'Edit Discussion' : 'New Discussion',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          _isEdit
                              ? 'Update your post below'
                              : 'Share a thought or ask a question',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            color: _textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _bg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: _textSub, size: 18),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Scrollable body ──────────────────────────────────────────
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      

                      const SizedBox(height: 16),

                      // Body field
                      // Body field with embedded image icon
_label('Content'),
const SizedBox(height: 8),
Stack(
  children: [
    TextField(
      controller: _bodyCtrl,
      focusNode: _bodyFocus,
      maxLines: 5,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 14,
        color: _textDark,
      ),
      decoration: InputDecoration(
        hintText: 'Share your thoughts, ask questions, or start a discussion...',
        hintStyle: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 14,
          color: Color(0xFFD1D5DB),
        ),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.fromLTRB(16, 14, 48, 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
      ),
    ),
    Positioned(
      right: 10,
      bottom: 10,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            size: 16,
            color: _textSub,
          ),
        ),
      ),
    ),
  ],
),

                      const SizedBox(height: 16),

                      // ── Image section ──────────────────────────────────
                      if (_imageFile != null) ...[
                        _label('Attached Image'),
                        const SizedBox(height: 8),
                        _ImagePreviewTile(
                          file: _imageFile!,
                          onPreview: _previewImage,
                          onRemove: _removeImage,
                        ),
                        const SizedBox(height: 12),
                      ] else if (_isEdit &&
                          _existingImageUrl != null &&
                          _existingImageUrl!.isNotEmpty) ...[
                        _label('Current Image'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _previewExistingImage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              _existingImageUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _UploadButton(onTap: _pickImage),
                        const SizedBox(height: 16),
                      ] else ...[
                       // _UploadButton(onTap: _pickImage),
                        const SizedBox(height: 16),
                      ],

                      // ── Pin toggle ─────────────────────────────────────
                      Row(
  children: [
    Expanded(child: _CheckOption(
      label: 'Pin to top',
      subtitle: 'Keep visible at top',
      icon: Icons.push_pin_rounded,
      value: _isPinned,
      activeColor: _blue,
      activeBackground: _blueSoft,
      onChanged: (v) => setState(() => _isPinned = v),
    )),
    const SizedBox(width: 10),
    Expanded(child: _CheckOption(
      label: 'Lock',
      subtitle: 'Disable comments',
      icon: Icons.lock_rounded,
      value: _isLocked,
      activeColor: const Color(0xFFF97316),
      activeBackground: const Color(0xFFFFF7ED),
      onChanged: (v) => setState(() => _isLocked = v),
    )),
  ],
),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Action buttons ───────────────────────────────────────────
              Row(
                children: [
                  // Cancel
                  

                  // Submit
                  Expanded(
                    flex: 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          disabledBackgroundColor: _blue.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isEdit
                                        ? Icons.check_rounded
                                        : Icons.send_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isEdit
                                        ? 'Save Changes'
                                        : 'Post Discussion',
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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

  // ── Small helpers ─────────────────────────────────────────────────────────
  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _textMid,
          letterSpacing: 0.2,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    FocusNode? focusNode,
  }) =>
      TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 14,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            color: Color(0xFFD1D5DB),
          ),
          filled: true,
          fillColor: _bg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
      );
}

// ─── Image preview tile ───────────────────────────────────────────────────────
class _ImagePreviewTile extends StatelessWidget {
  final File file;
  final VoidCallback onPreview;
  final VoidCallback onRemove;

  const _ImagePreviewTile({
    required this.file,
    required this.onPreview,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Thumbnail
          GestureDetector(
            onTap: onPreview,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                file,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path.split(Platform.pathSeparator).last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onPreview,
                  child: const Text(
                    'Tap thumbnail to preview',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Remove
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upload button ────────────────────────────────────────────────────────────
class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_photo_alternate_rounded,
                size: 18, color: Color(0xFF6B7280)),
            SizedBox(width: 8),
            Text(
              'Add an image (optional)',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pin toggle ───────────────────────────────────────────────────────────────
class _LockToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _LockToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFFFF7ED) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? const Color(0xFFF97316).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFFF97316).withOpacity(0.12)
                    : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 14,
                color: value
                    ? const Color(0xFFF97316)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lock discussion',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: value
                          ? const Color(0xFFF97316)
                          : const Color(0xFF374151),
                    ),
                  ),
                  Text(
                    'Keep the discussion open for everyone to comment',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFF97316),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _PinToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PinToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFFEFF6FF)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? const Color(0xFF2563EB).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF2563EB).withOpacity(0.12)
                    : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.push_pin_rounded,
                size: 14,
                color: value
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pin to top',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: value
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF374151),
                    ),
                  ),
                  Text(
                    'Keep this discussion visible at the top',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2563EB),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}


class _CheckOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Color activeColor;
  final Color activeBackground;
  final ValueChanged<bool> onChanged;

  const _CheckOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.activeColor,
    required this.activeBackground,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? activeBackground : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? activeColor.withOpacity(0.3) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: activeColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: value ? activeColor : const Color(0xFF374151),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 13, color: value ? activeColor : const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
