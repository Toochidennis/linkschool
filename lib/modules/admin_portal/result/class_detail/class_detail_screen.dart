import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/class_detail/explore_button_item_utils.dart';
import 'package:linkschool/modules/common/utils/class_detail/term_row_utils.dart';
import 'package:linkschool/modules/common/widgets/portal/class_detail/class_detail_barchart.dart';
import 'package:linkschool/modules/common/widgets/portal/class_detail/overlays.dart';
import 'package:linkschool/modules/admin_portal/result/class_detail/attendance/attendance.dart';
import 'package:linkschool/modules/admin_portal/result/class_detail/registration/registration.dart';


class ClassDetailScreen extends StatelessWidget {
  final String className;

  const ClassDetailScreen({Key? key, required this.className})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          className,
          style: AppTextStyles.normal600(fontSize: 18.0, color: AppColors.primaryLight,),
        ),
        leading: IconButton(
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.videoColor4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(
                  'See class list',
                  style: AppTextStyles.normal700(
                    fontSize: 14,
                    color: AppColors.backgroundLight,
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.bgColor1,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.bgColor1,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 15.0)),
                const SliverToBoxAdapter(child: ClassDetailBarChart()),
                SliverToBoxAdapter(
                  child: Container(
                    width: 360,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, -1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ExploreButtonItem(
                                  backgroundColor: AppColors.bgXplore1,
                                  label: 'Student Result',
                                  iconPath: 'assets/icons/result/assessment_icon.svg',
                                  onTap: () =>
                                      showStudentResultOverlay(context),
                                ),
                              ),
                              Expanded(
                                child: ExploreButtonItem(
                                  backgroundColor: AppColors.bgXplore2,
                                  label: 'Registration',
                                  iconPath: 'assets/icons/result/registration_icon.svg',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegistrationScreen()));
                                  },
                                ),
                              ),
                              Expanded(
                                child: ExploreButtonItem(
                                  backgroundColor: AppColors.bgXplore3,
                                  label: 'Attendance',
                                  iconPath: 'assets/icons/result/attendance_icon.svg',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (contex) =>
                                                 AttendanceScreen()));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '2015/2016 Session',
                                style: AppTextStyles.normal700(
                                    fontSize: 18,
                                    color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TermRow(
                            term: 'First Term',
                            percent: 0.75,
                            indicatorColor: AppColors.primaryLight,
                            onTap: () => showTermOverlay(context),
                          ),
                          TermRow(
                            term: 'Second Term',
                            percent: 0.75,
                            indicatorColor: AppColors.videoColor4,
                            onTap: () => showTermOverlay(context),
                          ),
                          TermRow(
                            term: 'Third Term',
                            percent: 0.75,
                            indicatorColor: AppColors.classProgressBar1,
                            onTap: () => showTermOverlay(context),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '2016/2017 Session',
                                style: AppTextStyles.normal700(
                                    fontSize: 18,
                                    color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TermRow(
                            term: 'First Term',
                            percent: 0.75,
                            indicatorColor: AppColors.primaryLight,
                            onTap: () => showTermOverlay(context),
                          ),
                          TermRow(
                            term: 'Second Term',
                            percent: 0.75,
                            indicatorColor: AppColors.videoColor4,
                            onTap: () => showTermOverlay(context),
                          ),
                          TermRow(
                            term: 'Third Term',
                            percent: 0.75,
                            indicatorColor: AppColors.classProgressBar1,
                            onTap: () => showTermOverlay(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}



