class CbtPlanModel {
  final int id;
  final String name;
  final int discountPercent;
  final String price;
  final num finalPrice;
  final int freeTrialDays;
  final String currency;
  final List<String> features;

  const CbtPlanModel({
    required this.id,
    required this.name,
    required this.discountPercent,
    required this.price,
    required this.finalPrice,
    required this.freeTrialDays,
    required this.currency,
    required this.features,
  });

  factory CbtPlanModel.fromJson(Map<String, dynamic> json) {
    return CbtPlanModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      discountPercent: json['discount_percent'] as int? ?? 0,
      price: json['price']?.toString() ?? '0',
      finalPrice: json['final_price'] ?? 0,
      freeTrialDays: json['free_trial_days'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'NGN',
      features: (json['features'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discount_percent': discountPercent,
      'price': price,
      'final_price': finalPrice,
      'free_trial_days': freeTrialDays,
      'currency': currency,
      'features': features,
    };
  }
}
