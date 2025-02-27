import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/E_library/elibrary-ebooks/fullpage.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';
// import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';
// import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:provider/provider.dart';

class BookScreen extends StatefulWidget {
  final Ebook suggestedBook;

  const BookScreen({super.key, required this.suggestedBook});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: BookProfileCard(suggestedBook: widget.suggestedBook),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: widget.suggestedBook.title,
                            style: AppTextStyles.normal600(
                                fontSize: 20, color: AppColors.bookText),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: AppTextStyles.normal400L(
                                    fontSize: 16,
                                    color: AppColors.bookText,
                                    height: 30 / 16),
                                children: [
                                  TextSpan(
                                    text: widget.suggestedBook.introduction,
                                    // 'Benedict Timothy Carlton Cumberbatch CBE (born 19 July 1976) is an English actor. '
                                    // 'A graduate of the Victoria University of Manchester, he continued his training at the '
                                    // 'London Academy of Music and Dramatic Art, obtaining a Master of Arts in Classical Acting. '
                                    // 'He first performed at the Open Air Theatre, Regent\'s Park in Shakespearean productions and made his '
                                    // 'West End debut in Richard Eyre\'s revival of Hedda Gabler in 2005.\n\n'
                                    // 'Since then, he has starred in the Royal National Theatre productions After the Dance (2010) and '
                                    // 'Frankenstein (2011). In 2015, he played the title role in Hamlet at the Barbican Theatre.',
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookProfileCard extends StatelessWidget {
  final Ebook suggestedBook;

  BookProfileCard({
    super.key,
    required this.suggestedBook,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Image.network(
                suggestedBook.thumbnail,
                // 'assets/images/book_1.png',
                height: 173,
                width: 114,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              LinearPercentIndicator(
                width: 130,
                lineHeight: 5.0,
                percent: 0.5,
                barRadius: Radius.circular(16),
                backgroundColor: Colors.grey.shade300,
                progressColor: Colors.blue,
              ),
            ],
          ),
          SizedBox(width: 19),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: suggestedBook.title,
                    // 'Purple Hibiscus',
                    style: AppTextStyles.normal600(
                        fontSize: 24, color: AppColors.bookText),
                  ),
                ),
                SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    text: 'by ' + suggestedBook.author,
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: AppColors.booksButtonTextColor,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child:
                            SvgPicture.asset('assets/icons/download_icon.svg'),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset('assets/icons/Shareicon.svg'),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FullPage(continueReading: suggestedBook)));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bookbutton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40))),
                    child: Text(
                      'Go to first page',
                      style: AppTextStyles.normal500(
                          fontSize: 16, color: AppColors.buttontext1),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class BookButtons extends StatelessWidget {
//   const BookButtons({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ElevatedButton(
//           onPressed: () {},
//           style: ElevatedButton.styleFrom(
//               shape: CircleBorder(),
//              fixedSize: Size(50, 50),
//               backgroundColor: AppColors.bookButton,
//               padding: EdgeInsets.all(16)),
//           child: Image(image: AssetImage('assets/icons/download-icon.png'),height: 26,width: 26,),
//         ),
//         SizedBox(width: 10),
//         ElevatedButton(
//           onPressed: () {},
//           style: ElevatedButton.styleFrom(

//               shape: CircleBorder(),
//               backgroundColor: AppColors.bookButton,
//               fixedSize: Size(50, 50),
//               padding: EdgeInsets.all(16)),
//           child: Image(image: AssetImage('assets/icons/shareicon.png'),height: 24,width: 24,),
//         ),
//       ],
//     );
//   }
// }
