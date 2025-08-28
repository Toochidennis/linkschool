import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/text_styles.dart';
import '../../../common/widgets/portal/profile/naira_icon.dart';
import '../../../model/admin/payment_models.dart';
import '../../../services/admin/payment/payment_service.dart';
import '../../../services/api/api_service.dart';


class PaymentReceivedScreen extends StatefulWidget {
  final int levelId;
  final int classId;
  final String levelName;
  final String className;

  const PaymentReceivedScreen({
    super.key,
    required this.levelId,
    required this.classId,
    required this.levelName,
    required this.className,
  });

  @override
  State<PaymentReceivedScreen> createState() => _PaymentReceivedScreenState();
}

class _PaymentReceivedScreenState extends State<PaymentReceivedScreen> {
  late double opacity;
  String? selectedClass;
  String searchQuery = '';
  List<PaidInvoice> _paidInvoices = [];
  bool _isLoading = true;
  late PaymentService _paymentService;
  late int _currentLevelId;
  late int _currentClassId;
  late String _currentClassName;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(ApiService());
    _currentLevelId = widget.levelId;
    _currentClassId = widget.classId;
    _currentClassName = widget.className;
    selectedClass = widget.className;
    _loadPaidInvoices();
  }

  Future<void> _loadPaidInvoices() async {
    setState(() => _isLoading = true);
    
    try {
      final invoices = await _paymentService.getPaidInvoices(
        levelId: _currentLevelId,
        classId: _currentClassId,
      );
      setState(() {
        _paidInvoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading paid invoices: $e');
    }
  }

  Map<String, List<PaidInvoice>> get groupedInvoices {
    final filtered = _paidInvoices.where((invoice) {
      return invoice.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final Map<String, List<PaidInvoice>> grouped = {};
    for (final invoice in filtered) {
      final key = '${invoice.name}_${invoice.regNo}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(invoice);
    }
    return grouped;
  }

  void _showClassSelectionOverlay() {
    final classes = _paymentService.getClassesForLevel(_currentLevelId);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Class',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: const Color.fromRGBO(47, 85, 221, 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classModel = classes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: _buildClassButton(classModel),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassButton(ClassModel classModel) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _currentClassId = classModel.id;
          _currentClassName = classModel.className;
          selectedClass = classModel.className;
        });
        _loadPaidInvoices();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(47, 85, 221, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          classModel.className,
          style: AppTextStyles.normal500(
            fontSize: 18,
            color: AppColors.backgroundLight,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
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
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Received',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: _showClassSelectionOverlay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedClass ?? 'Class',
                                  style: AppTextStyles.normal500(
                                    fontSize: 16.0,
                                    color: selectedClass != null
                                        ? AppColors.primaryLight
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: selectedClass != null
                                      ? AppColors.primaryLight
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
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
                      child: groupedInvoices.isEmpty
                          ? const Center(child: Text('No paid invoices found'))
                          : ListView.builder(
                              itemCount: groupedInvoices.length,
                              itemBuilder: (context, index) {
                                final entry = groupedInvoices.entries.elementAt(index);
                                final studentInvoices = entry.value;
                                final firstInvoice = studentInvoices.first;
                                final totalAmount = studentInvoices.fold(0.0, (sum, invoice) => sum + invoice.amount);
                                
                                return _buildStudentItem(context, firstInvoice, totalAmount, studentInvoices);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStudentItem(BuildContext context, PaidInvoice invoice, double totalAmount, List<PaidInvoice> allInvoices) {
    final className = _paymentService.getClassName(invoice.classId) ?? 'Unknown Class';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
        title: Text(
          invoice.name,
          style: AppTextStyles.normal500(
            fontSize: 18,
            color: AppColors.backgroundDark,
          ),
        ),
        subtitle: Text(
          className,
          style: AppTextStyles.normal400(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NairaSvgIcon(color: AppColors.paymentTxtColor2),
            const SizedBox(width: 4),
            Text(
              totalAmount.toStringAsFixed(2),
              style: AppTextStyles.normal700(
                fontSize: 18,
                color: AppColors.paymentTxtColor2,
              ),
            ),
          ],
        ),
        onTap: () {
          // If multiple invoices, show the first one (or you could show a selection)
          _showReceiptOverlay(context, allInvoices.first);
        },
      ),
    );
  }

  void _showReceiptOverlay(BuildContext context, PaidInvoice invoice) {
    final levelName = _paymentService.getLevelName(invoice.levelId) ?? 'Unknown Level';
    final className = _paymentService.getClassName(invoice.classId) ?? 'Unknown Class';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.5,
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
                    invoice.status == 1
                        ? SvgPicture.asset('assets/icons/profile/success_receipt_icon.svg', width: 80, height: 80)
                        : SvgPicture.asset('assets/icons/profile/failed_receipt_icon.svg', width: 80, height: 80),
                    const SizedBox(height: 16),
                    Text(
                      invoice.termText,
                      style: AppTextStyles.normal600(
                        fontSize: 20,
                        color: const Color.fromRGBO(47, 85, 221, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const NairaSvgIcon(color: AppColors.paymentTxtColor2),
                        const SizedBox(width: 4),
                        Text(
                          invoice.amount.toStringAsFixed(2),
                          style: AppTextStyles.normal700(
                            fontSize: 24,
                            color: AppColors.paymentTxtColor2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildReceiptRow('Date', invoice.date),
                          _buildReceiptRow('Name', invoice.name),
                          _buildReceiptRow('Level', levelName),
                          _buildReceiptRow('Class', className),
                          _buildReceiptRow('Registration Number', invoice.regNo),
                          _buildReceiptRow('Session', invoice.sessionText),
                          _buildReceiptRow('Term', invoice.termFeesText),
                          _buildReceiptRow('Reference Number', invoice.reference),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: AppTextStyles.normal500(
                            fontSize: 18,
                            color: AppColors.backgroundLight,
                          ),
                        ),
                      ),
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

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.normal500(
              fontSize: 14,
              color: Colors.grey[600]!,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.normal600(
              fontSize: 14,
              color: AppColors.backgroundDark,
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
// import 'package:linkschool/modules/model/profile/student_model.dart';

// class PaymentReceivedScreen extends StatefulWidget {
//   const PaymentReceivedScreen({
//     super.key,
//   });

//   @override
//   State<PaymentReceivedScreen> createState() => _PaymentReceivedScreenState();
// }

// class _PaymentReceivedScreenState extends State<PaymentReceivedScreen> {
//   late double opacity;
//   String? selectedClass;
//   String searchQuery = '';

//   // Dummy data for students with outstanding payments
//   final List<StudentPayment> dummyStudents = [
//     StudentPayment(name: "John Doe", grade: "Basic 1", amount: "₦45,000"),
//     StudentPayment(name: "Sarah Uche", grade: "JSS 2", amount: "₦62,500"),
//     StudentPayment(name: "Michael Akande", grade: "SSS 1", amount: "₦78,900"),
//     StudentPayment(name: "David Ugonna", grade: "Basic 2", amount: "₦55,000"),
//     StudentPayment(name: "Daniel Okoro", grade: "JSS 3", amount: "₦68,750"),
//     StudentPayment(name: "Sophie Toohi", grade: "SSS 2", amount: "₦82,300"),
//     StudentPayment(name: "James Amaka", grade: "Basic 3", amount: "₦58,900"),
//     StudentPayment(name: "Emma Bob", grade: "JSS 1", amount: "₦59,999"),
//     StudentPayment(name: "Oliver Toochi", grade: "SSS 3", amount: "₦89,500"),
//     StudentPayment(name: "Richard", grade: "Basic 1", amount: "₦48,750"),
//   ];

//   // Define class data
//   final Map<String, List<String>> ClassMap = {
//     'JSS': ['JSS 1', 'JSS 2', 'JSS 3'],
//     'SS': ['SS 1', 'SS 2', 'SS 3'],
//     'BASIC': ['Basic 1', 'Basic 2', 'Basic 3', 'Basic 4', 'Basic 5'],
//   };

//   // Filtered list based on search and class filter
//   List<StudentPayment> get filteredStudents {
//     return dummyStudents.where((student) {
//       bool matchesSearch =
//           student.name.toLowerCase().contains(searchQuery.toLowerCase());
//       bool matchesClass =
//           selectedClass == null || student.grade.startsWith(selectedClass!);
//       return matchesSearch && matchesClass;
//     }).toList();
//   }

//   void _showClassSelectionOverlay() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.backgroundLight,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.4,
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Select Class',
//                     style: AppTextStyles.normal600(
//                       fontSize: 20,
//                       color: const Color.fromRGBO(47, 85, 221, 1),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Flexible(
//                     child: ListView.builder(
//                       itemCount: ClassMap.keys.length,
//                       itemBuilder: (context, index) {
//                         String level = ClassMap.keys.elementAt(index);
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 8),
//                           child: _buildSubjectButton(level),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Received',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   InkWell(
//                     onTap: _showClassSelectionOverlay,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 8.0,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             selectedClass ?? 'Class',
//                             style: AppTextStyles.normal500(
//                               fontSize: 16.0,
//                               color: selectedClass != null
//                                   ? AppColors.primaryLight
//                                   : Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Icon(
//                             Icons.arrow_drop_down,
//                             color: selectedClass != null
//                                 ? AppColors.primaryLight
//                                 : Colors.grey,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search...',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredStudents.length,
//                   itemBuilder: (context, index) {
//                     final student = filteredStudents[index];
//                     return _buildStudentItem(context, student);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentItem(BuildContext context, StudentPayment student) {
//     // Extract the numeric part of the amount string (remove the ₦ symbol)
//     String amountValue = student.amount.replaceAll('₦', '');

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListTile(
//         leading: SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
//         title: Text(
//           student.name,
//           style: AppTextStyles.normal500(
//             fontSize: 18,
//             color: AppColors.backgroundDark,
//           ),
//         ),
//         subtitle: Text(
//           student.grade,
//           style: AppTextStyles.normal400(
//             fontSize: 14,
//             color: Colors.grey,
//           ),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const NairaSvgIcon(color: AppColors.paymentTxtColor2),
//             const SizedBox(width: 4),
//             Text(
//               amountValue,
//               style: AppTextStyles.normal700(
//                 fontSize: 18,
//                 color: AppColors.paymentTxtColor2,
//               ),
//             ),
//           ],
//         ),
//         onTap: () {
//           _showReceiptOverlay(context, student);
//         },
//       ),
//     );
//   }

//   void _showReceiptOverlay(BuildContext context, StudentPayment student) {
//     // Extract the numeric part of the amount string
//     String amountValue = student.amount.replaceAll('₦', '');
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // This allows the bottom sheet to be taller
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.72, // Start at 72% of screen height
//           minChildSize: 0.5, // Minimum height (50% of screen)
//           // maxChildSize: 0.95, // Maximum height (95% of screen)
//           expand: false,
//           builder: (_, controller) {
//             return SingleChildScrollView(
//               controller: controller,
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 5,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(2.5),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     SvgPicture.asset(
//                         'assets/icons/profile/success_receipt_icon.svg',
//                         height: 60),
//                     const SizedBox(height: 24),
//                     Text(
//                       'Second Term Fees Receipt',
//                       style: AppTextStyles.normal600(
//                         fontSize: 20.0,
//                         color: AppColors.primaryLight,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const NairaSvgIcon(color: AppColors.primaryLight),
//                         const SizedBox(width: 4),
//                         Text(
//                           amountValue,
//                           style: const TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primaryLight,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Text(student.amount,
//                     //   style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
//                     const SizedBox(height: 24),
//                     Divider(thickness: 1, color: Colors.grey.withOpacity(0.5)),
//                     const SizedBox(height: 16),
//                     _buildReceiptDetail('Date', '2023-10-23'),
//                     _buildReceiptDetail('Name', student.name),
//                     _buildReceiptDetail('Level', student.grade),
//                     _buildReceiptDetail('Class', '${student.grade} A'),
//                     _buildReceiptDetail('Registration number',
//                         'REG${DateTime.now().millisecondsSinceEpoch}'),
//                     _buildReceiptDetail('Session', '2023/2024'),
//                     _buildReceiptDetail('Term', '2nd Term Fees'),
//                     _buildReceiptDetail('Reference number',
//                         'REF${DateTime.now().millisecondsSinceEpoch}'),
//                     const SizedBox(height: 32),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {},
//                             style: OutlinedButton.styleFrom(
//                               side: const BorderSide(
//                                 color: Color.fromRGBO(47, 85, 221, 1),
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               child: Text('Share',
//                                   style: AppTextStyles.normal500(
//                                     fontSize: 18,
//                                     color: const Color.fromRGBO(47, 85, 221, 1),
//                                   )),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color.fromRGBO(47, 85, 221, 1),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               child: Text('Download',
//                                   style: AppTextStyles.normal500(
//                                       fontSize: 16.0,
//                                       color: AppColors.backgroundLight)),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildReceiptDetail(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(value),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectButton(String text) {
//     return ElevatedButton(
//       onPressed: () {
//         setState(() {
//           selectedClass = text;
//         });
//         Navigator.pop(context);
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 16),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 16),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
