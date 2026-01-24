import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_detail_screen.dart';
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

  String _trialViewsKey() {
    final profileId = widget.profileId;
    return "trial_views_${profileId ?? 'guest'}_${widget.courseId}";
  }

  Future<void> _initTrialViewsCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final int? stored = prefs.getInt(_trialViewsKey());

    int effective;
    if (stored == null) {
      // No local stored value: initialize to 0 (first tap becomes 1).
      effective = 0;
      await prefs.setInt(_trialViewsKey(), effective);
      
    } else {
      effective = stored;
    }

    if (mounted) {
      setState(() {
        _localLessonsTaken = effective;
      });
    }
  }

  Future<void> _saveTrialViewsCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trialViewsKey(), value);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompletionStatus();
    _localLessonsTaken = 0; // start at 0 by default regardless of server
    _initTrialViewsCounter();
    // Fetch lessons for this course
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessons(
            cohortId: widget.cohortId,
          );
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.courseName,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
            // Top banner image
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                widget.lessonImage,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
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
        
            // Course Content title and tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
        
            // Tab pages
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
            final isVideo = lesson.videoUrl.isNotEmpty;
            final hasReading = false;
            return GestureDetector(
              onTap: () async {
                print ('Tapped lesson: ${lesson.title}');
                if (isVideo) {
                  // Check if this is a trial course with views-based trial
                  final isTrialCourse =
                      widget.trialType?.toLowerCase() == 'views' &&
                          widget.trialValue > 0;
                  final currentLessonsTaken = _localLessonsTaken;
                  bool shouldPromptAfterView = false;

                  if (isTrialCourse) {
                    try {
                      final enrollmentProvider =
                          context.read<EnrollmentProvider>();

                      // Log tracing info: saved (prefs), local, server and trialValue
                      final prefs = await SharedPreferences.getInstance();
                      final savedPrefs = prefs.getInt(_trialViewsKey()) ?? 0;
                      final serverTaken = widget.lessonsTaken ?? 0;
                      
                       print(   '🔔 Lesson tap debug → savedPrefs: $savedPrefs, local: $currentLessonsTaken, server: $serverTaken, trialValue: ${widget.trialValue}');

                      // If trial already exhausted, prompt payment and do not update or navigate
                      if (currentLessonsTaken >= widget.trialValue) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Your trial views have been exhausted. Please complete payment to continue.')),
                          );

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) => CoursePaymentDialog(
                              amount:
                                  widget.cohortCost ?? 5000, // fallback amount
                              onPaymentSuccess: () {
                                Navigator.of(dialogContext).pop();
                                // Navigate to lesson after payment
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailScreen(
                                      courseTitle: lesson.title,
                                      courseName: widget.courseTitle,
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
                                    ),
                                  ),
                                );
                              },
                              onPaymentCompleted: (reference, amountPaid) {
                                // Handle payment completion
                                print(
                                    'Payment completed: $reference, Amount: $amountPaid');
                              },
                            ),
                          );
                        }

                        return; // Don't navigate to lesson
                      }

                      // Otherwise increment views and persist before allowing the view
                      final newLessonsTaken = currentLessonsTaken + 1;
                      // Only prompt after view when user exceeds allowed trial views (i.e., next tap would be blocked).
                      shouldPromptAfterView =
                          newLessonsTaken > widget.trialValue;

                      setState(() {
                        _localLessonsTaken = newLessonsTaken;
                      });
                      await _saveTrialViewsCounter(newLessonsTaken);

                      if (widget.profileId != null) {
                        enrollmentProvider.updateTrialViewsSilently({
                          'profile_id': widget.profileId,
                          'course_id': widget.cohortId,
                          'lessons_taken': newLessonsTaken,
                        }, widget.cohortId as int);
                      }
                    } catch (e) {
                      print('Error updating trial views: $e');
                      // Continue to lesson if update fails
                    }
                  }

                  // Navigate to video lesson screen with lesson data
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(
                        courseTitle: lesson.title,
                        courseName: widget.courseTitle,
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
                      ),
                    ),
                  );
                  // print trial data after returning
                  print('Returned from lesson. Current local lessons taken: $_localLessonsTaken');
                  print('widget.lessonsTaken: ${widget.lessonsTaken}');
                  print('shouldPromptAfterView: $shouldPromptAfterView');
                  await _loadCompletionStatus();
                  if (shouldPromptAfterView && mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => CoursePaymentDialog(
                        amount: widget.cohortCost ?? 0, // fallback amount
                        onPaymentSuccess: () {
                          Navigator.of(dialogContext).pop();
                        },
                        onPaymentCompleted: (reference, amountPaid) {
                          print(
                              'Payment completed: $reference, Amount: $amountPaid');
                        },
                      ),
                    );
                  }
                } else {
                  // No action for lessons without video
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No content available for this lesson')),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Checkbox/Indicator
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Lesson details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  lesson.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  isVideo
                                      ? Icons.play_circle_outline
                                      : hasReading
                                          ? Icons.article_outlined
                                          : Icons.description_outlined,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                // Text(
                                //   'Lesson ${lessonIndex}',
                                //   style: TextStyle(
                                //     fontSize: 12,
                                //     color: Colors.grey.shade600,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow icon
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                        size: 24,
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

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFFFFA500),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  String _getReadingContent(int lessonIndex) {
    // Sample reading content - you can customize this based on lesson index
    final Map<int, String> readingContents = {
      2: '''Fundamentals of Narrative Structure

A strong narrative structure is the backbone of any compelling story. Whether you're writing a novel, screenplay, or short story, understanding the fundamental elements that make up a narrative is essential for creating engaging content.

The Three-Act Structure

The most widely used narrative framework is the three-act structure, which divides a story into three distinct parts:

Act 1: Setup
This is where you introduce your characters, setting, and the central conflict. The setup establishes the "normal world" before the main action begins. By the end of Act 1, an inciting incident should occur that propels the protagonist into the main story.

Act 2: Confrontation
The longest section of your story, Act 2 is where the protagonist faces obstacles and challenges. This is where character development happens, relationships evolve, and the stakes are raised. The midpoint often introduces a major revelation or twist that changes the direction of the story.

Act 3: Resolution
The final act brings the story to its climax and resolution. All conflicts are addressed, character arcs are completed, and loose ends are tied up. This is where the protagonist faces their biggest challenge and emerges transformed.

Key Elements of Narrative

Beyond structure, several key elements work together to create a cohesive narrative:

Character Development
Characters should be multi-dimensional with clear motivations, flaws, and growth arcs. Readers connect with characters who feel real and relatable.

Conflict
Every story needs conflict - whether internal (character vs. self), external (character vs. character/nature/society), or both. Conflict drives the plot forward and creates tension.

Theme
The underlying message or central idea of your story. Themes give depth and meaning to your narrative beyond the surface plot.

Pacing
The rhythm and speed at which your story unfolds. Good pacing balances action, dialogue, and description to maintain reader engagement.

Applying These Principles

As you craft your own narratives, remember that these are guidelines, not rigid rules. The best stories often play with structure and conventions in creative ways. However, understanding these fundamentals gives you a solid foundation from which to experiment and innovate.

Practice identifying these elements in stories you love, and consciously apply them in your own writing. With time and experience, crafting compelling narratives will become second nature.''',
      4: '''Best Practices in Visual Communication

Visual communication is a powerful tool for conveying complex ideas quickly and effectively. In our increasingly visual world, understanding how to communicate through images, graphics, and design is essential for storytellers, marketers, and content creators.

The Power of Visual Hierarchy

Visual hierarchy is the arrangement of elements in order of importance. It guides the viewer's eye through your content in a deliberate sequence.

Size and Scale
Larger elements naturally draw more attention. Use size strategically to emphasize key information and create a clear focal point.

Color and Contrast
High contrast draws the eye. Use contrasting colors to highlight important elements and create visual interest. Complementary colors create vibrant combinations, while analogous colors provide harmony.

Typography
Font choice, size, and weight all contribute to hierarchy. Headlines should be bold and prominent, while body text should be readable and unobtrusive.

Principles of Effective Design

Several fundamental principles guide effective visual communication:

Balance
Distribute visual weight evenly across your design. Symmetrical balance creates formality and stability, while asymmetrical balance adds dynamism and interest.

Proximity
Group related elements together. This creates organization and helps viewers understand relationships between different pieces of information.

Alignment
Align elements to create clean, organized layouts. Even invisible alignment creates subconscious order that makes designs more professional and easier to navigate.

Repetition
Repeat design elements (colors, fonts, shapes) throughout your work to create consistency and unity. This builds brand recognition and visual cohesion.

White Space
Don't be afraid of empty space. White space (or negative space) gives your design room to breathe and prevents visual overwhelm. It can be just as important as the elements themselves.

Color Psychology

Colors evoke emotional responses and carry cultural meanings:

- Red: Energy, passion, urgency, danger
- Blue: Trust, calm, professionalism, stability
- Green: Growth, health, nature, harmony
- Yellow: Optimism, warmth, attention, caution
- Purple: Luxury, creativity, wisdom, mystery
- Orange: Enthusiasm, friendliness, confidence

Choose colors that align with your message and audience expectations.

Typography Best Practices

Font selection significantly impacts readability and tone:

- Use no more than 2-3 different fonts in a single design
- Pair contrasting fonts (e.g., serif with sans-serif)
- Ensure sufficient contrast between text and background
- Maintain appropriate line spacing (1.5x font size is standard)
- Limit line length to 50-75 characters for optimal readability

Visual Storytelling Techniques

When using visuals to tell stories:

Show, Don't Tell
Let images convey emotion and action rather than relying on text explanations. A powerful photograph or illustration can communicate what would take paragraphs to describe.

Create Narrative Flow
Arrange visual elements to guide viewers through your story. Use directional cues (arrows, eye gaze, leading lines) to create movement through your composition.

Use Metaphor and Symbolism
Visual metaphors can convey complex concepts quickly. A lightbulb for ideas, a path for journey, chains for connection - these visual shortcuts create instant understanding.

Practical Application

Apply these principles by:
1. Starting with a clear objective for each visual
2. Sketching rough layouts before digital creation
3. Seeking feedback from others
4. Iterating and refining based on responses
5. Studying effective designs in your field

Remember, effective visual communication balances aesthetics with functionality. Beautiful design that doesn't communicate clearly has failed its purpose. Always prioritize clarity and purpose over decoration.''',
    };

    return readingContents[lessonIndex] ??
        '''Sample Reading Content

This is a placeholder reading content for this lesson. In a real application, this would contain the actual educational content, with proper formatting, images, and interactive elements.

The content would be comprehensive, well-structured, and designed to provide valuable learning experiences for students taking this course.

Key topics would be covered in detail, with examples, exercises, and additional resources to help students master the subject matter.''';
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
