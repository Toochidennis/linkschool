import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_detail_screen.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_model.dart';
import 'reading_lesson_screen.dart';
import 'package:linkschool/modules/providers/explore/courses/lesson_provider.dart';
import 'package:linkschool/modules/providers/explore/courses/enrollment_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform, Directory, File;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_payment_dialog.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseTitle;
  final String courseDescription;
  final String provider;
  final String providerSubtitle;
  final String category;
  final Color categoryColor;
  final int courseId;
  final int categoryId;
  final String cohortId;
  final bool isFree;
  final String? trialExpiryDate;
  final int? profileId;
  final String courseName;
  final String lessonImage;
  final String? trialType;
  final int trialValue;
  final int? lessonsTaken;
  final int? cohortCost;

  const CourseContentScreen({
    super.key,
    required this.courseTitle,
    required this.courseDescription,
    required this.provider,
    required this.courseId,
    required this.categoryId,
    required this.cohortId,
    required this.isFree,
    this.trialExpiryDate,
    this.providerSubtitle = 'Powered By Digital Dreams',
    this.category = 'COURSE',
    this.categoryColor = const Color(0xFF6366F1),
    this.profileId,
    required this.courseName,
    required this.lessonImage,
    this.trialType,
    this.trialValue = 0,
    this.lessonsTaken,
    this.cohortCost,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _localLessonsTaken = 0;
  bool _hasPaid = false;
  final Set<int> _completedLessonIds = {};
  int _resolvedCohortCost() {
    final cost = widget.cohortCost ?? 0;
    return cost;
  }

  bool _isTrialDaysExpired() {
    final expiry = widget.trialExpiryDate;
    if (expiry == null || expiry.trim().isEmpty) {
      return false;
    }
    try {
      final expiryDate = DateTime.parse(expiry).toLocal();
      return expiryDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool _isViewsTrialExhausted() {
    return (widget.trialType?.toLowerCase() == 'views') &&
        widget.trialValue > 0 &&
        _localLessonsTaken >= widget.trialValue;
  }

  void _showPaymentDialog({
    required LessonModel lesson,
    required List<LessonModel> lessons,
    required int index,
    bool navigateOnSuccess = true,
  }) {
    if (!mounted) return;
    final amount = _resolvedCohortCost();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CoursePaymentDialog(
        amount: amount,
        onPaymentSuccess: () {
          Navigator.of(dialogContext).pop();
          if (navigateOnSuccess && lesson.videoUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(
                  courseTitle: lesson.title,
                  courseName: widget.courseTitle,
                  courseId: widget.courseId,
                  courseDescription: lesson.description,
                  provider: widget.provider,
                  videoUrl: lesson.videoUrl,
                  assignmentUrl: null,
                  assignmentDescription: null,
                  materialUrl: null,
                  zoomUrl: null,
                  recordedUrl: null,
                  classDate: null,
                  profileId: widget.profileId,
                  lessonId: lesson.id,
                  cohortId: widget.cohortId,
                  lessons: lessons,
                  lessonIndex: index,
                  onLessonCompleted: _markLessonCompleted,
                ),
              ),
            );
          }
        },
        onPaymentCompleted: (reference, amountPaid) async {
          final paid = await _refreshPaymentStatus();
          if (!paid && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment not confirmed yet. Please try again.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return paid;
        },
      ),
    );
  }

  String _trialViewsKey() {
    final profileId = widget.profileId;
    return "trial_views_${profileId ?? 'guest'}_${widget.courseId}";
  }

  Future<void> _initTrialViewsCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final int? stored = prefs.getInt(_trialViewsKey());

    int effective = stored ?? 0;
    final serverTaken = widget.lessonsTaken ?? 0;
    if (serverTaken > effective) {
      effective = serverTaken;
    }
    await prefs.setInt(_trialViewsKey(), effective);

    if (mounted) {
      setState(() {
        _localLessonsTaken = effective;
      });
    }
  }

  
  Future<bool> _refreshPaymentStatus() async {
    if (widget.isFree || widget.profileId == null) {
      _hasPaid = true;
      return true;
    }

    try {
      final paid = await context.read<EnrollmentProvider>().checkPaymentStatus(
            cohortId: widget.cohortId,
            profileId: widget.profileId!,
          );
      if (mounted) {
        setState(() {
          _hasPaid = paid;
        });
      } else {
        _hasPaid = paid;
      }
      return paid;
    } catch (e) {
      return false;
    }
  }
  String _completedLessonsKey() {
    final profileId = widget.profileId;
    return "completed_lessons_${profileId ?? 'guest'}_${widget.courseId}";
  }

  Future<void> _loadCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_completedLessonsKey()) ?? [];
    if (mounted) {
      setState(() {
        _completedLessonIds
          ..clear()
          ..addAll(stored.map(int.parse));
      });
    }
  }

  Future<void> _saveCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _completedLessonsKey(),
      _completedLessonIds.map((id) => id.toString()).toList(),
    );
  }

  void _markLessonCompleted(int lessonId) {
    if (_completedLessonIds.add(lessonId)) {
      _saveCompletedLessons();
      if (mounted) {
        setState(() {});
      }
    }
  }

    @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompletionStatus();
    _localLessonsTaken = 0; // start at 0 by default regardless of server
    _initTrialViewsCounter();
    _loadCompletedLessons();
    // Fetch lessons for this course
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessons(
            cohortId: widget.cohortId,
          );
      _refreshPaymentStatus();
    });
  }

  Future<void> _loadCompletionStatus() async {
    setState(() {});
  }

  Future<void> _previewMaterial(String materialUrl, String materialName) async {
    // Navigate to a PDF preview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MaterialPreviewScreen(
          materialUrl: materialUrl,
          materialTitle: materialName,
        ),
      ),
    );
  }

  // Helper function to get public Downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // For Android, use the public Downloads folder
      final downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);

      // Check if the directory exists, if not try alternative paths
      if (await downloadsDir.exists()) {
        return downloadsDir;
      }

      // Try alternative path (some devices use different paths)
      final altPath = '/sdcard/Download';
      final altDir = Directory(altPath);
      if (await altDir.exists()) {
        return altDir;
      }

      // If neither exists, create the standard one
      try {
        await downloadsDir.create(recursive: true);
        return downloadsDir;
      } catch (e) {
        // Fallback to external storage directory
        final dir = await getExternalStorageDirectory();
        return Directory('${dir!.path}/Download');
      }
    } else if (Platform.isIOS) {
      // For iOS, use the app's documents directory
      final dir = await getApplicationDocumentsDirectory();
      return Directory('${dir.path}/Downloads');
    }
    return null;
  }

  Future<void> _downloadMaterial(
      String materialUrl, String materialName) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Downloading material...'),
              ],
            ),
          ),
        );
      }

      final response = await http.get(Uri.parse(materialUrl));
      if (response.statusCode == 200) {
        final downloadsDir = await _getDownloadsDirectory();
        if (downloadsDir == null) {
          throw Exception('Could not access Downloads directory');
        }

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        // Extract file extension from URL or default to .pdf
        String extension = '.pdf';
        if (materialUrl.contains('.')) {
          extension = '.${materialUrl.split('.').last.split('?').first}';
        }

        final fileName =
            '${materialName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes, flush: true);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded: $materialName to Downloads folder'),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download material'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

    @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    const imageHeight = 240.0;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<LessonProvider>().loadLessons(
                cohortId: widget.cohortId,
              );
        },
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.network(
                    widget.lessonImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child:
                            Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    widget.courseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFFFA500),
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: const Color(0xFFFFA500),
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Lessons'),
                        Tab(text: 'Materials'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLessonsTab(),
                  _buildMaterialsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLessonsTab() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFA500),
            ),
          );
        }

        if (lessonProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  lessonProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => lessonProvider.refreshLessons(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final lessons = lessonProvider.lessons;

        if (lessons.isEmpty) {
          return const Center(
            child: Text(
              'No lessons available for this course',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final isCompleted = _completedLessonIds.contains(lesson.id);
            final isVideo = lesson.videoUrl.isNotEmpty;
            final hasReading = false;
            return GestureDetector(
              onTap: () async {
                final trialType = widget.trialType?.toLowerCase();
                if (!widget.isFree && !_hasPaid) {
                  if ((trialType == 'days' || trialType == 'day') &&
                      _isTrialDaysExpired()) {
                    _showPaymentDialog(
                      lesson: lesson,
                      lessons: lessons,
                      index: index,
                    );
                    return;
                  }
                  if (trialType == 'views' && _isViewsTrialExhausted()) {
                    _showPaymentDialog(
                      lesson: lesson,
                      lessons: lessons,
                      index: index,
                    );
                    return;
                  }
                }

                if (!isVideo) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No content available for this lesson'),
                    ),
                  );
                  return;
                }

                final isTrialCourse = !widget.isFree &&
                    !_hasPaid &&
                    trialType == 'views' &&
                    widget.trialValue > 0;
                final currentLessonsTaken = _localLessonsTaken;
                bool shouldPromptAfterView = false;

                if (isTrialCourse) {
                  try {
                    final enrollmentProvider =
                        context.read<EnrollmentProvider>();
                    final prefs = await SharedPreferences.getInstance();
                    final savedPrefs = prefs.getInt(_trialViewsKey()) ?? 0;

                    if (currentLessonsTaken >= widget.trialValue) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your trial views have been exhausted. Please complete payment to continue.',
                            ),
                          ),
                        );
                        _showPaymentDialog(
                          lesson: lesson,
                          lessons: lessons,
                          index: index,
                        );
                      }
                      return;
                    }

                    final newLessonsTaken = currentLessonsTaken + 1;
                    shouldPromptAfterView = newLessonsTaken > widget.trialValue;

                    setState(() {
                      _localLessonsTaken = newLessonsTaken;
                    });
                    if (savedPrefs < newLessonsTaken) {
                      await prefs.setInt(_trialViewsKey(), newLessonsTaken);
                    }

                    if (widget.profileId != null) {
                      enrollmentProvider.updateTrialViewsSilently({
                        'profile_id': widget.profileId,
                        'course_id': widget.courseId,
                        'lessons_taken': newLessonsTaken,
                      }, widget.courseId);
                    }
                  } catch (e) {
                    // Continue to lesson if update fails
                  }
                }

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      courseTitle: lesson.title,
                      courseName: widget.courseTitle,
                      courseId: widget.courseId,
                      courseDescription: lesson.description,
                      provider: widget.provider,
                      videoUrl: lesson.videoUrl,
                      assignmentUrl: null,
                      assignmentDescription: null,
                      materialUrl: null,
                      zoomUrl: null,
                      recordedUrl: null,
                      classDate: null,
                      profileId: widget.profileId,
                      lessonId: lesson.id,
                      cohortId: widget.cohortId,
                      lessons: lessons,
                      lessonIndex: index,
                      onLessonCompleted: _markLessonCompleted,
                    ),
                  ),
                );

                await _loadCompletionStatus();
                if (shouldPromptAfterView && mounted) {
                  _showPaymentDialog(
                    lesson: lesson,
                    lessons: lessons,
                    index: index,
                    navigateOnSuccess: false,
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.white,
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lesson ${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lesson.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lesson.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                isVideo
                                    ? Icons.play_circle_outline
                                    : hasReading
                                        ? Icons.article_outlined
                                        : Icons.description_outlined,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isVideo ? 'Video lesson' : 'Lesson content',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildMaterialsTab() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFA500),
            ),
          );
        }

        if (lessonProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  lessonProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => lessonProvider.refreshLessons(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final resources = lessonProvider.resources;

        if (resources.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No materials available for this course',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];

            return GestureDetector(
              onTap: () {
                // Preview the resource
                _previewMaterial(resource.url, resource.name);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // File icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Color(0xFF6366F1),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Material details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      // Download icon
                      IconButton(
                        icon: const Icon(Icons.download),
                        color: const Color(0xFFFFA500),
                        onPressed: () =>
                            _downloadMaterial(resource.url, resource.name),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Material Preview Screen
class _MaterialPreviewScreen extends StatefulWidget {
  final String materialUrl;
  final String materialTitle;

  const _MaterialPreviewScreen({
    required this.materialUrl,
    required this.materialTitle,
  });

    @override
  State<_MaterialPreviewScreen> createState() => _MaterialPreviewScreenState();
}

class _MaterialPreviewScreenState extends State<_MaterialPreviewScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;

    @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      final response = await http.get(Uri.parse(widget.materialUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_material.pdf');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load material';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading material: $e';
        _isLoading = false;
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.materialTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFA500),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : PDFView(
                  filePath: _localPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  fitEachPage: true,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: 0,
                  fitPolicy: FitPolicy.WIDTH,
                  // password: _localPath,
                  preventLinkNavigation: false,
                  onError: (error) {
                    setState(() {
                      _error = error.toString();
                    });
                  },
                  onPageError: (page, error) {
                    setState(() {
                      _error = '$page: ${error.toString()}';
                    });
                  },
                ),
    );
  }
}













