import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/text_styles.dart';
import '../../../common/widgets/portal/profile/naira_icon.dart';
import '../../../model/admin/payment_models.dart';
import '../../../services/admin/payment/payment_service.dart';
import '../../../services/api/api_service.dart';
import 'student_payment_detail_screen.dart';
import 'student_invoice_selection_screen.dart';


class PaymentOutstandingScreen extends StatefulWidget {
  final int levelId;
  final int classId;
  final String levelName;
  final String className;

  const PaymentOutstandingScreen({
    super.key,
    required this.levelId,
    required this.classId,
    required this.levelName,
    required this.className,
  });

  @override
  State<PaymentOutstandingScreen> createState() => _PaymentOutstandingScreenState();
}

class _PaymentOutstandingScreenState extends State<PaymentOutstandingScreen> {
  late double opacity;
  String? selectedClass;
  String searchQuery = '';
  List<UnpaidStudent> _unpaidStudents = [];
  bool _isLoading = true;
  late PaymentService _paymentService;
  late int _currentLevelId;
  late int _currentClassId;
  late String _currentClassName;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _currentLevelId = widget.levelId;
    _currentClassId = widget.classId;
    _currentClassName = widget.className;
    selectedClass = widget.className;
    _loadUnpaidInvoices();
  }

  void _initializeServices() {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      
      if (token == null || token.toString().isEmpty) {
        print('No authentication token found. User needs to login again.');
        return;
      }
      
      final apiService = ApiService();
      apiService.setAuthToken(token.toString());
      _paymentService = PaymentService(apiService);
      
      print('ApiService initialized with authentication token');
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  Future<void> _loadUnpaidInvoices() async {
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
      print('Error loading unpaid invoices: $e');
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
        _loadUnpaidInvoices();
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
          'Outstanding',
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
            // Navigate to invoice selection screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentInvoiceSelectionScreen(
                  student: student,
                ),
              ),
            );
          } else if (student.invoices.isNotEmpty) {
            // Navigate directly to payment detail screen
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
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
// import 'package:linkschool/modules/model/profile/student_model.dart';
// import 'package:linkschool/modules/admin/payment/receipt/student_payment_detail_screen.dart';


// class PaymentOutstandingScreen extends StatefulWidget {
//   const PaymentOutstandingScreen({
//     super.key,
//   });

//   @override
//   State<PaymentOutstandingScreen> createState() =>
//       _PaymentOutstandingScreenState();
// }

// class _PaymentOutstandingScreenState extends State<PaymentOutstandingScreen> {
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
//           'Outstanding',
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
//             NairaSvgIcon(color: AppColors.paymentTxtColor3),
//             const SizedBox(width: 4),
//             Text(
//               amountValue,
//               style: AppTextStyles.normal700(
//                 fontSize: 18,
//                 color: AppColors.paymentTxtColor3,
//               ),
//             ),
//           ],
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   StudentPaymentDetailsScreen(student: student, ),
//             ),
//           );
//         },
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
