import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/app_colors.dart';
import '../../common/text_styles.dart';

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


  const PortalNewsItem({
    super.key,
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
    this.delete
  });

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
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 16.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.newsBorderColor,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align children at the top
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.profileImageUrl),
                        radius: 16.0,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: AppTextStyles.normal2Light,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      
                      style: AppTextStyles.normal500(fontSize: 16.0, color: AppColors.text2Light),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    widget.newsContent,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.normal500(fontSize: 14.0, color: AppColors.text4Light),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    widget.time,
                    style: AppTextStyles.normal4Light,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(widget.likes.toString()),
                      IconButton(
                        icon: const Icon(Icons.favorite_outline),
                        onPressed: () {},
                      ),
                      Text(widget.comments.toString()),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/comment.svg',
                          height: 20.0,
                          width: 20.0,
                        ),
                        onPressed: () {},
                      ),
                      
                     if (canEdit && widget.edit != null)
                      IconButton(
                        icon: Icon(Icons.edit_note_outlined),
                        onPressed:widget.edit,
                      ),
                    
                      
                      if (canDelete && widget.delete != null)
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed:widget.delete,
                      ),
                    

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
