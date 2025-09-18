import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/pdf_reader.dart';

import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Simple file model your API returns inside a submission
class SubmissionFile {
  final String name;
  final String url;
 
  SubmissionFile({required this.name, required this.url,});
}

class AssignmentGradingScreen extends StatefulWidget {
  final String assignmentTitle;
  final String studentName;
  final DateTime turnedInAt;
  final int maxScore;                // e.g. 100
  final int? currentScore;           // nullable, if ungraded
  final String assignmentId;         // backend id for this submission
  final List<dynamic> files;  // attachments
  final String itemId;              // assignment id
  final VoidCallback? onGraded;      // callback when graded
  const AssignmentGradingScreen({
    super.key,
    required this.assignmentTitle,
    required this.studentName,
    required this.turnedInAt,
    required this.maxScore,
    required this.assignmentId,
    required this.files,
    this.currentScore, required this.itemId,
    this.onGraded,
  });

  @override
  State<AssignmentGradingScreen> createState() => _AssignmentGradingScreenState();
}

class _AssignmentGradingScreenState extends State<AssignmentGradingScreen> {
  final TextEditingController _privateCommentCtrl = TextEditingController();
  final TextEditingController _scoreCtrl = TextEditingController();
  final FocusNode _scoreFocusNode = FocusNode();
  bool _returning = false;
  bool _gradingMode = false;
  int? _creatorId;
  String? _creatorName;

  @override
  void initState() {
    super.initState();
    _scoreCtrl.text = widget.currentScore?.toString() ?? '';
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userBox = Hive.box('userData');
      final stored = userBox.get('userData') ?? userBox.get('loginResponse');
      if (stored != null) {
        final processed = stored is String ? json.decode(stored) : stored as Map<String, dynamic>;
        final data = (processed['response']?['data']) ?? processed['data'] ?? processed;
        final profile = data['profile'] ?? {};
        setState(() {
          _creatorId = profile['staff_id'] as int?;
          _creatorName = profile['name']?.toString();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _privateCommentCtrl.dispose();
    _scoreCtrl.dispose();
    _scoreFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0F12) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E0F12) : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.paymentTxtColor1,
        ),
        title: Text(
            "Assignment",
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.normal600(
            fontSize: 20,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.paymentTxtColor1),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'refresh', child: Text('Refresh')),
            ],
            onSelected: (_) => setState(() {}),
          )
        ],
      ),


    body: Column(
  children: [
    Expanded(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _StudentHeader(
            name: widget.studentName,
            status: 'Turned in',
            dateText: DateFormat('MMM d, yyyy • hh:mm a').format(widget.turnedInAt),
          ),
          const SizedBox(height: 16),
          _SubmissionPreview(files: widget.files),
          const SizedBox(height: 24),
      
        ],
      ),
    ),

    SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _GradeBox(
            controller: _scoreCtrl,
            maxScore: widget.maxScore,
            onChanged: (v) {
              
            },
            focusNode: _scoreFocusNode,
          ),
          const SizedBox(width: 12),
         SizedBox(
           height: 40, 
           width: 80,
           child: ElevatedButton(
         style: ElevatedButton.styleFrom(
           fixedSize: const Size(80, 40),           // 👈 exact size
           backgroundColor: AppColors.paymentTxtColor1,
           foregroundColor: AppColors.backgroundLight,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
           padding: EdgeInsets.zero,                // avoid extra growth
           tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduce default tap target
         ),
         onPressed: _returning ? null : _handleReturnWithGrade,
         child: _returning
             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
             : const Text('Return'),
         )
         
         
         ),
      
        ],
      ),
    ),
  ],
),

    );
  }



 Future<void> _handleReturnWithGrade() async {
  final raw = _scoreCtrl.text.trim();
  final score = int.tryParse(raw);

  if (score == null) {
    CustomToaster.toastError(context, 'Hold up', 'Enter a valid number');
    return;
  }
  if (score < 0 || score > 100) {
    CustomToaster.toastError(
      context,
      'Out of range',
      'Score must be between 0 and ${widget.maxScore}',
    );
    return;
  }

  setState(() => _returning = true);
  try {
    final marker = context.read<MarkAssignmentProvider>();
    await marker.markAssignment(widget.assignmentId, score.toString());
    print('Marked with score: $score');
    print('Returning submission id: ${widget.assignmentId}');
    print('Grader id: ${widget.assignmentId}, name: $_creatorName');
    CustomToaster.toastSuccess(context, 'Returned', 'Grade shared with student');
    widget.onGraded?.call();
    Navigator.pop(context, true);
  } catch (e) {
    CustomToaster.toastError(context, 'Error', 'Could not return submission');
  } finally {
    if (mounted) setState(() => _returning = false);
  }
}

}

