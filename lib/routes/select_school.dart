// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/providers/login/schools_provider.dart';
import 'package:provider/provider.dart';

class SelectSchool extends StatefulWidget {
  final void Function(String schoolCode)? onSchoolSelected;
  final VoidCallback? onBack;

  const SelectSchool({super.key, this.onSchoolSelected, this.onBack});

  @override
  State<SelectSchool> createState() => _SelectSchoolState();
}

class _SelectSchoolState extends State<SelectSchool> {
  String query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SchoolProvider>(context, listen: false).fetchSchools());
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final filteredSchools = schoolProvider.searchSchools(query);

    return PopScope(
      canPop: false, // Disable physical back button
      onPopInvoked: (didPop) {
        if (!didPop && widget.onBack != null) {
          // If back was attempted but prevented, call the callback
          widget.onBack!();
        }
      },
      child: Scaffold(
       
      body: Container(
        decoration: Constants.customScreenDec0ration(),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button - left aligned
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                onPressed: () {
                  // Check if there's a route to pop before attempting
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else if (widget.onBack != null) {
                    // If no route to pop but callback exists, use it
                    widget.onBack!();
                  }
                },
              ),
              const SizedBox(height: 24),
              // Title and subtitle - centered
              Center(
                child: Text(
                  "Select Your Institution",
                  style: AppTextStyles.normal700(
                      fontSize: 20, color: AppColors.aboutTitle),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  "Please select your School/Institution below",
                  style: AppTextStyles.normal500(
                      fontSize: 12, color: AppColors.admissionTitle),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  hintText: 'Search',
                  filled: true,
                  fillColor: AppColors.assessmentColor1,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                        width: 0.5, color: AppColors.assessmentColor1),
                  ),
                  hintStyle: TextStyle(color: AppColors.admissionTitle),
                ),
              ),
              const SizedBox(height: 10),
              if (schoolProvider.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (schoolProvider.error != null)
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 56,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Unable to Load Schools',
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text2Light,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'There was a problem loading the list of schools.\nPlease check your internet connection.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: AppColors.text7Light,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              schoolProvider.fetchSchools();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(
                              'Try Again',
                              style: AppTextStyles.normal600(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.eLearningBtnColor1,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (filteredSchools.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.text7Light,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No schools found',
                          style: AppTextStyles.normal600(
                            fontSize: 18,
                            color: AppColors.text2Light,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: AppTextStyles.normal400(
                            fontSize: 14,
                            color: AppColors.text7Light,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSchools.length,
                    itemBuilder: (context, index) {
                      final school = filteredSchools[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (widget.onSchoolSelected != null) {
                                widget.onSchoolSelected!(
                                  school.schoolCode.toString(),
                                );
                              }
                            },
                            child: _selectSchoolItems(
                              image: 'assets/images/explore-images/ls-logo.png',
                              title: school.schoolName,
                              address: school.address ?? '',
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    ),
    );
  }
}

Widget _selectSchoolItems({
  required String image,
  required String title,
  required String address,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.asset(image, height: 25, width: 25),
      const SizedBox(width: 8),
      Expanded(
        // ✅ Added Expanded to constrain width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.normal500(
                fontSize: 14,
                color: AppColors.backgroundDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (address.isNotEmpty) // ✅ Only show if address exists
              Text(
                address,
                style: AppTextStyles.normal500(
                  fontSize: 10,
                  color: AppColors.backgroundDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    ],
  );
}
