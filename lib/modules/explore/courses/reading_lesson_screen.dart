import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingLessonScreen extends StatefulWidget {
  final String lessonTitle;
  final String lessonContent;
  final String courseTitle;
  final String duration;
  final int currentIndex;
  final List<Map<String, dynamic>> courseContent;

  const ReadingLessonScreen({
    Key? key,
    required this.lessonTitle,
    required this.lessonContent,
    required this.courseTitle,
    required this.duration,
    required this.currentIndex,
    required this.courseContent,
  }) : super(key: key);

  @override
  State<ReadingLessonScreen> createState() => _ReadingLessonScreenState();
}

class _ReadingLessonScreenState extends State<ReadingLessonScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarShadow = false;
  double _readingProgress = 0.0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCompletionStatus();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.courseTitle}_${widget.lessonTitle}_completed';
    setState(() {
      _isCompleted = prefs.getBool(key) ?? false;
    });
  }

  Future<void> _markAsComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.courseTitle}_${widget.lessonTitle}_completed';
    await prefs.setBool(key, true);
    setState(() {
      _isCompleted = true;
    });
  }

  void _onScroll() {
    // Update app bar shadow
    if (_scrollController.offset > 0 && !_showAppBarShadow) {
      setState(() {
        _showAppBarShadow = true;
      });
    } else if (_scrollController.offset <= 0 && _showAppBarShadow) {
      setState(() {
        _showAppBarShadow = false;
      });
    }

    // Calculate reading progress
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    setState(() {
      _readingProgress =
          maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: _showAppBarShadow ? 2 : 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.courseTitle,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Reading',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Bookmark icon
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bookmark added'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
          ),
          // More options
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // Show more options
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _readingProgress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF2196F3),
            ),
            minHeight: 3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duration badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lesson title
                  Text(
                    widget.lessonTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reading stats
                  Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Article',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '1.2k views',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lessonContent,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade800,
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Mark as Complete Button
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCompleted
                    ? null
                    : () async {
                        await _markAsComplete();
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Great job!'),
                              content: const Text(
                                  'You\'ve completed this reading lesson.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(
                                        context); // Close reading screen
                                  },
                                  child: const Text('Continue'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted
                      ? Colors.grey.shade400
                      : const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isCompleted ? 'Completed' : 'Mark as Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
        );
      
  }
}
