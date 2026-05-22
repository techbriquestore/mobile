import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _companyCtrl;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _companyCtrl = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // D'abord essayer depuis le state
    final stateUser = ref.read(authProvider).user;
    if (stateUser != null && stateUser.firstName.isNotEmpty) {
      _fillControllers(stateUser);
      setState(() => _isLoading = false);
      return;
    }

    // Sinon charger depuis le backend
    try {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      if (mounted) {
        _fillControllers(user);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillControllers(dynamic user) {
    _firstNameCtrl.text = user.firstName ?? '';
    _lastNameCtrl.text = user.lastName ?? '';
    _phoneCtrl.text = user.phone ?? '';
    _emailCtrl.text = user.email ?? '';
    _companyCtrl.text = user.companyName ?? '';
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(authProvider.notifier).completeProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        companyName: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
          centerTitle: true,
          title: const Text('Mes informations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes informations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(radius: 48, backgroundColor: Colors.grey.shade200, child: Icon(Icons.person, size: 48, color: Colors.grey.shade400)),
                        Positioned(bottom: 0, right: 0,
                          child: Container(width: 32, height: 32,
                            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  _Label('PRÉNOM'),
                  TextFormField(controller: _firstNameCtrl, decoration: _inputDeco('Prénom', Icons.person_outline)),
                  const SizedBox(height: 16),

                  _Label('NOM'),
                  TextFormField(controller: _lastNameCtrl, decoration: _inputDeco('Nom', Icons.person_outline)),
                  const SizedBox(height: 16),

                  _Label('TÉLÉPHONE'),
                  TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: _inputDeco('07 xx xx xx xx', Icons.phone_outlined)),
                  const SizedBox(height: 16),

                  _Label('EMAIL'),
                  TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: _inputDeco('email@exemple.com', Icons.alternate_email)),
                  const SizedBox(height: 16),

                  _Label('ENTREPRISE (optionnel)'),
                  TextFormField(controller: _companyCtrl, decoration: _inputDeco('Nom de l\'entreprise', Icons.business_outlined)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28), color: Colors.white,
            child: SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: _isSaving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600, letterSpacing: 0.5)),
    );
  }
}
