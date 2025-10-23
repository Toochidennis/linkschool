import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/custom_input_field.dart';
import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart';
import 'package:linkschool/modules/providers/admin/home/dashboard_feed_provider.dart';
import 'package:provider/provider.dart';

class FeedDetailsScreen extends StatefulWidget {
  final String profileImageUrl;
  final String name;
  final String content;
  final String time;
  final int interactions;
  final List<Feed> replies; // ✅ New: dynamic replies list
  final int? parentId;

  const FeedDetailsScreen({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.content,
    required this.time,
    required this.interactions,
    this.replies = const [],
    this.parentId,
  });

  @override
  State<FeedDetailsScreen> createState() => _FeedDetailsScreenState();
}

class _FeedDetailsScreenState extends State<FeedDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String _commentMode = 'none'; // 'none' | 'reply' | 'edit'
  Feed? _activeTarget;
  int? creatorId;
  String? creatorName;
  int? academicTerm;
  String? userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserData();
      Provider.of<DashboardFeedProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');

      if (storedUserData != null) {
        final dataMap = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;

        final data = dataMap['response']?['data'] ?? dataMap['data'] ?? {};
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};

        setState(() {
          
          userRole = profile['role']?.toString() ?? '';  
          creatorId = profile['staff_id'] is int
              ? profile['staff_id']
              : int.tryParse(profile['staff_id'].toString());
              if (userRole == 'student') {
                creatorId = profile['id'] is int ? profile['id'] : int.tryParse(profile['id'].toString());
              }else if (userRole == 'Admin' || userRole == 'admin' || userRole == 'staff' || userRole == 'teacher') {
                creatorId = profile['staff_id'] is int
              ? profile['staff_id']
              : int.tryParse(profile['staff_id'].toString());
              }

          creatorName = profile['name']?.toString() ?? '';

          academicTerm = settings['term'] is int
              ? settings['term']
              : int.tryParse(settings['term'].toString());
        });

        debugPrint(
            '✅ User loaded: ID=$creatorId, Name=$creatorName, Term=$academicTerm Role=$userRole');
      } else {
        debugPrint('⚠️ No stored user data found.');
      }
    } catch (e, stack) {
      debugPrint(stack.toString());
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to load user data');
      }
    }
  }

