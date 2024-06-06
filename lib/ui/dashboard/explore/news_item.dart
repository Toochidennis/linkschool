import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../common/app_colors.dart';

class NewsItem extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String newsContent;
  final String time;
  final String imageUrl;

  const NewsItem({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.newsContent,
    required this.time,
    required this.imageUrl
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.newsBorderColor)
        )
      ),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl),
                radius: 20.0,
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Image.network(
                imageUrl,
                width: 80.0,
                height: 80.0,
                fit: BoxFit.cover,
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Text(
            newsContent,
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: () {},
              ),
              SizedBox(width: 10.0),
              Text(time),
            ],
          ),
        ],
      ),
    );
  }
}
