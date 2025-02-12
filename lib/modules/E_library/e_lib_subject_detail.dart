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
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
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
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.start,
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
                          mainAxisAlignment: MainAxisAlignment.start,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelColor: AppColors.bgBorder,
                                unselectedLabelColor:
                                    AppColors.assessmentColor2,
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
                                    Expanded(
                                      child: ListView(
                                        scrollDirection: Axis.vertical,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: Container(
                                              child: Text(
                                                'Elementary',
                                                style: AppTextStyles.normal500(
                                                    fontSize: 14,
                                                    color: AppColors
                                                        .assessmentColor2),
                                              ),
                                            ),
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            child: Text(
                                              'Junior Secondary',
                                              style: AppTextStyles.normal500(
                                                  fontSize: 14,
                                                  color: AppColors
                                                      .assessmentColor2),
                                            ),
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          subjectDetails(),
                                          SizedBox(
                                            height: 200,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Reviews tab content
                                    Expanded(child: Text(paratext)),
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

class subjectDetails extends StatelessWidget {
  const subjectDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 12, left: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bgColor3,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '02',
                      style: AppTextStyles.normal500(
                          fontSize: 14, color: AppColors.aboutTitle),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Improper Fraction',
                            style: AppTextStyles.normal600(
                                fontSize: 14.0,
                                color: AppColors.admissionTitle),
                          ),
                          Column(children: [
                            Text(
                              '02:57:00',
                              style: AppTextStyles.normal600(
                                  fontSize: 12.0,
                                  color: AppColors.admissionTitle),
                            )
                          ]),
                        ],
                      ),
                    ]),
                SizedBox(
                  width: 80,
                ),
                Container(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: AppColors.bgBorder,
                    size: 30,
                  ),
                )
              ]),
          Divider(
            color: AppColors.attBorderColor1,
            height: 10,
          )
        ],
      ),
    );
  }
}
