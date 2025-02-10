import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class ELibSubjectDetail extends StatefulWidget {
  const ELibSubjectDetail({super.key});

  @override
  State<ELibSubjectDetail> createState() => _ELibSubjectDetailState();
}

final String paratext =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

class _ELibSubjectDetailState extends State<ELibSubjectDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: Constants.customBoxDecoration(context),
      child: Stack(
        children: [
          Positioned(
            // top: 32,
            left: 0,
            right: 0,
            child: Image(
              image: AssetImage(
                  'assets/images/e-subject_detail/maths_colourful_words.png'),
              fit: BoxFit.cover,
              height: 338,
              width: 360,
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          Positioned(
              top: 310,
              left: 0,
              right: 0,
              child: Container(
                  width: 360,
                  height: 1141,
                  decoration: BoxDecoration(
                    color: AppColors.assessmentColor1,
                    border: Border.all(color: AppColors.assessmentColor3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Mathamatics',
                          style: AppTextStyles.normal700(
                              fontSize: 20, color: AppColors.aboutTitle),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                  ),
                                  Text(
                                    '3h 30min',
                                    style: AppTextStyles.normal400(
                                        fontSize: 12,
                                        color: AppColors.admissionTitle),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                  ),
                                  Text(
                                    '3h 30min',
                                    style: AppTextStyles.normal400(
                                        fontSize: 12,
                                        color: AppColors.admissionTitle),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '. 28 Lessons',
                                    style: AppTextStyles.normal400(
                                        fontSize: 12,
                                        color: AppColors.admissionTitle),
                                  ),
                                ])
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paratext,
                              style: AppTextStyles.normal400(
                                fontSize: 16,
                                color: AppColors.assessmentColor2,
                              ),
                            ),
                            TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Read More',
                                  style: AppTextStyles.normal400(
                                      fontSize: 14, color: AppColors.bgBorder),
                                ))
                          ],
                        ),
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelColor: AppColors.bgBorder,
                                unselectedLabelColor: AppColors.assessmentColor2,
                                indicatorColor: AppColors.bgBorder,
                

                                tabs: const [
                                  Tab(
                                    text: 'Lessons(28)',
                                  ),
                                  Tab(
                                    text: 'Reviews',
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 300, // Adjust height as needed
                                child: TabBarView(
                                  children: [
                                    // Lessons tab content
                                    Center(child: Text('Lessons Content')),
                                    // Reviews tab content
                                    Center(child: Text('Reviews Content')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )))
        ],
      ),
    ));
  }
}