bool _canEdit(Feed reply) {
  // Admin can edit their own posts
  if (userRole == 'admin') {
    return creatorId == reply.authorId;
  }
  // Others can edit only their own posts
  return creatorId == reply.authorId;
}

 bool _canDelete(Feed reply) {
  // Admin can delete any post
  if (userRole == 'admin') {
    return true;
  }
  // Others can delete only their own posts
  return creatorId == reply.authorId;
}

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.light ? 0.1 : 0.15;
    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Post by ${widget.name}',
          style: AppTextStyles.normal600(
            fontSize: 20,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        flexibleSpace: Opacity(
          opacity: opacity,
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildFeedHeader(),
                  const SizedBox(height: 12),
                  Text(widget.content,
                      style: AppTextStyles.normal500(
                          fontSize: 15, color: AppColors.text4Light)),
                  const SizedBox(height: 12),
                  Text(widget.time,
                      style: AppTextStyles.normal500(
                        fontSize: 13,
                        color: Colors.grey,
                      )),
                  const Divider(height: 24),
                  _buildInteractionRow(),
                  const Divider(height: 24),
                  if (widget.replies.isNotEmpty)
                    ...widget.replies.map((reply) => _buildModernReply(reply)),
                  if (widget.replies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: Text(
                          'No replies yet. Be the first to comment!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.profileImageUrl),
          radius: 20,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.primaryLight,
              ),
            ),
            Text(
              widget.time,
              style: AppTextStyles.normal500(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _interactionButton(Icons.favorite_border, widget.interactions),
        _dotDivider(),
        _interactionButton(Icons.chat_bubble_outline, widget.replies.length),
      ],
    );
  }

  Widget _interactionButton(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text('$count', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _dotDivider() => Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.circle,
        ),
      );

  // ✅ ISSUE #3 FIX: No nested replies display
  Widget _buildModernReply(Feed reply) {
      final canEdit = _canEdit(reply);
  final canDelete = _canDelete(reply);
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 18, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reply.authorName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight)),
                    Text(
                      reply.createdAt,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(reply.content),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text("Like",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showReplyInput(reply),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text("Reply",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(width: 12),
               if (canEdit) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showEditInput(reply),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text("Edit",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
              SizedBox(width: 12),
                if (canDelete) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _confirmDelete(reply),
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text("Delete",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
              const Spacer(),
              // ✅ ISSUE #3 FIX: Display reply count, click to open same page
              if (reply.replies.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedDetailsScreen(
                          profileImageUrl: 'https://via.placeholder.com/150',
                          name: reply.authorName,
                          content: reply.content,
                          time: reply.createdAt,
                          interactions: 0,
                          replies: reply.replies,
                          parentId: reply.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${reply.replies.length} ${reply.replies.length == 1 ? 'reply' : 'replies'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  

  void _showReplyInput(Feed replyTarget) {
    _commentController.clear();
    setState(() {
      _commentMode = 'reply';
      _activeTarget = replyTarget;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_commentFocusNode);
    });
  }

  void _showEditInput(Feed targetReply) {
    _commentController.text = targetReply.content;
    setState(() {
      _commentMode = 'edit';
      _activeTarget = targetReply;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_commentFocusNode);
    });
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_commentMode != 'none' && _activeTarget != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.textFieldLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _commentMode == 'reply'
                          ? 'Replying to ${_activeTarget?.authorName ?? ''}'
                          : 'Editing comment',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _commentMode = 'none';
                        _activeTarget = null;
                        _commentController.clear();
                      });
                      FocusScope.of(context).unfocus();
                    },
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          CustomCommentInput(
            controller: _commentController,
            focusNode: _commentFocusNode,
            hintText: _commentMode == 'edit'
                ? 'Update your comment...'
                : (_commentMode == 'reply'
                    ? 'Write your reply...'
                    : 'Write your comment...'),
            onSendPressed: () async {
              final text = _commentController.text.trim();
              if (text.isEmpty) return;

              try {
                final feedProvider =
                    Provider.of<DashboardFeedProvider>(context, listen: false);

                print('🟢 Preparing to send comment...');
                print('Mode: $_commentMode');
                print('ActiveTarget ID: ${_activeTarget?.id}');

                print('🟢 Comment Mode: $_commentMode');
                print('🟢 Active Target ID: ${_activeTarget?.id}');
                print('🟢 Active Target Parent ID: ${_activeTarget?.parentId}');
                print('🟢 Widget Parent ID: ${widget.parentId}');

                // ✅ ISSUE #1 FIX: Determine correct parent_id based on context
                int? parentId;
                if (_commentMode == 'reply' && _activeTarget != null) {
                  // Replying to a comment/reply - use the comment being replied to as parent
                  parentId = _activeTarget!.id;
                  print('📌 Reply mode: parent_id will be $_activeTarget.id');
                } else if (_commentMode == 'edit' && _activeTarget != null) {
                  // Editing: send the ORIGINAL parent_id of this comment
                  parentId = _activeTarget!.parentId;
                  print('📌 Edit mode: parent_id is ${_activeTarget!.parentId}');
                } else {
                  // Top-level comment on main post
                  parentId = widget.parentId;
                  print('📌 Top-level mode: parent_id is ${widget.parentId}');
                }

                final Map<String, dynamic> payload = {
                  'title': text,
                  'type':  'reply',
                  'parent_id': parentId,
                  'content': text,
                  'author_name': creatorName ?? 'You',
                  'author_id': creatorId ?? 0,
                  'term': academicTerm ?? '',
                  'files': <Map<String, dynamic>>[],
                };

                print('📤 Sending payload: $payload');

                // ✅ ISSUE #2 FIX: Properly call updateFeed for edits
                if (_commentMode == 'edit' && _activeTarget != null) {
                  // ✅ CRITICAL: Pass the comment ID being edited (e.g., 1031), NOT parent ID
                  print('📝 Calling updateFeed');
                  print('   - Comment ID: ${_activeTarget!.id}');
                  print('   - Comment Parent ID: ${_activeTarget!.parentId}');
                  print('   - Payload parent_id: $parentId');
                  await feedProvider.updateFeed(
                      payload, _activeTarget!.id.toString());
                } else {
                  print('✍️ Calling createFeed');
                  await feedProvider.createFeed(payload);
                }

                print('✅ API call completed');

                setState(() {
                  if (_commentMode == 'reply' && _activeTarget != null) {
                    // Add reply to active target's replies
                    _activeTarget!.replies.add(
                      Feed(
                        id: DateTime.now().millisecondsSinceEpoch,
                        authorName: creatorName ?? 'You',
                        authorId: creatorId ?? 0,
                        parentId: _activeTarget!.id,
                        title: '',
                        type: 'reply',
                        content: text,
                        createdAt: 'Now',
                        replies: [],
                      ),
                    );
                  } else if (_commentMode == 'edit' && _activeTarget != null) {
                   
                    _activeTarget!.content = text;
                    print('✅ Updated comment ID: ${_activeTarget!.id} with new content: $text');
                  } else {
                    // Add top-level comment
                    widget.replies.add(
                      Feed(
                        id: DateTime.now().millisecondsSinceEpoch,
                        authorName: creatorName ?? 'You',
                        authorId: creatorId ?? 0,
                        parentId: widget.parentId ?? 0,
                        title: '',
                        type: 'comment',
                        content: text,
                        createdAt: 'Now',
                        replies: [],
                      ),
                    );
                  }
                });

                _commentController.clear();
                setState(() {
                  _commentMode = 'none';
                  _activeTarget = null;
                });
                FocusScope.of(context).unfocus();
              } catch (e) {
                print('❌ Error sending comment: $e');
          
                if (mounted) {
                  CustomToaster.toastError(
                      context, 'Error', 'Failed to send comment');
                }
              }
            },
            borderColor: Colors.grey[300],

            focusedBorderColor: AppColors.primaryLight,
            hintTextColor: Colors.grey[400],
            sendIconColor: AppColors.primaryLight,
            fontSize: 14,
            iconSize: 22,
          ),
        ],
      ),
    );
  }



