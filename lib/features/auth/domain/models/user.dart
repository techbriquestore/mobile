/// Modèle représentant un utilisateur de l'application.
///
/// Ce modèle est utilisé dans toute l'application pour représenter
/// l'utilisateur connecté et ses informations de profil.
class User {
  /// Identifiant unique de l'utilisateur.
  final String id;

  /// Numéro de téléphone (format camerounais).
  final String? phone;

  /// Adresse email.
  final String? email;

  /// Prénom.
  final String firstName;

  /// Nom de famille.
  final String lastName;

  /// Type de client : `PARTICULIER` ou `PROFESSIONNEL`.
  final String clientType;

  /// Nom de l'entreprise (si professionnel).
  final String? companyName;

  /// Numéro d'identification fiscale (si professionnel).
  final String? taxId;

  /// Secteur d'activité (si professionnel).
  final String? sector;

  /// URL de la photo de profil.
  final String? profilePhotoUrl;

  /// Rôle de l'utilisateur : `CLIENT`, `ADMIN`, etc.
  final String role;

  /// Statut du compte : `ACTIVE`, `SUSPENDED`, `DELETED`.
  final String status;

  /// Indique si l'email a été vérifié.
  final bool emailVerified;

  /// Fournisseur d'authentification : `LOCAL`, `GOOGLE`.
  final String authProvider;

  /// Date de création du compte.
  final DateTime createdAt;

  User({
    required this.id,
    this.phone,
    this.email,
    required this.firstName,
    required this.lastName,
    this.clientType = 'PARTICULIER',
    this.companyName,
    this.taxId,
    this.sector,
    this.profilePhotoUrl,
    required this.role,
    required this.status,
    required this.emailVerified,
    required this.authProvider,
    required this.createdAt,
  });

  /// Crée un [User] à partir d'une map JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      clientType: json['clientType'] as String? ?? 'PARTICULIER',
      companyName: json['companyName'] as String?,
      taxId: json['taxId'] as String?,
      sector: json['sector'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      role: json['role'] as String? ?? 'CLIENT',
      status: json['status'] as String? ?? 'ACTIVE',
      emailVerified: json['emailVerified'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'LOCAL',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convertit l'utilisateur en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'clientType': clientType,
      'companyName': companyName,
      'taxId': taxId,
      'sector': sector,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role,
      'status': status,
      'emailVerified': emailVerified,
      'authProvider': authProvider,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Nom complet de l'utilisateur.
  String get fullName => '$firstName $lastName'.trim();

  /// Vérifie si le compte est actif.
  bool get isActive => status == 'ACTIVE';

  /// Vérifie si l'utilisateur est un professionnel.
  bool get isProfessional => clientType == 'PROFESSIONNEL';

  /// Vérifie si le profil est complet selon le type d'utilisateur.
  ///
  /// - PARTICULIER : firstName + lastName
  /// - PROFESSIONNEL : firstName + lastName + companyName + sector + taxId
  bool get isProfileComplete {
    if (firstName.isEmpty || lastName.isEmpty) return false;
    if (clientType == 'PROFESSIONNEL') {
      if (companyName == null || companyName!.isEmpty) return false;
      if (sector == null || sector!.isEmpty) return false;
      if (taxId == null || taxId!.isEmpty) return false;
    }
    return true;
  }

  /// Vérifie si l'utilisateur est un administrateur.
  bool get isAdmin => role == 'ADMIN';

  /// Vérifie si l'utilisateur s'est connecté via Google.
  bool get isGoogleUser => authProvider == 'GOOGLE';

  /// Retourne les initiales de l'utilisateur (pour les avatars).
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Crée une copie de l'utilisateur avec des champs modifiés.
  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? firstName,
    String? lastName,
    String? clientType,
    String? companyName,
    String? taxId,
    String? sector,
    String? profilePhotoUrl,
    String? role,
    String? status,
    bool? emailVerified,
    String? authProvider,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      clientType: clientType ?? this.clientType,
      companyName: companyName ?? this.companyName,
      taxId: taxId ?? this.taxId,
      sector: sector ?? this.sector,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, fullName: $fullName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
