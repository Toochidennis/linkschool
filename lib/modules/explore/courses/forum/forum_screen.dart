import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/courses/forum/forum_provider.dart';
import 'package:linkschool/modules/explore/courses/forum/topic_detail_screen.dart';
import 'package:provider/provider.dart';

class ForumScreen extends StatelessWidget {
  final String courseTitle;

  const ForumScreen({
    super.key,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForumProvider>();
    final topics = provider.topics;

    if (topics.isEmpty) {
      return const Center(
        child: Text(
          'No forum topics yet',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 15,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF9FAFB),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => ChangeNotifierProvider.value(
                  //       value: provider,
                  //       child: TopicDetailScreen(topicId: topic.id),
                  //     ),
                  //   ),
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row: avatar + info + like ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar with status dot
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: topic.avatarColor,
                                child: Text(
                                  topic.avatarLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: topic.statusColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          // Title + author
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.author,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                 SizedBox(height: 3),
                                Text(
                                  topic.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                    height: 1.3,
                                  ),
                                ),
                               
                                
                              ],
                            ),
                          ),

                          // Like button
                          GestureDetector(
                            onTap: () => provider.toggleTopicLike(topic.id),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                topic.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: const Color(0xFFEC4899),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Optional image ──
                      if (topic.imageUrl != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            topic.imageUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // ── Divider ──
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF3F4F6),
                      ),

                      const SizedBox(height: 10),

                      // ── Footer: replies + date ──
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${topic.replyCount} Replies',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const Spacer(),
                          Text(
                            topic.dateLabel,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}