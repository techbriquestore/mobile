import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../../../profile/data/providers/address_providers.dart';
import '../../../profile/presentation/screens/add_address_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;

  // ─── Payment plan (échelonné uniquement) ───
  int _installments = 3;
  bool _acceptedCGV = false;

  // ─── Correspondant secondaire (optionnel) ───
  bool _hasSecondaryContact = false;
  final _secondaryNameController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _secondaryNoteController = TextEditingController();

  // Frais de livraison — mode Standard uniquement
  static const double _deliveryFee = 15000;
  double _getTotal(double subtotal) => subtotal + _deliveryFee;
  double _getFirstPayment(double total) => (total * 0.15).ceilToDouble();
  double _getInstallmentAmount(double total, double firstPayment) => 
      ((total - firstPayment) / (_installments - 1)).ceilToDouble();
  bool get _hasFees => _installments > 4;
  double _getFees(double total) => _hasFees ? (total * 0.02) : 0;
  double _getGrandTotal(double total) => total + _getFees(total);


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(addressProvider.notifier).loadAddresses();
    });
  }

  @override
  void dispose() {
    _secondaryNameController.dispose();
    _secondaryPhoneController.dispose();
    _secondaryNoteController.dispose();
    super.dispose();
  }

  IconData _iconForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('chantier')) return Icons.construction;
    if (l.contains('bureau')) return Icons.business;
    if (l.contains('entrepôt') || l.contains('entrepot')) return Icons.warehouse;
    if (l.contains('domicile') || l.contains('maison')) return Icons.home_outlined;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    
    // Redirect to login if not authenticated
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(
            content: Text('Veuillez vous connecter pour passer commande'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ));
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final total = _getTotal(subtotal);
    final firstPayment = _getFirstPayment(total);
    final installmentAmount = _getInstallmentAmount(total, firstPayment);
    final fees = _getFees(total);
    final grandTotal = _getGrandTotal(total);

    // Redirect to cart if empty
    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/cart');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Finaliser la commande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ═══════════════ STEP 1 : Adresse de livraison ═══════════════
                  _SectionHeader(number: '1', title: 'Adresse de livraison'),
                  _buildAddressSection(),

                  const SizedBox(height: 8),

                  // ═══════════════ STEP 2 : Mode de livraison ═══════════════
                  _SectionHeader(number: '2', title: 'Mode de livraison'),
                  _SelectableCard(
                    selected: true,
                    onTap: () {},
                    icon: Icons.local_shipping_outlined,
                    title: 'Standard',
                    subtitle: '3 à 5 jours ouvrés',
                    trailing: Text('15 000 FCFA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),

                  const SizedBox(height: 8),

                  // ═══════════════ STEP 3 : Plan de paiement échelonné ═══════════════
                  _SectionHeader(number: '3', title: 'Paiement échelonné'),
                  const SizedBox(height: 4),
                    // Installment selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nombre d\'échéances', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            Row(
                              children: [2, 3, 4, 6, 12].map((n) {
                                final sel = _installments == n;
                                final hasExtraFee = n > 4;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _installments = n),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: sel ? AppColors.primary : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        children: [
                                          Text('${n}x', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textPrimary)),
                                          if (hasExtraFee)
                                            Text('+ frais', style: TextStyle(fontSize: 9, color: sel ? Colors.white70 : AppColors.error)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Installment summary
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _SummaryRow(label: '1er versement (15%)', value: '${_fmt(firstPayment)} FCFA', bold: true),
                                  const SizedBox(height: 6),
                                  _SummaryRow(label: '${_installments - 1} échéances de', value: '${_fmt(installmentAmount)} FCFA'),
                                  if (_hasFees) ...[
                                    const SizedBox(height: 6),
                                    _SummaryRow(label: 'Frais de gestion (2%)', value: '${_fmt(fees)} FCFA', color: AppColors.error),
                                  ],
                                  const SizedBox(height: 4),
                                  const Divider(),
                                  _SummaryRow(label: 'Total à payer', value: '${_fmt(grandTotal)} FCFA', bold: true, color: AppColors.primary),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline, size: 16, color: AppColors.info),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Prix bloqué et garanti pour toute la durée. Livraison après paiement complet ou par tranche selon l\'échéancier.',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),

                  // ═══════════════ STEP 4 : Récapitulatif ═══════════════
                  _SectionHeader(number: '4', title: 'Récapitulatif de la commande'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        _SummaryRow(label: 'Sous-total articles (${cart.itemCount})', value: '${_fmt(subtotal)} FCFA'),
                        const SizedBox(height: 10),
                        _SummaryRow(label: 'Frais de livraison', value: '${_fmt(_deliveryFee)} FCFA'),
                        if (_hasFees) ...[
                          const SizedBox(height: 10),
                          _SummaryRow(label: 'Frais de gestion', value: '${_fmt(fees)} FCFA', color: AppColors.error),
                        ],
                        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
                        _SummaryRow(
                          label: 'Total',
                          value: '${_fmt(grandTotal)} FCFA',
                          bold: true, color: AppColors.primary, large: true,
                        ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'À payer maintenant : ${_fmt(firstPayment)} FCFA',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ═══════════════ CORRESPONDANT SECONDAIRE (optionnel) ═══════════════
                  _buildSecondaryContactSection(),

                  const SizedBox(height: 8),

                  // ─── CGV acceptance ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _acceptedCGV = !_acceptedCGV),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: _acceptedCGV,
                              onChanged: (v) => setState(() => _acceptedCGV = v ?? false),
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'J\'accepte les ',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                children: const [
                                  TextSpan(text: 'Conditions Générales de Vente', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ═══════════════ Proceed to Payment ═══════════════
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1er versement (15%)',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    Text(
                      '${_fmt(firstPayment)} FCFA',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: (_acceptedCGV && _selectedAddressId != null) ? () => context.push('/payment', extra: {
                      'amount': firstPayment,
                      'orderId': 'NEW', // Will be created by backend
                      'isFirstPayment': true,
                      'totalInstallments': _installments,
                      'cartItems': ref.read(cartProvider.notifier).toOrderItems(),
                      'deliveryMode': 0, // Standard uniquement
                      'addressId': _selectedAddressId,
                      if (_hasSecondaryContact && _secondaryNameController.text.trim().isNotEmpty) ...{
                        'secondaryContactName': _secondaryNameController.text.trim(),
                        'secondaryContactPhone': _secondaryPhoneController.text.replaceAll(' ', ''),
                        if (_secondaryNoteController.text.trim().isNotEmpty)
                          'secondaryContactNote': _secondaryNoteController.text.trim(),
                      },
                    }) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                    ),
                    child: Text(
                      'Payer le 1er versement',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    final addrState = ref.watch(addressProvider);
    final addresses = addrState.addresses;

    // Loading
    if (addrState.status == AddressStatus.loading && addresses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // No addresses
    if (addresses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Column(
            children: [
              Icon(Icons.location_off_outlined, size: 40, color: Colors.orange.shade300),
              const SizedBox(height: 10),
              Text(
                'Aucune adresse enregistrée',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Text(
                'Ajoutez une adresse de livraison dans le Grand Abidjan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                    );
                    if (mounted) {
                      ref.read(addressProvider.notifier).loadAddresses();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter une adresse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Auto-select default address
    if (_selectedAddressId == null) {
      final def = addrState.defaultAddress;
      if (def != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedAddressId = def.id);
        });
      }
    }

    return Column(
      children: [
        ...addresses.map((addr) {
          final selected = _selectedAddressId == addr.id;
          return _SelectableCard(
            selected: selected,
            onTap: () => setState(() => _selectedAddressId = addr.id),
            icon: _iconForLabel(addr.label),
            title: addr.label,
            subtitle: addr.displayAddress,
            trailing: addr.isDefault && !selected
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Défaut', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  )
                : null,
          );
        }),
        // Add new address button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAddressScreen()),
              );
              if (mounted) {
                ref.read(addressProvider.notifier).loadAddresses();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text('Nouvelle adresse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Correspondant secondaire',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                Text('Optionnel', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Personne sur place qui pourra réceptionner votre commande si vous n\'êtes pas disponible.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _hasSecondaryContact,
              onChanged: (v) => setState(() => _hasSecondaryContact = v),
              title: const Text('Ajouter un correspondant', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            if (_hasSecondaryContact) ...[              
              const SizedBox(height: 8),
              TextFormField(
                controller: _secondaryNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Nom complet du correspondant',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _secondaryPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Téléphone du correspondant',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _secondaryNoteController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Note (optionnel) - ex: Disponible le matin uniquement',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Icon(Icons.note_outlined, color: AppColors.primary, size: 20),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ═══════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String number, title;
  const _SectionHeader({required this.number, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;

  const _SelectableCard({required this.selected, required this.onTap, required this.icon, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: selected ? AppColors.primary : Colors.grey.shade500, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (selected && trailing == null) const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final bool large;
  final Color? color;
  const _SummaryRow({required this.label, required this.value, this.bold = false, this.large = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: large ? 16 : 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? AppColors.textPrimary : Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: large ? 20 : 15, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}
