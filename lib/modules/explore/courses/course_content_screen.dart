import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_detail_screen.dart';
import 'reading_lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/providers/explore/courses/lesson_provider.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseTitle;
  final String courseDescription;
  final String provider;
  final String providerSubtitle;
  final String category;
  final Color categoryColor;
  final int courseId;
  final int categoryId;

  const CourseContentScreen({
    Key? key,
    required this.courseTitle,
    required this.courseDescription,
    required this.provider,
    required this.courseId,
    required this.categoryId,
    this.providerSubtitle = 'Powered By Digital Dreams',
    this.category = 'COURSE',
    this.categoryColor = const Color(0xFF6366F1),
  }) : super(key: key);

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompletionStatus();
    // Fetch lessons for this course
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessons(
            categoryId: widget.categoryId.toString(),
            courseId: widget.courseId.toString(),
          );
    });
  }

  Future<void> _loadCompletionStatus() async {
    // Placeholder for completion status tracking
    // This can be implemented later with a proper state management solution
    setState(() {});
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
          widget.courseTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Column(
            children: [
              // Tabs
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLessonsTab(),
          _buildMaterialsTab(),
        ],
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
          itemCount: lessons.length + 1, // +1 for the description header
          itemBuilder: (context, index) {
            // First item is the course description
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Description Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About this course',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.courseDescription,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Course stats
                        Row(
                          children: [
                            _buildStatItem(
                              Icons.play_circle_outline,
                              '${lessons.length} lessons',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // "Course Content" header
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Course Content',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Adjust index for lessons
            final lessonIndex = index - 1;
            final lesson = lessons[lessonIndex];
            final isVideo = lesson.videoUrl.isNotEmpty;
            final hasReading = lesson.readingUrl.isNotEmpty;

            return GestureDetector(
              onTap: () async {
                if (isVideo) {
                  // Navigate to video lesson screen with lesson data
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(
                        courseTitle: lesson.title,
                        courseDescription: lesson.description,
                        provider: widget.provider,
                        videoUrl: lesson.videoUrl,
                        assignmentUrl: lesson.assignmentUrl.isNotEmpty 
                            ? lesson.assignmentUrl 
                            : null,
                        assignmentDescription: lesson.assignmentDescription.isNotEmpty
                            ? lesson.assignmentDescription
                            : null,
                        materialUrl: lesson.materialUrl.isNotEmpty 
                            ? lesson.materialUrl 
                            : null,
                      ),
                    ),
                  );
                  await _loadCompletionStatus();
                } else if (hasReading) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReadingLessonScreen(
                        lessonTitle: lesson.title,
                        lessonContent: lesson.description,
                        courseTitle: widget.courseTitle,
                        duration: lesson.date,
                        currentIndex: lessonIndex,
                        courseContent: [],
                        onNavigate: null,
                      ),
                    ),
                  );
                  await _loadCompletionStatus();
                } else {
                  // Handle lessons with materials but no video/reading
                  if (lesson.materialUrl.isNotEmpty) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadingLessonScreen(
                          lessonTitle: lesson.title,
                          lessonContent: lesson.description,
                          courseTitle: widget.courseTitle,
                          duration: lesson.date,
                          currentIndex: lessonIndex,
                          courseContent: [],
                          onNavigate: null,
                        ),
                      ),
                    );
                    await _loadCompletionStatus();
                  }
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
                            Text(
                              lesson.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
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
                                Text(
                                  lesson.date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (hasReading && !isVideo) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2196F3)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Reading',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2196F3),
                                      ),
                                    ),
                                  ),
                                ],
                                if (lesson.hasQuiz == 1) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFA500)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Quiz',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFFA500),
                                      ),
                                    ),
                                  ),
                                ],
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
                // Open the resource URL
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${resource.name}...'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
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
                            Text(
                              'Resource ID: ${resource.id}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Download icon
                      IconButton(
                        icon: const Icon(Icons.download),
                        color: const Color(0xFFFFA500),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${resource.name}...'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                          );
                        },
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
