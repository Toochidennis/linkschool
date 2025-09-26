import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/text_styles.dart';
import '../../../common/widgets/portal/profile/naira_icon.dart';
import '../../../model/admin/payment_model.dart';
import '../../../services/admin/payment/payment_service.dart';
import '../../../services/api/api_service.dart';
import 'student_payment_detail_screen.dart';


class StudentInvoiceSelectionScreen extends StatefulWidget {
  final UnpaidStudent student;

  const StudentInvoiceSelectionScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentInvoiceSelectionScreen> createState() => _StudentInvoiceSelectionScreenState();
}

class _StudentInvoiceSelectionScreenState extends State<StudentInvoiceSelectionScreen> {
  late double opacity;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
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
          'Select Invoice',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/profile/payment_icon.svg',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                          Text(
                            'Reg No: ${widget.student.regNo}',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                          ),
                          Text(
                            _paymentService.getClassName(widget.student.classId) ?? 'Unknown Class',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Outstanding Invoices',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.backgroundDark,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.student.invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = widget.student.invoices[index];
                    return _buildInvoiceItem(context, invoice);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(BuildContext context, UnpaidInvoice invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(47, 85, 221, 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/e_learning/receipt_icon.svg',
              width: 24,
              height: 24,
              color: const Color.fromRGBO(47, 85, 221, 1),
            ),
          ),
        ),
        title: Text(
          '${invoice.year} - Term ${invoice.term}',
          style: AppTextStyles.normal600(
            fontSize: 16,
            color: AppColors.backgroundDark,
          ),
        ),
        subtitle: Text(
          invoice.sessionText,
          style: AppTextStyles.normal400(
            fontSize: 14,
            color: Colors.grey[600]!,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NairaSvgIcon(color: AppColors.paymentTxtColor3),
                const SizedBox(width: 4),
                Text(
                  invoice.totalAmount.toStringAsFixed(2),
                  style: AppTextStyles.normal700(
                    fontSize: 16,
                    color: AppColors.paymentTxtColor3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${invoice.invoiceDetails.where((d) => d.amount > 0).length} fees',
              style: AppTextStyles.normal400(
                fontSize: 12,
                color: Colors.grey[600]!,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentPaymentDetailScreen(
                student: widget.student,
                invoice: invoice,
              ),
            ),
          );
        },
      ),
    );
  }
}

