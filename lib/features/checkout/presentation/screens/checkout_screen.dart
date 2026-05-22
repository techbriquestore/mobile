import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/pricing_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../../../profile/data/providers/project_providers.dart';
import '../../../profile/presentation/screens/add_project_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum PaymentType { instant, installment }

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedProjectId;

  // ─── Type de paiement ───
  PaymentType _paymentType = PaymentType.instant;

  // ─── Payment plan (échelonné) ───
  int _months = PricingService.defaultDuration;
  bool _acceptedCGV = false;

  // ─── Correspondant secondaire (optionnel) ───
  bool _hasSecondaryContact = false;
  final _secondaryNameController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _secondaryNoteController = TextEditingController();

  // Utiliser PricingService pour tous les calculs
  PaymentPlan _getPaymentPlan(double subtotal) {
    return PricingService.calculatePaymentPlan(
      subtotal: subtotal,
      months: _months,
    );
  }


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(projectProvider.notifier).loadProjects();
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
        context.go('/auth/phone');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Utiliser PricingService pour tous les calculs
    final plan = _getPaymentPlan(subtotal);
    final total = plan.total;
    final firstPayment = plan.deposit;
    final installmentAmount = plan.installmentAmount;
    final fees = plan.managementFee;
    final grandTotal = plan.grandTotal;

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

                  // ═══════════════ STEP 1 : Projet de livraison ═══════════════
                  _SectionHeader(number: '1', title: 'Projet de livraison'),
                  _buildProjectSection(),

                  const SizedBox(height: 8),

                  // ═══════════════ STEP 2 : Mode de livraison ═══════════════
                  _SectionHeader(number: '2', title: 'Mode de livraison'),
                  _SelectableCard(
                    selected: true,
                    onTap: () {},
                    icon: Icons.local_shipping_outlined,
                    title: 'Standard',
                    subtitle: '3 à 5 jours ouvrés',
                    trailing: Text('${_fmt(PricingService.deliveryFeeStandard)} FCFA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),

                  const SizedBox(height: 8),

                  // ═══════════════ STEP 3 : Type de paiement ═══════════════
                  _SectionHeader(number: '3', title: 'Mode de paiement'),
                  _SelectableCard(
                    selected: _paymentType == PaymentType.instant,
                    onTap: () => setState(() => _paymentType = PaymentType.instant),
                    icon: Icons.flash_on_outlined,
                    title: 'Paiement instantané',
                    subtitle: 'Payez le montant total maintenant',
                  ),
                  _SelectableCard(
                    selected: _paymentType == PaymentType.installment,
                    onTap: () => setState(() => _paymentType = PaymentType.installment),
                    icon: Icons.calendar_month_outlined,
                    title: 'Paiement échelonné',
                    subtitle: '2 paiements par mois sur 3 à 12 mois',
                  ),

                  const SizedBox(height: 8),

                  // ═══════════════ STEP 4 : Plan de paiement échelonné (si sélectionné) ═══════════════
                  if (_paymentType == PaymentType.installment) ...[                    _SectionHeader(number: '4', title: 'Détails de l\'échelonnement'),
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
                            const Text('Durée de paiement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: PricingService.availableMonths.map((n) {
                                final sel = _months == n;
                                final hasExtraFee = PricingService.hasManagementFee(n);
                                return GestureDetector(
                                  onTap: () => setState(() => _months = n),
                                  child: Container(
                                    width: 72,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: sel ? AppColors.primary : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('$n mois', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textPrimary)),
                                        Text('${n * 2} éch.', style: TextStyle(fontSize: 10, color: sel ? Colors.white70 : Colors.grey.shade500)),
                                        if (hasExtraFee)
                                          Text('+ frais', style: TextStyle(fontSize: 9, color: sel ? Colors.white70 : AppColors.error)),
                                      ],
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
                                  _SummaryRow(label: '1er versement (${Formatters.percentage(PricingService.depositRate)})', value: '${_fmt(firstPayment)} FCFA', bold: true),
                                  const SizedBox(height: 6),
                                  _SummaryRow(label: '$_months mois × ${PricingService.paymentsPerMonth} paiem./mois', value: '${plan.totalPayments} échéances'),
                                  const SizedBox(height: 6),
                                  _SummaryRow(label: '${plan.regularPaymentsCount} échéances de', value: '${_fmt(installmentAmount)} FCFA'),
                                  if (plan.hasManagementFee) ...[
                                    const SizedBox(height: 6),
                                    _SummaryRow(label: 'Frais de gestion (${Formatters.percentage(PricingService.managementFeeRate)})', value: '${_fmt(fees)} FCFA', color: AppColors.error),
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
                                    '2 paiements par mois. Prix bloqué et garanti pour toute la durée. Livraison après paiement complet ou par tranche selon l\'échéancier.',
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

                  // ═══════════════ STEP 5 : Récapitulatif ═══════════════
                  _SectionHeader(number: _paymentType == PaymentType.instant ? '4' : '5', title: 'Récapitulatif de la commande'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        _SummaryRow(label: 'Sous-total articles (${cart.itemCount})', value: '${_fmt(subtotal)} FCFA'),
                        const SizedBox(height: 10),
                        _SummaryRow(label: 'Frais de livraison', value: '${_fmt(plan.deliveryFee)} FCFA'),
                        if (_paymentType == PaymentType.installment && plan.hasManagementFee) ...[
                          const SizedBox(height: 10),
                          _SummaryRow(label: 'Frais de gestion', value: '${_fmt(fees)} FCFA', color: AppColors.error),
                        ],
                        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
                        _SummaryRow(
                          label: 'Total',
                          value: '${_fmt(_paymentType == PaymentType.instant ? total : grandTotal)} FCFA',
                          bold: true, color: AppColors.primary, large: true,
                        ),
                        if (_paymentType == PaymentType.installment) ...[
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
                      _paymentType == PaymentType.instant ? 'Montant total' : '1er versement (15%)',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    Text(
                      _paymentType == PaymentType.instant ? '${_fmt(total)} FCFA' : '${_fmt(firstPayment)} FCFA',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: (_acceptedCGV && _selectedProjectId != null) ? () => context.push('/payment', extra: {
                      'paymentType': _paymentType == PaymentType.instant ? 'instant' : 'installment',
                      'amount': _paymentType == PaymentType.instant ? total : firstPayment,
                      'orderId': 'NEW', // Will be created by backend
                      'isFirstPayment': _paymentType == PaymentType.installment,
                      if (_paymentType == PaymentType.installment) ...{
                        'totalInstallments': plan.totalPayments, // Total échéances (mois × 2)
                        'paymentDurationMonths': _months, // Durée en mois pour le backend
                      },
                      'cartItems': ref.read(cartProvider.notifier).toOrderItems(),
                      'deliveryMode': 0, // Standard uniquement
                      'addressId': _selectedProjectId,
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
                      _paymentType == PaymentType.instant ? 'Payer maintenant' : 'Payer le 1er versement',
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

  Widget _buildProjectSection() {
    final projState = ref.watch(projectProvider);
    final projects = projState.projects;

    // Loading
    if (projState.status == ProjectStatus.loading && projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // No projects
    if (projects.isEmpty) {
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
              Icon(Icons.foundation, size: 40, color: Colors.orange.shade300),
              const SizedBox(height: 10),
              Text(
                'Aucun projet enregistré',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Text(
                'Créez un projet de construction pour associer vos commandes',
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
                      MaterialPageRoute(builder: (_) => const AddProjectScreen()),
                    );
                    if (mounted) {
                      ref.read(projectProvider.notifier).loadProjects();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Créer un projet'),
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

    // Auto-select default project
    if (_selectedProjectId == null) {
      final def = projState.defaultProject;
      if (def != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedProjectId = def.id);
        });
      }
    }

    return Column(
      children: [
        ...projects.map((proj) {
          final selected = _selectedProjectId == proj.id;
          return _SelectableCard(
            selected: selected,
            onTap: () => setState(() => _selectedProjectId = proj.id),
            icon: Icons.foundation,
            title: proj.name,
            subtitle: proj.displayAddress,
            trailing: proj.isDefault && !selected
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
        // Add new project button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProjectScreen()),
              );
              if (mounted) {
                ref.read(projectProvider.notifier).loadProjects();
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
                  const Text('Nouveau projet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
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

  // Utiliser Formatters.priceCompact pour le formatage des prix
  String _fmt(double v) => Formatters.priceCompact(v);
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
