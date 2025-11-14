import 'package:flutter/material.dart';

import '../../common/app_colors.dart';

class PortalNewsItem extends StatefulWidget {
  final String? CreatorId;
  final int? authorId;
  final String? role;
  final String profileImageUrl;
  final String name;
  final String newsContent;
  final String title;
  final String time;
  final int likes;
  final int comments;
  final int shares;
  final VoidCallback? edit;
  final VoidCallback? delete;

  const PortalNewsItem(
      {super.key,
      required this.profileImageUrl,
      required this.name,
      required this.newsContent,
      required this.time,
      required this.CreatorId,
      required this.authorId,
      required this.role,
      this.title = '',
      this.likes = 0,
      this.comments = 0,
      this.shares = 0,
      this.edit,
      this.delete});

  @override
  State<PortalNewsItem> createState() => _PortalNewsItemState();
}

class _PortalNewsItemState extends State<PortalNewsItem> {
  bool get canEdit {
    // Admin can edit only their own posts
    if (widget.role == 'admin') {
      return widget.authorId.toString() == widget.CreatorId;
    }
    // Staff, teacher, or student can edit only their own posts
    return widget.authorId.toString() == widget.CreatorId;
  }

  // Check if user can delete this post
  bool get canDelete {
    // Admin can delete anybody's post
    if (widget.role == 'admin') {
      return true;
    }
    // Staff, teacher, or student can delete only their own posts
    return widget.authorId.toString() == widget.CreatorId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + School
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.profileImageUrl),
                radius: 20.0,
                backgroundColor: AppColors.newsProfilePic,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      widget.title.isNotEmpty ? widget.title : '',
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7.0),
          
          // Content
          Text(
            widget.newsContent,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: Color(0xFF374151),
              height: 1.5,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 12.0),
          
          // Timestamp
          Text(
            widget.time,
            style: const TextStyle(
              fontSize: 9.0,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 12.0),
          
          // Bottom Row: Likes, Comments, Actions
          Row(
            children: [
              // Likes
              Row(
                children: [
                  Text(
                    widget.likes.toString(),
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.favorite_border,
                    size: 18.0,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
              const SizedBox(width: 9.0),
              
              // Comments
              Row(
                children: [
                  Text(
                    widget.comments.toString(),
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18.0,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Action Buttons (Share & Bookmark placeholders + Edit/Delete)
              Row(
                children: [
                  // IconButton(
                  //   icon: const Icon(
                  //     Icons.share_outlined,
                  //     size: 20.0,
                  //     color: Color(0xFF9CA3AF),
                  //   ),
                  //   onPressed: () {},
                  //   padding: EdgeInsets.zero,
                  //   constraints: const BoxConstraints(),
                  // ),
                 
                  if (canEdit && widget.edit != null) ...[
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20.0,
                        color: Color(0xFF3B82F6),
                      ),
                      onPressed: widget.edit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                  if (canDelete && widget.delete != null) ...[
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20.0,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: widget.delete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
