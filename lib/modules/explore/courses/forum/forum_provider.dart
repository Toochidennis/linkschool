import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/courses/forum/forum_models.dart';

class ForumProvider extends ChangeNotifier {
  ForumProvider({String? courseTitle})
      : _topics = _buildMockTopics(courseTitle ?? 'Course Forum');

  final List<ForumTopic> _topics;

  List<ForumTopic> get topics => List.unmodifiable(_topics);

  ForumTopic getTopicById(String topicId) {
    return _topics.firstWhere((topic) => topic.id == topicId);
  }

  ForumReply? getReplyById({
    required String topicId,
    required String replyId,
  }) {
    final topic = getTopicById(topicId);
    return _findReplyById(topic.replies, replyId);
  }

  void toggleTopicLike(String topicId) {
    final index = _topics.indexWhere((topic) => topic.id == topicId);
    if (index == -1) return;

    final topic = _topics[index];
    final nextLiked = !topic.isLiked;
    _topics[index] = topic.copyWith(
      isLiked: nextLiked,
      likeCount: nextLiked ? topic.likeCount + 1 : topic.likeCount - 1,
    );
    notifyListeners();
  }

  void toggleReplyLike({
    required String topicId,
    required String replyId,
    String? parentReplyId,
  }) {
    final index = _topics.indexWhere((topic) => topic.id == topicId);
    if (index == -1) return;

    final topic = _topics[index];
    final updatedReplies = _toggleReplyInTree(topic.replies, replyId);

    _topics[index] = topic.copyWith(replies: updatedReplies);
    notifyListeners();
  }

  void addReply({
    required String topicId,
    required String message,
    String? imagePath,
    String? parentReplyId,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty && (imagePath == null || imagePath.isEmpty)) return;

    final index = _topics.indexWhere((topic) => topic.id == topicId);
    if (index == -1) return;

    final topic = _topics[index];
    final reply = ForumReply(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: 'You',
      avatarLabel: 'Y',
      avatarColor: const Color(0xFFF472B6),
      message: trimmed,
      imagePath: imagePath,
      timestamp: 'Now',
      likeCount: 0,
    );

    final updatedReplies = parentReplyId == null
        ? [reply, ...topic.replies]
        : _insertReplyInTree(topic.replies, parentReplyId, reply);

    _topics[index] = topic.copyWith(replies: updatedReplies);
    notifyListeners();
  }

  ForumReply _toggleReply(ForumReply reply, String replyId) {
    if (reply.id != replyId) return reply;
    final nextLiked = !reply.isLiked;
    return reply.copyWith(
      isLiked: nextLiked,
      likeCount: nextLiked ? reply.likeCount + 1 : reply.likeCount - 1,
    );
  }

  List<ForumReply> _toggleReplyInTree(List<ForumReply> replies, String replyId) {
    return replies
        .map(
          (reply) => reply.id == replyId
              ? _toggleReply(reply, replyId)
              : reply.copyWith(
                  replies: _toggleReplyInTree(reply.replies, replyId),
                ),
        )
        .toList();
  }

  List<ForumReply> _insertReplyInTree(
    List<ForumReply> replies,
    String parentReplyId,
    ForumReply newReply,
  ) {
    return replies
        .map(
          (reply) => reply.id == parentReplyId
              ? reply.copyWith(replies: [...reply.replies, newReply])
              : reply.copyWith(
                  replies: _insertReplyInTree(
                    reply.replies,
                    parentReplyId,
                    newReply,
                  ),
                ),
        )
        .toList();
  }

  ForumReply? _findReplyById(List<ForumReply> replies, String replyId) {
    for (final reply in replies) {
      if (reply.id == replyId) {
        return reply;
      }
      final nestedMatch = _findReplyById(reply.replies, replyId);
      if (nestedMatch != null) {
        return nestedMatch;
      }
    }
    return null;
  }

