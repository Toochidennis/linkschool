import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/info_card.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/take_attendance_button.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/admin/result/class_detail/attendance/attendance_history.dart';
import 'package:linkschool/modules/model/admin/attendance_record_model.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatefulWidget {
  final String className;
  final String classId;

  const AttendanceScreen({
    super.key,
    required this.className,
    required this.classId,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  String _searchQuery = '';

  // Layout constants
  static const double _headerHeightRatio = 0.20;
  static const double _headerTranslateRatio = 0.15;
  static const double _horizontalPadding = 20.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _fetchAttendanceHistory());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      final attendanceProvider = locator<AttendanceProvider>();
      final authProvider = locator<AuthProvider>();

      final userBox = Hive.box('userData');
      final userData = userBox.get('userData') as Map<dynamic, dynamic>?;
      final dbName = userData?['_db']?.toString() ?? '';

      if (dbName.isEmpty) {
        throw Exception('Database name not found in user data');
      }

      final settings = authProvider.settings ?? authProvider.getSettings();

      final term = settings['term']?.toString() ?? '';
      final year = settings['year']?.toString() ?? '';

      if (term.isEmpty || year.isEmpty) {
        throw Exception('Term or year not configured');
      }

      await attendanceProvider.fetchAttendanceHistory(
        classId: widget.classId,
        term: term,
        year: year,
        dbName: dbName,
      );
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  List<AttendanceRecord> _getFilteredRecords(List<AttendanceRecord> records) {
    if (_searchQuery.isEmpty) return records;

    final provider = locator<AttendanceProvider>();

    return records.where((record) {
      final formattedDate = provider.formatDate(record.date).toLowerCase();
      final courseName = record.courseName.isEmpty
          ? 'general'
          : record.courseName.toLowerCase();

      final dayName = _getDayName(record.date).toLowerCase();
      final shortDay = _getShortDayName(record.date);

      final nameMatch = courseName.contains(_searchQuery);
      final dateMatch = formattedDate.contains(_searchQuery);
      final countMatch = record.count.toString().contains(_searchQuery);
      final dayMatch =
          dayName.contains(_searchQuery) || shortDay.contains(_searchQuery);

      return nameMatch || dateMatch || countMatch || dayMatch;
    }).toList();
  }

  String _getDayName(DateTime date) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[date.weekday - 1];
  }

  String _getShortDayName(DateTime date) {
    return _getDayName(date).substring(0, 3);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _fetchAttendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: locator<AttendanceProvider>(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: Consumer<AttendanceProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty) {
      return _buildError(provider.error);
    }

    final filteredRecords =
        _getFilteredRecords(provider.attendanceRecords);

    // ALWAYS show the content (InfoCard + TakeAttendanceButton)
    // Empty state will be shown in the history section only
    if (!_isSearching || _searchQuery.isEmpty) {
      return _buildContent(filteredRecords);
    }

    // When searching, show empty state in background
    return const SizedBox.shrink();
  },
),
            ),
            // Search results overlay
            if (_isSearching && _searchQuery.isNotEmpty) _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      title: !_isSearching
          ? Text(
              'Attendance',
              style: AppTextStyles.normal600(
                fontSize: 20,
                color: AppColors.backgroundLight,
              ),
            )
          : TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search attendance history...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
      leading: IconButton(
        icon: Image.asset(
          'assets/icons/arrow_back.png',
          color: AppColors.backgroundLight,
          width: 30,
          height: 30,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: SvgPicture.asset(
            _isSearching
                ? 'assets/icons/close.svg'
                : 'assets/icons/result/search.svg',
            color: AppColors.backgroundLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        final filteredRecords = _getFilteredRecords(provider.attendanceRecords);

        return Container(
          color: Colors.grey[200],
          child: Column(
            children: [
              // Search results header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredRecords.length} result${filteredRecords.length == 1 ? '' : 's'} found',
                      style: AppTextStyles.normal600(fontSize: 14),
                    ),
                    if (filteredRecords.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              // Search results list
              Expanded(
                child: filteredRecords.isEmpty
                    ? _buildEmpty(false)
                    : Container(
                        color: Colors.white,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredRecords.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey[300]),
                          itemBuilder: (context, index) =>
                              _buildHistoryItem(filteredRecords[index]),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(List<AttendanceRecord> filteredRecords) {
  final screenHeight = MediaQuery.of(context).size.height;

  return SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Column(
      children: [
        Container(
          height: screenHeight * _headerHeightRatio,
          decoration: const BoxDecoration(
            color: AppColors.paymentTxtColor1,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -screenHeight * _headerTranslateRatio),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  className: widget.className,
                  classId: widget.classId,
                ),
                const SizedBox(height: 20),
                TakeAttendanceButton(classId: widget.classId),
                const SizedBox(height: 30),
                _buildHistorySection(filteredRecords),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHistorySection(List<AttendanceRecord> records) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Attendance History',
        style: AppTextStyles.normal600(fontSize: 18),
      ),
      const SizedBox(height: 12),
      
      // Show empty state here if no records
      if (records.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No attendance records yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take attendance using the button above',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        )
      else
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Colors.grey[300]),
          itemBuilder: (context, index) => _buildHistoryItem(records[index]),
        ),
    ],
  );
}

  Widget _buildHistoryItem(AttendanceRecord record) {
    final provider = locator<AttendanceProvider>();
    final formattedDate = provider.formatDate(record.date);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      ),
      title: Text(
        formattedDate,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Subject: ${record.courseName}, Count: ${record.count}',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _navigateToHistory(formattedDate, record.id.toString()),
    );
  }

  void _navigateToHistory(String date, String attendanceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceHistoryScreen(
          date: date,
          attendanceId: attendanceId,
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isActuallyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActuallyEmpty ? Icons.history : Icons.search_off,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              isActuallyEmpty
                  ? 'No attendance records found'
                  : 'No results match your search',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            if (!isActuallyEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 10),
            const Text(
              'Error loading attendance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchAttendanceHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
