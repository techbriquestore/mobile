class Preorder {
  final String id;
  final String userId;
  final int totalAmount;
  final int depositPercentage;
  final int depositAmount;
  final DateTime? depositPaidAt;
  final int durationMonths;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? deliveryAddressId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PreorderItem> items;
  final List<PreorderSchedule> schedules;
  final PreorderUser? user;

  Preorder({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.depositPercentage,
    required this.depositAmount,
    this.depositPaidAt,
    required this.durationMonths,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.deliveryAddressId,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.schedules = const [],
    this.user,
  });

  bool get isDepositPaid => depositPaidAt != null;
  int get remainingAmount => totalAmount - depositAmount;

  factory Preorder.fromJson(Map<String, dynamic> json) {
    return Preorder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      totalAmount: json['totalAmount'] as int,
      depositPercentage: (json['depositPercentage'] as num?)?.toInt() ?? 15,
      depositAmount: (json['depositAmount'] as num?)?.toInt() ?? 0,
      depositPaidAt: json['depositPaidAt'] != null
          ? DateTime.parse(json['depositPaidAt'] as String)
          : null,
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 3,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      deliveryAddressId: json['deliveryAddressId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PreorderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      schedules: (json['schedules'] as List<dynamic>?)
              ?.map((e) => PreorderSchedule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      user: json['user'] != null
          ? PreorderUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PreorderItem {
  final String id;
  final String preorderId;
  final String productId;
  final int quantity;
  final int lockedPrice;
  final int subtotal;
  final Map<String, dynamic>? product;

  PreorderItem({
    required this.id,
    required this.preorderId,
    required this.productId,
    required this.quantity,
    required this.lockedPrice,
    required this.subtotal,
    this.product,
  });

  String get productName => product?['name'] as String? ?? 'Produit';
  String get productReference => product?['reference'] as String? ?? '';

  factory PreorderItem.fromJson(Map<String, dynamic> json) {
    return PreorderItem(
      id: json['id'] as String,
      preorderId: json['preorderId'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      lockedPrice: json['lockedPrice'] as int,
      subtotal: json['subtotal'] as int,
      product: json['product'] as Map<String, dynamic>?,
    );
  }
}

class PreorderSchedule {
  final String id;
  final String preorderId;
  final DateTime dueDate;
  final int amount;
  final String status;
  final DateTime? paidAt;
  final bool reminderSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  PreorderSchedule({
    required this.id,
    required this.preorderId,
    required this.dueDate,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.reminderSent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PreorderSchedule.fromJson(Map<String, dynamic> json) {
    return PreorderSchedule(
      id: json['id'] as String,
      preorderId: json['preorderId'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      amount: json['amount'] as int,
      status: json['status'] as String,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      reminderSent: (json['reminderSent'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class PreorderUser {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;

  PreorderUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
  });

  factory PreorderUser.fromJson(Map<String, dynamic> json) {
    return PreorderUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';
}

class PreordersPage {
  final List<Preorder> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  PreordersPage({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PreordersPage.fromJson(Map<String, dynamic> json) {
    return PreordersPage(
      data: (json['data'] as List<dynamic>)
          .map((e) => Preorder.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class PreorderDetail extends Preorder {
  final int amountPaid;
  final int remaining;
  final int depositPaid;
  final int paidSchedules;
  final int totalSchedules;
  final int progress;
  final PreorderSchedule? nextSchedule;

  PreorderDetail({
    required super.id,
    required super.userId,
    required super.totalAmount,
    required super.depositPercentage,
    required super.depositAmount,
    super.depositPaidAt,
    required super.durationMonths,
    required super.status,
    required super.startDate,
    required super.endDate,
    super.deliveryAddressId,
    required super.createdAt,
    required super.updatedAt,
    super.items,
    super.schedules,
    super.user,
    required this.amountPaid,
    required this.remaining,
    required this.depositPaid,
    required this.paidSchedules,
    required this.totalSchedules,
    required this.progress,
    this.nextSchedule,
  });

  factory PreorderDetail.fromJson(Map<String, dynamic> json) {
    return PreorderDetail(
      id: json['id'] as String,
      userId: json['userId'] as String,
      totalAmount: json['totalAmount'] as int,
      depositPercentage: (json['depositPercentage'] as num?)?.toInt() ?? 15,
      depositAmount: (json['depositAmount'] as num?)?.toInt() ?? 0,
      depositPaidAt: json['depositPaidAt'] != null
          ? DateTime.parse(json['depositPaidAt'] as String)
          : null,
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 3,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      deliveryAddressId: json['deliveryAddressId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PreorderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      schedules: (json['schedules'] as List<dynamic>?)
              ?.map((e) => PreorderSchedule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      user: json['user'] != null
          ? PreorderUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      depositPaid: (json['depositPaid'] as num?)?.toInt() ?? 0,
      paidSchedules: (json['paidSchedules'] as num?)?.toInt() ?? 0,
      totalSchedules: (json['totalSchedules'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      nextSchedule: json['nextSchedule'] != null
          ? PreorderSchedule.fromJson(json['nextSchedule'] as Map<String, dynamic>)
          : null,
    );
  }
}