  static List<ForumTopic> _buildMockTopics(String courseTitle) {
    return [
      ForumTopic(
        id: 'topic-1',
        title: 'Best way to structure weekly revision notes?',
        author: 'Maya Johnson',
        avatarLabel: 'M',
        avatarColor: const Color(0xFFFBBF24),
        statusColor: const Color(0xFF22C55E),
        content:
            'I have been turning each lesson into a one-page summary. Curious how everyone else is organizing notes for quick revision before quizzes.',
        dateLabel: 'Mar 10',
        timestamp: '10:24 AM · Mar 10, 2026',
        likeCount: 18,
        imageUrl: 'https://picsum.photos/seed/forum-notes/900/520',
        replies: const [
          ForumReply(
            id: 'reply-1',
            author: 'Daniel Reed',
            avatarLabel: 'D',
            avatarColor: Color(0xFF93C5FD),
            message:
                'I split mine into definitions, worked examples, and a final recap. It makes review faster.',
            timestamp: '11:02 AM',
            likeCount: 6,
            replies: [
              ForumReply(
                id: 'reply-1-1',
                author: 'Amara Okafor',
                avatarLabel: 'A',
                avatarColor: Color(0xFFA7F3D0),
                message:
                    'Same here. I also add one “common mistake” line under each example.',
                timestamp: '11:18 AM',
                likeCount: 3,
              ),
            ],
          ),
          ForumReply(
            id: 'reply-2',
            author: 'Sofia Carter',
            avatarLabel: 'S',
            avatarColor: Color(0xFFF9A8D4),
            message:
                'Flash cards for key formulas, then a single sheet for deeper explanations.',
            timestamp: '12:06 PM',
            likeCount: 2,
          ),
        ],
      ),
      ForumTopic(
        id: 'topic-2',
        title: 'Can we share project milestone checklists here?',
        author: 'Jordan Lee',
        avatarLabel: 'J',
        avatarColor: const Color(0xFF86EFAC),
        statusColor: const Color(0xFFF59E0B),
        content:
            'Posting this thread so we can compare milestone checklists for the final course project and spot anything we are missing.',
        dateLabel: 'Mar 11',
        timestamp: '3:48 PM · Mar 11, 2026',
        likeCount: 27,
        replies: const [
          ForumReply(
            id: 'reply-3',
            author: 'Priya Shah',
            avatarLabel: 'P',
            avatarColor: Color(0xFFC4B5FD),
            message:
                'Yes. I grouped mine by research, prototype, testing, and final demo prep.',
            timestamp: '4:13 PM',
            likeCount: 5,
          ),
          ForumReply(
            id: 'reply-4',
            author: 'Leo Grant',
            avatarLabel: 'L',
            avatarColor: Color(0xFFFCA5A5),
            message:
                'Would be useful if everyone added estimated time per milestone too.',
            timestamp: '4:41 PM',
            likeCount: 4,
          ),
        ],
      ),
      ForumTopic(
        id: 'topic-3',
        title: '$courseTitle: hardest concept so far?',
        author: 'Nina Brooks',
        avatarLabel: 'N',
        avatarColor: const Color(0xFFFDA4AF),
        statusColor: const Color(0xFF22C55E),
        content:
            'For me it is less about the formulas and more about understanding when to apply each method. Interested in what others found tricky.',
        dateLabel: 'Mar 12',
        timestamp: '8:05 AM · Mar 12, 2026',
        likeCount: 34,
        imageUrl: 'https://picsum.photos/seed/forum-concept/900/520',
        replies: const [
          ForumReply(
            id: 'reply-5',
            author: 'Ethan Cole',
            avatarLabel: 'E',
            avatarColor: Color(0xFF67E8F9),
            message:
                'Application questions. I know the theory, but mixed scenarios slow me down.',
            timestamp: '8:22 AM',
            likeCount: 8,
            replies: [
              ForumReply(
                id: 'reply-5-1',
                author: 'Grace Kim',
                avatarLabel: 'G',
                avatarColor: Color(0xFFFDE68A),
                message:
                    'Same. Practice sets with short explanations helped more than rereading.',
                timestamp: '8:35 AM',
                likeCount: 2,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
