/// Modèle représentant un pays avec son indicatif téléphonique
class Country {
  final String code;      // ISO 3166-1 alpha-2
  final String name;      // Nom du pays en français
  final String dialCode;  // Indicatif téléphonique (ex: +225)
  final String flag;      // Emoji du drapeau
  final int minLength;    // Longueur minimale du numéro (sans indicatif)
  final int maxLength;    // Longueur maximale du numéro (sans indicatif)

  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.minLength,
    required this.maxLength,
  });

  /// Nom complet avec drapeau et indicatif
  String get displayName => '$flag $name ($dialCode)';

  /// Nom court avec drapeau
  String get shortDisplayName => '$flag $dialCode';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Liste de tous les pays supportés
const List<Country> countries = [
  // Afrique
  Country(code: 'CI', name: 'Côte d\'Ivoire', dialCode: '+225', flag: '🇨🇮', minLength: 10, maxLength: 10),
  Country(code: 'SN', name: 'Sénégal', dialCode: '+221', flag: '🇸🇳', minLength: 9, maxLength: 9),
  Country(code: 'ML', name: 'Mali', dialCode: '+223', flag: '🇲🇱', minLength: 8, maxLength: 8),
  Country(code: 'BF', name: 'Burkina Faso', dialCode: '+226', flag: '🇧🇫', minLength: 8, maxLength: 8),
  Country(code: 'GN', name: 'Guinée', dialCode: '+224', flag: '🇬🇳', minLength: 9, maxLength: 9),
  Country(code: 'TG', name: 'Togo', dialCode: '+228', flag: '🇹🇬', minLength: 8, maxLength: 8),
  Country(code: 'BJ', name: 'Bénin', dialCode: '+229', flag: '🇧🇯', minLength: 8, maxLength: 8),
  Country(code: 'NE', name: 'Niger', dialCode: '+227', flag: '🇳🇪', minLength: 8, maxLength: 8),
  Country(code: 'CM', name: 'Cameroun', dialCode: '+237', flag: '🇨🇲', minLength: 9, maxLength: 9),
  Country(code: 'GA', name: 'Gabon', dialCode: '+241', flag: '🇬🇦', minLength: 7, maxLength: 8),
  Country(code: 'CG', name: 'Congo', dialCode: '+242', flag: '🇨🇬', minLength: 9, maxLength: 9),
  Country(code: 'CD', name: 'RD Congo', dialCode: '+243', flag: '🇨🇩', minLength: 9, maxLength: 9),
  Country(code: 'MA', name: 'Maroc', dialCode: '+212', flag: '🇲🇦', minLength: 9, maxLength: 9),
  Country(code: 'DZ', name: 'Algérie', dialCode: '+213', flag: '🇩🇿', minLength: 9, maxLength: 9),
  Country(code: 'TN', name: 'Tunisie', dialCode: '+216', flag: '🇹🇳', minLength: 8, maxLength: 8),
  Country(code: 'EG', name: 'Égypte', dialCode: '+20', flag: '🇪🇬', minLength: 10, maxLength: 10),
  Country(code: 'NG', name: 'Nigeria', dialCode: '+234', flag: '🇳🇬', minLength: 10, maxLength: 10),
  Country(code: 'GH', name: 'Ghana', dialCode: '+233', flag: '🇬🇭', minLength: 9, maxLength: 9),
  Country(code: 'KE', name: 'Kenya', dialCode: '+254', flag: '🇰🇪', minLength: 9, maxLength: 9),
  Country(code: 'ZA', name: 'Afrique du Sud', dialCode: '+27', flag: '🇿🇦', minLength: 9, maxLength: 9),
  Country(code: 'RW', name: 'Rwanda', dialCode: '+250', flag: '🇷🇼', minLength: 9, maxLength: 9),
  Country(code: 'MG', name: 'Madagascar', dialCode: '+261', flag: '🇲🇬', minLength: 9, maxLength: 9),
  Country(code: 'MU', name: 'Maurice', dialCode: '+230', flag: '🇲🇺', minLength: 7, maxLength: 8),
  
  // Europe
  Country(code: 'FR', name: 'France', dialCode: '+33', flag: '🇫🇷', minLength: 9, maxLength: 9),
  Country(code: 'BE', name: 'Belgique', dialCode: '+32', flag: '🇧🇪', minLength: 9, maxLength: 9),
  Country(code: 'CH', name: 'Suisse', dialCode: '+41', flag: '🇨🇭', minLength: 9, maxLength: 9),
  Country(code: 'DE', name: 'Allemagne', dialCode: '+49', flag: '🇩🇪', minLength: 10, maxLength: 11),
  Country(code: 'GB', name: 'Royaume-Uni', dialCode: '+44', flag: '🇬🇧', minLength: 10, maxLength: 10),
  Country(code: 'ES', name: 'Espagne', dialCode: '+34', flag: '🇪🇸', minLength: 9, maxLength: 9),
  Country(code: 'IT', name: 'Italie', dialCode: '+39', flag: '🇮🇹', minLength: 9, maxLength: 10),
  Country(code: 'PT', name: 'Portugal', dialCode: '+351', flag: '🇵🇹', minLength: 9, maxLength: 9),
  Country(code: 'NL', name: 'Pays-Bas', dialCode: '+31', flag: '🇳🇱', minLength: 9, maxLength: 9),
  Country(code: 'LU', name: 'Luxembourg', dialCode: '+352', flag: '🇱🇺', minLength: 9, maxLength: 9),
  Country(code: 'AT', name: 'Autriche', dialCode: '+43', flag: '🇦🇹', minLength: 10, maxLength: 11),
  Country(code: 'PL', name: 'Pologne', dialCode: '+48', flag: '🇵🇱', minLength: 9, maxLength: 9),
  Country(code: 'SE', name: 'Suède', dialCode: '+46', flag: '🇸🇪', minLength: 9, maxLength: 9),
  Country(code: 'NO', name: 'Norvège', dialCode: '+47', flag: '🇳🇴', minLength: 8, maxLength: 8),
  Country(code: 'DK', name: 'Danemark', dialCode: '+45', flag: '🇩🇰', minLength: 8, maxLength: 8),
  Country(code: 'FI', name: 'Finlande', dialCode: '+358', flag: '🇫🇮', minLength: 9, maxLength: 10),
  Country(code: 'IE', name: 'Irlande', dialCode: '+353', flag: '🇮🇪', minLength: 9, maxLength: 9),
  Country(code: 'GR', name: 'Grèce', dialCode: '+30', flag: '🇬🇷', minLength: 10, maxLength: 10),
  Country(code: 'RO', name: 'Roumanie', dialCode: '+40', flag: '🇷🇴', minLength: 9, maxLength: 9),
  Country(code: 'CZ', name: 'Tchéquie', dialCode: '+420', flag: '🇨🇿', minLength: 9, maxLength: 9),
  Country(code: 'HU', name: 'Hongrie', dialCode: '+36', flag: '🇭🇺', minLength: 9, maxLength: 9),
  Country(code: 'SK', name: 'Slovaquie', dialCode: '+421', flag: '🇸🇰', minLength: 9, maxLength: 9),
  Country(code: 'HR', name: 'Croatie', dialCode: '+385', flag: '🇭🇷', minLength: 9, maxLength: 9),
  Country(code: 'BG', name: 'Bulgarie', dialCode: '+359', flag: '🇧🇬', minLength: 9, maxLength: 9),
  Country(code: 'RS', name: 'Serbie', dialCode: '+381', flag: '🇷🇸', minLength: 9, maxLength: 9),
  Country(code: 'UA', name: 'Ukraine', dialCode: '+380', flag: '🇺🇦', minLength: 9, maxLength: 9),
  Country(code: 'RU', name: 'Russie', dialCode: '+7', flag: '🇷🇺', minLength: 10, maxLength: 10),
  Country(code: 'TR', name: 'Turquie', dialCode: '+90', flag: '🇹🇷', minLength: 10, maxLength: 10),
  
  // Amérique
  Country(code: 'US', name: 'États-Unis', dialCode: '+1', flag: '🇺🇸', minLength: 10, maxLength: 10),
  Country(code: 'CA', name: 'Canada', dialCode: '+1', flag: '🇨🇦', minLength: 10, maxLength: 10),
  Country(code: 'MX', name: 'Mexique', dialCode: '+52', flag: '🇲🇽', minLength: 10, maxLength: 10),
  Country(code: 'BR', name: 'Brésil', dialCode: '+55', flag: '🇧🇷', minLength: 10, maxLength: 11),
  Country(code: 'AR', name: 'Argentine', dialCode: '+54', flag: '🇦🇷', minLength: 10, maxLength: 10),
  Country(code: 'CO', name: 'Colombie', dialCode: '+57', flag: '🇨🇴', minLength: 10, maxLength: 10),
  Country(code: 'CL', name: 'Chili', dialCode: '+56', flag: '🇨🇱', minLength: 9, maxLength: 9),
  Country(code: 'PE', name: 'Pérou', dialCode: '+51', flag: '🇵🇪', minLength: 9, maxLength: 9),
  Country(code: 'VE', name: 'Venezuela', dialCode: '+58', flag: '🇻🇪', minLength: 10, maxLength: 10),
  Country(code: 'EC', name: 'Équateur', dialCode: '+593', flag: '🇪🇨', minLength: 9, maxLength: 9),
  Country(code: 'HT', name: 'Haïti', dialCode: '+509', flag: '🇭🇹', minLength: 8, maxLength: 8),
  Country(code: 'DO', name: 'République Dominicaine', dialCode: '+1', flag: '🇩🇴', minLength: 10, maxLength: 10),
  Country(code: 'CU', name: 'Cuba', dialCode: '+53', flag: '🇨🇺', minLength: 8, maxLength: 8),
  Country(code: 'JM', name: 'Jamaïque', dialCode: '+1', flag: '🇯🇲', minLength: 10, maxLength: 10),
  Country(code: 'GP', name: 'Guadeloupe', dialCode: '+590', flag: '🇬🇵', minLength: 9, maxLength: 9),
  Country(code: 'MQ', name: 'Martinique', dialCode: '+596', flag: '🇲🇶', minLength: 9, maxLength: 9),
  Country(code: 'GF', name: 'Guyane française', dialCode: '+594', flag: '🇬🇫', minLength: 9, maxLength: 9),
  Country(code: 'RE', name: 'La Réunion', dialCode: '+262', flag: '🇷🇪', minLength: 9, maxLength: 9),
  
  // Asie
  Country(code: 'CN', name: 'Chine', dialCode: '+86', flag: '🇨🇳', minLength: 11, maxLength: 11),
  Country(code: 'JP', name: 'Japon', dialCode: '+81', flag: '🇯🇵', minLength: 10, maxLength: 10),
  Country(code: 'KR', name: 'Corée du Sud', dialCode: '+82', flag: '🇰🇷', minLength: 10, maxLength: 10),
  Country(code: 'IN', name: 'Inde', dialCode: '+91', flag: '🇮🇳', minLength: 10, maxLength: 10),
  Country(code: 'ID', name: 'Indonésie', dialCode: '+62', flag: '🇮🇩', minLength: 10, maxLength: 12),
  Country(code: 'TH', name: 'Thaïlande', dialCode: '+66', flag: '🇹🇭', minLength: 9, maxLength: 9),
  Country(code: 'VN', name: 'Vietnam', dialCode: '+84', flag: '🇻🇳', minLength: 9, maxLength: 10),
  Country(code: 'PH', name: 'Philippines', dialCode: '+63', flag: '🇵🇭', minLength: 10, maxLength: 10),
  Country(code: 'MY', name: 'Malaisie', dialCode: '+60', flag: '🇲🇾', minLength: 9, maxLength: 10),
  Country(code: 'SG', name: 'Singapour', dialCode: '+65', flag: '🇸🇬', minLength: 8, maxLength: 8),
  Country(code: 'HK', name: 'Hong Kong', dialCode: '+852', flag: '🇭🇰', minLength: 8, maxLength: 8),
  Country(code: 'TW', name: 'Taïwan', dialCode: '+886', flag: '🇹🇼', minLength: 9, maxLength: 9),
  Country(code: 'PK', name: 'Pakistan', dialCode: '+92', flag: '🇵🇰', minLength: 10, maxLength: 10),
  Country(code: 'BD', name: 'Bangladesh', dialCode: '+880', flag: '🇧🇩', minLength: 10, maxLength: 10),
  Country(code: 'LK', name: 'Sri Lanka', dialCode: '+94', flag: '🇱🇰', minLength: 9, maxLength: 9),
  Country(code: 'NP', name: 'Népal', dialCode: '+977', flag: '🇳🇵', minLength: 10, maxLength: 10),
  Country(code: 'AE', name: 'Émirats arabes unis', dialCode: '+971', flag: '🇦🇪', minLength: 9, maxLength: 9),
  Country(code: 'SA', name: 'Arabie saoudite', dialCode: '+966', flag: '🇸🇦', minLength: 9, maxLength: 9),
  Country(code: 'QA', name: 'Qatar', dialCode: '+974', flag: '🇶🇦', minLength: 8, maxLength: 8),
  Country(code: 'KW', name: 'Koweït', dialCode: '+965', flag: '🇰🇼', minLength: 8, maxLength: 8),
  Country(code: 'BH', name: 'Bahreïn', dialCode: '+973', flag: '🇧🇭', minLength: 8, maxLength: 8),
  Country(code: 'OM', name: 'Oman', dialCode: '+968', flag: '🇴🇲', minLength: 8, maxLength: 8),
  Country(code: 'JO', name: 'Jordanie', dialCode: '+962', flag: '🇯🇴', minLength: 9, maxLength: 9),
  Country(code: 'LB', name: 'Liban', dialCode: '+961', flag: '🇱🇧', minLength: 7, maxLength: 8),
  Country(code: 'IL', name: 'Israël', dialCode: '+972', flag: '🇮🇱', minLength: 9, maxLength: 9),
  
  // Océanie
  Country(code: 'AU', name: 'Australie', dialCode: '+61', flag: '🇦🇺', minLength: 9, maxLength: 9),
  Country(code: 'NZ', name: 'Nouvelle-Zélande', dialCode: '+64', flag: '🇳🇿', minLength: 9, maxLength: 10),
  Country(code: 'PF', name: 'Polynésie française', dialCode: '+689', flag: '🇵🇫', minLength: 6, maxLength: 6),
  Country(code: 'NC', name: 'Nouvelle-Calédonie', dialCode: '+687', flag: '🇳🇨', minLength: 6, maxLength: 6),
];

/// Pays par défaut (Côte d'Ivoire)
const String defaultCountryCode = 'CI';

/// Récupère le pays par défaut
Country get defaultCountry => countries.firstWhere((c) => c.code == defaultCountryCode);

/// Trouve un pays par son code ISO
Country? getCountryByCode(String code) {
  try {
    return countries.firstWhere((c) => c.code == code.toUpperCase());
  } catch (_) {
    return null;
  }
}

/// Trouve un pays par son indicatif
Country? getCountryByDialCode(String dialCode) {
  try {
    return countries.firstWhere((c) => c.dialCode == dialCode);
  } catch (_) {
    return null;
  }
}

/// Recherche des pays par nom ou indicatif
List<Country> searchCountries(String query) {
  if (query.isEmpty) return countries;
  
  final lowerQuery = query.toLowerCase();
  return countries.where((c) {
    return c.name.toLowerCase().contains(lowerQuery) ||
           c.dialCode.contains(query) ||
           c.code.toLowerCase().contains(lowerQuery);
  }).toList();
}
