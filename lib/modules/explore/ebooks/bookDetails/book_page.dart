import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';

import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/ebooks/bookScreen.dart'
    show BookScreen;
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';

class MybookPage extends StatefulWidget {
  final Ebook suggestedbook;
  const MybookPage({super.key, required this.suggestedbook});

  @override
  State<MybookPage> createState() => _MybookPageState();
}

class _MybookPageState extends State<MybookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            Container(
              height: 350,
              padding: EdgeInsets.only(top: 50),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bookCard1,
                    AppColors.bookCard2,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Image(
                    image: AssetImage(
                      // 'assets/images/book_1.png'
                      widget.suggestedbook.thumbnail,
                    ),
                    height: 200,
                  ),
                  SizedBox(height: 12),
                  Text(
                    // 'Purple Hibiscus',
                    widget.suggestedbook.title,
                    style: AppTextStyles.normal600(
                      fontSize: 24,
                      color: AppColors.bookText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    // 'by Chimamanda Adichie',
                    widget.suggestedbook.author,
                    style: AppTextStyles.normal400(
                      fontSize: 16,
                      color: AppColors.bookText,
                    ),
                  ),
                  SizedBox(height: 8),
                  RatingBar.builder(
                    itemCount: 5,
                    initialRating: 4.5,
                    allowHalfRating: true,
                    minRating: 1,
                    itemSize: 18,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (value) {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    // 'Benedict Timothy Carlton Cumberbatch CBE (born 19 July 1976) is an English actor. '
                    // 'A graduate of the Victoria University of Manchester, he continued his training at '
                    // 'the London Academy of Music and... he continued his training at the London Academy of Music and...',
                    widget.suggestedbook.chapters.entries.join(","),
                    style: AppTextStyles.normal400(
                      fontSize: 16,
                      color: AppColors.bookText,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      CustomButton(text: 'Literature'),
                      SizedBox(width: 10),
                      CustomButton(text: 'Based on a true story'),
                    ],
                  ),
                  SizedBox(height: 40),
                  CustomLongElevatedButton(
                    text: 'Start Reading',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return BookScreen(
                              suggestedBook: widget.suggestedbook,
                            );
                          },
                        ),
                      );
                    },
                    backgroundColor: AppColors.bgXplore3,
                    textStyle: AppTextStyles.normal500(
                        fontSize: 16, color: AppColors.assessmentColor1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;

  const CustomButton({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CustomOutlineButton(
      onPressed: () {},
      text: text,
      borderColor: AppColors.cbtBorderColor2,
      textColor: AppColors.bookText1,
    );
  }
}
