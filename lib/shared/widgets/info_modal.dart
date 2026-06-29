import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Types de modales informatives.
enum InfoModalType {
  success,
  error,
  warning,
  info,
}

/// Configuration visuelle pour chaque type de modale.
class _ModalConfig {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String defaultTitle;

  const _ModalConfig({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.defaultTitle,
  });
}

/// Modale informative élégante pour remplacer les messages d'erreur bruts.
///
/// Usage :
/// ```dart
/// InfoModal.show(
///   context,
///   type: InfoModalType.error,
///   title: 'Connexion impossible',
///   message: 'Vérifiez votre connexion internet et réessayez.',
/// );
/// ```
class InfoModal extends StatelessWidget {
  final InfoModalType type;
  final String? title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool dismissible;

  const InfoModal({
    super.key,
    required this.type,
    this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.dismissible = true,
  });

  static final Map<InfoModalType, _ModalConfig> _configs = {
    InfoModalType.success: _ModalConfig(
      color: AppColors.success,
      bgColor: const Color(0xFFE8F5E9),
      icon: Icons.check_circle_rounded,
      defaultTitle: 'Succès',
    ),
    InfoModalType.error: _ModalConfig(
      color: AppColors.error,
      bgColor: const Color(0xFFFFEBEE),
      icon: Icons.error_rounded,
      defaultTitle: 'Erreur',
    ),
    InfoModalType.warning: _ModalConfig(
      color: AppColors.warning,
      bgColor: const Color(0xFFFFF8E1),
      icon: Icons.warning_rounded,
      defaultTitle: 'Attention',
    ),
    InfoModalType.info: _ModalConfig(
      color: AppColors.info,
      bgColor: const Color(0xFFE3F2FD),
      icon: Icons.info_rounded,
      defaultTitle: 'Information',
    ),
  };

  /// Affiche la modale et retourne `true` si le bouton principal est pressé.
  static Future<bool> show(
    BuildContext context, {
    required InfoModalType type,
    String? title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool dismissible = true,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'InfoModal',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => InfoModal(
        type: type,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        dismissible: dismissible,
      ),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
    return result ?? false;
  }

  /// Raccourci pour afficher une erreur.
  static Future<bool> showError(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'Compris',
  }) {
    return show(
      context,
      type: InfoModalType.error,
      title: title,
      message: message,
      primaryButtonText: buttonText,
    );
  }

  /// Raccourci pour afficher un succès.
  static Future<bool> showSuccess(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'OK',
  }) {
    return show(
      context,
      type: InfoModalType.success,
      title: title,
      message: message,
      primaryButtonText: buttonText,
    );
  }

  /// Raccourci pour afficher un avertissement.
  static Future<bool> showWarning(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'Compris',
  }) {
    return show(
      context,
      type: InfoModalType.warning,
      title: title,
      message: message,
      primaryButtonText: buttonText,
    );
  }

  /// Raccourci pour afficher une info.
  static Future<bool> showInfo(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = 'OK',
  }) {
    return show(
      context,
      type: InfoModalType.info,
      title: title,
      message: message,
      primaryButtonText: buttonText,
    );
  }

  /// Raccourci pour afficher une confirmation (2 boutons).
  static Future<bool> showConfirm(
    BuildContext context, {
    String? title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    InfoModalType type = InfoModalType.warning,
  }) {
    return show(
      context,
      type: type,
      title: title,
      message: message,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      dismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _configs[type]!;
    final displayTitle = title ?? config.defaultTitle;
    final primaryText = primaryButtonText ?? 'OK';

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Header avec icône ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: config.bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(config.icon, color: config.color, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: config.color,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Message ───
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              // ─── Boutons ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    if (secondaryButtonText != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            onSecondaryPressed?.call();
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            secondaryButtonText!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onPrimaryPressed?.call();
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: config.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          primaryText,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
