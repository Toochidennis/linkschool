import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:share_plus/share_plus.dart';

class AllnewsScreen extends StatefulWidget {
  const AllnewsScreen({super.key});

  @override
  State<AllnewsScreen> createState() => _AllnewsScreenState();
}

class _AllnewsScreenState extends State<AllnewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final allNews = newsProvider.newsmodel.take(6).toList();
    return Scaffold(
      appBar: Constants.customAppBar(
          context: context, title: 'All News', centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
              itemCount: allNews.length,
              itemBuilder: (context, index) {
                final news = allNews[index];
                return allNwesSections(
                    news.title, news.content, news.date_posted, news.image_url);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget allNwesSections(
      String title, String content, String time, String imageUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.normal500(
                        fontSize: 16.0,
                        color: AppColors.text2Light,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(time,
                        style: AppTextStyles.normal500(
                          fontSize: 12.0,
                          color: AppColors.text4Light,
                        )),
                    const SizedBox(height: 8.0),
                    Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.normal500(
                        fontSize: 14.0,
                        color: AppColors.text4Light,
                      ),
                    ),
                    // const SizedBox(height: 4.0),
                    // Text(
                    //   time,
                    //   style: AppTextStyles.normal500(
                    //     fontSize: 12.0,
                    //     color: AppColors.text4Light,
                    //   ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share),
                          // SvgPicture.asset(
                          //   'assets/icons/share.svg',
                          //   height: 20.0,
                          //   width: 20.0,
                          // ),
                          onPressed: () =>
                              (Share.share("Digital Dreams Academy, News")),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              SizedBox(
                width: 100.0,
                height: 120.0,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
