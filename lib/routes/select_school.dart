// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/providers/login/schools_provider.dart';
import 'package:provider/provider.dart';

class SelectSchool extends StatefulWidget {
  final void Function(String schoolCode)? onSchoolSelected;

  const SelectSchool({super.key, this.onSchoolSelected});

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

    return Scaffold(
      body: Container(
        decoration: Constants.customScreenDec0ration(),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 92, left: 16, right: 16),
          child: Column(
            children: [
              Text(
                "Select Your Institution",
                style: AppTextStyles.normal700(
                    fontSize: 20, color: AppColors.aboutTitle),
                textAlign: TextAlign.center,
              ),
              Text(
                "Please select your School/Institution below",
                style: AppTextStyles.normal500(
                    fontSize: 12, color: AppColors.admissionTitle),
                textAlign: TextAlign.center,
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
                const Center(child: CircularProgressIndicator())
              else if (schoolProvider.error != null)
                Center(child: Text("Error: ${schoolProvider.error}"))
              else
                Expanded(
                  // ✅ Only change: Use Expanded instead of SizedBox
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
