import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/model/student/payment_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class StudentRecieptDialog extends StatefulWidget {
  final Payment payment;

  const StudentRecieptDialog({
    super.key,
    required this.payment,
  });

  @override
  State<StudentRecieptDialog> createState() => _StudentRecieptDialogState();
}

class _StudentRecieptDialogState extends State<StudentRecieptDialog> {
  final GlobalKey _receiptKey = GlobalKey(); // 👈 for snapshot capture
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Capture receipt widget as PDF
  Future<Uint8List?> _generateReceiptPdf() async {
    try {
      RenderRepaintBoundary boundary =
          _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0); // high quality
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Center(
            child: pw.Image(pdfImage),
          ),
        ),
      );

      return pdf.save();
    } catch (e) {
      debugPrint("Error generating receipt PDF: $e");
      return null;
    }
  }

  /// Handle Share / Download
  Future<void> _handleReceiptAction({required bool isShare}) async {
    final pdfData = await _generateReceiptPdf();
    if (pdfData == null) return;

    if (isShare) {
      await Printing.sharePdf(
        bytes: pdfData,
        filename: 'receipt_${widget.payment.reference}.pdf',
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfData,
        name: 'receipt_${widget.payment.reference}.pdf',
      );
      
      // Show success message after download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt downloaded successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(1, 248, 248, 248),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: const Color(0xFF1565C0),
            width: 28,
            height: 28,
          ),
        ),
        title: const Text(
          'Payment Receipt',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(1, 248, 248, 248),
        padding: const EdgeInsets.only(bottom: 190),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 👈 Move RepaintBoundary to wrap only the content to be captured
                    RepaintBoundary(
                      key: _receiptKey,
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 175, 235, 191),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 36, color: Color(0xFF32A852)),
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (context) {
                              String schoolName = "School Name";
                              try {
                                final userBox = Hive.box('userData');
                                final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
                                final processedData = storedUserData is String ? json.decode(storedUserData) : storedUserData;
                                final response = processedData['response'] ?? processedData;
                                final data = response['data'] ?? response;
                                final settings = data['settings'] ?? data;
                                schoolName = settings['school_name']?.toString() ?? "School Name";
                              } catch (e) {}
                              return Text(
                                schoolName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.payment.termName} Fees Receipt',
                            style: AppTextStyles.normal500(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const NairaSvgIcon(color: Color(0xFF2F55DD), 
                              width: 16,
                              // size: 25 
                              ),
                              Text(
                                _formatAmount(widget.payment.amount),
                                style: AppTextStyles.normal700(
                                  fontSize: 24,
                                  color: Color(0xFF2F55DD),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Successful',
                            style: AppTextStyles.normal400(
                              fontSize: 13,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const DottedLine(
                            dashLength: 6,
                            dashGapLength: 4,
                            lineThickness: 1,
                            dashColor: Color(0xFFE6E6E6),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow('Date', _formatDate(widget.payment.date)),
                          _buildDetailRow('Name', widget.payment.name),
                          _buildDetailRow('Class', widget.payment.levelName),
                          _buildDetailRow('Registration number', widget.payment.regNo),
                          _buildDetailRow('Session', widget.payment.year),
                          _buildDetailRow('Term', '${widget.payment.termName} Fees'),
                          _buildDetailRow('Reference number', widget.payment.reference),
                          const SizedBox(height: 18),
                          const DottedLine(
                            dashLength: 6,
                            dashGapLength: 4,
                            lineThickness: 1,
                            dashColor: Color(0xFFE6E6E6),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                    // 👇 These buttons are now outside the RepaintBoundary
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleReceiptAction(isShare: true),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2F55DD)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Share',
                              style: AppTextStyles.normal500(
                                  fontSize: 16, color: const Color(0xFF2F55DD)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleReceiptAction(isShare: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F55DD),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Download',
                              style: AppTextStyles.normal500(
                                  fontSize: 16, color: AppColors.backgroundLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.normal400(
                  fontSize: 14.0, color: AppColors.textGray)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  AppTextStyles.normal600(fontSize: 14.0, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}