import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/dash_line_utils.dart';

class InfoCard extends StatefulWidget {
  final String? className;
  final String? classId;
  
  const InfoCard({super.key, this.className, this.classId});

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
    String _academicSession = '';
   Map<String, dynamic> _settings = {};
   String _selectedTerm = 'First term';

    @override
  void initState() {
    super.initState();
    _loadSettingsFromHive();
  }
    void _loadSettingsFromHive() {
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');

    if (userData != null && userData['data'] != null && userData['data']['settings'] != null) {
      setState(() {
        _settings = Map<String, dynamic>.from(userData['data']['settings']);

        int termNumber = _settings['term'] ?? 1;
        _selectedTerm = termNumber == 1
            ? 'First term'
            : termNumber == 2
                ? 'Second term'
                : 'Third term';

        _academicSession = "${int.parse(_settings['year'] ?? '2023') - 1}/${_settings['year'] ?? '2023'} academic session";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 396,
      height: 190,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCardHeader(),
              const SizedBox(height: 16),
              const DashedLine(color: Colors.grey),
              const SizedBox(height: 16),
              _buildCardDate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        _buildCardIcon(),
        const SizedBox(width: 16),
        _buildCardInfo(),
      ],
    );
  }

  Widget _buildCardIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
      child: Center(child: SvgPicture.asset('assets/icons/result/study_book.svg', width: 30, height: 30)),
    );
  }

  Widget _buildCardInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTermContainer(),
        const SizedBox(height: 4),
        Text(_getClassName(), style: AppTextStyles.normal600(fontSize: 22, color: AppColors.primaryLight)),
        const SizedBox(height: 4),
        Text(_academicSession, style: AppTextStyles.normal500(fontSize: 14, color: AppColors.textGray)),
      ],
    );
  }

  Widget _buildTermContainer() {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.videoColor4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(_getTermText(), style: AppTextStyles.normal600(fontSize: 12, color: AppColors.videoColor4)),
      ),
    );
  }

  Widget _buildCardDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text('Date :', style: AppTextStyles.normal500(fontSize: 16, color: AppColors.textGray)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(_getCurrentDate(), style: AppTextStyles.normal600(fontSize: 18, color: AppColors.primaryLight)),
        ),
      ],
    );
  }

  // Helper method to get the class name from props or fallback to stored data
  String _getClassName() {
    if (widget.className != null && widget.className!.isNotEmpty) {
      return widget.className!;
    }
    
    // Fallback: try to get from Hive storage if not provided
    try {
      final userBox = Hive.box('userData');
      final classes = userBox.get('classes');
      if (classes != null && classes is List && classes.isNotEmpty) {
        // Return the first class name as fallback
        return classes.first['class_name'] ?? 'Unknown Class';
      }
    } catch (e) {
      print('Error getting class name from Hive: $e');
    }
    
    return 'Unknown Class';
  }

  // Helper method to get the term text based on term number
  String _getTermText() {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');
      
      if (settings != null && settings is Map<String, dynamic>) {
        final term = settings['term'];
        
        if (term != null) {
          switch (term.toString()) {
            case '1':
              return 'First Term';
            case '2':
              return 'Second Term';
            case '3':
              return 'Third Term';
            default:
              return 'Unknown Term';
          }
        }
      }
    } catch (e) {
      print('Error getting term from Hive: $e');
    }
    
    return 'Third Term'; // Fallback to original dummy data
  }

  // Helper method to get the academic session based on year from Hive
  String _getAcademicSession() {
    try {
      final userBox = Hive.box('userData');
      final settings = userBox.get('settings');
      
      if (settings != null && settings is Map<String, dynamic>) {
        final year = settings['year'];
        
        if (year != null) {
          final currentYear = int.tryParse(year.toString());
          if (currentYear != null) {
            final nextYear = currentYear + 1;
            return '$currentYear/$nextYear Academic Session';
          }
        }
      }
    } catch (e) {
      print('Error getting year from Hive: $e');
    }
    
    return '2015/2016 Academic session'; // Fallback to original dummy data
  }

  // Helper method to get current date in the same format as dummy data
  String _getCurrentDate() {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('d MMMM, yyyy');
      return formatter.format(now);
    } catch (e) {
      print('Error formatting current date: $e');
      return '20 July, 2024'; // Fallback to original dummy data
    }
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/utils/dash_line_utils.dart';

// class InfoCard extends StatelessWidget {
//     final String? className;
//   final String? classId;
//   const InfoCard({super.key, this.className, this.classId});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 396,
//       height: 190,
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _buildCardHeader(),
//               const SizedBox(height: 16),
//               const DashedLine(color: Colors.grey),
//               const SizedBox(height: 16),
//               _buildCardDate(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCardHeader() {
//     return Row(
//       children: [
//         _buildCardIcon(),
//         const SizedBox(width: 16),
//         _buildCardInfo(),
//       ],
//     );
//   }

//   Widget _buildCardIcon() {
//     return Container(
//       width: 60,
//       height: 60,
//       decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
//       child: Center(child: SvgPicture.asset('assets/icons/result/study_book.svg', width: 30, height: 30)),
//     );
//   }

//   Widget _buildCardInfo() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTermContainer(),
//         const SizedBox(height: 4),
//         Text('JSS2 A', style: AppTextStyles.normal600(fontSize: 22, color: AppColors.primaryLight)),
//         const SizedBox(height: 4),
//         Text('2015/2016 Academic session', style: AppTextStyles.normal500(fontSize: 14, color: AppColors.textGray)),
//       ],
//     );
//   }

//   Widget _buildTermContainer() {
//     return Container(
//       height: 22,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.videoColor4),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Center(
//         child: Text('Third Term', style: AppTextStyles.normal600(fontSize: 12, color: AppColors.videoColor4)),
//       ),
//     );
//   }

//   Widget _buildCardDate() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16.0),
//           child: Text('Date :', style: AppTextStyles.normal500(fontSize: 16, color: AppColors.textGray)),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 20.0),
//           child: Text('20 July, 2024', style: AppTextStyles.normal600(fontSize: 18, color: AppColors.primaryLight)),
//         ),
//       ],
//     );
//   }
// }