/* ---------- UI pieces ---------- */

class _StudentHeader extends StatelessWidget {
  final String name;
  final String status;
  final String dateText;
  const _StudentHeader({required this.name, required this.status, required this.dateText});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.paymentTxtColor1,
          child: Text(initials, style: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundLight)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.normal600(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 2),
              Text('$status • $dateText',
                  style: AppTextStyles.normal500(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}


class _SubmissionPreview extends StatelessWidget {
  final List<dynamic> files;
  const _SubmissionPreview({required this.files});

  bool _isImage(String name) {
    final n = name.toLowerCase();
    return n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png') ||
        n.endsWith('.gif') ||
        n.endsWith('.webp');
  }

  bool _isPdf(String name) {
    final n = name.toLowerCase();
    return n.endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: _cardDecoration(context),
        child: Text(
          'No files attached',
          style: AppTextStyles.normal500(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 120,
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.all(10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final f = files[index];

          String name;
          String url;
          if (f is SubmissionFile) {
            name = f.name;
            url = f.url;
          } else if (f is Map<String, dynamic>) {
            name = f['name']?.toString() ?? f['file_name']?.toString() ?? '';
            url = f['url']?.toString() ?? '';
          } else {
            name = '';
            url = '';
          }

          final isImg = _isImage(name);
          final isPdf = _isPdf(name);

          return InkWell(
            onTap: () async {
              if (isImg) {
                print("this is an image $name");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(),
                      body: Center(child: Image.network("https://linkskool.net/$name")),
                    ),
                  ),
                );
              } else if (isPdf) {
                print("this is an image $name");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfViewerPage(url:"https://linkskool.net/$name"),
                  ),
                );
              } else if (url.isNotEmpty) {
                final uri = Uri.parse(url);
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open file')),
                  );
                }
              }
            },
            child: SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 64,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isImg
                        ? Image.network(url, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported))
                        : isPdf
        ? FutureBuilder<String>(
            future: _downloadPdf(url), // Download to local temp file
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Icon(Icons.picture_as_pdf, size: 36);
              } else {
                return PDFView(
                  filePath: snapshot.data!,
                  enableSwipe: false,
                  swipeHorizontal: false,
                  pageSnap: false,
                  autoSpacing: false,
                  defaultPage: 0, // only first page
                );
              }
            },
          )
        : const Icon(Icons.insert_drive_file, size: 36),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name.split('/').last,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.normal600(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    
  }
  Future<String> _downloadPdf(String url) async {
  final response = await http.get(Uri.parse("https://linkskool.net/$url"));
  if (response.statusCode == 200) {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/${url.split('/').last}");
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } else {
    throw Exception("Failed to load PDF");
  }
}
}



//   BoxDecoration _cardDecoration(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return BoxDecoration(
//       color: isDark ? const Color(0xFF17191E) : Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: Colors.white10),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.08),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     );
//   }
// }

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF17191E) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }




class _GradeBox extends StatelessWidget {
  final TextEditingController controller;
  final int maxScore;
  final ValueChanged<String?> onChanged;
  final FocusNode? focusNode;
  const _GradeBox({
    required this.controller,
    required this.maxScore,
    required this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

   return Container(
     height: 44,
     padding: const EdgeInsets.symmetric(horizontal: 12),
     decoration: BoxDecoration(
       color: isDark ? const Color(0xFF17191E) : Colors.white,
       borderRadius: BorderRadius.circular(12),
       border: Border.all(
         color: focusNode?.hasFocus == true 
             ? Colors.blue 
             : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
         width: 1.5,
       ),
     ),
     child: Row(
       mainAxisSize: MainAxisSize.min,
       children: [
         SizedBox(
          width: 180,
           child: TextField(
             controller: controller,
             keyboardType: TextInputType.number,
             onChanged: onChanged,
             decoration: const InputDecoration(border: InputBorder.none),
             style: AppTextStyles.normal600(
               fontSize: 16,
               color: isDark ? Colors.white : Colors.black,
             ),
             textAlign: TextAlign.center,
             focusNode: focusNode,
           ),
         ),
         Text('/', style: AppTextStyles.normal600(fontSize: 16, color: Colors.grey)),
         Text(maxScore.toString(),
             style: AppTextStyles.normal600(fontSize: 16, color: Colors.grey)),
       ],
     ),
   );

  }
}