Future<void> _confirmDelete(Feed reply) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Comment'),
      content: const Text('Are you sure you want to delete this comment?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    final feedProvider = Provider.of<DashboardFeedProvider>(context, listen: false);
    await feedProvider.deleteFeed(reply.id.toString()); // ✅ API call

    // If success, remove locally
    setState(() {
      widget.replies.removeWhere((r) => r.id == reply.id);
    });

    if (mounted) {
      CustomToaster.toastSuccess(context, 'Deleted', 'Comment deleted successfully');
    }
  } catch (e) {
    if (mounted) {
      CustomToaster.toastError(context, 'Error', 'Failed to delete comment');
    }
  }
}
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/student/custom_input_field.dart';
// import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart';
// import 'package:linkschool/modules/providers/admin/home/dashboard_feed_provider.dart';
// import 'package:provider/provider.dart';

// class FeedDetailsScreen extends StatefulWidget {
//   final String profileImageUrl;
//   final String name;
//   final String content;
//   final String time;
//   final int interactions;
//   final List<Feed> replies; // ✅ New: dynamic replies list
//   final int? parentId;

//   const FeedDetailsScreen({
//     super.key,
//     required this.profileImageUrl,
//     required this.name,
//     required this.content,
//     required this.time,
//     required this.interactions,
//     this.replies = const [],
//    this.parentId,
//   });

//   @override
//   State<FeedDetailsScreen> createState() => _FeedDetailsScreenState();
// }

// class _FeedDetailsScreenState extends State<FeedDetailsScreen> {
//   final TextEditingController _commentController = TextEditingController();
//   final FocusNode _commentFocusNode = FocusNode();
//   String _commentMode = 'none'; // 'none' | 'reply' | 'edit'
//   Feed? _activeTarget;
//   int? creatorId;
//   String? creatorName;
//   int? academicTerm;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       // Fetch initial data or perform setup tasks here if needed
//       await _loadUserData();
//       Provider.of<DashboardFeedProvider>(context, listen: false);
//     });
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     _commentFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final userBox = Hive.box('userData');
//       final storedUserData =
//           userBox.get('userData') ?? userBox.get('loginResponse');

//       if (storedUserData != null) {
//         // Decode if it's a JSON string
//         final dataMap = storedUserData is String
//             ? json.decode(storedUserData)
//             : storedUserData as Map<String, dynamic>;

//         // Handle both "response.data" and "data" roots
//         final data = dataMap['response']?['data'] ?? dataMap['data'] ?? {};

//         // Extract key sections
//         final profile = data['profile'] ?? {};
//         final settings = data['settings'] ?? {};

