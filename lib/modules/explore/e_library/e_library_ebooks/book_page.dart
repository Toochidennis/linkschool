import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/explore/e_library/e_library_ebooks/bookScreen.dart';

import '../../../common/buttons/custom_long_elevated_button.dart';


class MybookPage extends StatefulWidget {
  const MybookPage({super.key});

  @override
  State<MybookPage> createState() => _MybookPageState();
}

class _MybookPageState extends State<MybookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Image.asset(
              'assets/icons/arrow_back.png',
              color: AppColors.primaryLight,
              width: 34.0,
              height: 34.0,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.bookmark_border,
                size: 29,
                color: AppColors.primaryLight,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 404,
              padding: EdgeInsets.only(top: 12),
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
                    image: AssetImage('assets/images/book_1.png'),
                    height: 280,
                    width: 198,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Purple Hibiscus',
                    style: AppTextStyles.normal600(
                      fontSize: 26,
                      color: AppColors.bookText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'by Chimamanda Adichie',
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Text(
                    'Benedict Timothy Carlton Cumberbatch CBE (born 19 July 1976) is an English actor. '
                    'A graduate of the Victoria University of Manchester, he continued his training at '
                    'the London Academy of Music and... he continued his training at the London Academy of Music and...',
                    style: AppTextStyles.normal400(
                      fontSize: 16,
                      color: AppColors.bookText,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.grayColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                           side: BorderSide(color: AppColors.eLearningBtnColor1),
                        ),
                        child: Text('Literature',style: AppTextStyles.normal500(fontSize: 16,color: AppColors.eLearningBtnColor1),),
                      ),
                       SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.grayColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                           side: BorderSide(color: AppColors.eLearningBtnColor1),
                        ),
                        child: Text('Based on a true story',style: AppTextStyles.normal500(fontSize: 16,color: AppColors.eLearningBtnColor1),),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  CustomLongElevatedButton(
                    text: 'Start Reading',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookScreen(),
                          ));
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

// class CustomButton extends StatelessWidget {
//   final String text;

//   const CustomButton({
//     super.key,
//     required this.text,
//   });

//  @override
// Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adjust padding
//     child: CustomOutlineButton(
//       onPressed: () {},
//       text: text,
//       borderColor: AppColors.cbtBorderColor2,
//       textColor: AppColors.bookText1,
//     ),
//   );
// }
// }
