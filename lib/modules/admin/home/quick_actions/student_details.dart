import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/model/admin/home/manage_student_model.dart';

class StudentProfileScreen extends StatelessWidget {
  final Students student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.paymentTxtColor1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: const BoxDecoration(
              color: AppColors.paymentTxtColor1,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: [
                // Student photo OR initials
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: _getStudentImage(),
                  child: _getStudentImage() == null
                      ? Text(
                          student.getInitials(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.paymentTxtColor1,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 10.0),

                // Student full name
                Text(
                  "${student.surname} ${student.firstName} ${student.middle}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5.0),

                // Mobile number (guardian phone if student has none)
                Text(
                  "Mobile ${student.guardianPhoneNo ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20.0),

                // Call / SMS / WhatsApp row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconColumn('assets/icons/staff/phone_icon.svg'),
                    const SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        color: AppColors.backgroundLight,
                        thickness: 2,
                        width: 20,
                      ),
                    ),
                    _buildIconColumn('assets/icons/staff/message_icon.svg'),
                    const SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        color: AppColors.backgroundLight,
                        thickness: 2,
                        width: 20,
                      ),
                    ),
                    _buildIconColumn(
                        'assets/icons/staff/whatsapp_call_icon.svg'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Bottom Section
          Expanded(
            child: Container(
              decoration: Constants.customBoxDecoration(context),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: [
                  // Email
                  _buildSectionHeader('Email address'),
                  _buildRowWithIcon(
                    svgIcon: 'assets/icons/staff/email_icon.svg',
                    text: student.email ?? "N/A",
                  ),
                  const Divider(),

                  // Guardian
                  _buildSectionHeader('Guardian Information'),
                  const SizedBox(height: 5.0),
                  _buildSubText('Name'),
                  const SizedBox(height: 5.0),
                  Text(
                    student.guardianName ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Guardian phone
                  _buildSubText('Phone number'),
                  const SizedBox(height: 5.0),
                  Text(
                    student.guardianPhoneNo ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Address
                  _buildSubText('Address'),
                  const SizedBox(height: 5.0),
                  Text(
                    student.address ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to results page with this student
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.staffCtnColor2,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'See student results',
                          style: TextStyle(
                            color: AppColors.paymentTxtColor1,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/icons/staff/arrow_forward_icon.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Helper to get student photo source
  ImageProvider? _getStudentImage() {
    if (student.photo?.file != null && student.photo!.file!.isNotEmpty) {
      // Base64 image
      return MemoryImage(base64Decode(student.photo!.file!));
    } else if (student.photoPath != null && student.photoPath!.isNotEmpty) {
      // Network image
      return NetworkImage("https://linkskool.net/${student.photoPath}");
    }
    return null; // fallback to initials
  }

  // === Reusable Widgets ===
  Widget _buildIconColumn(String svgPath) {
    return SvgPicture.asset(svgPath);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.paymentTxtColor1,
        ),
      ),
    );
  }

  Widget _buildRowWithIcon({required String svgIcon, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SvgPicture.asset(svgIcon, width: 24, height: 24),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubText(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
