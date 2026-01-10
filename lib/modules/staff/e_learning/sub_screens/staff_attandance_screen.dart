import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/info_card.dart';
import 'package:linkschool/modules/staff/home/staff_take_attandance_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_class_attendance_screen.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_list.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_header.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/model/admin/attendance_record_model.dart';
import 'package:linkschool/modules/admin/result/class_detail/attendance/attendance_history.dart';
import 'package:provider/provider.dart';

class StaffAttendanceScreen extends StatefulWidget {
  final String classId;
  final String? courseId;
  final String className;
  final String? courseName;
  final bool isFromFormClasses;

  const StaffAttendanceScreen({
    super.key,
    required this.classId,
    required this.className,
    this.courseId,
    this.courseName,
    this.isFromFormClasses = false,
  });

  @override
  State<StaffAttendanceScreen> createState() => _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends State<StaffAttendanceScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  String _searchQuery = '';

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

  Future<void> _fetchAttendanceHistory() async {
    try {
      final attendanceProvider = _attendanceProvider;
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

  Future<void> _handleRefresh() async {
    await _fetchAttendanceHistory();
  }

  List<AttendanceRecord> _getFilteredRecords(List<AttendanceRecord> records) {
    if (_searchQuery.isEmpty) return records;

    final provider = _attendanceProvider;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                // Show full content when not searching
                if (!_isSearching || _searchQuery.isEmpty) {
                  if (provider.attendanceRecords.isEmpty) {
                    return _buildEmpty(true);
                  }
                  return _buildContent();
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
    );
  }

  AttendanceProvider get _attendanceProvider => locator<AttendanceProvider>();

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.paymentTxtColor1,
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
                hintText: 'Search attendance...',
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

  Widget _buildContent() {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: screenHeight * 0.20,
            decoration: const BoxDecoration(
              color: AppColors.paymentTxtColor1,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -screenHeight * 0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    // key: ValueKey('info_card_$_refreshCounter'),
                    className: widget.className,
                    classId: widget.classId,
                  ),
                  const SizedBox(height: 20),
                  CustomLongElevatedButton(
                    text: 'Take Attendance',
                    onPressed: () => _showTakeAttendanceDialog(context),
                    backgroundColor: AppColors.videoColor4,
                    textStyle: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AttendanceHistoryHeader(),
                  const SizedBox(height: 12),
                  AttendanceHistoryList(
                    onRefresh: _handleRefresh,
                    classId: widget.classId,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(AttendanceRecord record) {
    final provider = _attendanceProvider;
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

  // Reuse your modal + course logic
  void _showTakeAttendanceDialog(BuildContext context) {
    if (widget.isFromFormClasses) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAttendanceButton('Take Class Attendance', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffTakeClassAttendance(
                        classId: widget.classId,
                        className: widget.className,
                      ),
                    ),
                  ).then((_) => _handleRefresh());
                }),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffTakeAttendanceScreen(
            classId: widget.classId,
            courseId: widget.courseId!,
            className: widget.className,
            courseName: widget.courseName!,
          ),
        ),
      ).then((_) => _handleRefresh());
    }
  }

  Widget _buildAttendanceButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
