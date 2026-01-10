import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/payment/transaction_receipt_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/model/admin/payment_model.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionHistoryScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _filterOptions => [
        'All',
        'Receipts',
        'Expenditure',
      ];

  List<Transaction> get _filteredTransactions {
    List<Transaction> filtered = widget.transactions;

    // Apply type filter
    if (_selectedFilter != 'All') {
      String filterType = _selectedFilter.toLowerCase();
      if (filterType == 'receipts') {
        filtered = filtered.where((t) => t.type == 'receipts').toList();
      } else if (filterType == 'expenditure') {
        filtered = filtered.where((t) => t.type == 'expenditure').toList();
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            transaction.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            transaction.reference
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            transaction.regNo
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) {
      try {
        DateTime dateA = DateTime.parse(a.date);
        DateTime dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA);
      } catch (e) {
        return b.id.compareTo(a.id); // Fallback to ID sorting
      }
    });

    return filtered;
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions;

    CustomStudentAppBar customAppBar = CustomStudentAppBar(
      title: 'Transaction History',
      showNotification: false,
      showSettings: false,
      centerTitle: true,
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
    );

    return Scaffold(
      appBar: customAppBar,
      body: SafeArea(
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Column(
            children: [
              // Header with total count and filters
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${filteredTransactions.length} Transactions',
                              style: AppTextStyles.normal600(
                                fontSize: 18,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            Text(
                              _getFilterSummary(),
                              style: AppTextStyles.normal500(
                                fontSize: 14,
                                color: AppColors.text10Light,
                              ),
                            ),
                          ],
                        ),
                        _buildTotalAmount(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.text10Light.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.text10Light.withOpacity(0.3),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Filter chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterOptions.length,
                        itemBuilder: (context, index) {
                          final option = _filterOptions[index];
                          final isSelected = _selectedFilter == option;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(option),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = option;
                                });
                              },
                              selectedColor: AppColors.paymentBtnColor1,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.backgroundDark,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction list
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.text10Light,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No transactions match your search'
                                  : 'No transactions found',
                              style: AppTextStyles.normal500(
                                fontSize: 16,
                                color: AppColors.text10Light,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search terms',
                                style: AppTextStyles.normal400(
                                  fontSize: 14,
                                  color: AppColors.text10Light,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return _buildTransactionItem(transaction);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterSummary() {
    final total = widget.transactions.length;
    final filtered = _filteredTransactions.length;

    if (_selectedFilter == 'All' && _searchQuery.isEmpty) {
      return 'Showing all transactions';
    } else if (_searchQuery.isNotEmpty && _selectedFilter != 'All') {
      return 'Filtered by $_selectedFilter and search';
    } else if (_searchQuery.isNotEmpty) {
      return 'Filtered by search';
    } else {
      return 'Filtered by $_selectedFilter';
    }
  }

  Widget _buildTotalAmount() {
    final transactions = _filteredTransactions;
    double totalIncome = 0;
    double totalExpenditure = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'receipts') {
        totalIncome += transaction.amount;
      } else {
        totalExpenditure += transaction.amount;
      }
    }

    final netAmount = totalIncome - totalExpenditure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              netAmount >= 0 ? 'Net: +' : 'Net: -',
              style: TextStyle(
                color: netAmount >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const NairaSvgIcon(color: Colors.grey),
            Text(
              netAmount.abs().toStringAsFixed(2),
              style: TextStyle(
                color: netAmount >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (totalIncome > 0 && totalExpenditure > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Income: ₦${totalIncome.toStringAsFixed(2)}',
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
          Text(
            'Expenditure: ₦${totalExpenditure.toStringAsFixed(2)}',
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isReceipt = transaction.type == 'receipts';
    final iconColor = isReceipt ? Colors.green : Colors.red;
    final amountColor = isReceipt ? Colors.green : Colors.red;
    final prefix = isReceipt ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionReceiptScreen(transaction: transaction),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Transaction type icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isReceipt ? Icons.arrow_downward : Icons.arrow_upward,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Transaction details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.name,
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: AppColors.backgroundDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.description,
                          style: AppTextStyles.normal400(
                            fontSize: 13,
                            color: AppColors.text10Light,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.text10Light,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(transaction.date),
                              style: AppTextStyles.normal400(
                                fontSize: 12,
                                color: AppColors.text10Light,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.school,
                              size: 14,
                              color: AppColors.text10Light,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                transaction.levelName.isNotEmpty
                                    ? transaction.levelName
                                    : 'N/A',
                                style: AppTextStyles.normal400(
                                  fontSize: 12,
                                  color: AppColors.text10Light,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prefix,
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: amountColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const NairaSvgIcon(color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            transaction.amount.toStringAsFixed(2),
                            style: AppTextStyles.normal700(
                              fontSize: 16,
                              color: amountColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: iconColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isReceipt ? 'Income' : 'Expense',
                          style: AppTextStyles.normal500(
                            fontSize: 11,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Reference number (if available)
              if (transaction.reference.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.text10Light.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.text10Light.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 14,
                        color: AppColors.text10Light,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ref: ${transaction.reference}',
                        style: AppTextStyles.normal400(
                          fontSize: 12,
                          color: AppColors.text10Light,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Reg: ${transaction.regNo}',
                        style: AppTextStyles.normal400(
                          fontSize: 12,
                          color: AppColors.text10Light,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
