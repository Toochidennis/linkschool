// // providers/invoice_provider.dart
// import 'package:flutter/foundation.dart';
// providers/invoice_provider.dart
import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/student/payment_model.dart';
import 'package:linkschool/modules/services/student/payment_services.dart';

class InvoiceProvider with ChangeNotifier {
  final InvoiceService _invoiceService;

  InvoiceResponse? _invoiceData;
  bool _isLoading = false;
  String? _error;

  InvoiceResponse? get invoiceData => _invoiceData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  InvoiceProvider(this._invoiceService);

  Future<void> fetchInvoiceData(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _invoiceData = await _invoiceService.fetchInvoices(studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _invoiceData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods to get specific data
  List<Invoice>? get invoices => _invoiceData?.response.invoices;
  List<Payment>? get payments => _invoiceData?.response.payments;

  double? get totalPaidAmount {
    if (payments == null) return null;
    return payments!.fold(0, (sum, payment) => sum! + payment.amount);
  }

  double? get totalInvoiceAmount {
    if (invoices == null) return null;
    return invoices!.fold(0, (sum, invoice) => sum! + invoice.amount);
  }
}
