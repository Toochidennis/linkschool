import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_register/button_section.dart';
import 'package:linkschool/modules/common/widgets/portal/result_register/history_section.dart';
import 'package:linkschool/modules/common/widgets/portal/result_register/top_container.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/admin/term_provider.dart';

class RegistrationScreen extends StatefulWidget {
  final String classId;
  final String className;
  const RegistrationScreen({super.key, required this.classId, required this.className});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with RouteAware {
  final ApiService _apiService = locator<ApiService>();
  final AuthProvider _authProvider = locator<AuthProvider>();
  String _selectedTerm = 'First term';

  // RouteObserver to track navigation
  final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

  @override
  void initState() {
    super.initState();
    // Ensure the auth token is set
    if (_authProvider.token != null) {
      _apiService.setAuthToken(_authProvider.token!);
    }

    // Set initial term based on server data
    _setInitialTerm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the route observer
    final ModalRoute? route = ModalRoute.of(context);
    if (route is ModalRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when the screen is revisited (popped back to)
    _refreshData();
  }

  @override
  void dispose() {
    // Unsubscribe from the route observer
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _setInitialTerm() {
    final settings = _authProvider.getSettings();
    final termNumber = settings['term'] ?? 1;

    setState(() {
      _selectedTerm = termNumber == 1
          ? 'First term'
          : termNumber == 2
              ? 'Second term'
              : 'Third term';
    });
  }

  // Method to handle pull-to-refresh and navigation refresh
  Future<void> _refreshData() async {
    try {
      // Refresh term selection
      _setInitialTerm();

      // Refresh TermProvider data for HistorySection
      final termProvider = Provider.of<TermProvider>(context, listen: false);
      await termProvider
          .fetchTerms(widget.classId); // Assuming TermProvider has fetchTerms

      // TopContainer will automatically refresh via FutureBuilder
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registration',
          style: AppTextStyles.normal600(
              fontSize: 18.0, color: AppColors.primaryLight),
        ),
        centerTitle: true,
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
        backgroundColor: AppColors.backgroundLight,
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              TopContainer(
                className: widget.className,
                selectedTerm: _selectedTerm,
                onTermChanged: (newValue) {
                  setState(() {
                    _selectedTerm = newValue!;
                  });
                },
                classId: widget.classId,
                apiService: _apiService,
                authProvider: _authProvider,
              ),
              ButtonSection(classId: widget.classId),
              const SizedBox(height: 25),
              HistorySection(classId: widget.classId),
            ],
          ),
        ),
      ),
    );
  }
}
