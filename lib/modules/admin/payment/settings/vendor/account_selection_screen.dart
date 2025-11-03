import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/account_model.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:provider/provider.dart';

class AccountSelectionScreen extends StatefulWidget {
  const AccountSelectionScreen({super.key});

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch accounts when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Account',
          style: AppTextStyles.normal600(fontSize: 24, color: AppColors.paymentTxtColor1),
        ),
        backgroundColor: AppColors.backgroundLight,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage,
                    style: AppTextStyles.normal500(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchAccounts(),
                    child: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paymentTxtColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // Filter for expenditure accounts only (account_type: 23 or 24)
          final expenditureAccounts = provider.allAccounts.where((acc) => acc.accountType == 23 || acc.accountType == 24).toList();
          return _buildAccountList(context, expenditureAccounts, 'No expenditure accounts available');
        },
      ),
    );
  }

  Widget _buildAccountList(BuildContext context, List<AccountModel> accounts, String emptyMessage) {
    if (accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundDark),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              account.accountName,
              style: AppTextStyles.normal600(fontSize: 16, color: AppColors.paymentTxtColor1),
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
                    text: '${account.accountNumber}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.pop(context, account),
          ),
        );
      },
    );
  }
}






