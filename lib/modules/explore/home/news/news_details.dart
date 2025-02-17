import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';

import 'package:provider/provider.dart';

class NewsDetails extends StatefulWidget {
  final NewsModel news;
  const NewsDetails({super.key, required this.news});

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

  final String para_body =
      "Crowds watched solemnly as the body of Rep. John Lewis crossed the Edmund Pettus Bridge one final time, 55 years after the civil rights icon marched for peace and was met with brutality in Selma, Alabama.";

  final String para_body2 =
      "Body bearers from the U.S. armed forces placed the late Georgia congressman and civil rights icon onto a horse-drawn caisson Sunday at the Brown Chapel African Methodist Episcopal Church. From there, the public were allowed to line up to honor Lewis for about a half-mile to the foot of the bridge.";

  final String para_body3 =
      "Rep. Terri Sewell, D-Al., thanked Lewis’ family during a ceremony at the chapel for sharing the congressman with the public for so many years.";
  final String para_body4 =
      "Our nation is better off because of John Robert Lewis,” she remarked. “My life is better, Selma is better, this nation and this world is better because of John Robert Lewis.";

  final String paraTitle =
      "This is a mock data showing the details of recording";

  final List<Widget> headNews = [
    relatedHeadlines(),
    relatedHeadlines(),
    relatedHeadlines(),
    relatedHeadlines(),
    relatedHeadlines(),
    relatedHeadlines(),
    relatedHeadlines(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Constants.customAppBar(
            context: context, title: 'News', centerTitle: true),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              decoration: Constants.customBoxDecoration(context),
              child: Column(
                children: [
                  Container(
                    width: 360,
                    height: 159,
                    decoration: BoxDecoration(
                      color: AppColors.text2Light,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        children: [
                          // pageTesting(),

                          Text(
                            "This is a mock data showing the details of recording",
                            style: AppTextStyles.normal700(
                              fontSize: 24.0,
                              color: AppColors.assessmentColor1,
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text("30 mins ago",
                                  style: AppTextStyles.normal700(
                                      fontSize: 12.0,
                                      color: AppColors.assessmentColor1)),
                              SizedBox(
                                width: 8,
                              ),
                              Text("|",
                                  style: AppTextStyles.normal700(
                                      fontSize: 12.0,
                                      color: AppColors.assessmentColor1)),
                              SizedBox(
                                width: 8,
                              ),
                              Text("Vanguard News",
                                  style: AppTextStyles.normal700(
                                      fontSize: 12.0,
                                      color: AppColors.assessmentColor1)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 360,
                    height: 156,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/news-images/paper-test.png'),
                            fit: BoxFit.cover)),
                    // child: Image(image: AssetImage('assets/images/news-images/paper-test.png')),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          newBodyText(
                              para_body: widget.news.content,
                              para_body2: widget.news.content,
                              para_body3: widget.news.content),
                          newsActionButtons(),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            child: Column(
                              children: [
                                Text(
                                  "Lewis, she remarked. “My life is better, Selma is better, this nation and this world is better because of John Robert Lewis.”",
                                  style: AppTextStyles.normal400(
                                      fontSize: 14.0,
                                      color: AppColors.backgroundDark),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Divider(
                            color: AppColors.admissionclosed,
                          ),
                          Container(
                            child: Column(
                              children: [
                                Text(
                                  paraTitle,
                                  style: AppTextStyles.normal600(
                                      fontSize: 28.0,
                                      color: AppColors.backgroundDark),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: AppColors.admissionclosed,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: Column(
                              children: [
                                newBodyText(
                                    para_body: widget.news.content,
                                    para_body2: widget.news.content,
                                    para_body3: widget.news.content),
                                Text(
                                  widget.news.subject,
                                  style: AppTextStyles.normal400(
                                      fontSize: 14.0,
                                      color: AppColors.backgroundDark),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // recommendation
                  Constants.headingWithSeeAll600(
                      title: "Recommended",
                      titleColor: AppColors.aboutTitle,
                      titleSize: 16),
                  recommendationSection(),
                  SizedBox(
                    height: 8,
                  ),
                  recommendationSection(),
                  SizedBox(
                    height: 8,
                  ),
                  recommendationSection(),
                  // Recommendation
                  Constants.headingWithSeeAll600(
                      title: "Related headlines",
                      titleColor: AppColors.aboutTitle,
                      titleSize: 16),
                  SizedBox(
                    height: 8,
                  ),

                  Container(
                    height: 395,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: headNews.length,
                      itemBuilder: (context, index) {
                        return headNews[index];
                      },
                    ),
                  ),
                ],
              ),
            )));
  }
}

// class pageTesting extends StatelessWidget {
//   const pageTesting({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       children: [
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => SelectSchool()));
//           },
//           child: Icon(
//             Icons.select_all_outlined,
//             size: 24,
//             color: AppColors.assessmentColor1,
//           ),
//         ),

//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => LoginScreens()));
//           },
//           child: Icon(
//             Icons.login,
//             size: 24,
//             color: AppColors.assessmentColor1,
//           ),
//         ),
//       ],
//     );
//   }
// }

class relatedHeadlines extends StatelessWidget {
  final String relatednews_Body =
      " Aston Villa avoided relegation on the final day of the Premier League season as they drew 1-1 at West Ham United and other results went their way. ";

  const relatedHeadlines({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            width: 220,
            height: 299,
            decoration: BoxDecoration(
              color: AppColors.bgColor1,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage(
                        'assets/images/news-images/related_headline_image.png'),
                    width: 220,
                    height: 92,
                  ),
                  Card(
                      color: AppColors.assessmentColor1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 200,
                            child: Text(
                              "Aston Villa avoid relegation on final day",
                              style: AppTextStyles.normal700(
                                  fontSize: 16.0,
                                  color: AppColors.backgroundDark),
                            ),
                          ),
                          Text(
                            relatednews_Body,
                            style: AppTextStyles.normal400(
                                fontSize: 12.0,
                                color: AppColors.backgroundDark),
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.33, left: 1.33),
                                child: Icon(
                                  Icons.favorite_border,
                                  size: 20,
                                  weight: 20,
                                ),
                              ),
                              Image(
                                image: AssetImage(
                                    "assets/images/news-images/chart_bubble_icon.png"),
                                height: 20,
                                width: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.33, left: 1.33),
                                child: Image(
                                  image: AssetImage(
                                      "assets/images/news-images/shareiconvector.png"),
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      )),
                ],
              ),
            )));
  }
}

class recommendationSection extends StatelessWidget {
  const recommendationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor1,
          ),
          child: Column(
            children: [
              Divider(
                color: AppColors.assessmentColor3,
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            // border: Border.all(width: 1),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: AppColors.attBorderColor1),
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text("02"),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Vanguard News",
                                        style: AppTextStyles.normal500(
                                            fontSize: 16.0,
                                            color: AppColors.backgroundDark),
                                      )
                                    ],
                                  ),
                                  Text(
                                    "This is a mock data showing the info details of a recording.",
                                    style: AppTextStyles.normal500(
                                        fontSize: 14.0,
                                        color: AppColors.backgroundDark),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "30 mins ago",
                                    style: AppTextStyles.normal500(
                                        fontSize: 10.0,
                                        color: AppColors.admissionTitle),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2.33, left: 1.33),
                                        child: Icon(
                                          Icons.favorite_border,
                                          size: 11.67,
                                          weight: 13.33,
                                        ),
                                      ),
                                      Image(
                                        image: AssetImage(
                                            "assets/images/news-images/chart_bubble_icon.png"),
                                        height: 11.67,
                                        width: 13.33,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2.33, left: 1.33),
                                        child: Image(
                                          image: AssetImage(
                                              "assets/images/news-images/shareiconvector.png"),
                                          height: 11.67,
                                          width: 13.33,
                                        ),
                                        // child: Icon(
                                        //   Icons.share_sharp,
                                        //   size: 11.67,
                                        //   weight: 13.33,
                                        // ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Image(
                              image: AssetImage(
                                  "assets/images/news-images/paper-test.png"),
                              height: 71,
                              width: 108.33,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 8,
        )
      ],
    );
  }
}

