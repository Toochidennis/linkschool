import 'package:flutter/material.dart';
import 'package:linkschool/modules/E_library/test_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class CbtDetailScreen extends StatefulWidget {
  const CbtDetailScreen({super.key});

  @override
  State<CbtDetailScreen> createState() => _CbtDetailScreenState();
}

class _CbtDetailScreenState extends State<CbtDetailScreen> {
  String? selectedYear;

  final List<int> years = [
    2023,
    2022,
    2021,
    2020,
    2019,
    2018,
    2017,
    2016,
    2015,
    2014,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(
          context: context, title: 'WAEC/SSCE', centerTitle: true),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.cbtCardColor5,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/further_maths.png',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Further Mathematics',
                          style: AppTextStyles.normal500(
                            fontSize: 18.0,
                            color: AppColors.cbtText,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                 
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                     children: [
                       Text('Year :',style: AppTextStyles.normal500(fontSize: 16, color: AppColors.libtitle),),
                       Text('$selectedYear',style: AppTextStyles.normal500(fontSize: 16, color:AppColors.text3Light)),
                     ],
                   ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: DropdownButton<String>(
                      items: years.map((int year) {
                        return DropdownMenuItem<String>(
                          value: year.toString(),

                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                                        ),
                    ),
                ],
              ),
                Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      Text('Duration :',style: AppTextStyles.normal500(fontSize: 16,   color: AppColors.libtitle),),
                      Text('2hrs 30 minutes',style: AppTextStyles.normal500(fontSize: 16, color:AppColors.text3Light)),
                    ],
                  ),
                ),
                Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      Text('Instructions :',style: AppTextStyles.normal500(fontSize: 16,   color: AppColors.libtitle)),
                      Text('Answer all questions',style: AppTextStyles.normal500(fontSize: 16, color:AppColors.text3Light)),
                    ],
                  ),
                ),
                  Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:8.0),
                  child: CustomLongElevatedButton(
                    text: 'Start Exam',
                    onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen())),
                    backgroundColor: AppColors.bookText1,
                    textStyle: AppTextStyles.normal500(fontSize: 18.0, color: AppColors.bookText2 ),
                  ),
                )
              
            ],
          ),
        ),
      ),
    );
  }
}