import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/profile/expenditure/expense_download_receipt_screen.dart';
import 'package:linkschool/modules/portal/profile/expenditure/expense_share_reciept_screen.dart';

class ExpenseTransactionDetail extends StatefulWidget {
  final String amount;

  const ExpenseTransactionDetail({Key? key, required this.amount})
      : super(key: key);

  @override
  State<ExpenseTransactionDetail> createState() =>
      _ExpenseTransactionDetailState();
}

class _ExpenseTransactionDetailState extends State<ExpenseTransactionDetail> {
  late double opacity;
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
          'Transaction Details',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        centerTitle: true,
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
              _buildFirstCard(),
              const SizedBox(height: 16),
              _buildSecondCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showShareReciept(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: const Color.fromRGBO(47, 85, 221, 1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Share',
                        style: AppTextStyles.normal500(
                          fontSize: 18,
                          color: const Color.fromRGBO(47, 85, 221, 1),
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDownloadReciept(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Download',
                        style: AppTextStyles.normal500(
                            fontSize: 16.0, color: AppColors.backgroundLight)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstCard() {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              SvgPicture.asset('assets/icons/profile/rounded_success_icon.svg'),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'Expenditure',
                style: AppTextStyles.normal400(
                    fontSize: 14, color: AppColors.backgroundDark),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                widget.amount,
                style: AppTextStyles.normal700(
                    fontSize: 26, color: AppColors.paymentTxtColor1),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text('Successful',
                  style: AppTextStyles.normal600(
                      fontSize: 18, color: AppColors.eLearningContColor3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Date', '2023-10-23'),
            _buildDetailRow('Name', 'John Doe'),
            _buildDetailRow('Phone Number', '08012345679'),
            _buildDetailRow('Session', '2022/2023'),
            _buildDetailRow('Reference No', 'ABC123XYZ'),
            _buildDetailRow('Description', 'Clinical medication'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  void _showShareReciept() async {
   await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => ExpenseShareRecieptScreen(amount: '23,790.00'),
      ),
    );

  }

  void _showDownloadReciept() async {
   await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => ExpenseDownloadReceiptScreen(amount: '23,790.00'),
      ),
    );

  }
}
