import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de stockage sécurisé pour les tokens.
///
/// Sur mobile (iOS/Android) : utilise flutter_secure_storage
/// Sur web/desktop : utilise shared_preferences
///
/// ⚠️ IMPORTANT : Le refresh token JAMAIS dans SharedPreferences sur mobile
class SecureTokenStorage {
  SharedPreferences? _prefs;
  FlutterSecureStorage? _secureStorage;

  /// Préfixe pour les clés de stockage sécurisé
  static const String _prefix = 'secure_';

  /// Initialise le service de stockage
  Future<void> init() async {
    if (_useSecureStorage) {
      _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );
    } else {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Détermine si on doit utiliser flutter_secure_storage
  bool get _useSecureStorage {
    // Sur mobile (iOS/Android), utiliser flutter_secure_storage
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return true;
    }
    // Sur web/desktop, utiliser shared_preferences
    return false;
  }

  /// Écrit une valeur de façon sécurisée
  Future<void> write({required String key, required String? value}) async {
    if (_useSecureStorage) {
      if (value == null) {
        await _secureStorage!.delete(key: '$_prefix$key');
      } else {
        await _secureStorage!.write(key: '$_prefix$key', value: value);
      }
    } else {
      _prefs ??= await SharedPreferences.getInstance();
      if (value == null) {
        await _prefs!.remove('$_prefix$key');
      } else {
        await _prefs!.setString('$_prefix$key', value);
      }
    }
  }

  /// Lit une valeur stockée de façon sécurisée
  Future<String?> read({required String key}) async {
    if (_useSecureStorage) {
      return await _secureStorage!.read(key: '$_prefix$key');
    } else {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.getString('$_prefix$key');
    }
  }

  /// Supprime une valeur stockée
  Future<void> delete({required String key}) async {
    if (_useSecureStorage) {
      await _secureStorage!.delete(key: '$_prefix$key');
    } else {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove('$_prefix$key');
    }
  }

  /// Supprime toutes les valeurs stockées avec le préfixe sécurisé
  Future<void> deleteAll() async {
    if (_useSecureStorage) {
      await _secureStorage!.deleteAll();
    } else {
      _prefs ??= await SharedPreferences.getInstance();
      final keys = _prefs!.getKeys().where((k) => k.startsWith(_prefix));
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    }
  }

  /// Vérifie si une clé existe
  Future<bool> containsKey({required String key}) async {
    if (_useSecureStorage) {
      final value = await _secureStorage!.read(key: '$_prefix$key');
      return value != null;
    } else {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.containsKey('$_prefix$key');
    }
  }

  /// Écrit une valeur booléenne (pour profileComplete)
  Future<void> writeBool({required String key, required bool value}) async {
    if (_useSecureStorage) {
      await _secureStorage!.write(key: '$_prefix$key', value: value.toString());
    } else {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setBool('$_prefix$key', value);
    }
  }

  /// Lit une valeur booléenne
  Future<bool?> readBool({required String key}) async {
    if (_useSecureStorage) {
      final value = await _secureStorage!.read(key: '$_prefix$key');
      if (value == null) return null;
      return value.toLowerCase() == 'true';
    } else {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.getBool('$_prefix$key');
    }
  }
}
