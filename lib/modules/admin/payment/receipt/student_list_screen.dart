// Modified student_list_screen.dart (now matches payment_outstanding_screen structure)
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/payment_model.dart';
import 'package:linkschool/modules/services/admin/payment/payment_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/admin/payment/custom_toaster.dart';
import '../../../common/widgets/portal/profile/naira_icon.dart';
import '../../../services/api/api_service.dart';
import 'student_payment_detail_screen.dart';
import 'student_invoice_selection_screen.dart';

class StudentListScreen extends StatefulWidget {
  final int levelId;
  final int classId;
  final String className;

  const StudentListScreen({
    super.key,
    required this.levelId,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<UnpaidStudent> _unpaidStudents = [];
  bool _isLoading = true;
  late PaymentService _paymentService;
  late int _currentLevelId;
  late int _currentClassId;
  late String _currentClassName;
  String? selectedClass;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(locator<ApiService>());
    _currentLevelId = widget.levelId;
    _currentClassId = widget.classId;
    _currentClassName = widget.className;
    selectedClass = widget.className;
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _paymentService.getUnpaidInvoices(
        levelId: _currentLevelId,
        classId: _currentClassId,
      );
      setState(() {
        _unpaidStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      CustomToaster.toastError(context, 'Error', 'Failed to load students: $e');
    }
  }

  List<UnpaidStudent> get filteredStudents {
    return _unpaidStudents.where((student) {
      return student.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
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
        _loadStudents();
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        centerTitle: true,
        title: Text(
          _currentClassName,
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
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
                                    color: selectedClass != null ? AppColors.primaryLight : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: selectedClass != null ? AppColors.primaryLight : Colors.grey,
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
                      child: filteredStudents.isEmpty
                          ? const Center(child: Text('No outstanding payments found'))
                          : ListView.builder(
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return _buildStudentItem(context, student);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStudentItem(BuildContext context, UnpaidStudent student) {
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
          _paymentService.getClassName(student.classId) ?? 'Unknown Class',
          style: AppTextStyles.normal400(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NairaSvgIcon(color: AppColors.paymentTxtColor3),
            const SizedBox(width: 4),
            Text(
              student.totalAmount.toStringAsFixed(2),
              style: AppTextStyles.normal700(
                fontSize: 18,
                color: AppColors.paymentTxtColor3,
              ),
            ),
          ],
        ),
        onTap: () {
          if (student.invoices.length > 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentInvoiceSelectionScreen(
                  student: student,
                ),
              ),
            );
          } else if (student.invoices.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentPaymentDetailScreen(
                  student: student,
                  invoice: student.invoices.first,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/admin/payment_model.dart'; // For UnpaidStudent, etc.
// import 'package:linkschool/modules/services/admin/payment/payment_service.dart'; // For PaymentService
// import 'package:linkschool/modules/services/api/service_locator.dart';

// import '../../../services/api/api_service.dart'; // For locator
// // import 'package:linkschool/modules/admin/payment/custom_toaster.dart'; // For toasts (if needed in bottomsheet)

// class StudentListScreen extends StatefulWidget {
//   final int levelId;
//   final int classId;
//   final String className;

//   const StudentListScreen({
//     super.key,
//     required this.levelId,
//     required this.classId,
//     required this.className,
//   });

//   @override
//   State<StudentListScreen> createState() => _StudentListScreenState();
// }

// class _StudentListScreenState extends State<StudentListScreen> {
//   List<UnpaidStudent> _students = [];
//   bool _isLoading = true;
//   late PaymentService _paymentService;

//   @override
//   void initState() {
//     super.initState();
//     _paymentService = PaymentService(locator<ApiService>());
//     _loadStudents();
//   }

//   Future<void> _loadStudents() async {
//     try {
//       final unpaid = await _paymentService.getUnpaidInvoices(
//         levelId: widget.levelId,
//         classId: widget.classId,
//       );
//       setState(() {
//         _students = unpaid;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       CustomToaster.toastError(context, 'Error', 'Failed to load students: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           widget.className,
//           style: AppTextStyles.normal600(fontSize: 24.0, color: AppColors.paymentTxtColor1),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : ListView.builder(
//                 padding: const EdgeInsets.all(16.0),
//                 itemCount: _students.length,
//                 itemBuilder: (context, index) {
//                   final student = _students[index];
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 8.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       side: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.all(16.0),
//                       leading: CircleAvatar(
//                         backgroundColor: const Color.fromRGBO(47, 85, 221, 0.1),
//                         child: Text(
//                           student.name[0],
//                           style: const TextStyle(color: Color.fromRGBO(47, 85, 221, 1), fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       title: Text(
//                         student.name,
//                         style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
//                       ),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                       onTap: () {
//                         showModalBottomSheet(
//                           context: context,
//                           isScrollControlled: true,
//                           builder: (context) => AddReceiptBottomSheet(student: student),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }

// // Renamed and made stateful for payment recording
// class AddReceiptBottomSheet extends StatefulWidget {
//   final UnpaidStudent student;

//   const AddReceiptBottomSheet({super.key, required this.student});

//   @override
//   State<AddReceiptBottomSheet> createState() => _AddReceiptBottomSheetState();
// }

// class _AddReceiptBottomSheetState extends State<AddReceiptBottomSheet> {
//   late List<InvoiceDetail> _fees;
//   Set<InvoiceDetail> _selectedFees = {};
//   double _totalAmount = 0.0;
//   final TextEditingController _referenceController = TextEditingController();
//   late PaymentService _paymentService;

//   @override
//   void initState() {
//     super.initState();
//     _paymentService = PaymentService(locator<ApiService>());
//     _fees = widget.student.invoices.isNotEmpty
//         ? widget.student.invoices[0].invoiceDetails.where((d) => d.amount > 0).toList()
//         : [];
//     _selectedFees = Set.from(_fees);
//     _updateTotal();
//   }

//   void _updateTotal() {
//     _totalAmount = _selectedFees.fold(0.0, (sum, fee) => sum + fee.amount);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 16,
//         right: 16,
//         top: 16,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Add Receipt',
//                 style: AppTextStyles.normal600(fontSize: 20, color: const Color.fromRGBO(47, 85, 221, 1)),
//               ),
//               IconButton(
//                 icon: SvgPicture.asset('assets/icons/profile/cancel_receipt.svg'),
//                 color: AppColors.bgGray,
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildInputField('Student name', widget.student.name, enabled: false),
//           const SizedBox(height: 16),
//           Text('Select Fees to Pay', style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark)),
//           SizedBox(
//             height: 150, // Adjustable
//             child: ListView.builder(
//               itemCount: _fees.length,
//               itemBuilder: (context, index) {
//                 final fee = _fees[index];
//                 return CheckboxListTile(
//                   title: Text(fee.feeName),
//                   subtitle: Text('₦${fee.amount.toStringAsFixed(2)}'),
//                   value: _selectedFees.contains(fee),
//                   onChanged: (bool? value) {
//                     setState(() {
//                       if (value == true) {
//                         _selectedFees.add(fee);
//                       } else {
//                         _selectedFees.remove(fee);
//                       }
//                       _updateTotal();
//                     });
//                   },
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text('Total: ₦$_totalAmount', style: AppTextStyles.normal700(fontSize: 18, color: AppColors.paymentTxtColor1)),
//           const SizedBox(height: 16),
//           _buildInputField('Reference', 'Enter reference (optional)'),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _recordPayment,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//               ),
//               child: Text(
//                 'Record payment',
//                 style: AppTextStyles.normal500(fontSize: 18, color: AppColors.backgroundLight),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputField(String label, String hint, {bool enabled = true}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AppTextStyles.normal500(fontSize: 16.0, color: AppColors.backgroundDark)),
//         const SizedBox(height: 8),
//         TextField(
//           enabled: enabled,
//           controller: enabled ? _referenceController : TextEditingController(text: hint),
//           decoration: InputDecoration(
//             hintText: enabled ? hint : null,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _recordPayment() async {
//     if (_selectedFees.isEmpty) {
//       CustomToaster.toastWarning(context, 'Warning', 'Select at least one fee');
//       return;
//     }

//     String reference = _referenceController.text.trim();
//     if (reference.isEmpty) {
//       reference = 'REF${DateTime.now().millisecondsSinceEpoch}';
//     }

//     final invoice = widget.student.invoices[0];

//     try {
//       final success = await _paymentService.makePayment(
//         invoiceId: invoice.id.toString(),
//         reference: reference,
//         studentId: widget.student.studentId,
//         regNo: widget.student.regNo,
//         name: widget.student.name,
//         fees: _selectedFees.toList(),
//         amount: _totalAmount,
//         classId: widget.student.classId,
//         levelId: widget.student.levelId,
//         year: invoice.year,
//         term: invoice.term,
//       );
//       if (success) {
//         CustomToaster.toastSuccess(context, 'Success', 'Payment recorded successfully');
//         Navigator.pop(context);
//         // Optionally refresh student list by popping to previous and reloading
//       }
//     } catch (e) {
//       CustomToaster.toastError(context, 'Error', 'Failed to record payment: $e');
//     }
//   }
// }