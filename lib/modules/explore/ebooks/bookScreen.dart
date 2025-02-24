import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
      ),
      body:  Container(
        decoration: Constants.customBoxDecoration(context),
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: BookProfileCard(),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Chapter 20',
                            style: AppTextStyles.normal600(
                                fontSize: 20, color: AppColors.bookText),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.bookText,
                                    height: 2.5),
                                children: [
                                  TextSpan(
                                    text:
                                        'Benedict Timothy Carlton Cumberbatch CBE (born 19 July 1976) is an English actor. '
                                        'A graduate of the Victoria University of Manchester, he continued his training at the '
                                        'London Academy of Music and Dramatic Art, obtaining a Master of Arts in Classical Acting. '
                                        'He first performed at the Open Air Theatre, Regent\'s Park in Shakespearean productions and made his '
                                        'West End debut in Richard Eyre\'s revival of Hedda Gabler in 2005.\n\n'
                                        'Since then, he has starred in the Royal National Theatre productions After the Dance (2010) and '
                                        'Frankenstein (2011). In 2015, he played the title role in Hamlet at the Barbican Theatre.',
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
  const BookProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/book_1.png',
                height: 180,
                width: 116,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            LinearPercentIndicator(
              width: 116.0,
              lineHeight: 5.0,
              percent: 0.5,
              barRadius: Radius.circular(16),
              backgroundColor: Colors.grey.shade300,
              progressColor: Colors.blue,
            ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Purple Hibiscus',
                  style: AppTextStyles.normal600(
                      fontSize: 26, color: AppColors.bookText),
                ),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  text: 'by Chimamanda Adichie',
                  style: AppTextStyles.normal400(
                    fontSize: 16,
                    color: AppColors.booksButtonTextColor,
                  ),
                ),
              ),
              SizedBox(height: 10),
              BookButtons(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bookbutton,
                    fixedSize: Size(150, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: Text(
                  'Go to first page',
                  style: AppTextStyles.normal500(
                      fontSize: 16, color: AppColors.buttontext1),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class BookButtons extends StatelessWidget {
  const BookButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              fixedSize: Size(60, 60),
              backgroundColor: AppColors.bookButton,
              padding: EdgeInsets.all(16)),
          child: Image(image: AssetImage('assets/icons/download-icon.png')),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: AppColors.bookButton,
              fixedSize: Size(50, 60),
              padding: EdgeInsets.all(16)),
          child: Image(image: AssetImage('assets/icons/shareicon.png')),
        ),
      ],
    );
  }
}
