class PaymentDashboardSummary {
  final double income;
  final double invoiced;
  final List<Transaction> transactions;

  PaymentDashboardSummary({
    required this.income,
    required this.invoiced,
    required this.transactions,
  });

  factory PaymentDashboardSummary.fromJson(Map<String, dynamic> json) {
    return PaymentDashboardSummary(
      income: (json['income'] ?? 0).toDouble(),
      invoiced: (json['invoiced'] ?? 0).toDouble(),
      transactions: (json['transactions'] as List?)
          ?.map((t) => Transaction.fromJson(t))
          .toList() ?? [],
    );
  }

  double get outstanding => invoiced - income;
}

class Transaction {
  final int id;
  final String type;
  final String reference;
  final String regNo;
  final String description;
  final String name;
  final double amount;
  final String date;
  final String year;
  final int term;
  final int levelId;
  final int classId;
  final int status;
  final String levelName;

  Transaction({
    required this.id,
    required this.type,
    required this.reference,
    required this.regNo,
    required this.description,
    required this.name,
    required this.amount,
    required this.date,
    required this.year,
    required this.term,
    required this.levelId,
    required this.classId,
    required this.status,
    required this.levelName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      reference: json['reference'] ?? '',
      regNo: json['reg_no'] ?? '',
      description: json['description'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      year: json['year'] ?? '',
      term: json['term'] ?? 0,
      levelId: json['level_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      status: json['status'] ?? 0,
      levelName: json['level_name'] ?? '',
    );
  }
}

class PaidInvoice {
  final int id;
  final String reference;
  final String regNo;
  final String description;
  final String name;
  final double amount;
  final String date;
  final String year;
  final int term;
  final int levelId;
  final int classId;
  final int status;

  PaidInvoice({
    required this.id,
    required this.reference,
    required this.regNo,
    required this.description,
    required this.name,
    required this.amount,
    required this.date,
    required this.year,
    required this.term,
    required this.levelId,
    required this.classId,
    required this.status,
  });

  factory PaidInvoice.fromJson(Map<String, dynamic> json) {
    return PaidInvoice(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      regNo: json['reg_no'] ?? '',
      description: json['description'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      year: json['year'] ?? '',
      term: json['term'] ?? 0,
      levelId: json['level_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      status: json['status'] ?? 0,
    );
  }

  String get termText {
    switch (term) {
      case 1: return 'First Term Fees Receipt';
      case 2: return 'Second Term Fees Receipt';
      case 3: return 'Third Term Fees Receipt';
      default: return 'Term Fees Receipt';
    }
  }

  String get sessionText {
    int yearInt = int.tryParse(year) ?? 0;
    return '${yearInt - 1}/$year';
  }

  String get termFeesText {
    switch (term) {
      case 1: return 'First Term Fees';
      case 2: return 'Second Term Fees';
      case 3: return 'Third Term Fees';
      default: return 'Term Fees';
    }
  }
}

class UnpaidStudent {
  final String studentId;
  final String regNo;
  final String name;
  final int levelId;
  final int classId;
  final List<UnpaidInvoice> invoices;

  UnpaidStudent({
    required this.studentId,
    required this.regNo,
    required this.name,
    required this.levelId,
    required this.classId,
    required this.invoices,
  });

  factory UnpaidStudent.fromJson(Map<String, dynamic> json) {
    return UnpaidStudent(
      studentId: json['student_id'] ?? '',
      regNo: json['reg_no'] ?? '',
      name: json['name'] ?? '',
      levelId: json['level_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      invoices: (json['invoices'] as List?)
          ?.map((i) => UnpaidInvoice.fromJson(i))
          .toList() ?? [],
    );
  }

  double get totalAmount {
    return invoices.fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }
}

class UnpaidInvoice {
  final int id;
  final String? reference;
  final List<InvoiceDetail> invoiceDetails;
  final String? amountDue;
  final String year;
  final int term;

  UnpaidInvoice({
    required this.id,
    this.reference,
    required this.invoiceDetails,
    this.amountDue,
    required this.year,
    required this.term,
  });

  factory UnpaidInvoice.fromJson(Map<String, dynamic> json) {
    return UnpaidInvoice(
      id: json['id'] ?? 0,
      reference: json['reference'],
      invoiceDetails: (json['invoice_details'] as List?)
          ?.map((d) => InvoiceDetail.fromJson(d))
          .toList() ?? [],
      amountDue: json['amount_due'],
      year: json['year'] ?? '',
      term: json['term'] ?? 0,
    );
  }

  double get totalAmount {
    return invoiceDetails.fold(0.0, (sum, detail) => sum + detail.amount);
  }

  String get termText {
    switch (term) {
      case 1: return 'First Term Fee Charges for';
      case 2: return 'Second Term Fee Charges for';
      case 3: return 'Third Term Fee Charges for';
      default: return 'Term Fee Charges for';
    }
  }

  String get sessionText {
    int yearInt = int.tryParse(year) ?? 0;
    return '${yearInt - 1}/$year Session';
  }
}

class InvoiceDetail {
  final String feeId;
  final String feeName;
  final double amount;

  InvoiceDetail({
    required this.feeId,
    required this.feeName,
    required this.amount,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      feeId: json['fee_id'] ?? '',
      feeName: json['fee_name'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class Level {
  final int id;
  final String levelName;

  Level({required this.id, required this.levelName});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] ?? 0,
      levelName: json['level_name'] ?? '',
    );
  }
}

class ClassModel {
  final int id;
  final String className;
  final int levelId;
  final String? formTeacher;

  ClassModel({
    required this.id,
    required this.className,
    required this.levelId,
    this.formTeacher,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? 0,
      className: json['class_name'] ?? '',
      levelId: json['level_id'] ?? 0,
      formTeacher: json['form_teacher'],
    );
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginData response;

  LoginResponse({
    required this.success,
    required this.message,
    required this.response,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      response: LoginData.fromJson(json['response'] ?? {}),
    );
  }
}

class LoginData {
  final UserProfile profile;
  final Settings settings;
  final List<ClassModel> classes;
  final List<Level> levels;
  final String token;
  final String db;

  LoginData({
    required this.profile,
    required this.settings,
    required this.classes,
    required this.levels,
    required this.token,
    required this.db,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      profile: UserProfile.fromJson(json['data']?['profile'] ?? {}),
      settings: Settings.fromJson(json['data']?['settings'] ?? {}),
      classes: (json['data']?['classes'] as List?)
          ?.map((c) => ClassModel.fromJson(c))
          .toList() ?? [],
      levels: (json['data']?['levels'] as List?)
          ?.map((l) => Level.fromJson(l))
          .toList() ?? [],
      token: json['token'] ?? '',
      db: json['_db'] ?? '',
    );
  }
}

class UserProfile {
  final int staffId;
  final String name;
  final String email;
  final String role;

  UserProfile({
    required this.staffId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      staffId: json['staff_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class Settings {
  final String schoolName;
  final String year;
  final int term;

  Settings({
    required this.schoolName,
    required this.year,
    required this.term,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      schoolName: json['school_name'] ?? '',
      year: json['year'] ?? '',
      term: json['term'] ?? 0,
    );
  }
}
