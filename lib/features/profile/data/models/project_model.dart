class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String status; // ACTIVE, PAUSED, COMPLETED
  final int? budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final String label;
  final String fullAddress;
  final String? landmarks;
  final String city;
  final String? commune;
  final double? gpsLat;
  final double? gpsLng;
  final String contactName;
  final String contactPhone;
  final String? driverInstructions;
  final String? relayContactName;
  final String? relayContactPhone;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  // KPIs (remplis uniquement sur le détail)
  final ProjectKpis? kpis;
  final List<ProjectOrderSummary>? orders;
  final List<ProjectPreorderSummary>? preorders;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.status = 'ACTIVE',
    this.budget,
    this.startDate,
    this.endDate,
    required this.label,
    required this.fullAddress,
    this.landmarks,
    required this.city,
    this.commune,
    this.gpsLat,
    this.gpsLng,
    required this.contactName,
    required this.contactPhone,
    this.driverInstructions,
    this.relayContactName,
    this.relayContactPhone,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.kpis,
    this.orders,
    this.preorders,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['label'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      budget: json['budget'] as int?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      label: json['label'] as String? ?? '',
      fullAddress: json['fullAddress'] as String? ?? '',
      landmarks: json['landmarks'] as String?,
      city: json['city'] as String? ?? '',
      commune: json['commune'] as String?,
      gpsLat: (json['gpsLat'] as num?)?.toDouble(),
      gpsLng: (json['gpsLng'] as num?)?.toDouble(),
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      driverInstructions: json['driverInstructions'] as String?,
      relayContactName: json['relayContactName'] as String?,
      relayContactPhone: json['relayContactPhone'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      kpis: json['kpis'] != null
          ? ProjectKpis.fromJson(json['kpis'] as Map<String, dynamic>)
          : null,
      orders: json['orders'] != null
          ? (json['orders'] as List).map((e) => ProjectOrderSummary.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      preorders: json['preorders'] != null
          ? (json['preorders'] as List).map((e) => ProjectPreorderSummary.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (budget != null) 'budget': budget,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'label': label,
      'fullAddress': fullAddress,
      if (landmarks != null && landmarks!.isNotEmpty) 'landmarks': landmarks,
      'city': city,
      if (commune != null && commune!.isNotEmpty) 'commune': commune,
      if (gpsLat != null) 'gpsLat': gpsLat,
      if (gpsLng != null) 'gpsLng': gpsLng,
      'contactName': contactName,
      'contactPhone': contactPhone,
      if (driverInstructions != null && driverInstructions!.isNotEmpty)
        'driverInstructions': driverInstructions,
      if (relayContactName != null && relayContactName!.isNotEmpty)
        'relayContactName': relayContactName,
      if (relayContactPhone != null && relayContactPhone!.isNotEmpty)
        'relayContactPhone': relayContactPhone,
      'isDefault': isDefault,
    };
  }

  String get displayAddress {
    final parts = <String>[fullAddress];
    if (commune != null && commune!.isNotEmpty) parts.add(commune!);
    parts.add(city);
    return parts.join(', ');
  }

  String get statusLabel {
    switch (status) {
      case 'ACTIVE': return 'Actif';
      case 'PAUSED': return 'En pause';
      case 'COMPLETED': return 'Terminé';
      default: return status;
    }
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    int? budget,
    DateTime? startDate,
    DateTime? endDate,
    String? label,
    String? fullAddress,
    String? landmarks,
    String? city,
    String? commune,
    double? gpsLat,
    double? gpsLng,
    String? contactName,
    String? contactPhone,
    String? driverInstructions,
    String? relayContactName,
    String? relayContactPhone,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectKpis? kpis,
    List<ProjectOrderSummary>? orders,
    List<ProjectPreorderSummary>? preorders,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      landmarks: landmarks ?? this.landmarks,
      city: city ?? this.city,
      commune: commune ?? this.commune,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      driverInstructions: driverInstructions ?? this.driverInstructions,
      relayContactName: relayContactName ?? this.relayContactName,
      relayContactPhone: relayContactPhone ?? this.relayContactPhone,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kpis: kpis ?? this.kpis,
      orders: orders ?? this.orders,
      preorders: preorders ?? this.preorders,
    );
  }
}

class ProjectKpis {
  final int totalSpent;
  final int totalAmount;
  final int totalRemaining;
  final int totalBricks;
  final int totalOrders;
  final int ordersCount;
  final int preordersCount;
  final int? budgetProgress;

  ProjectKpis({
    required this.totalSpent,
    required this.totalAmount,
    required this.totalRemaining,
    required this.totalBricks,
    required this.totalOrders,
    required this.ordersCount,
    required this.preordersCount,
    this.budgetProgress,
  });

  factory ProjectKpis.fromJson(Map<String, dynamic> json) {
    return ProjectKpis(
      totalSpent: json['totalSpent'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
      totalRemaining: json['totalRemaining'] as int? ?? 0,
      totalBricks: json['totalBricks'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      ordersCount: json['ordersCount'] as int? ?? 0,
      preordersCount: json['preordersCount'] as int? ?? 0,
      budgetProgress: json['budgetProgress'] as int?,
    );
  }
}

class ProjectOrderSummary {
  final String id;
  final String? orderNumber;
  final int? totalAmount;
  final String status;
  final DateTime createdAt;
  final int itemsCount;
  final int totalPaid;

  ProjectOrderSummary({
    required this.id,
    this.orderNumber,
    this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.itemsCount,
    required this.totalPaid,
  });

  factory ProjectOrderSummary.fromJson(Map<String, dynamic> json) {
    return ProjectOrderSummary(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String?,
      totalAmount: json['totalAmount'] as int?,
      status: json['status'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      itemsCount: json['itemsCount'] as int? ?? 0,
      totalPaid: json['totalPaid'] as int? ?? 0,
    );
  }
}

class ProjectPreorderSummary {
  final String id;
  final int totalAmount;
  final String status;
  final DateTime createdAt;
  final int itemsCount;
  final int totalPaid;
  final int schedulesCount;
  final int paidSchedules;

  ProjectPreorderSummary({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.itemsCount,
    required this.totalPaid,
    required this.schedulesCount,
    required this.paidSchedules,
  });

  factory ProjectPreorderSummary.fromJson(Map<String, dynamic> json) {
    return ProjectPreorderSummary(
      id: json['id'] as String,
      totalAmount: json['totalAmount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      itemsCount: json['itemsCount'] as int? ?? 0,
      totalPaid: json['totalPaid'] as int? ?? 0,
      schedulesCount: json['schedulesCount'] as int? ?? 0,
      paidSchedules: json['paidSchedules'] as int? ?? 0,
    );
  }
}
