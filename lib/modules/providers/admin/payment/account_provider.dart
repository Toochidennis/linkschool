import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/account_model.dart';
import 'package:linkschool/modules/services/admin/payment/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService;

  AccountProvider(this._accountService);

  List<AccountModel> _accounts = [];
  List<AccountModel> _filteredAccounts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isAddingAccount = false;
  bool _isUpdatingAccount = false;
  String _searchQuery = '';
  String? _selectedAccountTypeFilter;
  bool _isDeletingAccount = false;

  // Getters
  List<AccountModel> get accounts => _filteredAccounts;
  List<AccountModel> get allAccounts => _accounts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAddingAccount => _isAddingAccount;
  bool get isUpdatingAccount => _isUpdatingAccount;
  String get searchQuery => _searchQuery;
  String? get selectedAccountTypeFilter => _selectedAccountTypeFilter;

  
  bool get isDeletingAccount => _isDeletingAccount;

  // Fetch accounts from API, handling pagination
  Future<void> fetchAccounts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    List<AccountModel> allData = [];
    int page = 1;
    bool hasNext = true;

    while (hasNext) {
      try {
        final response = await _accountService.fetchAccounts(page: page);

        if (response.success && response.data != null) {
          allData.addAll(response.data!.data);
          hasNext = response.data!.meta['has_next'] ?? false;
          page++;
        } else {
          // Check if it's an auth error
          if (response.statusCode == 401 || response.statusCode == 400 || 
              response.message.toLowerCase().contains('token')) {
            await _handleAuthError();
            // Retry the current page after handling auth error
            final retryResponse = await _accountService.fetchAccounts(page: page);
            if (retryResponse.success && retryResponse.data != null) {
              allData.addAll(retryResponse.data!.data);
              hasNext = retryResponse.data!.meta['has_next'] ?? false;
              page++;
            } else {
              _errorMessage = retryResponse.message;
              hasNext = false;
            }
          } else {
            _errorMessage = response.message;
            hasNext = false;
          }
        }
      } catch (e) {
        _errorMessage = 'Failed to fetch accounts: ${e.toString()}';
        hasNext = false;
      }
    }

    if (_errorMessage.isEmpty) {
      // Sort accounts by ID in descending order (newest first)
      _accounts = allData;
      _accounts.sort((a, b) => b.id.compareTo(a.id));
      _applyFilters();
    } else {
      _accounts = [];
      _filteredAccounts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new account
  Future<bool> addAccount({
    required String accountName,
    required String accountNumber,
    required int accountType,
  }) async {
    _isAddingAccount = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _accountService.addAccount(
        accountName: accountName,
        accountNumber: accountNumber,
        accountType: accountType,
      );

      if (response.success) {
        // Refresh the accounts list after successful addition
        await fetchAccounts();
        _errorMessage = '';
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to add account: ${e.toString()}';
      return false;
    } finally {
      _isAddingAccount = false;
      notifyListeners();
    }
  }

  // Update existing account
  Future<bool> updateAccount({
    required int accountId,
    required String accountName,
    required String accountNumber,
    required int accountType,
  }) async {
    _isUpdatingAccount = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _accountService.updateAccount(
        accountId: accountId,
        accountName: accountName,
        accountNumber: accountNumber,
        accountType: accountType,
      );

      if (response.success) {
        // Refresh the accounts list after successful update
        await fetchAccounts();
        _errorMessage = '';
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update account: ${e.toString()}';
      return false;
    } finally {
      _isUpdatingAccount = false;
      notifyListeners();
    }
  }

  // Search functionality
  void searchAccounts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter functionality
  void filterByAccountType(String? accountType) {
    _selectedAccountTypeFilter = accountType;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedAccountTypeFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply search and filter logic
  void _applyFilters() {
    _filteredAccounts = _accounts.where((account) {
      // Apply search filter
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        matchesSearch = account.accountName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                       account.accountNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      // Apply account type filter
      bool matchesTypeFilter = true;
      if (_selectedAccountTypeFilter != null) {
        if (_selectedAccountTypeFilter == 'Income') {
          matchesTypeFilter = account.accountType == 0;
        } else if (_selectedAccountTypeFilter == 'Expenditure') {
          matchesTypeFilter = account.accountType == 1;
        }
      }

      return matchesSearch && matchesTypeFilter;
    }).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Get account by ID
  AccountModel? getAccountById(int id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // Handle authentication errors and retry using existing auth system
  Future<void> _handleAuthError() async {
    try {
      print('Handling authentication error...');
      
      // Check if user is still logged in according to existing auth system
      final userBox = Hive.box('userData');
      final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);
      final token = userBox.get('token');
      
      print('Is logged in: $isLoggedIn');
      print('Token exists: ${token != null && token.isNotEmpty}');
      
      if (!isLoggedIn || token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
      } else {
        // Refresh the auth token in the service
        _accountService.refreshAuthToken();
      }
    } catch (e) {
      print('Error handling auth error: $e');
      _errorMessage = 'Authentication error. Please login again.';
    }
  }

  Future<bool> deleteAccount({
    required int accountId,
  }) async {
    _isDeletingAccount = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _accountService.deleteAccount(
        accountId: accountId,
      );

      if (response.success) {
        // Refresh the accounts list after successful deletion
        await fetchAccounts();
        _errorMessage = '';
        return true;
      } else {
        // Check if it's an auth error
        if (response.statusCode == 401 || response.statusCode == 400 || 
            response.message.toLowerCase().contains('token')) {
          await _handleAuthError();
          // Retry the delete after handling auth error
          final retryResponse = await _accountService.deleteAccount(
            accountId: accountId,
          );
          if (retryResponse.success) {
            await fetchAccounts();
            _errorMessage = '';
            return true;
          } else {
            _errorMessage = retryResponse.message;
            return false;
          }
        } else {
          _errorMessage = response.message;
          return false;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to delete account: ${e.toString()}';
      return false;
    } finally {
      _isDeletingAccount = false;
      notifyListeners();
    }
  }
}



