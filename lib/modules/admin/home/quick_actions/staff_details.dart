import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/model/admin/home/add_staff_model.dart';

class StaffProfileScreen extends StatelessWidget {
   final Staff staff;

  const StaffProfileScreen({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
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
          'Staff Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                // Staff photo OR initials
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
               
                  child:
                      Text(
                          _getInitials(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.paymentTxtColor1,
                          ),
                        )
                     
                ),
                const SizedBox(height: 10.0),

                // Staff full name
                Text(
                  "${staff.lastName ?? ''} ${staff.firstName ?? ''} ${staff.middleName ?? ''}".trim(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5.0),

                // Staff ID
                Text(
                  "Staff ID: ${staff.staffNo ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 5.0),

                // Phone number
                Text(
                  "Mobile: ${staff.phoneNumber ?? 'N/A'}",
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
                    _buildIconColumn('assets/icons/staff/whatsapp_call_icon.svg'),
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
                  _buildSectionHeader('Contact Information'),
                  _buildRowWithIcon(
                    svgIcon: 'assets/icons/staff/email_icon.svg',
                    text: staff.emailAddress ?? "N/A",
                  ),
                  const Divider(),

                  // Personal Information
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 5.0),
                  
                  _buildSubText('Gender'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.gender ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Birth Date'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.birthDate ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Marital Status'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.maritalStatus ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Nationality'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.nationality ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Address Information
                  _buildSectionHeader('Address Information'),
                  _buildSubText('Address'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.address ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('State of Origin'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.stateOrigin ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('LGA of Origin'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.lgaOrigin ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Employment Information
                  _buildSectionHeader('Employment Information'),
                  _buildSubText('Employment Date'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.employmentDate ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Employment Status'),
                  const SizedBox(height: 5.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: staff.isActive
                          ? AppColors.attCheckColor2.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      staff.employmentStatus ?? "N/A",
                      style: TextStyle(
                        color: staff.isActive
                            ? AppColors.attCheckColor2
                            : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Access Level'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.accessLevel ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Next of Kin Information
                  _buildSectionHeader('Next of Kin Information'),
                  _buildSubText('Name'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.nextOfKinName ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Phone number'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.nextOfKinPhone ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Email'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.nextOfKinEmail ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  _buildSubText('Address'),
                  const SizedBox(height: 5.0),
                  Text(
                    staff.nextOfKinAddress ?? "N/A",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to get staff photo source
  // ImageProvider? _getStaffImage() {
  //   if (staff.photo?.codeUnitAt(index) != null && staff.photo!.file!.isNotEmpty) {
  //     // Base64 image
  //     return MemoryImage(base64Decode(staff.photo!.file!));
  //   } else if (staff.photoPath != null && staff.photoPath!.isNotEmpty) {
  //     // Network image
  //     return NetworkImage("https://linkskool.net/${staff.photoPath}");
  //   }
  //   return null; // fallback to initials
  // }

  /// Get initials from staff name
  String _getInitials() {
    String initials = '';
    if (staff.firstName != null && staff.firstName!.isNotEmpty) {
      initials += staff.firstName![0].toUpperCase();
    }
    if (staff.lastName != null && staff.lastName!.isNotEmpty) {
      initials += staff.lastName![0].toUpperCase();
    }
    return initials.isNotEmpty ? initials : 'S';
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