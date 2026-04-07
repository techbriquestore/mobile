class AddressModel {
  final String id;
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

  AddressModel({
    required this.id,
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
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
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
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
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
}
