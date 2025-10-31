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
                  hintStyle:
                      TextStyle(color: AppColors.admissionTitle),
                ),
              ),
              const SizedBox(height: 10),
              if (schoolProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (schoolProvider.error != null)
                Center(child: Text("Error: ${schoolProvider.error}"))
              else
                Expanded( // ✅ Only change: Use Expanded instead of SizedBox
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
      Expanded(  // ✅ Added Expanded to constrain width
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
            if (address.isNotEmpty)  // ✅ Only show if address exists
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


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/routes/login_in.dart';

// class SelectSchool extends StatefulWidget {
//   const SelectSchool({super.key});

//   @override
//   State<SelectSchool> createState() => _SelectSchoolState();
// }

// class _SelectSchoolState extends State<SelectSchool> {
//   final _selectSchoolCount = [
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Daughters Of Divine Love Juniorate',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Graceland Schools',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Seat Of Wisdom Secondary School',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Spring Of Life International School',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Seat Of Wisdom Secondary School',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Mount Carmel College',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Graceland Schools',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Evergreen ',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//     _selectSchoolItems(
//       image: 'assets/images/explore-images/ls-logo.png',
//       title: 'Mount Carmel College ',
//       address: 'Abakpa-Nike, Enugu, Enugu State.',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar:AppBar(title:Text("Select School") ,),
      
//       body: Container(
//         decoration: Constants.customScreenDec0ration(),
//         width: double.infinity,
//         height: double.infinity,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 92, left: 16, right: 16),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: Column(
//                   children: [
//                     Text(
//                       "Select Your Institution",
//                       style: AppTextStyles.normal700(
//                           fontSize: 20, color: AppColors.aboutTitle),
//                       textAlign: TextAlign.center,
//                     ),
//                     Text(
//                       "Please select your School/nstitution below",
//                       style: AppTextStyles.normal500(
//                           fontSize: 12, color: AppColors.admissionTitle),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(
//                       height: 8,
//                     ),
//                     Padding(
//                         padding:
//                             const EdgeInsets.only(right: 8, left: 8, top: 8),
//                         child: Column(
//                           children: [
//                             TextField(
//                               onChanged: (value) {
//                                 setState(() {
//                                   // query = value;
//                                 });
//                               },
//                               decoration: InputDecoration(
//                                 hintText: 'Search',
//                                 filled: true,
//                                 fillColor: AppColors.assessmentColor1,
//                                 contentPadding: EdgeInsets.symmetric(
//                                     vertical: 8,
//                                     horizontal: 22), // Reduces height
//                                 prefixIcon: Icon(Icons.search),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(50),
//                                   borderSide: BorderSide(
//                                     width: 0.5,
//                                     color: AppColors.assessmentColor1,
//                                   ),
//                                 ),
//                                 hintStyle:
//                                     TextStyle(color: AppColors.admissionTitle),
//                               ),
//                             ),
//                           ],
//                         )),
//                     SizedBox(height: 10),
//                     SizedBox(
//                       height: 450,
//                       child: ListView.builder(
//                         itemCount: _selectSchoolCount.length,
//                         itemBuilder: (context, index) {
//                           return Column(
//                             children: [
//                              GestureDetector(
//                               onTap: (){
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreens()));
//                               },
//                               child: _selectSchoolCount[index],
//                              ),
//                               Divider(),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(color: AppColors.assessmentColor1),
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       top: 8,
//                     ),
//                     child: Column(
//                       children: [
//                         SizedBox(height: 10),
//                         Wrap(
//                           alignment: WrapAlignment.center,
//                           children: [
//                             Text(
//                               "Looking for your school? ",
//                               style: AppTextStyles.normal400(
//                                   fontSize: 14,
//                                   color: AppColors.assessmentColor2),
//                             ),
//                             InkWell(
//                               child: Text(
//                                 "Tap here",
//                                 style: AppTextStyles.normal400(
//                                     fontSize: 14, color: AppColors.aboutTitle),
//                               ),
//                             ),
//                             Text(
//                               " to send us a message.",
//                               style: AppTextStyles.normal400(
//                                   fontSize: 14,
//                                   color: AppColors.assessmentColor2),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 15),
//                       ],
//                     ),
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget _selectSchoolItems({
//   required String image,
//   required String title,
//   required String address,
// }) {
//   return Container(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image(
//               image: AssetImage(image),
//               height: 25,
//               width: 25,
//               // color: AppColors.assessmentColor1,
//               alignment: Alignment.bottomRight,
//             ),
//             SizedBox(
//               width: 8,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyles.normal500(
//                       fontSize: 14, color: AppColors.backgroundDark),
//                 ),
//                 Text(
//                   address,
//                   style: AppTextStyles.normal500(
//                       fontSize: 10, color: AppColors.backgroundDark),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ],
//     ),
//   );
// }
