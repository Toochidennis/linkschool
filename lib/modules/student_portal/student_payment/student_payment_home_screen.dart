import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/student_portal/home_screen/new_post_dialog.dart';
import 'package:linkschool/modules/student_portal/student_payment/student_setting_dialog.dart';

class StudentPaymentHomeScreen extends StatefulWidget {
  final VoidCallback logout;
  

  const StudentPaymentHomeScreen({
    Key? key,
    required this.logout,
  }) : super(key: key);

  @override
  _StudentPaymentHomeScreenState createState() =>
      _StudentPaymentHomeScreenState();
}

class _StudentPaymentHomeScreenState extends State<StudentPaymentHomeScreen> {
  int _currentCardIndex = 0;
    bool _isAmountHidden = false;
    late double opacity;

  final List<Map<String, dynamic>> _cards = [
    {
      'term': '2017/2018 First Term Fees',
      'amount': '534,790.00',
    },
    {
      'term': '2019/2020 Second Term Fees',
      'amount': '534,790.00',
    },
  ];

  final List<Map<String, dynamic>> _paymentHistory = [
    {
      'term': '2017/2018 Second Term Fees',
      'date': '2022-05-24',
      'amount': '23,790.00',
      'status': 'Paid',
      'icon': 'assets/icons/e_learning/receipt_list_icon.svg',
    },
    {
      'term': '2016/2017 Third Term Fees',
      'date': '2022-05-24',
      'amount': '23,790.00',
      'status': 'Paid',
      'icon': 'assets/icons/e_learning/receipt_list_icon.svg',
    },
    {
      'term': '2016/2017 Third Term Fees',
      'date': '2022-05-24',
      'amount': '23,790.00',
      'status': 'Paid',
      'icon': 'assets/icons/e_learning/receipt_list_icon.svg',
    },
    {
      'term': '2016/2017 Third Term Fees',
      'date': '2022-05-24',
      'amount': '23,790.00',
      'status': 'Paid',
      'icon': 'assets/icons/e_learning/receipt_list_icon.svg',
    },
      {
      'term': '2016/2017 Third Term Fees',
      'date': '2022-05-24',
      'amount': '23,790.00',
      'status': 'Paid',
      'icon': 'assets/icons/e_learning/receipt_list_icon.svg',
    },
      {
      'term': '2016/2017 Third Term Fees',
      'date': '2022-05-24',
      'amount': '23,790.00',
      'status': 'Paid',
      'icon': 'assets/icons/e_learning/receipt_list_icon.svg',
    },
      {
      'term': '2016/2017 Third Term Fees',
      'date': '2022-05-24',
      'amount': '23,790.00',
      'status': 'Paid',
      'icon': 'assets/icons/e_learning/receipt_list_icon.svg',
    },
  ];

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewPostDialog();
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudentSettingDialog(logout: widget.logout);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: 'Tochukwu',
        showNotification: true,
        showSettings: true,
        showPostInput: true,
        onNotificationTap: () {},
        onSettingsTap: _showSettingsDialog,
        onPostTap: _showNewPostDialog,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 150,
                  viewportFraction: 0.93,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCardIndex = index;
                    });
                  },
                ),
                items: _cards.map((card) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                          height: 130,
                          decoration: BoxDecoration(
                            color: AppColors.eLearningBtnColor1,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          card['term'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                          IconButton(
                                            icon: Icon(
                                              _isAmountHidden
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isAmountHidden = !_isAmountHidden;
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                      Container(
                                        padding:  const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              198, 210, 255, 1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child:  Text('Pay Now', style: AppTextStyles.normal500(fontSize: 12, color: AppColors.paymentTxtColor1),),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Row(
                                    children: [
                                      const NairaSvgIcon(color: AppColors.backgroundLight),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isAmountHidden ? '********' : '${card['amount']}',
                                        style: AppTextStyles.normal700(fontSize: 24, color: AppColors.backgroundLight),
                                      ),
                                    ],
                                  ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'View Details',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _cards.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentCardIndex == entry.key
                          ? const Color(0xFF2196F3)
                          : Colors.grey.shade300,
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _paymentHistory.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final payment = _paymentHistory[index];
                    return PaymentHistoryItem(payment: payment);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentHistoryItem extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentHistoryItem({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.paymentBtnColor1,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(payment['icon'],
              width: 24, height: 24, color: Colors.white),
        ),
      ),
      title: Text(
        payment['term'],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        payment['date'],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₦${payment['amount']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            payment['status'],
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}