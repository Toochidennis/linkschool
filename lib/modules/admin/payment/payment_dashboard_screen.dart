import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/admin/payment/transaction_receipt_screen.dart';
import 'package:linkschool/modules/admin/payment/widget/transaction_history_screen.dart';

import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/widgets/portal/profile/naira_icon.dart';
import '../../common/widgets/portal/student/student_customized_appbar.dart';
import '../../model/admin/payment_model.dart';
import '../../services/admin/payment/payment_service.dart';
import '../../services/api/api_service.dart';
import 'expenditure/expenditure_screen.dart';
import 'receipt/payment_outstanding_screen.dart';
import 'receipt/payment_received_screen.dart';
import 'receipt/receipt_screen.dart' hide Level, ClassModel;
import 'settings/payment_setting_screen.dart';

class PaymentDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const PaymentDashboardScreen({super.key, required this.onLogout});

  @override
  State<PaymentDashboardScreen> createState() => _PaymentDashboardScreenState();
}

class _PaymentDashboardScreenState extends State<PaymentDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  late double opacity;
  bool _hideAmounts = false;
  PaymentDashboardSummary? _dashboardData;
  bool _isLoading = true;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Animations will start after dashboard data is loaded
    _initializeServices();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');

      if (token == null || token.toString().isEmpty) {
        print('No authentication token found. User needs to login again.');
        // Optionally redirect to login screen
        return;
      }

      final apiService = ApiService();
      apiService.setAuthToken(token.toString());
      _paymentService = PaymentService(apiService);

      print('ApiService initialized with authentication token');
    } catch (e) {
      print('Error initializing services: $e');
      // Handle error - maybe show error dialog or redirect to login
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _paymentService.getDashboardSummary();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
      // Start entrance animations after successful data load
      _runEntranceAnimations();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading dashboard data: $e');
    }
  }

  void _runEntranceAnimations() {
    if (!mounted) return;
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bounceController.forward();
    });
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    // Calculate interval with proper bounds
    final double intervalStart = (index * 0.05).clamp(0.0, 0.8);
    final double intervalEnd = (intervalStart + 0.2).clamp(0.2, 1.0);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3 + (index * 0.05).clamp(0.0, 0.5)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                intervalStart,
                intervalEnd,
                curve: Curves.elasticOut,
              ),
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 800 + (index * 200)),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            icon,
                            size: 24,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    CustomStudentAppBar customAppBar = CustomStudentAppBar(
      title: 'Revenue',
      showNotification: false,
      showSettings: true,
      centerTitle: false,
      onNotificationTap: () {
        // Handle notification icon press
      },
      onSettingsTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PaymentSettingScreen(onLogout: widget.onLogout)),
        );
      },
    );

    return Scaffold(
      appBar: customAppBar,
      body: SafeArea(
        child: Container(
         color: Colors.white,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedCard(
                          index: 0,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(58, 49, 145, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _hideAmounts = !_hideAmounts;
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _hideAmounts
                                                ? Icons.visibility_off
                                                : Icons.remove_red_eye,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _hideAmounts
                                                ? 'Show all'
                                                : 'Hide all',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Expected Revenue',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            if (!_hideAmounts) ...[
                                              const NairaSvgIcon(
                                                color: AppColors.backgroundLight,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _dashboardData?.invoiced
                                                        .toStringAsFixed(2) ??
                                                    '0.00',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ] else ...[
                                              const Text('****',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoContainer(
                                        'Received',
                                        _dashboardData?.income
                                                .toStringAsFixed(2) ??
                                            '0.00',
                                        () => _showLevelSelectionForReceived(),
                                      ),
                                      _buildInfoContainer(
                                        'Outstanding',
                                        _dashboardData?.outstanding
                                                .toStringAsFixed(2) ??
                                            '0.00',
                                        () => _showLevelSelectionForOutstanding(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Second section
                        _buildAnimatedCard(
                          index: 1,
                          child: Text('Records',
                              style: AppTextStyles.normal600(
                                  fontSize: 18, color: AppColors.backgroundDark)),
                        ),
                        const SizedBox(height: 10),
                        _buildAnimatedCard(
                          index: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildRecordContainer(
                                'Receipt',
                                'assets/icons/e_learning/receipt_icon.svg',
                                const Color.fromRGBO(45, 99, 255, 1),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ReceiptScreen()),
                                  );
                                },
                              ),
                              _buildRecordContainer(
                                'Expenditure',
                                'assets/icons/e_learning/expenditure_icon.svg',
                                const Color.fromRGBO(30, 136, 229, 1),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ExpenditureScreen()),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAnimatedCard(
                          index: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Transaction History',
                                  style: AppTextStyles.normal600(
                                      fontSize: 18,
                                      color: AppColors.backgroundDark)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionHistoryScreen(
                                        transactions:
                                            _dashboardData?.transactions ?? [],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'See all',
                                  style: TextStyle(
                                    color: AppColors.paymentTxtColor1,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_dashboardData?.transactions.isNotEmpty == true)
                          ..._dashboardData!.transactions.take(10).map(
                                (transaction) => _buildAnimatedCard(
                                  index: 4,
                                  child: _buildTransactionItem(
                                    transaction.name,
                                    transaction.date,
                                    transaction.amount,
                                    transaction.levelName,
                                    transaction, // transaction object
                                  ),
                                ),
                              )
                        else
                          _buildAnimatedCard(
                            index: 4,
                            child: const Center(
                              child: Text('No transactions available'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _showLevelSelectionForReceived() {
    final levels = _paymentService.getAvailableLevels();

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
                    'Select Level',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: const Color.fromRGBO(47, 85, 221, 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: ListView.builder(
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: _buildLevelButton(level, true),
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

  void _showLevelSelectionForOutstanding() {
    final levels = _paymentService.getAvailableLevels();

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
                    'Select Level',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: const Color.fromRGBO(47, 85, 221, 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: ListView.builder(
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: _buildLevelButton(level, false),
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

  Widget _buildLevelButton(Level level, bool isForReceived) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showClassSelectionForLevel(level, isForReceived);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(47, 85, 221, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          level.levelName,
          style: AppTextStyles.normal500(
            fontSize: 18,
            color: AppColors.backgroundLight,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showClassSelectionForLevel(Level level, bool isForReceived) {
    final classes = _paymentService.getClassesForLevel(level.id);

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: _buildClassButton(
                              classModel, level, isForReceived),
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

  Widget _buildClassButton(
      ClassModel classModel, Level level, bool isForReceived) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (isForReceived) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentReceivedScreen(
                levelId: level.id,
                classId: classModel.id,
                levelName: level.levelName,
                className: classModel.className,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentOutstandingScreen(
                levelId: level.id,
                classId: classModel.id,
                levelName: level.levelName,
                className: classModel.className,
              ),
            ),
          );
        }
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

  Widget _buildInfoContainer(String title, String value, VoidCallback onTap) {
    bool isOutstanding = title == 'Outstanding';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.paymentCtnColor1,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              isOutstanding ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(title,
                  style: AppTextStyles.normal600(
                      fontSize: 12, color: AppColors.assessmentColor1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: title == 'Received'
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  if (!_hideAmounts) ...[
                    const NairaSvgIcon(color: AppColors.backgroundLight),
                    const SizedBox(width: 4),
                    Text(value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ] else ...[
                    const Text('****',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordContainer(String title, String iconPath,
      Color backgroundColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 75,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath,
                width: 36, height: 36, color: Colors.white),
            const SizedBox(height: 4),
            Text(title,
                style: AppTextStyles.normal600(
                    fontSize: 14, color: AppColors.backgroundLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String name, String time, double amount,
      String grade, Transaction transaction) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionReceiptScreen(transaction: transaction),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.paymentBtnColor1,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                        'assets/icons/e_learning/receipt_list_icon.svg',
                        width: 24,
                        height: 24,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: AppTextStyles.normal600(
                              fontSize: 16, color: AppColors.backgroundDark)),
                      Text(time,
                          style: AppTextStyles.normal500(
                              fontSize: 12, color: AppColors.text10Light)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          amount >= 0 ? '+' : '-',
                          style: AppTextStyles.normal700(
                              fontSize: 16,
                              color: amount >= 0
                                  ? AppColors.paymentTxtColor4
                                  : AppColors.paymentTxtColor3),
                        ),
                        const SizedBox(width: 4),
                        NairaSvgIcon(
                            color: amount >= 0 ? Colors.green : Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          amount.abs().toStringAsFixed(2),
                          style: TextStyle(
                            color: amount >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      grade,
                      style: AppTextStyles.normal500(
                          fontSize: 12, color: AppColors.paymentTxtColor1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
