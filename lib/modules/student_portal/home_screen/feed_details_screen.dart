import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class FeedDetailsScreen extends StatefulWidget {
  final String profileImageUrl;
  final String name;
  final String content;
  final String time;
  final int interactions;

  const FeedDetailsScreen({
    Key? key,
        required this.profileImageUrl,
    required this.name,
    required this.content,
    required this.time,
    required this.interactions,
  }) : super(key: key);

  @override
  State<FeedDetailsScreen> createState() => _FeedDetailsScreenState();
}

class _FeedDetailsScreenState extends State<FeedDetailsScreen> {
  late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          widget.name,
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
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
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [

                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.profileImageUrl),
                    radius: 16.0,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: AppTextStyles.normal500(
                            fontSize: 16, color: AppColors.primaryLight),
                      ),
                      Text(
                        widget.time,
                        style: AppTextStyles.normal500(
                            fontSize: 12, color: AppColors.text5Light),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(widget.content),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_outline),
                        onPressed: () {},
                      ),
                        Text(
                          '${widget.interactions}',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/comment.svg',
                          height: 20.0,
                          width: 20.0,
                        ),
                        onPressed: () {},
                      ),
                        Text(
                          '${widget.interactions}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildCommentItem('John Doe', 'Great post!', '2 hours ago'),
                    _buildCommentItem('Jane Smith',
                        'I agree, this is really helpful.', '1 hour ago'),
                    _buildCommentItem('Bob Johnson', 'Thanks for sharing this!',
                        '30 minutes ago'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // Add comment logic
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(String name, String comment, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.normal500(
                      fontSize: 14, color: AppColors.primaryLight),
                ),
                const SizedBox(height: 4),
                Text(comment),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: AppTextStyles.normal500(
                          fontSize: 12, color: AppColors.text5Light),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/icons/student/heart_icon.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        Colors.grey[600]!,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Like',
                      style: AppTextStyles.normal500(
                          fontSize: 12, color: AppColors.text5Light),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reply',
                      style: AppTextStyles.normal500(
                          fontSize: 12, color: AppColors.text5Light),
                    ),
                  ],
                ),
                const Divider()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
