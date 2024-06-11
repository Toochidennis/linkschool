import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/app_colors.dart';
import '../../../common/text_styles.dart';

class PortalNewsItem extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String newsContent;
  final String time;

  const PortalNewsItem({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.newsContent,
    required this.time,
  });

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
                        backgroundImage: NetworkImage(profileImageUrl),
                        radius: 16.0,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.normal2Light,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    newsContent,
                    style: AppTextStyles.normal3Light,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    time,
                    style: AppTextStyles.normal4Light,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('14'),
                      IconButton(
                        icon: const Icon(Icons.favorite_outline),
                        onPressed: () {},
                      ),
                      Text('64'),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/comment.svg',
                          height: 20.0,
                          width: 20.0,
                        ),
                        onPressed: () {},
                      ),
                      Text('22'),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/share.svg',
                          height: 22.0,
                          width: 22.0,
                        ),
                        onPressed: () {},
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
