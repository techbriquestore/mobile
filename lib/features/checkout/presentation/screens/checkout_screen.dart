import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedAddress = 0;
  int _selectedDelivery = 0;

  // ─── Payment plan ───
  /// 0 = paiement complet, 1 = échelonné
  int _paymentType = 0;
  int _installments = 3;
  bool _acceptedCGV = false;

  // Mock data
  static const double _subtotal = 860000;
  static const double _deliveryFee = 15000;
  double get _total => _subtotal + _deliveryFee;
  double get _firstPayment => _paymentType == 0 ? _total : (_total * 0.15).ceilToDouble();
  double get _installmentAmount => _paymentType == 0 ? 0 : ((_total - _firstPayment) / (_installments - 1)).ceilToDouble();
  bool get _hasFees => _installments > 4;
  double get _fees => _hasFees ? (_total * 0.02) : 0;
  double get _grandTotal => _total + _fees;

  final _addresses = [
    {'label': 'Chantier Cocody', 'address': 'Cocody Riviera Palmeraie, Abidjan', 'icon': Icons.construction},
    {'label': 'Bureau', 'address': 'Plateau, Rue du Commerce, Abidjan', 'icon': Icons.business},
  ];

  final _deliveryModes = [
    {'label': 'Standard', 'sub': '3 à 5 jours ouvrés', 'price': '15 000 FCFA', 'icon': Icons.local_shipping_outlined},
    {'label': 'Express', 'sub': '48 heures', 'price': '35 000 FCFA', 'icon': Icons.bolt},
    {'label': 'Retrait en dépôt', 'sub': 'Jour J ou J+1 • Gratuit', 'price': 'Gratuit', 'icon': Icons.store_outlined},
  ];

  @override
  Widget build(BuildContext context) {
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
                  ...List.generate(_addresses.length, (i) {
                    final a = _addresses[i];
                    final selected = _selectedAddress == i;
                    return _SelectableCard(
                      selected: selected,
                      onTap: () => setState(() => _selectedAddress = i),
                      icon: a['icon'] as IconData,
                      title: a['label'] as String,
                      subtitle: a['address'] as String,
                    );
                  }),

                  const SizedBox(height: 8),

                  // ═══════════════ STEP 2 : Mode de livraison ═══════════════
                  _SectionHeader(number: '2', title: 'Mode de livraison'),
                  ...List.generate(_deliveryModes.length, (i) {
                    final d = _deliveryModes[i];
                    final selected = _selectedDelivery == i;
                    return _SelectableCard(
                      selected: selected,
                      onTap: () => setState(() => _selectedDelivery = i),
                      icon: d['icon'] as IconData,
                      title: d['label'] as String,
                      subtitle: d['sub'] as String,
                      trailing: Text(d['price'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : Colors.grey.shade500)),
                    );
                  }),

                  const SizedBox(height: 8),

                  // ═══════════════ STEP 3 : Plan de paiement ═══════════════
                  _SectionHeader(number: '3', title: 'Plan de paiement'),

                  // Toggle complet / échelonné
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _PaymentTypeChip(label: 'Paiement complet', selected: _paymentType == 0, onTap: () => setState(() => _paymentType = 0)),
                        const SizedBox(width: 10),
                        _PaymentTypeChip(label: 'Paiement échelonné', selected: _paymentType == 1, onTap: () => setState(() => _paymentType = 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_paymentType == 1) ...[
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
                                  _SummaryRow(label: '1er versement (15%)', value: '${_fmt(_firstPayment)} FCFA', bold: true),
                                  const SizedBox(height: 6),
                                  _SummaryRow(label: '${_installments - 1} échéances de', value: '${_fmt(_installmentAmount)} FCFA'),
                                  if (_hasFees) ...[
                                    const SizedBox(height: 6),
                                    _SummaryRow(label: 'Frais de gestion (2%)', value: '${_fmt(_fees)} FCFA', color: AppColors.error),
                                  ],
                                  const SizedBox(height: 4),
                                  const Divider(),
                                  _SummaryRow(label: 'Total à payer', value: '${_fmt(_grandTotal)} FCFA', bold: true, color: AppColors.primary),
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
                  ],

                  // ═══════════════ STEP 4 : Récapitulatif ═══════════════
                  _SectionHeader(number: '4', title: 'Récapitulatif de la commande'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        _SummaryRow(label: 'Sous-total articles', value: '${_fmt(_subtotal)} FCFA'),
                        const SizedBox(height: 10),
                        _SummaryRow(label: 'Frais de livraison', value: '${_fmt(_deliveryFee)} FCFA'),
                        if (_hasFees && _paymentType == 1) ...[
                          const SizedBox(height: 10),
                          _SummaryRow(label: 'Frais de gestion', value: '${_fmt(_fees)} FCFA', color: AppColors.error),
                        ],
                        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
                        _SummaryRow(
                          label: 'Total',
                          value: '${_fmt(_paymentType == 0 ? _total : _grandTotal)} FCFA',
                          bold: true, color: AppColors.primary, large: true,
                        ),
                        if (_paymentType == 1) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'À payer maintenant : ${_fmt(_firstPayment)} FCFA',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

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
                      _paymentType == 0 ? 'Total à payer' : '1er versement',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    Text(
                      _paymentType == 0 ? '${_fmt(_total)} FCFA' : '${_fmt(_firstPayment)} FCFA',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _acceptedCGV ? () => context.push('/payment', extra: {
                      'amount': _paymentType == 0 ? _total : _firstPayment,
                      'orderId': '2026-0042',
                      'isFirstPayment': _paymentType == 1,
                      'totalInstallments': _paymentType == 1 ? _installments : 1,
                    }) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                    ),
                    child: Text(
                      _paymentType == 0 ? 'Procéder au paiement' : 'Payer le 1er versement',
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

class _PaymentTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentTypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300, width: 1.5),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary))),
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
