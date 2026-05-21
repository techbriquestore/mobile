import 'package:shared_preferences/shared_preferences.dart';

/// Service de stockage sécurisé pour les tokens.
///
/// Utilise SharedPreferences pour le développement.
/// Pour la production mobile, réactiver flutter_secure_storage.
///
/// Note: flutter_secure_storage désactivé temporairement car incompatible
/// avec les chemins Windows contenant des espaces.
class SecureTokenStorage {
  SharedPreferences? _prefs;

  /// Préfixe pour les clés de stockage sécurisé
  static const String _prefix = 'secure_';

  /// Initialise le service de stockage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Écrit une valeur de façon sécurisée
  Future<void> write({required String key, required String? value}) async {
    _prefs ??= await SharedPreferences.getInstance();
    if (value == null) {
      await _prefs!.remove('$_prefix$key');
    } else {
      await _prefs!.setString('$_prefix$key', value);
    }
  }

  /// Lit une valeur stockée de façon sécurisée
  Future<String?> read({required String key}) async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString('$_prefix$key');
  }

  /// Supprime une valeur stockée
  Future<void> delete({required String key}) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove('$_prefix$key');
  }

  /// Supprime toutes les valeurs stockées avec le préfixe sécurisé
  Future<void> deleteAll() async {
    _prefs ??= await SharedPreferences.getInstance();
    final keys = _prefs!.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  /// Vérifie si une clé existe
  Future<bool> containsKey({required String key}) async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.containsKey('$_prefix$key');
  }

  /// Écrit une valeur booléenne (pour profileComplete)
  Future<void> writeBool({required String key, required bool value}) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool('$_prefix$key', value);
  }

  /// Lit une valeur booléenne
  Future<bool?> readBool({required String key}) async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool('$_prefix$key');
  }
}
