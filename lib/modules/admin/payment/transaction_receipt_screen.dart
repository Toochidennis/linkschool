import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/widgets/portal/profile/naira_icon.dart';
import '../../model/admin/payment_model.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Receipt',
          style: AppTextStyles.normal600(
            fontSize: 18,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Receipt Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Success Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Receipt Title
                    Text(
                      _getReceiptTitle(),
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const NairaSvgIcon(
                          color: AppColors.paymentTxtColor1,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatAmount(transaction.amount),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: transaction.type == 'receipts' 
                                ? AppColors.paymentTxtColor1 
                                : const Color(0xFFFF5722),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Status
                    Text(
                      transaction.type == 'receipts' ? 'Successful' : 'Paid',
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: Colors.grey[600]!,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Dashed line
                    CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DashedLinePainter(),
                    ),
                    const SizedBox(height: 32),
                    
                    // Receipt Details
                    _buildReceiptRow('Date', _formatDate(transaction.date)),
                    const SizedBox(height: 20),
                    
                    _buildReceiptRow('Name', transaction.name),
                    const SizedBox(height: 20),
                    
                    _buildReceiptRow('Class', transaction.levelName),
                    const SizedBox(height: 20),
                    
                    _buildReceiptRow('Registration number', transaction.regNo),
                    const SizedBox(height: 20),
                    
                    _buildReceiptRow('Session', _getSessionText()),
                    const SizedBox(height: 20),
                    
                    _buildReceiptRow('Term', _getTermText()),
                    const SizedBox(height: 20),
                    
                    _buildReceiptRow('Reference number', transaction.reference),
                    const SizedBox(height: 32),
                    
                    // Bottom dashed line
                    CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DashedLinePainter(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Buttons (if needed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Handle share functionality
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.paymentTxtColor1,
                        side: const BorderSide(color: AppColors.paymentTxtColor1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle download functionality
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.paymentTxtColor1,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.normal500(
              fontSize: 14,
              color: Colors.grey[600]!,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.normal600(
              fontSize: 14,
              color: Colors.black,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _getReceiptTitle() {
    if (transaction.type == 'receipts') {
      switch (transaction.term) {
        case 1:
          return 'First Term Fees Receipt';
        case 2:
          return 'Second Term Fees Receipt';
        case 3:
          return 'Third Term Fees Receipt';
        default:
          return 'School Fees Receipt';
      }
    } else {
      return 'Expenditure Receipt';
    }
  }

  String _getTermText() {
    switch (transaction.term) {
      case 1:
        return 'First Term Fees';
      case 2:
        return 'Second Term Fees';
      case 3:
        return 'Third Term Fees';
      default:
        return 'Term Fees';
    }
  }

  String _getSessionText() {
    try {
      int year = int.parse(transaction.year);
      return '${year - 1}/${transaction.year}';
    } catch (e) {
      return transaction.year;
    }
  }

  String _formatAmount(double amount) {
    return amount.abs().toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      String day = date.day.toString().padLeft(2, '0');
      String month = months[date.month];
      String year = date.year.toString();
      
      return '$day-$month-$year';
    } catch (e) {
      return dateString;
    }
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}