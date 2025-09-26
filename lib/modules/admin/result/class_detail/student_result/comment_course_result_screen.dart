import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/utils/term_comparison_utils.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

// Screen for commenting on course results
class CommentCourseResultScreen extends StatefulWidget {
  final String classId;
  final String year;
  final String termName;
  final int term;
  final bool isCurrentTerm;
  final bool isUserCurrentTerm; // New parameter for term comparison

  const CommentCourseResultScreen({
    super.key,
    required this.classId,
    required this.year,
    required this.termName,
    required this.term,
    required this.isCurrentTerm,
    required this.isUserCurrentTerm, // Add this parameter
  });

  @override
  State<CommentCourseResultScreen> createState() => _CommentCourseResultScreenState();
}

class _CommentCourseResultScreenState extends State<CommentCourseResultScreen> {
  List<Map<String, dynamic>> studentResults = [];
  List<String> assessmentNames = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _commentController = TextEditingController();
  int _currentStudentIndex = 0;
  final SwiperController _swiperController = SwiperController();
  String? userRole;
    
  // Comment modal state
  bool _isCommentModalOpen = false;
  final TextEditingController _modalCommentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeUserRole();
    fetchStudentResults();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _modalCommentController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  // Initialize user role from Hive storage
  void _initializeUserRole() {
    final userBox = Hive.box('userData');
    userRole = userBox.get('role')?.toString() ?? 'admin';
  }

  // Check if user can post/edit comments based on term comparison
  bool _canUserPostOrEditComments() {
    return widget.isUserCurrentTerm; // Only allow if user's term matches selected term
  }

  // Fetch student results from API
  Future<void> fetchStudentResults() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();
      final userBox = Hive.box('userData');
      final levelId = userBox.get('currentLevelId')?.toString() ?? '66';
      final role = userBox.get('role')?.toString() ?? 'admin';

      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final endpoint = 'portal/classes/${widget.classId}/students-result';
      final queryParams = {
        '_db': dbName,
        'year': widget.year,
        'term': widget.term.toString(),
        'level_id': levelId,
        'role': role,
      };

      final response = await apiService.get(
        endpoint: endpoint,
        queryParams: queryParams,
      );

      print('Raw API Response: ${response.rawData}');

