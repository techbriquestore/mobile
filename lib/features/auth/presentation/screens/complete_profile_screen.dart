import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/auth_providers.dart';

/// Écran de complétion du profil après inscription OTP.
///
/// Cet écran est OBLIGATOIRE et ne peut pas être ignoré :
/// - PAS de bouton "Passer"
/// - PAS de bouton retour
/// - PAS de croix de fermeture
/// - Le bouton Valider est désactivé tant que le nom n'est pas valide
///
/// L'utilisateur DOIT renseigner son nom et prénom pour continuer.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  /// Type de client sélectionné
  String _clientType = 'PARTICULIER';

  /// Champs professionnels (affichés si clientType == PROFESSIONNEL)
  final _companyNameController = TextEditingController();
  final _sectorController = TextEditingController();
  final _taxIdController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _sectorController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  /// Vérifie si le formulaire est valide pour activer le bouton
  bool get _isFormValid {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    // Nom et prénom obligatoires (min 2 caractères)
    if (firstName.length < 2 || lastName.length < 2) {
      return false;
    }

    // Si professionnel, le nom de l'entreprise est obligatoire
    if (_clientType == 'PROFESSIONNEL') {
      final companyName = _companyNameController.text.trim();
      if (companyName.length < 2) {
        return false;
      }
    }

    return true;
  }

  /// Valide le prénom
  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre prénom';
    }
    if (value.trim().length < 2) {
      return 'Le prénom doit contenir au moins 2 caractères';
    }
    return null;
  }

  /// Valide le nom
  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre nom';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  /// Valide l'email (optionnel)
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email optionnel
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Adresse email invalide';
    }
    return null;
  }

  /// Soumet le formulaire
  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).completeProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
            clientType: _clientType,
            companyName: _clientType == 'PROFESSIONNEL'
                ? _companyNameController.text.trim()
                : null,
            sector: _clientType == 'PROFESSIONNEL' &&
                    _sectorController.text.trim().isNotEmpty
                ? _sectorController.text.trim()
                : null,
            taxId: _clientType == 'PROFESSIONNEL' &&
                    _taxIdController.text.trim().isNotEmpty
                ? _taxIdController.text.trim()
                : null,
          );

      if (!mounted) return;

      // Profil complété → aller au catalogue
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _parseError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Parse les erreurs de l'API
  String _parseError(String error) {
    if (error.contains('email est déjà utilisée')) {
      return 'Cette adresse email est déjà utilisée.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Masque partiellement le numéro de téléphone
  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    final start = phone.substring(0, 4);
    final end = phone.substring(phone.length - 2);
    return '$start****$end';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Empêcher le retour arrière
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        // PAS d'AppBar avec bouton retour
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Icône
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titre
                  const Text(
                    'Complétez votre profil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sous-titre
                  Text(
                    'Ces informations sont nécessaires pour passer vos commandes.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Numéro de téléphone déjà vérifié
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Numéro de téléphone',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Consumer(
                                builder: (context, ref, _) {
                                  final authState = ref.watch(authProvider);
                                  final user = authState.user;
                                  final phone = user?.phone ?? '';
                                  return Text(
                                    _maskPhone(phone),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Champ Prénom
                  TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    validator: _validateFirstName,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      label: 'Prénom *',
                      hint: 'Ex: Jean',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Champ Nom
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    validator: _validateLastName,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      label: 'Nom *',
                      hint: 'Ex: Dupont',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Champ Email (optionnel)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    decoration: _inputDecoration(
                      label: 'Email (optionnel)',
                      hint: 'Ex: jean.dupont@email.com',
                      icon: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sélection du type de client
                  const Text(
                    'Type de compte',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ClientTypeCard(
                          title: 'Particulier',
                          icon: Icons.person,
                          isSelected: _clientType == 'PARTICULIER',
                          onTap: () =>
                              setState(() => _clientType = 'PARTICULIER'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ClientTypeCard(
                          title: 'Professionnel',
                          icon: Icons.business,
                          isSelected: _clientType == 'PROFESSIONNEL',
                          onTap: () =>
                              setState(() => _clientType = 'PROFESSIONNEL'),
                        ),
                      ),
                    ],
                  ),

                  // Champs professionnels
                  if (_clientType == 'PROFESSIONNEL') ...[
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _companyNameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        label: 'Nom de l\'entreprise *',
                        hint: 'Ex: SARL Construction Plus',
                        icon: Icons.business,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sectorController,
                      decoration: _inputDecoration(
                        label: 'Secteur d\'activité',
                        hint: 'Ex: BTP, Commerce...',
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxIdController,
                      decoration: _inputDecoration(
                        label: 'N° d\'identification fiscale',
                        hint: 'Ex: CI-123456789',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                  ],

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

                  // Bouton Valider
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_isFormValid && !_isLoading)
                          ? _submitProfile
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
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Valider',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Décoration commune pour les champs de saisie
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}

/// Carte de sélection du type de client
class _ClientTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClientTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.primary : Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
