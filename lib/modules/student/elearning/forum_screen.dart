import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/model/student/dashboard_model.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/providers/student/streams_provider.dart';
import 'package:provider/provider.dart';

import '../../common/custom_toaster.dart';
import '../../model/student/comment_model.dart';
import '../../providers/student/comment_provider.dart';
import '../../services/api/service_locator.dart';


class ForumScreen extends StatefulWidget {
  final DashboardData dashboardData;
  final String courseTitle;
  final int syllabusid;

  const ForumScreen({super.key, required this.dashboardData,required this.courseTitle, required this.syllabusid});


  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  // At the top of your State class
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }
// When building a comment box for each stream
  Widget buildCommentBox(StreamsModel sm) {
    _controllers.putIfAbsent(sm.id, () => TextEditingController());
    _focusNodes.putIfAbsent(sm.id, () => FocusNode());

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controllers[sm.id],
            focusNode: _focusNodes[sm.id],
            decoration: const InputDecoration(
              hintText: 'Add a comment...',
              border: UnderlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          color: AppColors.paymentTxtColor1,
          onPressed: () {
            _addComment(sm, _controllers[sm.id]!.text);
          },
        ),
      ],
    );
  }
  final TextEditingController _commentController = TextEditingController();
  List<StudentComment> comments = [];

  bool _isAddingComment = true;
  bool _isEditing = false;
  StudentComment? _editingComment;
  Map<String, dynamic>? streams;
  bool isLoading = true;
  String? creatorName;
  int? creatorId;
  int? academicTerm;
  String? academicYear;
  void initState() {
    super.initState();
    _loadUserData();
    fetchStreams();
  }
  Future<void> fetchStreams() async {
    final provider = Provider.of<StreamsProvider>(context, listen: false);
    final data = await provider.fetchStreams(widget.syllabusid);

    setState(() {
      streams = data;
      isLoading = false;
    });
  }
  Future<void> _loadUserData() async {


    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
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

  String ellipsize(String? text, [int maxLength = 1]) {
    if (text == null) return '';
    return text.length <= maxLength ? text : '${text.substring(0, maxLength).trim()}...';
  }
  String _getIconPath(String? type) {
    switch (type) {
      case 'material':
        return 'assets/icons/student/note_icon.svg';
      case 'assignment':
        return 'assets/icons/student/assignment_icon.svg';
      case 'quiz':
        return 'assets/icons/student/quiz_icon.svg';
      default:
        return 'assets/icons/student/note_icon.svg'; // fallback
    }
  }


  String deduceSession(String datePosted) {
    DateTime date = DateTime.parse(datePosted);
    int year = date.year;

    // If before September, session started the previous year
    if (date.month < 9) {
      return "${year - 1}/${year} Session";
    } else {
      return "${year}/${year + 1} Session";
    }
  }
  String getTermString(int term) {
    return {
      1: "1st",
      2: "2nd",
      3: "3rd",
    }[term] ?? "Unknown";
  }

  getuserdata(){
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData = storedUserData is String
        ? json.decode(storedUserData)
        : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    return data;
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading || streams?['streams'] == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final streamsList = streams!['streams'] as List<StreamsModel>;
    String termString = getTermString(getuserdata()['settings']['term']);
    String sessionString = deduceSession(widget.dashboardData.recentActivities.last.datePosted);
    String coursetitle = widget.courseTitle;

    return Scaffold(
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Header with reduced height and left-aligned text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width, // Ensure full width
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          // This ensures the image fills the available space
                          child: SvgPicture.asset(
                            'assets/images/student/header_background.svg',
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Text Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            height: 100,
                            alignment: Alignment.centerLeft,
                            child:  Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${coursetitle}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${sessionString} Session',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${termString} Term',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Section 2: Input Card (still visually attached to the header)
              Transform.translate(
                offset: const Offset(0, -2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.booksButtonColor,
                            radius: 16,
                            child: Icon(Icons.person,
                                color: Colors.grey[600], size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Share with your class...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section 3: Post Card
              Column(
                children: streamsList.map((stream) {
                  return Column(
                    children: [
                      buildPostCard(
                        iconPath: _getIconPath(stream.type),
                        subtitle:   'No Subtitle',
                        sm: stream, // adjust to your StreamsModel fields
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildPostCard({
    required String iconPath,
    required String subtitle,
    required StreamsModel sm
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(

          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  SvgPicture.asset(iconPath, height: 32, width: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      ellipsize( sm.title, 30),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.grey),

              // Comment Rows
              //loop thru

              Column(
                children: sm.comments.map<Widget>((comment) {
                  return Column(
                    children: [
                      buildComment(
                       // comment: comment,
                        avatarColor: AppColors.booksButtonColor,
                        name: comment.authorName ?? 'Unknown',
                        date: comment.uploadDate ?? '',
                        message: comment.comment ?? '',
                      ),

                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

                  buildCommentBox(sm)

              // Add Comment Field

            ],
          ),
        ),
      ),
    );
  }

  Widget buildComment({
    required Color avatarColor,
    required String name,
    required String date,
    required String message,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: avatarColor,
          radius: 16,
          child:  Icon(Icons.person, size: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Like',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Reply',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
    _addComment(StreamsModel sm,String text, [Map<String, dynamic>? updatedComment]) async {
    if (text.isNotEmpty) {
      final comment = updatedComment ?? {
        "content_title": sm.title,
        "user_id": creatorId ,
        "user_name": creatorName,
        "comment": text,
        "level_id": 71,
        "course_id": 25,
        "course_name": "widget.courseName",
        "term": academicTerm??0,
        if (_isEditing == true && _editingComment != null)
          "content_id": sm.id.toString() , // Use the ID of the comment being edited
      };

      try {
//
        final commentProvider = Provider.of<CommentProvider>(context, listen: false);
        final contentId = _editingComment?.id;
        if (_isEditing) {
          comment['content_id'];
          await commentProvider.UpdateComment(comment,contentId.toString());
        } else {

          await commentProvider.createComment(comment, sm.id.toString());
        }

        setState(() {
          fetchStreams();

          _isAddingComment = false;
          _isEditing = false;
          _editingComment = null;
          _controllers[sm.id]?.clear();
          if (!_isEditing) {
            comments.add(StudentComment(
              author: creatorName ?? 'Unknown',
              date: DateTime.now(),
              text: text,
              contentTitle: sm.title,
              userId: creatorId,
              levelId: "71",
              courseId: "25",
              courseName: "Computer science",
              term: academicTerm ??0,
            ));
          }
        });
      } catch (e) {
        CustomToaster.toastError(context, 'Error', _isEditing ? 'Failed to update comment' : 'Failed to add comment');
      }
    }
  }

}