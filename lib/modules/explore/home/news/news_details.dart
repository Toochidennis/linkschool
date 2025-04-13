import 'package:flutter/material.dart';
// import 'package:linkschool/modules/explore/home/news/allnews_screen.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/home/news/all_news_screen.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetails extends StatefulWidget {
  final NewsModel news;
  final dynamic time;

  const NewsDetails({
    super.key,
    required this.news,
    required this.time,
  });

  @override
  State<NewsDetails> createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
    });
  }

  _navigatorAllNews() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AllnewsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final recommendedNews = newsProvider.newsmodel.take(6).toList();

    final relatedNews =
        newsProvider.newsmodel.take(6).toList(); // Fetch 6 items
    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        title: 'News',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // News Title & Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.text2Light),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.news.title,
                    style: AppTextStyles.normal700(
                        fontSize: 24.0, color: AppColors.assessmentColor1),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          Text(widget.time,
                              style: AppTextStyles.normal700(
                                  fontSize: 12.0,
                                  color: AppColors.assessmentColor1)),
                          SizedBox(width: 4),
                          Text("|",
                              style: AppTextStyles.normal700(
                                  fontSize: 12.0,
                                  color: AppColors.assessmentColor1)),
                          SizedBox(width: 8),
                          Text(widget.news.title,
                              style: AppTextStyles.normal700(
                                  fontSize: 12.0,
                                  color: AppColors.assessmentColor1)),
                          SizedBox(width: 4)
                        ],
                      ),
                      TextButton(
                          onPressed: () => (Share.share(
                              'dream ict/${widget.news.title}')),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.white, // Button background color
                            // foregroundColor: Colors.blueAccent, // Text color
                            // padding: EdgeInsets.symmetric(
                            //     horizontal: 2, vertical: 2),
                            textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.aicircle),
                            elevation: 5, // Shadow depth
                            alignment: Alignment(0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                          ),
                          child: Icon(Icons.share))
                    ],
                  ),
                ],
              ),
            ),

            // News Image
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.news.image_url),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // News Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  textSection(widget.news.content),
                  // SizedBox(height: 25),
                  // _buildLikesButton(widget.news.user_like, widget.news.likes),
                  // SizedBox(height: 25),
                  // Divider(color: AppColors.admissionclosed),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Recommended Section
            Constants.headingWithSeeAll600(
              title: "Recommended",
              titleColor: AppColors.aboutTitle,
              titleSize: 16,
              onPressed: _navigatorAllNews,
            ),

            ListView.builder(
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
              itemCount: recommendedNews.length,
              itemBuilder: (context, index) {
                final news = recommendedNews[index];
                return recommendationSection(
                    news.title, news.content, widget.time, news.image_url);
              },
            ),

            SizedBox(height: 8),

            // Related Headlines Section
            Constants.headingWithSeeAll600(
                title: "Related headlines",
                titleColor: AppColors.aboutTitle,
                titleSize: 16),
            SizedBox(height: 4),

            SizedBox(
              height: 395,
              child: ListView.builder(
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: relatedNews.length,
                itemBuilder: (context, index) {
                  final newsheadlines = relatedNews[index];
                  return relatedHeadlines(
                      newsheadlines.title,
                      newsheadlines.content,
                      widget.time,
                      newsheadlines.image_url);
                  //   return recommendationSection(
                  //     news.title, news.content, news.date_posted, news.image_url);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== Helper Widgets ======================

Widget relatedHeadlines(
    String title, String content, String time, String imageUrl) {
  return Container(
    width: 220,
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.bgColor1,
      borderRadius: BorderRadius.circular(3),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: AppColors.assessmentColor1,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.asset(
              //   'assets/images/news-images/related_headline_image.png',
              //   width: 220,
              //   height: 92,
              // ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Image.network(
                  imageUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  // "Aston Villa avoid relegation on final day" +
                  title,
                  style: AppTextStyles.normal700(
                      fontSize: 16.0, color: AppColors.backgroundDark),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  // "Aston Villa avoid relegation on final day" +
                  content,
                  style: AppTextStyles.normal700(
                      fontSize: 14.0, color: AppColors.backgroundDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => (Share.share('dream ict')),
                      icon: Icon(Icons.share)
                      // SvgPicture.asset(
                      //   'assets/icons/share.svg',
                      //   height: 20.0,
                      //   width: 20.0,
                      // )
                      )
                ],
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Widget recommendationSection(
    String title, String content, String time, String imageUrl) {
  return Container(
    margin: EdgeInsets.only(bottom: 8),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.share),
                        //  SvgPicture.asset(
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

Widget _buildLikesButton() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // Icon(Icons.favorite, size: 20, color: AppColors.aitext),
      // SizedBox(width: 8),
      // Text(userLikes.toString(),
      //     style: AppTextStyles.normal400(
      //         fontSize: 14.0, color: AppColors.admissionTitle)),
      // SizedBox(width: 20),
      // Icon(Icons.chat_bubble_outline, size: 20),
      // SizedBox(width: 8),
      // Text(likes.toString(),
      //     style: AppTextStyles.normal400(
      //         fontSize: 12, color: AppColors.assessmentColor2)),
      IconButton(
        icon: Icon(Icons.share),
        // SvgPicture.asset(
        //   'assets/icons/share.svg',
        //   height: 20.0,
        //   width: 20.0,
        // ),
        onPressed: () => (Share.share("Digital Dreams Academy, News")),
      ),
    ],
  );
}

Widget textSection(paraBody) {
  return Text(
    paraBody,
    style: AppTextStyles.normal400(
        fontSize: 14.0, color: AppColors.backgroundDark),
  );
}
