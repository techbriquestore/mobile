import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/auth_providers.dart';

/// Écran de vérification du code OTP à 6 chiffres.
///
/// Reçoit le numéro de téléphone et le purpose (INSCRIPTION ou CONNEXION)
/// via les paramètres de navigation.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final String? purpose;
  final String? debugCode;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.purpose,
    this.debugCode,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  /// Contrôleurs pour les 6 champs de saisie
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  String? _errorMessage;

  /// Compte à rebours pour le renvoi du code
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // En mode dev, pré-remplir le code si disponible
    if (widget.debugCode != null && widget.debugCode!.length == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDebugCodeSnackbar();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  /// Démarre le compte à rebours pour le renvoi du code
  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  /// Affiche le code de debug en mode développement
  void _showDebugCodeSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔧 Mode dev - Code OTP : ${widget.debugCode}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Copier',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.debugCode!));
          },
        ),
      ),
    );
  }

  /// Récupère le code OTP complet
  String get _code => _controllers.map((c) => c.text).join();

  /// Vérifie le code OTP
  Future<void> _verifyOtp() async {
    if (_code.length < 6) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(authProvider.notifier).verifyOtp(
            widget.phone,
            _code,
          );

      if (!mounted) return;

      final profileComplete = result['profileComplete'] as bool? ?? false;

      if (profileComplete) {
        // Profil complet → aller au catalogue
        context.go('/');
      } else {
        // Profil incomplet → aller à l'écran de complétion
        context.go('/auth/complete-profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _parseError(e.toString());
        // Vider les champs en cas d'erreur
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  /// Renvoie le code OTP
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(authProvider.notifier).requestOtp(
            widget.phone,
          );

      if (!mounted) return;

      _startResendTimer();

      // Afficher le nouveau code en mode dev
      if (result['debugCode'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔧 Nouveau code : ${result['debugCode']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 10),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un nouveau code a été envoyé.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = _parseError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  /// Parse les erreurs de l'API
  String _parseError(String error) {
    if (error.contains('Code incorrect')) {
      return 'Code incorrect. Veuillez réessayer.';
    }
    if (error.contains('expiré')) {
      return 'Ce code a expiré. Veuillez demander un nouveau code.';
    }
    if (error.contains('Trop de tentatives')) {
      return 'Trop de tentatives. Veuillez demander un nouveau code.';
    }
    if (error.contains('Aucun code en attente')) {
      return 'Aucun code en attente. Veuillez demander un nouveau code.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Masque partiellement le numéro de téléphone
  String get _maskedPhone {
    final phone = widget.phone;
    if (phone.length < 6) return phone;
    final start = phone.substring(0, 4);
    final end = phone.substring(phone.length - 2);
    return '$start****$end';
  }

  @override
  Widget build(BuildContext context) {
    final isNewUser = widget.purpose == 'INSCRIPTION';

    return Scaffold(
      backgroundColor: Colors.white,
      // PAS de bouton retour - l'utilisateur doit compléter le flux
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Icône
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Text(
                isNewUser ? 'Créez votre compte' : 'Vérification',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Entrez le code à 6 chiffres envoyé au ',
                    ),
                    TextSpan(
                      text: _maskedPhone,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Champs OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 1,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (value.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        setState(() {});

                        // Vérifier automatiquement quand tous les chiffres sont saisis
                        if (_code.length == 6) {
                          _verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),

              // Message d'erreur
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Bouton Vérifier
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_code.length == 6 && !_isVerifying)
                      ? _verifyOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Vérifier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Lien pour renvoyer le code
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas reçu de code ? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resendCountdown == 0 ? _resendOtp : null,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Renvoyer (${_resendCountdown}s)'
                            : 'Renvoyer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _resendCountdown > 0
                              ? Colors.grey.shade400
                              : AppColors.primary,
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
