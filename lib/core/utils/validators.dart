import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.trim().length < 2) return 'Le nom doit contenir au moins 2 caractÃ¨res';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Le numÃ©ro de tÃ©lÃ©phone est requis';
    if (value.length != AppConstants.phoneNumberLength) return 'Le numÃ©ro doit contenir ${AppConstants.phoneNumberLength} chiffres';
    if (!AppConstants.validPhonePrefixes.any((p) => value.startsWith(p))) return 'Le numÃ©ro doit commencer par 07, 05 ou 01';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) return 'Adresse email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < AppConstants.minPasswordLength) return 'Min ${AppConstants.minPasswordLength} caractÃ¨res';
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'Le code PIN est requis';
    if (value.length != AppConstants.pinLength || !RegExp(r'^\d+$').hasMatch(value)) return 'Le PIN doit Ãªtre de ${AppConstants.pinLength} chiffres';
    return null;
  }

  static String? required(String? value, [String field = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) return '$field est requis';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'La valeur']) {
    if (value == null || value.isEmpty) return '$field est requis';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return '$field doit Ãªtre un nombre positif';
    return null;
  }
}
