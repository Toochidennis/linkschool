import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/profile/student_model.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

class PaymentReceivedScreen extends StatefulWidget {

  const PaymentReceivedScreen({
    super.key,
  });

  @override
  State<PaymentReceivedScreen> createState() => _PaymentReceivedScreenState();
}

class _PaymentReceivedScreenState extends State<PaymentReceivedScreen> {
  late double opacity;
  String? selectedClass;
  String searchQuery = '';

  // Dummy data for students with outstanding payments
  final List<StudentPayment> dummyStudents = [
    StudentPayment(name: "John Doe", grade: "Basic 1", amount: "₦45,000"),
    StudentPayment(name: "Sarah Uche", grade: "JSS 2", amount: "₦62,500"),
    StudentPayment(name: "Michael Akande", grade: "SSS 1", amount: "₦78,900"),
    StudentPayment(name: "David Ugonna", grade: "Basic 2", amount: "₦55,000"),
    StudentPayment(name: "Daniel Okoro", grade: "JSS 3", amount: "₦68,750"),
    StudentPayment(name: "Sophie Toohi", grade: "SSS 2", amount: "₦82,300"),
    StudentPayment(name: "James Amaka", grade: "Basic 3", amount: "₦58,900"),
    StudentPayment(name: "Emma Bob", grade: "JSS 1", amount: "₦59,999"),
    StudentPayment(name: "Oliver Toochi", grade: "SSS 3", amount: "₦89,500"),
    StudentPayment(name: "Richard", grade: "Basic 1", amount: "₦48,750"),
  ];

 // Filtered list based on search and class filter
  List<StudentPayment> get filteredStudents {
    return dummyStudents.where((student) {
      bool matchesSearch = student.name.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesClass = selectedClass == null || student.grade.startsWith(selectedClass!);
      return matchesSearch && matchesClass;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          'Receive',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    hint: const Text('Class'),
                    items: ['Basic', 'JSS', 'SSS']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    // onChanged: (_) {},
                    onChanged: (String? value) {
                      setState(() {
                        selectedClass = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
             Expanded(
                child: ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _buildStudentItem(context, student);
                  },
                ),
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: 5,
              //     itemBuilder: (context, index) {
              //       return _buildStudentItem(context);
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentItem(BuildContext context, StudentPayment student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
        title: Text(
          student.name,
          style: AppTextStyles.normal500(
            fontSize: 18,
            color: AppColors.backgroundDark,
          ),
        ),
        subtitle: Text(
          student.grade,
          style: AppTextStyles.normal400(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Text(
          student.amount,
          style: AppTextStyles.normal700(
            fontSize: 18,
            color: AppColors.paymentTxtColor2,
          ),
        ),
        onTap: () {
          _showReceiptOverlay(context, student);
        },
      ),
    );
  }

 void _showReceiptOverlay(BuildContext context, StudentPayment student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the bottom sheet to be taller
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85, // Start at 85% of screen height
          minChildSize: 0.5, // Minimum height (50% of screen)
          maxChildSize: 0.95, // Maximum height (95% of screen)
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SvgPicture.asset('assets/icons/profile/success_receipt_icon.svg', height: 60),
                    const SizedBox(height: 24),
                    const Text('Second Term Fees Receipt', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(student.amount, 
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    const SizedBox(height: 24),
                    Divider(thickness: 1, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    _buildReceiptDetail('Date', '2023-10-23'),
                    _buildReceiptDetail('Name',  student.name),
                    _buildReceiptDetail('Level', student.grade),
                    _buildReceiptDetail('Class', '${student.grade} A'),
                    _buildReceiptDetail('Registration number', 'REG${DateTime.now().millisecondsSinceEpoch}'),
                    _buildReceiptDetail('Session', '2023/2024'),
                    _buildReceiptDetail('Term', '2nd Term Fees'),
                    _buildReceiptDetail('Reference number', 'REF${DateTime.now().millisecondsSinceEpoch}'),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: const Color.fromRGBO(47, 85, 221, 1),),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Share', style: AppTextStyles.normal500(fontSize: 18, color: const Color.fromRGBO(47, 85, 221, 1),)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Download', style: AppTextStyles.normal500(fontSize: 16.0, color: AppColors.backgroundLight)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReceiptDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }
}