//         setState(() {
//           creatorId = profile['staff_id'] is int
//               ? profile['staff_id']
//               : int.tryParse(profile['staff_id'].toString());

//           creatorName = profile['name']?.toString() ?? '';

//           academicTerm = settings['term'] is int
//               ? settings['term']
//               : int.tryParse(settings['term'].toString());
//         });

//         debugPrint(
//             '✅ User loaded: ID=$creatorId, Name=$creatorName, Term=$academicTerm');
//       } else {
//         debugPrint('⚠️ No stored user data found.');
//       }
//     } catch (e, stack) {
//       debugPrint(stack.toString());
//       if (mounted) {
//         CustomToaster.toastError(context, 'Error', 'Failed to load user data');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     final opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundLight,
//         leading: IconButton(
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.eLearningBtnColor1,
//             width: 34,
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Post by ${widget.name}',
//           style: AppTextStyles.normal600(
//             fontSize: 20,
//             color: AppColors.eLearningBtnColor1,
//           ),
//         ),
//         flexibleSpace: Opacity(
//           opacity: opacity,
//           child: Image.asset(
//             'assets/images/background.png',
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(16.0),
//                 children: [
//                   _buildFeedHeader(),
//                   const SizedBox(height: 12),
//                   Text(widget.content,
//                       style: AppTextStyles.normal500(
//                           fontSize: 15, color: AppColors.text4Light)),
//                   const SizedBox(height: 12),
//                   Text(widget.time,
//                       style: AppTextStyles.normal500(
//                         fontSize: 13,
//                         color: Colors.grey,
//                       )),
//                   const Divider(height: 24),
//                   _buildInteractionRow(),
//                   const Divider(height: 24),
//                   if (widget.replies.isNotEmpty)
//                     ...widget.replies
//                         .map((reply) => _buildModernReply(reply, depth: 0)),
//                   if (widget.replies.isEmpty)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 16.0),
//                       child: Center(
//                         child: Text(
//                           'No replies yet. Be the first to comment!',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             _buildCommentInput(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFeedHeader() {
//     return Row(
//       children: [
//         CircleAvatar(
//           backgroundImage: NetworkImage(widget.profileImageUrl),
//           radius: 20,
//         ),
//         const SizedBox(width: 10),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.name,
//               style: AppTextStyles.normal600(
//                 fontSize: 16,
//                 color: AppColors.primaryLight,
//               ),
//             ),
//             Text(
//               widget.time,
//               style: AppTextStyles.normal500(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildInteractionRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _interactionButton(Icons.favorite_border, widget.interactions),
//         _dotDivider(),
//         _interactionButton(Icons.chat_bubble_outline, widget.replies.length),
//       ],
//     );
//   }

//   Widget _interactionButton(IconData icon, int count) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: Colors.grey[700]),
//         const SizedBox(width: 4),
//         Text('$count', style: TextStyle(color: Colors.grey[600])),
//       ],
//     );
//   }

//   Widget _dotDivider() => Container(
//         width: 4,
//         height: 4,
//         decoration: BoxDecoration(
//           color: Colors.grey[400],
//           shape: BoxShape.circle,
//         ),
//       );

//   Widget _buildModernReply(Feed reply, {int depth = 0}) {
//     return Container(
//       margin: EdgeInsets.only(left: depth * 20.0, top: 8, bottom: 8),
//       decoration: BoxDecoration(
//         border: Border(
//           left: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
//         ),
//       ),
//       padding: const EdgeInsets.only(left: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 14,
//                 backgroundColor: Colors.grey[300],
//                 child: const Icon(Icons.person, size: 18, color: Colors.grey),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(reply.authorName,
//                         style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.primaryLight)),
//                     Text(
//                       reply.createdAt,
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(reply.content),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               Icon(Icons.favorite_border, size: 14, color: Colors.grey[600]),
//               const SizedBox(width: 4),
//               Text("Like",
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//               const SizedBox(width: 12),
//               GestureDetector(
//                 onTap: () => _showReplyInput(reply),
//                 child: Row(
//                   children: [
//                     Icon(Icons.reply, size: 14, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Text("Reply",
//                         style:
//                             TextStyle(fontSize: 12, color: Colors.grey[600])),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               GestureDetector(
//                 onTap: () => _showEditInput(reply),
//                 child: Row(
//                   children: [
//                     Icon(Icons.edit, size: 14, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Text("Edit",
//                         style:
//                             TextStyle(fontSize: 12, color: Colors.grey[600])),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           // ✅ RECURSIVE CALL
//           if (reply.replies.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 6.0),
//               child: Column(
//                 children: reply.replies
//                     .map((subReply) =>
//                         _buildModernReply(subReply, depth: depth + 1))
//                     .toList(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showReplyInput(Feed replyTarget) {
//     // Reuse bottom input: set mode and active target, focus input
//     _commentController.clear();
//     setState(() {
//       _commentMode = 'reply';
//       _activeTarget = replyTarget;
//     });
//     // Focus after frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_commentFocusNode);
//     });
//   }

