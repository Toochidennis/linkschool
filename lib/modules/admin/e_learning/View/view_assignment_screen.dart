import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/comment_model.dart';

import '../../../common/widgets/portal/attachmentItem.dart';


class ViewAssignmentScreen extends StatefulWidget {
  final Assignment assignment;

  const ViewAssignmentScreen({super.key, required this.assignment});

  @override
  _ViewAssignmentScreenState createState() => _ViewAssignmentScreenState();
}

class _ViewAssignmentScreenState extends State<ViewAssignmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  bool _isAddingComment = false;
  late double opacity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Assignment',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryLight),
            onSelected: (String result) {
              // Handle menu item selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
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
              )
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Instructions',
                style: AppTextStyles.normal600(
                    fontSize: 18, color: AppColors.primaryLight),
              ),
            ),
            Tab(
              child: Text(
                'Student work',
                style: AppTextStyles.normal600(
                    fontSize: 18, color: AppColors.primaryLight),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInstructionsTab(),
            const Center(child: Text('Student work content')),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDueDate(),
          _buildDivider(),
          _buildTitle(),
          _buildGrade(),
          _buildDivider(),
          _buildDescription(),
          _buildDivider(),
          _buildAttachments(),
          _buildDivider(),
          _buildCommentSection(),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey.withOpacity(0.5)),
    );
  }

  Widget _buildDueDate() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, bottom: 16.0, right: 16.0, left: 16.0),
      child: Row(
        children: [
          Text(
            'Due: ',
            style: AppTextStyles.normal600(
                fontSize: 16.0, color: AppColors.eLearningTxtColor1),
          ),
          Text(
            DateFormat('E, dd MMM yyyy (hh:mm a)')
                .format(widget.assignment.dueDate),
            style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primaryLight, width: 2.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Mid-Term Assignment',
          style: AppTextStyles.normal600(
            fontSize: 20.0,
            color: AppColors.primaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildGrade() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Grade : ',
            style: AppTextStyles.normal600(
                fontSize: 16.0, color: AppColors.eLearningTxtColor1),
          ),
          Text(
            widget.assignment.marks,
            style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Description : ',
            style: AppTextStyles.normal600(
                fontSize: 16.0, color: AppColors.eLearningTxtColor1),
          ),
          Text(
            widget.assignment.description,
            style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.assignment.attachments.length,
        itemBuilder: (context, index) {
          return _buildAttachmentItem(widget.assignment.attachments[index]);
        },
      ),
    );
  }

  Widget _buildAttachmentItem(AttachmentItem attachment) {
    if (attachment.fileName!.startsWith('http')) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(attachment.fileName!),
        ),
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryLight),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(attachment.fileContent!),
        ),
      );
    }
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Class comments',
              style:
                  AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
            ),
          ),
          ...comments.map(_buildCommentItem),
          _buildDivider(),
        ],
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isAddingComment
              ? _buildCommentInput()
              : InkWell(
                  onTap: () {
                    setState(() {
                      _isAddingComment = true;
                    });
                  },
                  child: Text(
                    'Add class comment',
                    style: AppTextStyles.normal500(
                        fontSize: 16.0, color: AppColors.primaryLight),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        child: Text(
          comment.author[0].toUpperCase(),
          style: AppTextStyles.normal500(
              fontSize: 18, color: AppColors.backgroundLight),
        ),
      ),
      title: Row(
        children: [
          Text(comment.author,
              style: AppTextStyles.normal600(
                  fontSize: 16.0, color: AppColors.backgroundDark)),
          const SizedBox(width: 8),
          Text(
            DateFormat('d MMMM').format(comment.date),
            style: AppTextStyles.normal400(fontSize: 14.0, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Text(
        comment.text,
        style:
            AppTextStyles.normal500(fontSize: 16, color: AppColors.text4Light),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Type your comment...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _addComment,
          color: AppColors.primaryLight,
        ),
      ],
    );
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add(Comment(
          author: 'Joe Onwe',
          text: _commentController.text,
          date: DateTime.now(),
        ));
        _commentController.clear();
        _isAddingComment = false;
      });
    }
  }
}