class newsActionButtons extends StatelessWidget {
  const newsActionButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Icon(Icons.bookmark_border, size: 20),
          SizedBox(
            width: 150,
          ),
          Icon(
            Icons.favorite,
            size: 20,
            color: AppColors.admissionclosed,
          ),
          Text(
            "28",
            style: AppTextStyles.normal400(
                fontSize: 14.0, color: AppColors.admissionTitle),
          ),
          SizedBox(
            width: 25,
          ),
          Image(
            image:
                AssetImage("assets/images/news-images/chart_bubble_icon.png"),
            height: 11.67,
            width: 13.33,
          ),
          Text(
            "21",
            style: AppTextStyles.normal400L(
                fontSize: 12, color: AppColors.assessmentColor2),
          ),
          SizedBox(
            width: 20,
          ),
          Image(
            image: AssetImage("assets/images/news-images/shareiconvector.png"),
            height: 11.67,
            width: 13.33,
          ),
          Text(
            "21",
            style: AppTextStyles.normal400L(
                fontSize: 12, color: AppColors.assessmentColor2),
          )
        ],
      )
    ]);
  }
}

class newBodyText extends StatelessWidget {
  const newBodyText({
    super.key,
    required this.para_body,
    required this.para_body2,
    required this.para_body3,
  });

  final String para_body;
  final String para_body2;
  final String para_body3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(para_body,
            style: AppTextStyles.normal400(
                fontSize: 14.0, color: AppColors.backgroundDark)),
        SizedBox(height: 20.0),
        Text(para_body2,
            style: AppTextStyles.normal400(
                fontSize: 14.0, color: AppColors.backgroundDark)),
        SizedBox(height: 20.0),
        Text(para_body3,
            style: AppTextStyles.normal400(
                fontSize: 14.0, color: AppColors.backgroundDark)),
        SizedBox(
          height: 25,
        ),
      ],
    );
  }
}
