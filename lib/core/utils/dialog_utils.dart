import 'package:flutter/material.dart';
import '../../shared/widgets/info_modal.dart';

/// Utilitaires pour afficher des dialogues informatifs.
///
/// Utilise le `rootNavigatorKey` global pour afficher des modales
/// même depuis des callbacks hors widget (ex: erreurs réseau).
class DialogUtils {
  DialogUtils._();

  /// Affiche une modale d'erreur.
  static Future<bool> showError(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'Compris',
  }) {
    return InfoModal.showError(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Affiche une modale de succès.
  static Future<bool> showSuccess(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'OK',
  }) {
    return InfoModal.showSuccess(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Affiche une modale d'avertissement.
  static Future<bool> showWarning(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'Compris',
  }) {
    return InfoModal.showWarning(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Affiche une modale d'information.
  static Future<bool> showInfo(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'OK',
  }) {
    return InfoModal.showInfo(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Affiche une modale de confirmation avec 2 boutons.
  /// Retourne `true` si l'utilisateur confirme, `false` sinon.
  static Future<bool> showConfirm(
    BuildContext context, {
    String? title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    InfoModalType type = InfoModalType.warning,
  }) {
    return InfoModal.showConfirm(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      type: type,
    );
  }

  /// Extrait un message d'erreur lisible depuis une exception.
  static String extractErrorMessage(dynamic error) {
    if (error == null) return 'Une erreur inconnue est survenue.';
    
    final str = error.toString();
    
    // Nettoyer les préfixes courants
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    if (str.startsWith('ServerException: ')) {
      return str.substring(17);
    }
    if (str.contains('SocketException')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    }
    if (str.contains('TimeoutException') || str.contains('Délai dépassé')) {
      return 'La requête a pris trop de temps. Veuillez réessayer.';
    }
    if (str.contains('FormatException')) {
      return 'Erreur de format de données. Veuillez réessayer.';
    }
    
    // Message par défaut si trop technique
    if (str.length > 150 || str.contains('Stack') || str.contains('at ')) {
      return 'Une erreur technique est survenue. Veuillez réessayer.';
    }
    
    return str;
  }

  /// Affiche une erreur à partir d'une exception (avec extraction automatique du message).
  static Future<bool> showErrorFromException(
    BuildContext context,
    dynamic error, {
    String? title,
  }) {
    return showError(
      context,
      title: title,
      message: extractErrorMessage(error),
    );
  }
}
