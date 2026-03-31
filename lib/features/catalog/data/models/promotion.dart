class Promotion {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String type; // PERCENTAGE, FIXED_AMOUNT, FREE_DELIVERY
  final double value;
  final String? code;
  final double? minAmount;
  final double? maxDiscount;
  final String? productId;
  final String? categoryId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? usageLimit;
  final int usageCount;

  const Promotion({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.type,
    required this.value,
    this.code,
    this.minAmount,
    this.maxDiscount,
    this.productId,
    this.categoryId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.usageLimit,
    this.usageCount = 0,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      code: json['code'] as String?,
      minAmount: json['minAmount'] != null ? (json['minAmount'] as num).toDouble() : null,
      maxDiscount: json['maxDiscount'] != null ? (json['maxDiscount'] as num).toDouble() : null,
      productId: json['productId'] as String?,
      categoryId: json['categoryId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  // Helper methods
  bool get isPercentage => type == 'PERCENTAGE';
  bool get isFixedAmount => type == 'FIXED_AMOUNT';
  bool get isFreeDelivery => type == 'FREE_DELIVERY';
  
  String get displayValue {
    if (isPercentage) return '-${value.toStringAsFixed(0)}%';
    if (isFreeDelivery) return 'Livraison gratuite';
    return '-${value.toStringAsFixed(0)} F';
  }
  
  bool get isValid {
    final now = DateTime.now();
    return isActive && startDate.isBefore(now) && endDate.isAfter(now);
  }
  
  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays;
  }
}