//   void _showEditInput(Feed targetReply) {
//     // Reuse bottom input: set controller text, set mode and active target, focus input
//     _commentController.text = targetReply.content;
//     setState(() {
//       _commentMode = 'edit';
//       _activeTarget = targetReply;
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_commentFocusNode);
//     });
//   }

// Widget _buildCommentInput() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (_commentMode != 'none' && _activeTarget != null)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             margin: const EdgeInsets.only(bottom: 8),
//             decoration: BoxDecoration(
//               color: AppColors.textFieldLight,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     _commentMode == 'reply'
//                         ? 'Replying to ${_activeTarget?.authorName ?? ''}'
//                         : 'Editing comment',
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _commentMode = 'none';
//                       _activeTarget = null;
//                       _commentController.clear();
//                     });
//                     FocusScope.of(context).unfocus();
//                   },
//                   child: const Icon(Icons.close, size: 18),
//                 ),
//               ],
//             ),
//           ),
//         CustomCommentInput(
//           controller: _commentController,
//           focusNode: _commentFocusNode,
//           hintText: _commentMode == 'edit'
//               ? 'Update your comment...'
//               : (_commentMode == 'reply'
//                   ? 'Write your reply...'
//                   : 'Write your comment...'),
//           onSendPressed: () async {
//             final text = _commentController.text.trim();
//             if (text.isEmpty) return;

//             try {
//               final feedProvider =
//                   Provider.of<DashboardFeedProvider>(context, listen: false);

//               print('🟢 Preparing to send comment...');
//               print('Mode: $_commentMode, ActiveTarget: ${_activeTarget?.id}');

//               // Build payload dynamically
//               final Map<String, dynamic> payload = {
//                 'title': text,
//                 'type': "reply",
//                 'parent_id': _commentMode == "reply" ? _activeTarget?.id : widget.parentId, // 0 for main comment
//                 'content': "RJTJ",
//                 'author_name': creatorName ?? 'You',
//                 'author_id': creatorId ?? 0,
//                 'term': academicTerm ?? '',
//                 'files': <Map<String, dynamic>>[],
//               };

//               print('📤 Sending payload: $payload');
//               print('📤 Activity ID: ${_activeTarget?.id} || parent iDD: ${widget.parentId}');
//               if(_commentMode == "reply"){
//                 await feedProvider.updateFeed(payload, _activeTarget!.id.toString());
//               }else{
//                 await feedProvider.createFeed(payload);
//               }

//               await feedProvider.createFeed(payload);
//               print('✅ API call completed');
//               setState(() {
//                 if (_commentMode == 'reply' && _activeTarget != null) {
//                   _activeTarget!.replies.add(
//                     Feed(
//                       id: DateTime.now().millisecondsSinceEpoch,
//                       authorName: creatorName ?? 'You',
//                       authorId: creatorId ?? 0,
//                       parentId: _activeTarget!.id,
//                       title: '',
//                       type: 'reply',
//                       content: text,
//                       createdAt: 'Now',
//                       replies: [],
//                     ),
//                   );
//                 } else {
//                   widget.replies.add(
//                     Feed(
//                       id: DateTime.now().millisecondsSinceEpoch,
//                       authorName: creatorName ?? 'You',
//                       authorId: creatorId ?? 0,
//                       parentId: 0,
//                       title: '',
//                       type: 'comment',
//                       content: text,
//                       createdAt: 'Now',
//                       replies: [],
//                     ),
//                   );
//                 }
//               });

