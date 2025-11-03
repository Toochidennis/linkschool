import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/account_model.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:provider/provider.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  late double opacity;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch accounts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().fetchAccounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Account Settings',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: Icon(
              Icons.search,
              color: AppColors.eLearningBtnColor1,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: Icon(
              Icons.filter_list,
              color: AppColors.eLearningBtnColor1,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
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
              // Active filters display
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final hasActiveFilters = accountProvider.searchQuery.isNotEmpty ||
                      accountProvider.selectedAccountTypeFilter != null;
                  
                  if (!hasActiveFilters) return const SizedBox.shrink();
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.eLearningBtnColor1.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: AppColors.eLearningBtnColor1,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (accountProvider.searchQuery.isNotEmpty)
                                Chip(
                                  label: Text('Search: "${accountProvider.searchQuery}"'),
                                  backgroundColor: AppColors.eLearningBtnColor1.withOpacity(0.2),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    accountProvider.searchAccounts('');
                                  },
                                ),
                              if (accountProvider.selectedAccountTypeFilter != null)
                                Chip(
                                  label: Text('Type: ${accountProvider.selectedAccountTypeFilter}'),
                                  backgroundColor: AppColors.eLearningBtnColor1.withOpacity(0.2),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    accountProvider.filterByAccountType(null);
                                  },
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            accountProvider.clearFilters();
                          },
                          child: Text(
                            'Clear All',
                            style: TextStyle(color: AppColors.eLearningBtnColor1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Accounts list
              Expanded(
                child: Consumer<AccountProvider>(
                  builder: (context, accountProvider, child) {
                    if (accountProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (accountProvider.errorMessage.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${accountProvider.errorMessage}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                accountProvider.fetchAccounts();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (accountProvider.accounts.isEmpty) {
                      final hasFilters = accountProvider.searchQuery.isNotEmpty ||
                          accountProvider.selectedAccountTypeFilter != null;
                      
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasFilters ? Icons.search_off : Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hasFilters 
                                  ? 'No accounts match your search criteria'
                                  : 'No accounts found',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (hasFilters) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  accountProvider.clearFilters();
                                },
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: accountProvider.accounts.length,
                      itemBuilder: (context, index) {
                        final account = accountProvider.accounts[index];
                        return _buildAccountRow(account);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditAccountOverlay(context),
        backgroundColor: AppColors.videoColor4,
        child: Icon(
          Icons.add,
          color: AppColors.backgroundLight,
          size: 24,
        ),
      ),
    );
  }

  // Widget _buildAccountRow(AccountModel account) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 8),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: ListTile(
  //       leading: CircleAvatar(
  //         backgroundColor: AppColors.eLearningBtnColor1,
  //         child: SvgPicture.asset(
  //           'assets/icons/profile/fee.svg',
  //           color: Colors.white,
  //         ),
  //       ),
  //       title: Text(
  //         account.accountName,
  //         style: const TextStyle(
  //           fontWeight: FontWeight.w600,
  //           fontSize: 16,
  //         ),
  //       ),
  //       subtitle: RichText(
  //         text: TextSpan(
  //           children: [
  //             TextSpan(
  //               text: 'Number: ',
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //                 fontSize: 14,
  //               ),
  //             ),
  //             TextSpan(
  //               text: '${account.accountNumber} • ',
  //               style: TextStyle(color: Colors.grey[600], fontSize: 14),
  //             ),
  //             TextSpan(
  //               text: 'Type: ',
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //                 fontSize: 14,
  //               ),
  //             ),
  //             TextSpan(
  //               text: account.accountTypeString,
  //               style: TextStyle(
  //                 color: account.accountType == 0 ? Colors.green[600] : Colors.orange[600],
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       trailing: SvgPicture.asset('assets/icons/profile/edit_pen.svg'),
  //       onTap: () => _showAddEditAccountOverlay(context, account: account),
  //     ),
  //   );
  // }


  Widget _buildAccountRow(AccountModel account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.eLearningBtnColor1,
          child: SvgPicture.asset(
            'assets/icons/profile/fee.svg',
            color: Colors.white,
          ),
        ),
        title: Text(
          account.accountName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Number: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: '${account.accountNumber} • ',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              TextSpan(
                text: 'Type: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: account.accountTypeString,
                style: TextStyle(
                  color: account.accountType == 0 ? Colors.green[600] : Colors.orange[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showAddEditAccountOverlay(context, account: account),
              icon: SvgPicture.asset(
                'assets/icons/profile/edit_pen.svg',
                width: 20,
                height: 20,
              ),
              tooltip: 'Edit Account',
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmationDialog(context, account),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[600],
                size: 20,
              ),
              tooltip: 'Delete Account',
            ),
          ],
        ),
        onTap: () => _showAddEditAccountOverlay(context, account: account),
      ),
    );
  }


  void _showDeleteConfirmationDialog(BuildContext context, AccountModel account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this account?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Name: ${account.accountName}'),
                    Text('Number: ${account.accountNumber}'),
                    Text('Type: ${account.accountTypeString}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                return ElevatedButton(
                  onPressed: accountProvider.isDeletingAccount
                      ? null
                      : () async {
                          final success = await accountProvider.deleteAccount(
                            accountId: account.id,
                          );
                          
                          if (success) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // Keep dialog open to show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${accountProvider.errorMessage}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child: accountProvider.isDeletingAccount
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Delete'),
                );
              },
            ),
          ],
        );
      },
    );
  }


  void _showSearchDialog(BuildContext context) {
    final accountProvider = context.read<AccountProvider>();
    _searchController.text = accountProvider.searchQuery;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Accounts'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter account name or number...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              accountProvider.searchAccounts(value.trim());
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                accountProvider.searchAccounts('');
                _searchController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                accountProvider.searchAccounts(_searchController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final accountProvider = context.read<AccountProvider>();
    String? selectedFilter = accountProvider.selectedAccountTypeFilter;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Accounts'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Account Type:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String?>(
                    title: const Text('All Types'),
                    value: null,
                    groupValue: selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value;
                      });
                    },
                  ),
                  RadioListTile<String?>(
                    title: const Text('Income'),
                    value: 'Income',
                    groupValue: selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value;
                      });
                    },
                  ),
                  RadioListTile<String?>(
                    title: const Text('Expenditure'),
                    value: 'Expenditure',
                    groupValue: selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    accountProvider.filterByAccountType(null);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    accountProvider.filterByAccountType(selectedFilter);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddEditAccountOverlay(BuildContext context, {AccountModel? account}) {
    final isEditing = account != null;
    final accountNameController = TextEditingController(
      text: isEditing ? account.accountName : '',
    );
    final accountNumberController = TextEditingController(
      text: isEditing ? account.accountNumber : '',
    );
    String? selectedAccountType = isEditing 
        ? (account.accountType == 0 ? 'Income' : 'Expenditure')
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Consumer<AccountProvider>(
                  builder: (context, accountProvider, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isEditing ? 'Edit account' : 'Add account',
                          style: AppTextStyles.normal600(
                            fontSize: 24,
                            color: AppColors.backgroundDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: accountNameController,
                          decoration: const InputDecoration(
                            hintText: 'Account name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: accountNumberController,
                          decoration: const InputDecoration(
                            hintText: 'Account number (5 digits)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedAccountType,
                          decoration: const InputDecoration(
                            hintText: 'Select account type',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Income', 'Expenditure'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAccountType = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (accountProvider.errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              accountProvider.errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ElevatedButton(
                          onPressed: (accountProvider.isAddingAccount || 
                                     accountProvider.isUpdatingAccount)
                              ? null
                              : () async {
                                  if (accountNameController.text.isEmpty ||
                                      accountNumberController.text.isEmpty ||
                                      selectedAccountType == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final accountType = selectedAccountType == 'Income' ? 0 : 1;
                                  bool success;

                                  if (isEditing) {
                                    success = await accountProvider.updateAccount(
                                      accountId: account!.id,
                                      accountName: accountNameController.text,
                                      accountNumber: accountNumberController.text,
                                      accountType: accountType,
                                    );
                                  } else {
                                    success = await accountProvider.addAccount(
                                      accountName: accountNameController.text,
                                      accountNumber: accountNumberController.text,
                                      accountType: accountType,
                                    );
                                  }

                                  if (success) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing 
                                              ? 'Account updated successfully'
                                              : 'Account added successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.eLearningBtnColor1,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: (accountProvider.isAddingAccount || 
                                 accountProvider.isUpdatingAccount)
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEditing ? 'Update' : 'Add',
                                  style: AppTextStyles.normal600(
                                    fontSize: 16,
                                    color: AppColors.backgroundLight,
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}





