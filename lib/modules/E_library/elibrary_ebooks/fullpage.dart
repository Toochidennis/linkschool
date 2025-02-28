import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';

class FullPage extends StatefulWidget {
  final Ebook continueReading;
  const FullPage({Key? key, required this.continueReading}) : super(key: key);

  @override
  State<FullPage> createState() => _FullPageState();
}

class _FullPageState extends State<FullPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(context: context),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Chapter 1',
              //   style: AppTextStyles.normal700(
              //     fontSize: 26,
              //     color: AppColors.text3Light,
              //   ),
              // ),
              const SizedBox(height: 16),

              Column(
                children: widget.continueReading.chapters.entries.map((entry) {
                  return ListTile(
                    title: Text(
                      entry.key.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ), // Chapter title
                    subtitle: Text(
                      entry.value,
                      style: AppTextStyles.normal400L(
                        fontSize: 16,
                        height: 30 / 16,
                        color: AppColors.text3Light,
                      ),
                    ), // Chapter content
                  );
                }).toList(),
              ),
              // Text(
              // widget.continueReading.chapters.entries.join(' \n '),

              // 'Benedict Timothy Carlton Cumberbatch CBE (born 19 July 1976) is an '
              // 'English actor. A graduate of the Victoria University of Manchester, '
              // 'he continued his training at the London Academy of Music and Dramatic '
              // 'Art, obtaining a Master of Arts in Classical Acting. He first performed '
              // 'at the Open Air Theatre, Regent\'s Park in Shakespearean productions '
              // 'and made his West End debut in Richard Eyre\'s revival of Hedda Gabler '
              // 'in 2005.\n\n'
              // 'Since then, he has starred in the Royal National Theatre productions '
              // 'After the Dance (2010) and Frankenstein (2011). In 2015, he played '
              // 'the title role in Hamlet at the Barbican Theatre.'
              // 'Benedict Timothy Carlton Cumberbatch CBE (born 19 July 1976) is an '
              // 'English actor. A graduate of the Victoria University of Manchester, '
              // 'he continued his training at the London Academy of Music and Dramatic '
              // 'Art, obtaining a Master of Arts in Classical Acting. He first performed '
              // 'at the Open Air Theatre, Regent\'s Park in Shakespearean productions '
              // 'and made his West End debut in Richard Eyre\'s revival of Hedda Gabler '
              // 'in 2005.\n\n'
              // 'Since then, he has starred in the Royal National Theatre productions '
              // 'After the Dance (2010) and Frankenstein (2011). In 2015, he played '
              // 'the title role in Hamlet at the Barbican Theatre.',
              //   style: AppTextStyles.normal400L(
              //     fontSize: 16,
              //     height: 30 / 16,
              //     color: AppColors.text3Light,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
