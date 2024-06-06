import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/common/text_styles.dart';

import '../../../common/app_colors.dart';

class NewsItem extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String newsContent;
  final String time;
  final String imageUrl;

  const NewsItem(
      {super.key,
      required this.profileImageUrl,
      required this.name,
      required this.newsContent,
      required this.time,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.newsBorderColor))),
      child: Row(
        children: [
          Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                    radius: 20.0,
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
              const SizedBox(height: 10.0),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_outline),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.favorite_outline),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.favorite_outline),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 10.0),
          Container(
            width: 108.33,
            height: 80.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, 0.4),
                  blurRadius: 1.05,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.network(
                imageUrl,
                width: 108.33,
                height: 80.0,
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    );
  }
}