//               // Reset
//               _commentController.clear();
//               setState(() {
//                 _commentMode = 'none';
//                 _activeTarget = null;
//               });
//               FocusScope.of(context).unfocus();
//             } catch (e, s) {
//               print('❌ Error sending comment: $e');
//               print(s);
//               if (mounted) {
//                 CustomToaster.toastError(
//                     context, 'Error', 'Failed to send comment');
//               }
//             }
//           },
//           borderColor: Colors.grey[300],
//           focusedBorderColor: AppColors.primaryLight,
//           hintTextColor: Colors.grey[400],
//           sendIconColor: AppColors.primaryLight,
//           fontSize: 14,
//           iconSize: 22,
//         ),
//       ],
//     ),
//   );
// }





// //   Widget _buildCommentInput() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           if (_commentMode != 'none' && _activeTarget != null)
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //               margin: const EdgeInsets.only(bottom: 8),
// //               decoration: BoxDecoration(
// //                 color: AppColors.textFieldLight,
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.grey[300]!),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Text(
// //                       _commentMode == 'reply'
// //                           ? 'Replying to ${_activeTarget?.authorName ?? ''}'
// //                           : 'Editing comment',
// //                       style: const TextStyle(fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   GestureDetector(
// //                     onTap: () {
// //                       setState(() {
// //                         _commentMode = 'none';
// //                         _activeTarget = null;
// //                         _commentController.clear();
// //                       });
// //                       FocusScope.of(context).unfocus();
// //                     },
// //                     child: const Icon(Icons.close, size: 18),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           CustomCommentInput(
// //             controller: _commentController,
// //             focusNode: _commentFocusNode,
// //             hintText: _commentMode == 'edit'
// //                 ? 'Update your comment...'
// //                 : (_commentMode == 'reply' ? 'Write your reply...' : 'Tweet your reply...'),
// //             onSendPressed: () async{
// //                print('🟢 Send pressed');
// //               final text = _commentController.text.trim();
// //              final feedProvider =  Provider.of<DashboardFeedProvider>(context, listen: false);
// //              print('🟢 Send pressed');
// //               if (text.isEmpty) return;


// //              if (_commentMode == 'reply' && _activeTarget != null) {

// //               try{
// //                     print('🟢 Send pressed');
// //   final newFeed = {
// //     'title': "",
// //     'type': "reply",
// //     'parent_id': _activeTarget!.id, // ✅ Use the active reply or post ID
// //     'content': text,                // ✅ The reply text
// //     'author_name': creatorName ?? 'You',
// //     'author_id': creatorId ?? 0,
// //     'term': academicTerm ?? '',
// //     'files': <Map<String, dynamic>>[],
// //   };
// //   print("++++++ adding paylaod");
// //   print(newFeed);

// //   await feedProvider.createFeed(newFeed); // Post to backend or Hive, etc.
// //               }catch(e){
// //                   print("omo i no dey work ooo");
// //               }
           

// //   setState(() {
// //     _activeTarget!.replies.add(
// //       Feed(
// //         id: DateTime.now().millisecondsSinceEpoch,
// //         authorName: creatorName ?? 'You',
// //         authorId: creatorId ?? 0,
// //         parentId: _activeTarget!.id,
// //         title: '',
// //         type: 'reply',
// //         content: text,
// //         createdAt: 'Now',
// //         replies: [],
// //       ),
// //     );
// //   });
// // }
// //  else if (_commentMode == 'edit' && _activeTarget != null) {
// //                 setState(() {
// //                   _activeTarget!.content = text;
// //                 });
// //               } else {
// //                 // new top-level comment
// //                 setState(() {
// //                   widget.replies.add(
// //                     Feed(
// //                       id: DateTime.now().millisecondsSinceEpoch,
// //                       authorName: 'You',
// //                       authorId: 0,
// //                       parentId: 0,
// //                       title: '',
// //                       type: 'comment',
// //                       content: text,
// //                       createdAt: 'Now',
// //                       replies: [],
// //                     ),
// //                   );
// //                 });
// //               }

// //               // reset
// //               _commentController.clear();
// //               setState(() {
// //                 _commentMode = 'none';
// //                 _activeTarget = null;
// //               });
// //               FocusScope.of(context).unfocus();
// //             },
// //             borderColor: Colors.grey[300],
// //             focusedBorderColor: AppColors.primaryLight,
// //             hintTextColor: Colors.grey[400],
// //             sendIconColor: AppColors.primaryLight,
// //             fontSize: 14,
// //             iconSize: 22,
// //           ),
// //         ],
// //       ),
// //     );
//  }