      if (response.success && response.rawData != null) {
        final jsonResponse = response.rawData as Map<String, dynamic>;
        print('Extracted jsonResponse: $jsonResponse');
        final results = jsonResponse['response'] as List<dynamic>? ?? [];
        print('Extracted results: $results');

        final uniqueAssessments = <String>{};
        for (var student in results) {
          final subjects = student['subjects'] as List<dynamic>? ?? [];
          for (var subject in subjects) {
            final assessments = subject['assessments'] as List<dynamic>? ?? [];
            for (var assessment in assessments) {
              uniqueAssessments.add(assessment['assessment_name'] as String? ?? '');
            }
          }
          // Ensure comments field is a Map or null
          if (student['comments'] != null && student['comments'] is! Map) {
            student['comments'] = {'legacy_comment': student['comments']};
          }
        }

        setState(() {
          studentResults = List<Map<String, dynamic>>.from(results);
          assessmentNames = uniqueAssessments.toList();
          _commentController.text = studentResults.isNotEmpty
              ? (studentResults[0]['comments']?['principal_comment'] ??
                  studentResults[0]['comments']?['teacher_comment'] ??
                  '')
              : '';
          isLoading = false;
        });
      } else {
        setState(() {
          error = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in fetchStudentResults: $e');
      setState(() {
        error = 'Failed to load results: $e';
        isLoading = false;
      });
    }
  }

  // Submit comment to API
  Future<void> submitComment(int studentId, String comment) async {
    // Check if user can post/edit comments
    if (!_canUserPostOrEditComments()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only post/edit comments for the current term'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = locator<ApiService>();
      final userBox = Hive.box('userData');
      final role = userBox.get('role')?.toString() ?? 'admin';

      if (authProvider.token != null) {
        apiService.setAuthToken(authProvider.token!);
      }

      final dbName = EnvConfig.dbName;
      final endpoint = 'portal/students/result/comment';
      final payload = {
        'student_id': studentId,
        'comment': comment,
        'role': role,
        'year': int.parse(widget.year),
        'term': widget.term,
        '_db': dbName,
      };

      final response = await apiService.post(
        endpoint: endpoint,
        body: payload,
      );

      if (response.success) {
        setState(() {
          if (studentResults[_currentStudentIndex]['comments'] == null) {
            studentResults[_currentStudentIndex]['comments'] = {};
          }
                    
          if (role == 'admin') {
            studentResults[_currentStudentIndex]['comments']['principal_comment'] = comment;
          } else {
            studentResults[_currentStudentIndex]['comments']['teacher_comment'] = comment;
          }
          _isEditing = false; // Reset editing state after submission
        });
                
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          error = response.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit comment: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = 'Failed to submit comment: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build comment bottom sheet
  Widget _buildCommentBottomSheet() {
    final currentStudent = studentResults[_currentStudentIndex];
    final comments = currentStudent['comments'];
    final canPostOrEdit = _canUserPostOrEditComments();
        
    String existingComment = '';
    if (comments is Map<String, dynamic>) {
      if (userRole == 'admin') {
        existingComment = comments['principal_comment'] ?? '';
      } else {
        existingComment = comments['teacher_comment'] ?? '';
      }
    } else if (comments is String && comments.isNotEmpty) {
      existingComment = comments;
    }
        
    if (!_isEditing) {
      _modalCommentController.text = '';
    }

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
                            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Student Comments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.eLearningBtnColor1,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setModalState(() {
                        _isEditing = false;
                        _modalCommentController.text = '';
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
                            
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.primaries[_currentStudentIndex % Colors.primaries.length],
                      child: Text(
                        currentStudent['student_name']?.isNotEmpty == true
                            ? currentStudent['student_name'][0].toUpperCase()
                            : 'S',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStudent['student_name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Reg No: ${currentStudent['reg_no'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                            
              const SizedBox(height: 20),

              // Show restriction message if user cannot post/edit
              if (!canPostOrEdit) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can only view comments for this term. Posting and editing are restricted to the current term.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
                            
              // Show Post a comment input field only if no comments exist AND user can post
              if (!_hasExistingComment() && canPostOrEdit) ...[
                Text(
                  'Post a Comment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _modalCommentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter your comment here...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmittingComment ? null : () async {
                      if (_modalCommentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a comment'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                                            
                      setModalState(() {
                        _isSubmittingComment = true;
                      });
                                            
                      await submitComment(
                        currentStudent['student_id'],
                        _modalCommentController.text.trim(),
                      );
                                            
                      setModalState(() {
                        _isSubmittingComment = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eLearningBtnColor1,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmittingComment
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Comment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
                            
              // Show existing comments
              if (comments != null) ...[
                if (comments is Map<String, dynamic>) ...[
                  if (comments['principal_comment'] != null && comments['principal_comment'].toString().isNotEmpty)
                    _buildCommentCard(
                      'Principal Comment',
                      comments['principal_comment'].toString(),
                      Colors.blue,
                      canEdit: userRole == 'admin' && canPostOrEdit, // Only allow edit if user can post/edit
                      onEdit: () {
                        setModalState(() {
                          _isEditing = true;
                          _modalCommentController.text = comments['principal_comment'].toString();
                        });
                      },
                    ),
                                    
                  const SizedBox(height: 12),
                                    
                  if (comments['teacher_comment'] != null && comments['teacher_comment'].toString().isNotEmpty)
                    _buildCommentCard(
                      'Teacher Comment',
                      comments['teacher_comment'].toString(),
                      Colors.green,
                      canEdit: userRole == 'teacher' && canPostOrEdit, // Only allow edit if user can post/edit
                      onEdit: () {
                        setModalState(() {
                          _isEditing = true;
                          _modalCommentController.text = comments['teacher_comment'].toString();
                        });
                      },
                    ),
                ] else if (comments is String && comments.isNotEmpty) ...[
                  _buildCommentCard(
                    'Legacy Comment',
                    comments,
                    Colors.grey,
                    canEdit: false,
                  ),
                ],
                const SizedBox(height: 20),
                                
                // Show edit comment field only if there is an existing comment AND user can edit
                if (_hasExistingComment() && canPostOrEdit) ...[
                  Text(
                    'Edit Your Comment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _modalCommentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter your comment here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmittingComment || !_isEditing ? null : () async {
                        if (_modalCommentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a comment'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                                                
                        setModalState(() {
                          _isSubmittingComment = true;
                        });
                                                
                        await submitComment(
                          currentStudent['student_id'],
                          _modalCommentController.text.trim(),
                        );
                                                
                        setModalState(() {
                          _isSubmittingComment = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eLearningBtnColor1,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmittingComment
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Update Comment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  // Build comment card for displaying existing comments
  Widget _buildCommentCard(String title, String comment, Color color, {bool canEdit = false, VoidCallback? onEdit}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              // Only show Edit button if user can edit AND it's not already being edited
              if (canEdit && onEdit != null && !_isEditing)
                TextButton(
                  onPressed: onEdit,
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Check if there is an existing comment for the current user role
  bool _hasExistingComment() {
    if (studentResults.isEmpty) return false;
        
    final currentStudent = studentResults[_currentStudentIndex];
    final comments = currentStudent['comments'];
        
    if (comments == null) return false;
        
    if (comments is Map<String, dynamic>) {
      if (userRole == 'admin') {
        return comments['principal_comment'] != null && comments['principal_comment'].toString().isNotEmpty;
      } else {
        return comments['teacher_comment'] != null && comments['teacher_comment'].toString().isNotEmpty;
      }
    } else if (comments is String) {
      return comments.isNotEmpty;
    }
        
    return false;
  }

  // Handle swiper index change
  void _onSwiperIndexChanged(int index) {
    setState(() {
      _currentStudentIndex = index;
      _isEditing = false; // Reset editing state when switching students
      _modalCommentController.text = ''; // Clear comment field
      final student = studentResults[index];
      _commentController.text = student['comment'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comment on Results',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
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
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: Constants.customBoxDecoration(context),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      error!,
                                      style: const TextStyle(color: Colors.red, fontSize: 16),
                                    ),
                                    ElevatedButton(
                                      onPressed: fetchStudentResults,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  // Student and term card
                                  _buildStudentTermCard(),
                                  Expanded(
                                    child: Swiper(
                                      controller: _swiperController,
                                      itemCount: studentResults.length,
                                      index: _currentStudentIndex,
                                      onIndexChanged: _onSwiperIndexChanged,
                                      loop: false,
                                      itemBuilder: (context, index) {
                                        final student = studentResults[index];
                                        return SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              _buildSubjectsTable(student),
                                              const SizedBox(height: 150), // Space for bottom sheet
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
            // Persistent bottom sheet drawer
            if (studentResults.isNotEmpty)
              DraggableScrollableSheet(
                initialChildSize: _hasExistingComment() ? 0.2 : 0.4,
                minChildSize: _hasExistingComment() ? 0.2 : 0.4,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: _buildCommentBottomSheet(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Build card containing student and term information
  Widget _buildStudentTermCard() {
    if (studentResults.isEmpty) {
      return const SizedBox.shrink();
    }

    final student = studentResults[_currentStudentIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentStudentIndex > 0
                        ? () => _swiperController.previous(animation: true)
                        : null,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _currentStudentIndex > 0 ? AppColors.eLearningBtnColor1 : Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.primaries[_currentStudentIndex % Colors.primaries.length],
                        child: Text(
                          student['student_name']?.isNotEmpty == true
                              ? student['student_name'][0].toUpperCase()
                              : 'S',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        student['student_name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _currentStudentIndex < studentResults.length - 1
                        ? () => _swiperController.next(animation: true)
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentStudentIndex < studentResults.length - 1
                          ? AppColors.eLearningBtnColor1
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.orange, width: 2),
                    bottom: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${widget.year}/${int.parse(widget.year) + 1} ${widget.termName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build subjects table with layout matching StaffSkillsBehaviourScreen
  Widget _buildSubjectsTable(Map<String, dynamic> student) {
    final subjects = student['subjects'] as List? ?? [];
    if (subjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No subjects available', style: TextStyle(color: Colors.black)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSubjectColumn(subjects),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...assessmentNames
                        .asMap()
                        .entries
                        .map((entry) => _buildScrollableColumn(
                              entry.value,
                              100,
                              subjects,
                              entry.key,
                              isAssessment: true,
                            ))
                        .toList(),
                    _buildScrollableColumn('Total', 100, subjects, -1, isTotal: true),
                    _buildScrollableColumn('Grade', 100, subjects, -2, isGrade: true),
                    _buildScrollableColumn('Remark', 100, subjects, -3, isRemark: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build fixed subject column
  Widget _buildSubjectColumn(List subjects) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              'Subjects',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...subjects.asMap().entries.map((entry) {
            final subject = entry.value;
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subject['course_name']?.toString() ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Build scrollable column for assessments, total, grade, or remark
  Widget _buildScrollableColumn(String title, double width, List subjects, int index,
      {bool isAssessment = false, bool isTotal = false, bool isGrade = false, bool isRemark = false}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              border: Border(
                left: const BorderSide(color: Colors.white),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...subjects.asMap().entries.map((entry) {
            final subject = entry.value;
            String value = '-';
            if (isAssessment) {
              final assessmentData = (subject['assessments'] as List? ?? []).firstWhere(
                (a) => a['assessment_name'] == title,
                orElse: () => {'score': ''},
              );
              value = assessmentData['score']?.toString() ?? '-';
            } else if (isTotal) {
              value = subject['total_score']?.toString() ?? '-';
            } else if (isGrade) {
              value = subject['grade']?.toString() ?? '-';
            } else if (isRemark) {
              value = subject['remark']?.toString() ?? '-';
            }

            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: isGrade ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:flutter_swiper_view/flutter_swiper_view.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/config/env_config.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:provider/provider.dart';

// // Screen for commenting on course results
// class CommentCourseResultScreen extends StatefulWidget {
//   final String classId;
//   final String year;
//   final String termName;
//   final int term;
//   final bool isCurrentTerm;

//   const CommentCourseResultScreen({
//     super.key,
//     required this.classId,
//     required this.year,
//     required this.termName,
//     required this.term,
//     required this.isCurrentTerm,
//   });

//   @override
//   State<CommentCourseResultScreen> createState() => _CommentCourseResultScreenState();
// }

// class _CommentCourseResultScreenState extends State<CommentCourseResultScreen> {
//   List<Map<String, dynamic>> studentResults = [];
//   List<String> assessmentNames = [];
//   bool isLoading = true;
//   String? error;
//   final TextEditingController _commentController = TextEditingController();
//   int _currentStudentIndex = 0;
//   final SwiperController _swiperController = SwiperController();
//   String? userRole;
  
//   // Comment modal state
//   bool _isCommentModalOpen = false;
//   final TextEditingController _modalCommentController = TextEditingController();
//   bool _isSubmittingComment = false;
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserRole();
//     fetchStudentResults();
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     _modalCommentController.dispose();
//     _swiperController.dispose();
//     super.dispose();
//   }

//   // Initialize user role from Hive storage
//   void _initializeUserRole() {
//     final userBox = Hive.box('userData');
//     userRole = userBox.get('role')?.toString() ?? 'admin';
//   }

//   // Fetch student results from API
//   Future<void> fetchStudentResults() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final apiService = locator<ApiService>();
//       final userBox = Hive.box('userData');
//       final levelId = userBox.get('currentLevelId')?.toString() ?? '66';
//       final role = userBox.get('role')?.toString() ?? 'admin';

//       if (authProvider.token != null) {
//         apiService.setAuthToken(authProvider.token!);
//       }

//       final dbName = EnvConfig.dbName;
//       final endpoint = 'portal/classes/${widget.classId}/students-result';
//       final queryParams = {
//         '_db': dbName,
//         'year': widget.year,
//         'term': widget.term.toString(),
//         'level_id': levelId,
//         'role': role,
//       };

//       final response = await apiService.get(
//         endpoint: endpoint,
//         queryParams: queryParams,
//       );

//       print('Raw API Response: ${response.rawData}');

//       if (response.success && response.rawData != null) {
//         final jsonResponse = response.rawData as Map<String, dynamic>;
//         print('Extracted jsonResponse: $jsonResponse');
//         final results = jsonResponse['response'] as List<dynamic>? ?? [];
//         print('Extracted results: $results');

//         final uniqueAssessments = <String>{};
//         for (var student in results) {
//           final subjects = student['subjects'] as List<dynamic>? ?? [];
//           for (var subject in subjects) {
//             final assessments = subject['assessments'] as List<dynamic>? ?? [];
//             for (var assessment in assessments) {
//               uniqueAssessments.add(assessment['assessment_name'] as String? ?? '');
//             }
//           }
//           // Ensure comments field is a Map or null
//           if (student['comments'] != null && student['comments'] is! Map) {
//             student['comments'] = {'legacy_comment': student['comments']};
//           }
//         }

//         setState(() {
//           studentResults = List<Map<String, dynamic>>.from(results);
//           assessmentNames = uniqueAssessments.toList();
//           _commentController.text = studentResults.isNotEmpty
//               ? (studentResults[0]['comments']?['principal_comment'] ??
//                   studentResults[0]['comments']?['teacher_comment'] ??
//                   '')
//               : '';
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = response.message;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error in fetchStudentResults: $e');
//       setState(() {
//         error = 'Failed to load results: $e';
//         isLoading = false;
//       });
//     }
//   }

//   // Submit comment to API
//   Future<void> submitComment(int studentId, String comment) async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final apiService = locator<ApiService>();
//       final userBox = Hive.box('userData');
//       final role = userBox.get('role')?.toString() ?? 'admin';

//       if (authProvider.token != null) {
//         apiService.setAuthToken(authProvider.token!);
//       }

//       final dbName = EnvConfig.dbName;
//       final endpoint = 'portal/students/result/comment';
//       final payload = {
//         'student_id': studentId,
//         'comment': comment,
//         'role': role,
//         'year': int.parse(widget.year),
//         'term': widget.term,
//         '_db': dbName,
//       };

//       final response = await apiService.post(
//         endpoint: endpoint,
//         body: payload,
//       );

//       if (response.success) {
//         setState(() {
//           if (studentResults[_currentStudentIndex]['comments'] == null) {
//             studentResults[_currentStudentIndex]['comments'] = {};
//           }
          
//           if (role == 'admin') {
//             studentResults[_currentStudentIndex]['comments']['principal_comment'] = comment;
//           } else {
//             studentResults[_currentStudentIndex]['comments']['teacher_comment'] = comment;
//           }
//           _isEditing = false; // Reset editing state after submission
//         });
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Comment submitted successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         setState(() {
//           error = response.message;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to submit comment: ${response.message}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Failed to submit comment: $e';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error submitting comment: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Build comment bottom sheet
//   Widget _buildCommentBottomSheet() {
//     final currentStudent = studentResults[_currentStudentIndex];
//     final comments = currentStudent['comments'];
    
//     String existingComment = '';
//     if (comments is Map<String, dynamic>) {
//       if (userRole == 'admin') {
//         existingComment = comments['principal_comment'] ?? '';
//       } else {
//         existingComment = comments['teacher_comment'] ?? '';
//       }
//     } else if (comments is String && comments.isNotEmpty) {
//       existingComment = comments;
//     }
    
//     if (!_isEditing) {
//       _modalCommentController.text = '';
//     }

//     return StatefulBuilder(
//       builder: (context, setModalState) {
//         return Container(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 20,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//           ),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
              
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Student Comments',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.eLearningBtnColor1,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       setModalState(() {
//                         _isEditing = false;
//                         _modalCommentController.text = '';
//                       });
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
              
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundColor: Colors.primaries[_currentStudentIndex % Colors.primaries.length],
//                       child: Text(
//                         currentStudent['student_name']?.isNotEmpty == true
//                             ? currentStudent['student_name'][0].toUpperCase()
//                             : 'S',
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             currentStudent['student_name'] ?? 'N/A',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(
//                             'Reg No: ${currentStudent['reg_no'] ?? 'N/A'}',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Always show Post a comment input field if no comments exist
//               if (!_hasExistingComment()) ...[
//                 Text(
//                   'Post a Comment',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: TextField(
//                     controller: _modalCommentController,
//                     maxLines: 4,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter your comment here...',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.all(12),
//                     ),
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isSubmittingComment ? null : () async {
//                       if (_modalCommentController.text.trim().isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please enter a comment'),
//                             backgroundColor: Colors.orange,
//                           ),
//                         );
//                         return;
//                       }
                      
//                       setModalState(() {
//                         _isSubmittingComment = true;
//                       });
                      
//                       await submitComment(
//                         currentStudent['student_id'],
//                         _modalCommentController.text.trim(),
//                       );
                      
//                       setModalState(() {
//                         _isSubmittingComment = false;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.eLearningBtnColor1,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: _isSubmittingComment
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Submit Comment',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
              
//               // Show existing comments
//               if (comments != null) ...[
//                 if (comments is Map<String, dynamic>) ...[
//                   if (comments['principal_comment'] != null && comments['principal_comment'].toString().isNotEmpty)
//                     _buildCommentCard(
//                       'Principal Comment',
//                       comments['principal_comment'].toString(),
//                       Colors.blue,
//                       canEdit: userRole == 'admin', // Removed isCurrentTerm check
//                       onEdit: () {
//                         setModalState(() {
//                           _isEditing = true;
//                           _modalCommentController.text = comments['principal_comment'].toString();
//                         });
//                       },
//                     ),
                  
//                   const SizedBox(height: 12),
                  
//                   if (comments['teacher_comment'] != null && comments['teacher_comment'].toString().isNotEmpty)
//                     _buildCommentCard(
//                       'Teacher Comment',
//                       comments['teacher_comment'].toString(),
//                       Colors.green,
//                       canEdit: userRole == 'teacher', // Removed isCurrentTerm check
//                       onEdit: () {
//                         setModalState(() {
//                           _isEditing = true;
//                           _modalCommentController.text = comments['teacher_comment'].toString();
//                         });
//                       },
//                     ),
//                 ] else if (comments is String && comments.isNotEmpty) ...[
//                   _buildCommentCard(
//                     'Legacy Comment',
//                     comments,
//                     Colors.grey,
//                     canEdit: false,
//                   ),
//                 ],
//                 const SizedBox(height: 20),
                
//                 // Always show edit comment field if there is an existing comment
//                 if (_hasExistingComment()) ...[
//                   Text(
//                     'Edit Your Comment',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: TextField(
//                       controller: _modalCommentController,
//                       maxLines: 4,
//                       decoration: const InputDecoration(
//                         hintText: 'Enter your comment here...',
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.all(12),
//                       ),
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isSubmittingComment || !_isEditing ? null : () async {
//                         if (_modalCommentController.text.trim().isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Please enter a comment'),
//                               backgroundColor: Colors.orange,
//                             ),
//                           );
//                           return;
//                         }
                        
//                         setModalState(() {
//                           _isSubmittingComment = true;
//                         });
                        
//                         await submitComment(
//                           currentStudent['student_id'],
//                           _modalCommentController.text.trim(),
//                         );
                        
//                         setModalState(() {
//                           _isSubmittingComment = false;
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.eLearningBtnColor1,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: _isSubmittingComment
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             )
//                           : const Text(
//                               'Update Comment',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Build comment card for displaying existing comments
//   Widget _buildCommentCard(String title, String comment, Color color, {bool canEdit = false, VoidCallback? onEdit}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               if (canEdit && onEdit != null)
//                 TextButton(
//                   onPressed: onEdit,
//                   child: Text(
//                     'Edit',
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             comment,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[800],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Check if there is an existing comment for the current user role
//   bool _hasExistingComment() {
//     if (studentResults.isEmpty) return false;
    
//     final currentStudent = studentResults[_currentStudentIndex];
//     final comments = currentStudent['comments'];
    
//     if (comments == null) return false;
    
//     if (comments is Map<String, dynamic>) {
//       if (userRole == 'admin') {
//         return comments['principal_comment'] != null && comments['principal_comment'].toString().isNotEmpty;
//       } else {
//         return comments['teacher_comment'] != null && comments['teacher_comment'].toString().isNotEmpty;
//       }
//     } else if (comments is String) {
//       return comments.isNotEmpty;
//     }
    
//     return false;
//   }

//   // Handle swiper index change
//   void _onSwiperIndexChanged(int index) {
//     setState(() {
//       _currentStudentIndex = index;
//       _isEditing = false; // Reset editing state when switching students
//       _modalCommentController.text = ''; // Clear comment field
//       final student = studentResults[index];
//       _commentController.text = student['comment'] ?? '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     final opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Comment on Results',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: AppColors.eLearningBtnColor1,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.eLearningBtnColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: Constants.customBoxDecoration(context),
//                     child: isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : error != null
//                             ? Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       error!,
//                                       style: const TextStyle(color: Colors.red, fontSize: 16),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: fetchStudentResults,
//                                       child: const Text('Retry'),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Column(
//                                 children: [
//                                   // Student and term card
//                                   _buildStudentTermCard(),
//                                   Expanded(
//                                     child: Swiper(
//                                       controller: _swiperController,
//                                       itemCount: studentResults.length,
//                                       index: _currentStudentIndex,
//                                       onIndexChanged: _onSwiperIndexChanged,
//                                       loop: false,
//                                       itemBuilder: (context, index) {
//                                         final student = studentResults[index];
//                                         return SingleChildScrollView(
//                                           child: Column(
//                                             children: [
//                                               _buildSubjectsTable(student),
//                                               const SizedBox(height: 150), // Space for bottom sheet
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                   ),
//                 ),
//               ],
//             ),
//             // Persistent bottom sheet drawer
//             if (studentResults.isNotEmpty)
//               DraggableScrollableSheet(
//                 initialChildSize: _hasExistingComment() ? 0.2 : 0.4,
//                 minChildSize: _hasExistingComment() ? 0.2 : 0.4,
//                 maxChildSize: 0.8,
//                 builder: (context, scrollController) {
//                   return SingleChildScrollView(
//                     controller: scrollController,
//                     child: _buildCommentBottomSheet(),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build card containing student and term information
//   Widget _buildStudentTermCard() {
//     if (studentResults.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     final student = studentResults[_currentStudentIndex];

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: _currentStudentIndex > 0
//                         ? () => _swiperController.previous(animation: true)
//                         : null,
//                     icon: Icon(
//                       Icons.arrow_back_ios,
//                       color: _currentStudentIndex > 0 ? AppColors.eLearningBtnColor1 : Colors.grey,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 16,
//                         backgroundColor: Colors.primaries[_currentStudentIndex % Colors.primaries.length],
//                         child: Text(
//                           student['student_name']?.isNotEmpty == true
//                               ? student['student_name'][0].toUpperCase()
//                               : 'S',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         student['student_name'] ?? 'N/A',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     onPressed: _currentStudentIndex < studentResults.length - 1
//                         ? () => _swiperController.next(animation: true)
//                         : null,
//                     icon: Icon(
//                       Icons.arrow_forward_ios,
//                       color: _currentStudentIndex < studentResults.length - 1
//                           ? AppColors.eLearningBtnColor1
//                           : Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12.0),
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     top: BorderSide(color: Colors.orange, width: 2),
//                     bottom: BorderSide(color: Colors.orange, width: 2),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${widget.year}/${int.parse(widget.year) + 1} ${widget.termName}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Build subjects table with layout matching StaffSkillsBehaviourScreen
//   Widget _buildSubjectsTable(Map<String, dynamic> student) {
//     final subjects = student['subjects'] as List? ?? [];

//     if (subjects.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Text('No subjects available', style: TextStyle(color: Colors.black)),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             _buildSubjectColumn(subjects),
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ...assessmentNames
//                         .asMap()
//                         .entries
//                         .map((entry) => _buildScrollableColumn(
//                               entry.value,
//                               100,
//                               subjects,
//                               entry.key,
//                               isAssessment: true,
//                             ))
//                         .toList(),
//                     _buildScrollableColumn('Total', 100, subjects, -1, isTotal: true),
//                     _buildScrollableColumn('Grade', 100, subjects, -2, isGrade: true),
//                     _buildScrollableColumn('Remark', 100, subjects, -3, isRemark: true),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build fixed subject column
//   Widget _buildSubjectColumn(List subjects) {
//     return Container(
//       width: 120,
//       decoration: BoxDecoration(
//         color: Colors.blue[700],
//         borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 48,
//             alignment: Alignment.center,
//             child: const Text(
//               'Subjects',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ...subjects.asMap().entries.map((entry) {
//             final subject = entry.value;
//             return Container(
//               height: 50,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(
//                   top: BorderSide(color: Colors.grey[300]!),
//                   right: BorderSide(color: Colors.grey[300]!),
//                 ),
//               ),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   subject['course_name']?.toString() ?? 'N/A',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   // Build scrollable column for assessments, total, grade, or remark
//   Widget _buildScrollableColumn(String title, double width, List subjects, int index,
//       {bool isAssessment = false, bool isTotal = false, bool isGrade = false, bool isRemark = false}) {
//     return Container(
//       width: width,
//       decoration: BoxDecoration(
//         border: Border(left: BorderSide(color: Colors.grey[300]!)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 48,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: AppColors.eLearningBtnColor1,
//               border: Border(
//                 left: const BorderSide(color: Colors.white),
//                 bottom: BorderSide(color: Colors.grey[300]!),
//               ),
//             ),
//             child: Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           ...subjects.asMap().entries.map((entry) {
//             final subject = entry.value;
//             String value = '-';

//             if (isAssessment) {
//               final assessmentData = (subject['assessments'] as List? ?? []).firstWhere(
//                 (a) => a['assessment_name'] == title,
//                 orElse: () => {'score': ''},
//               );
//               value = assessmentData['score']?.toString() ?? '-';
//             } else if (isTotal) {
//               value = subject['total_score']?.toString() ?? '-';
//             } else if (isGrade) {
//               value = subject['grade']?.toString() ?? '-';
//             } else if (isRemark) {
//               value = subject['remark']?.toString() ?? '-';
//             }

//             return Container(
//               height: 50,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(
//                   top: BorderSide(color: Colors.grey[300]!),
//                   right: BorderSide(color: Colors.grey[300]!),
//                 ),
//               ),
//               child: Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black,
//                   fontWeight: isGrade ? FontWeight.w600 : FontWeight.normal,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }