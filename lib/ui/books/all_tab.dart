import 'package:flutter/material.dart';

import '../../common/text_styles.dart';
import '../books/history_item.dart';


class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    const historyItems = [
      HistoryItem(),
      HistoryItem(),
      HistoryItem(),
    ];

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 290.0,
            child: ListView.builder(
                itemCount: historyItems.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return historyItems[index];
            }),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggested for you',
                  style: AppTextStyles.title3Light,
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(),
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 290.0,
            child: ListView.builder(
                itemCount: historyItems.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return historyItems[index];
                }),
          ),
        ],
      ),
    );
  }
}
