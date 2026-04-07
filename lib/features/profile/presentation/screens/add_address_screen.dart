import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/providers/address_providers.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final AddressModel? address;

  const AddAddressScreen({super.key, this.address});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _landmarksController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _driverInstructionsController = TextEditingController();
  final _communeController = TextEditingController();

  String? _selectedCity;
  bool _isDefault = false;
  bool _isLoading = false;

  bool get _isEditing => widget.address != null;

  static const List<String> _labelSuggestions = [
    'Chantier',
    'Bureau',
    'Entrepôt',
    'Domicile',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.address!;
      _labelController.text = a.label;
      _fullAddressController.text = a.fullAddress;
      _landmarksController.text = a.landmarks ?? '';
      _contactNameController.text = a.contactName;
      _contactPhoneController.text = a.contactPhone;
      _driverInstructionsController.text = a.driverInstructions ?? '';
      _selectedCity = a.city;
      _communeController.text = a.commune ?? '';
      _isDefault = a.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullAddressController.dispose();
    _landmarksController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _driverInstructionsController.dispose();
    _communeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) return;

    setState(() => _isLoading = true);

    final data = {
      'label': _labelController.text.trim(),
      'fullAddress': _fullAddressController.text.trim(),
      if (_landmarksController.text.trim().isNotEmpty)
        'landmarks': _landmarksController.text.trim(),
      'city': _selectedCity!,
      if (_communeController.text.trim().isNotEmpty)
        'commune': _communeController.text.trim(),
      'contactName': _contactNameController.text.trim(),
      'contactPhone': _contactPhoneController.text.replaceAll(' ', ''),
      if (_driverInstructionsController.text.trim().isNotEmpty)
        'driverInstructions': _driverInstructionsController.text.trim(),
      'isDefault': _isDefault,
    };

    bool success;
    if (_isEditing) {
      success = await ref
          .read(addressProvider.notifier)
          .updateAddress(widget.address!.id, data);
    } else {
      success = await ref.read(addressProvider.notifier).createAddress(data);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Adresse modifiée' : 'Adresse ajoutée'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      final error = ref.read(addressProvider).errorMessage;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          if (required)
            const Text(' *',
                style: TextStyle(color: AppColors.error, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          _isEditing ? 'Modifier l\'adresse' : 'Nouvelle adresse',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Info zone Grand Abidjan ───
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'La livraison est actuellement disponible dans le Grand Abidjan uniquement.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── Libellé ───
                    _buildLabel('LIBELLÉ'),
                    TextFormField(
                      controller: _labelController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        hint: 'Ex: Chantier, Bureau...',
                        icon: Icons.label_outline,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le libellé est requis'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _labelSuggestions.map((s) {
                        final selected = _labelController.text == s;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _labelController.text = s);
                          },
                          child: Chip(
                            label: Text(s,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade700)),
                            backgroundColor: selected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    ),

                    // ─── Ville (Grand Abidjan) ───
                    _buildLabel('VILLE'),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: _inputDecoration(
                        hint: 'Sélectionnez une ville',
                        icon: Icons.location_city_outlined,
                      ),
                      items: grandAbidjanCities
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child:
                                  Text(c, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedCity = v;
                        _communeController.clear();
                      }),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'La ville est requise'
                          : null,
                    ),

                    // ─── Commune (si Abidjan) ───
                    if (_selectedCity == 'Abidjan') ...[
                      _buildLabel('COMMUNE'),
                      DropdownButtonFormField<String>(
                        value: _communeController.text.isEmpty
                            ? null
                            : _communeController.text,
                        decoration: _inputDecoration(
                          hint: 'Sélectionnez une commune',
                          icon: Icons.map_outlined,
                        ),
                        items: abidjanCommunes
                            .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(fontSize: 14))))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _communeController.text = v ?? ''),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'La commune est requise'
                            : null,
                      ),
                    ],
                    if (_selectedCity != null && _selectedCity != 'Abidjan') ...[
                      _buildLabel('QUARTIER / ZONE', required: false),
                      TextFormField(
                        controller: _communeController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          hint: 'Ex: Centre-ville, Zone industrielle...',
                          icon: Icons.map_outlined,
                        ),
                      ),
                    ],

                    // ─── Adresse complète ───
                    _buildLabel('ADRESSE COMPLÈTE'),
                    TextFormField(
                      controller: _fullAddressController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        hint: 'Rue, lot, bâtiment, étage...',
                        icon: Icons.location_on_outlined,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'L\'adresse est requise'
                          : null,
                    ),

                    // ─── Points de repère ───
                    _buildLabel('POINTS DE REPÈRE', required: false),
                    TextFormField(
                      controller: _landmarksController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        hint:
                            'Ex: Près de la pharmacie, après le carrefour...',
                        icon: Icons.explore_outlined,
                      ),
                    ),

                    // ─── Section contact ───
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_pin_circle_outlined,
                              color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Personne qui sera sur place pour réceptionner la livraison.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildLabel('NOM DU RÉCEPTIONNAIRE'),
                    TextFormField(
                      controller: _contactNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        hint: 'Nom complet',
                        icon: Icons.person_outline,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le nom du contact est requis'
                          : null,
                    ),

                    _buildLabel('TÉLÉPHONE DU RÉCEPTIONNAIRE'),
                    TextFormField(
                      controller: _contactPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        hint: '07 12 34 56 78',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le téléphone est requis';
                        }
                        final cleaned = value.replaceAll(' ', '');
                        if (!RegExp(r'^(07|05|01)\d{8}$').hasMatch(cleaned)) {
                          return 'Numéro ivoirien invalide';
                        }
                        return null;
                      },
                    ),

                    // ─── Instructions livreur ───
                    _buildLabel('INSTRUCTIONS POUR LE LIVREUR',
                        required: false),
                    TextFormField(
                      controller: _driverInstructionsController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        hint: 'Ex: Sonner 2 fois, portail bleu...',
                        icon: Icons.local_shipping_outlined,
                      ),
                    ),

                    // ─── Par défaut ───
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      title: const Text('Adresse par défaut',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Sera présélectionnée lors de vos commandes',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Save button ───
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        _isEditing
                            ? 'Enregistrer les modifications'
                            : 'Ajouter l\'adresse',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
