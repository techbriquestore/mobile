import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../../../preorders/data/providers/preorder_providers.dart';
import '../../../preorders/domain/models/preorder.dart';
import '../../domain/models/order.dart';
import '../../data/providers/order_providers.dart';

// ════════════════════════════════════════════════════════
// Page unifiée "Mes Achats" : Commandes + Pré-commandes
// ════════════════════════════════════════════════════════

class OrdersScreen extends ConsumerStatefulWidget {
  /// Onglet initial : 0 = Commandes, 1 = Pré-commandes
  final int initialTab;
  const OrdersScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mes Achats',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 24, color: AppColors.textPrimary),
                onPressed: () => context.push('/cart'),
              ),
              if (ref.watch(cartProvider).itemCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Center(child: Text(
                      '${ref.watch(cartProvider).itemCount}',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                    )),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(
              icon: Icon(Icons.precision_manufacturing_outlined, size: 18),
              text: 'Commandes',
              iconMargin: EdgeInsets.only(bottom: 2),
            ),
            Tab(
              icon: Icon(Icons.calendar_month_outlined, size: 18),
              text: 'Pré-commandes',
              iconMargin: EdgeInsets.only(bottom: 2),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OrdersTab(),
          _PreordersTab(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// Onglet 1 : Commandes (paiement instantané + fabrication)
// ════════════════════════════════════════════════════════

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(orderFiltersProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return Column(
      children: [
        // ── Bandeau explicatif ──
        Container(
          color: const Color(0xFFFFF8F0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Paiement instantané · Suivi de fabrication inclus',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),

        // ── Filtres statuts ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _StatusChip(label: 'Toutes', isSelected: filters.status == null, color: AppColors.primary, onTap: () => ref.read(orderFiltersProvider.notifier).setStatus(null)),
                const SizedBox(width: 8),
                ...OrderStatus.values.where((s) => s != OrderStatus.returned).map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatusChip(label: s.label, isSelected: filters.status == s, color: s.color, onTap: () => ref.read(orderFiltersProvider.notifier).setStatus(s)),
                )),
              ],
            ),
          ),
        ),

        // ── Liste ──
        Expanded(
          child: ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _ErrorRetry(onRetry: () => ref.invalidate(ordersProvider)),
            data: (page) => page.data.isEmpty
                ? _EmptyState(
                    icon: Icons.precision_manufacturing_outlined,
                    title: 'Aucune commande',
                    subtitle: 'Passez une commande depuis le catalogue',
                    actionLabel: 'Voir le catalogue',
                    onAction: () => context.go('/catalog'),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => ref.invalidate(ordersProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: page.data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _OrderCard(order: page.data[i]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// Onglet 2 : Pré-commandes (paiement échelonné)
// ════════════════════════════════════════════════════════

class _PreordersTab extends ConsumerStatefulWidget {
  const _PreordersTab();

  @override
  ConsumerState<_PreordersTab> createState() => _PreordersTabState();
}

class _PreordersTabState extends ConsumerState<_PreordersTab> {
  String? _statusFilter;

  static const _statuses = [
    ('ACTIVE', 'En cours', AppColors.info),
    ('COMPLETED', 'Complétées', AppColors.success),
    ('SUSPENDED', 'Suspendues', Colors.orange),
    ('CANCELLED', 'Annulées', AppColors.error),
  ];

  @override
  Widget build(BuildContext context) {
    final preordersAsync = ref.watch(preordersProvider);

    return Column(
      children: [
        // ── Bandeau explicatif ──
        Container(
          color: const Color(0xFFF0F4FF),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Paiement échelonné · 2 versements/mois · Prix bloqué',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),

        // ── Filtres statuts ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _StatusChip(label: 'Toutes', isSelected: _statusFilter == null, color: AppColors.primary, onTap: () { setState(() => _statusFilter = null); ref.read(preorderFiltersProvider.notifier).setStatus(null); }),
                const SizedBox(width: 8),
                ..._statuses.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatusChip(label: s.$2, isSelected: _statusFilter == s.$1, color: s.$3, onTap: () { setState(() => _statusFilter = s.$1); ref.read(preorderFiltersProvider.notifier).setStatus(s.$1); }),
                )),
              ],
            ),
          ),
        ),

        // ── Liste ──
        Expanded(
          child: preordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _ErrorRetry(onRetry: () => ref.invalidate(preordersProvider)),
            data: (page) => page.data.isEmpty
                ? _EmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'Aucune pré-commande',
                    subtitle: 'Choisissez le paiement échelonné lors de votre prochaine commande',
                    actionLabel: 'Commander',
                    onAction: () => context.go('/catalog'),
                  )
                : RefreshIndicator(
                    color: AppColors.info,
                    onRefresh: () async => ref.invalidate(preordersProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: page.data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PreorderCard(preorder: page.data[i]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// Carte Commande — parcours de fabrication
// ════════════════════════════════════════════════════════

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  // Les étapes du parcours dans l'ordre
  static const _journey = [
    (OrderStatus.pendingValidation, 'Validée'),
    (OrderStatus.validated, 'Fabrication'),
    (OrderStatus.inPreparation, 'Expédition'),
    (OrderStatus.shipped, 'Livraison'),
    (OrderStatus.delivered, 'Terminée'),
  ];

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr_FR');
    final items = order.items;
    final isCancelled = order.status == OrderStatus.cancelled || order.status == OrderStatus.returned;

    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCancelled ? Border.all(color: Colors.red.shade100, width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // ── En-tête : réf + statut ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(6)),
                            child: const Text('CMD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 8),
                          Text(order.reference, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(fmt.format(order.date), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: order.status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(order.status.icon, size: 13, color: order.status.color),
                      const SizedBox(width: 5),
                      Text(order.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: order.status.color)),
                    ]),
                  ),
                ],
              ),
            ),

            // ── Produit ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.view_in_ar, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items.isEmpty ? 'Commande' : '${items.first.productName}${items.length > 1 ? '  +${items.length - 1}' : ''}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Parcours de fabrication ──
            if (!isCancelled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: _FabricationJourney(currentStatus: order.status, journey: _journey),
              ),

            if (isCancelled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(Icons.cancel_outlined, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 8),
                    Text('Commande annulée', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red.shade400)),
                  ]),
                ),
              ),

            // ── Pied : total + flèche ──
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    Text('${_fmt(order.total)} FCFA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ]),
                  Row(children: [
                    const Text('Détails', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.primary),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stepper linéaire pour le parcours de fabrication
class _FabricationJourney extends StatelessWidget {
  final OrderStatus currentStatus;
  final List<(OrderStatus, String)> journey;

  const _FabricationJourney({required this.currentStatus, required this.journey});

  @override
  Widget build(BuildContext context) {
    final currentIdx = journey.indexWhere((j) => j.$1 == currentStatus);
    // Si le statut n'est pas dans le parcours, on prend le dernier atteint
    final activeIdx = currentIdx == -1 ? 0 : currentIdx;

    return Row(
      children: List.generate(journey.length, (i) {
        final isDone = i < activeIdx;
        final isActive = i == activeIdx;
        final step = journey[i];
        final isLast = i == journey.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Cercle
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.success : isActive ? AppColors.primary : Colors.grey.shade200,
                        border: isActive ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3) : null,
                      ),
                      child: Center(child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Icon(step.$1.icon, size: 13, color: isActive ? Colors.white : Colors.grey.shade400)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      step.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isDone ? AppColors.success : isActive ? AppColors.primary : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              // Ligne de connexion
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: isDone ? AppColors.success.withValues(alpha: 0.4) : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════
// Carte Pré-commande — progression de paiement
// ════════════════════════════════════════════════════════

class _PreorderCard extends StatelessWidget {
  final Preorder preorder;
  const _PreorderCard({required this.preorder});

  static Color _statusColor(String s) {
    switch (s) {
      case 'ACTIVE': return AppColors.info;
      case 'COMPLETED': return AppColors.success;
      case 'SUSPENDED': return Colors.orange;
      case 'CANCELLED': return AppColors.error;
      default: return Colors.grey;
    }
  }

  static IconData _statusIcon(String s) {
    switch (s) {
      case 'ACTIVE': return Icons.hourglass_top_rounded;
      case 'COMPLETED': return Icons.check_circle_rounded;
      case 'SUSPENDED': return Icons.pause_circle_rounded;
      case 'CANCELLED': return Icons.cancel_rounded;
      default: return Icons.circle;
    }
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'ACTIVE': return 'En cours';
      case 'COMPLETED': return 'Complétée';
      case 'SUSPENDED': return 'Suspendue';
      case 'CANCELLED': return 'Annulée';
      default: return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr_FR');
    final statusColor = _statusColor(preorder.status);
    final schedules = preorder.schedules;
    final paidCount = schedules.where((s) => s.status == 'PAID').length;
    final totalCount = schedules.length;
    final paidAmount = schedules
        .where((s) => s.status == 'PAID')
        .fold<int>(0, (sum, s) => sum + s.amount);
    final progress = totalCount > 0 ? paidCount / totalCount : 0.0;
    final isCompleted = preorder.status == 'COMPLETED';
    final isCancelled = preorder.status == 'CANCELLED';

    // Prochaine échéance due ou à venir
    final nextSchedule = schedules
        .where((s) => s.status == 'UPCOMING' || s.status == 'DUE' || s.status == 'OVERDUE')
        .isNotEmpty
        ? schedules.firstWhere((s) => s.status == 'UPCOMING' || s.status == 'DUE' || s.status == 'OVERDUE')
        : null;

    return GestureDetector(
      onTap: () => context.push('/preorders/${preorder.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5)
              : isCancelled
                  ? Border.all(color: Colors.red.shade100, width: 1.5)
                  : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // ── En-tête ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text('PRÉ-CMD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.info)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PC-${preorder.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(fmt.format(preorder.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_statusIcon(preorder.status), size: 13, color: statusColor),
                      const SizedBox(width: 5),
                      Text(_statusLabel(preorder.status), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
                    ]),
                  ),
                ],
              ),
            ),

            // ── Progression de paiement ──
            if (!isCancelled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$paidCount/$totalCount échéances payées',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: statusColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(text: TextSpan(children: [
                          TextSpan(text: '${_fmt(paidAmount.toDouble())} ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                          TextSpan(text: '/ ${_fmt(preorder.totalAmount.toDouble())} FCFA', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ])),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check_circle, size: 13, color: AppColors.success),
                              const SizedBox(width: 4),
                              const Text('Prêt à convertir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                            ]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            // ── Prochaine échéance ──
            if (nextSchedule != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: nextSchedule.status == 'OVERDUE'
                        ? Colors.red.shade50
                        : const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        nextSchedule.status == 'OVERDUE' ? Icons.warning_rounded : Icons.event_rounded,
                        size: 15,
                        color: nextSchedule.status == 'OVERDUE' ? AppColors.error : AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nextSchedule.status == 'OVERDUE'
                              ? 'Échéance en retard : ${_fmt(nextSchedule.amount.toDouble())} FCFA'
                              : 'Prochaine échéance le ${DateFormat('dd MMM', 'fr_FR').format(nextSchedule.dueDate)} : ${_fmt(nextSchedule.amount.toDouble())} FCFA',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: nextSchedule.status == 'OVERDUE' ? AppColors.error : AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Pied ──
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Montant total', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    Text('${_fmt(preorder.totalAmount.toDouble())} FCFA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ]),
                  Row(children: [
                    const Text('Détails', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.info)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.info),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// Composants partagés
// ════════════════════════════════════════════════════════

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 1.5),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary))),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onRetry,
          child: const Text('Réessayer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, actionLabel;
  final VoidCallback onAction;
  const _EmptyState({required this.icon, required this.title, required this.subtitle, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(actionLabel),
          ),
        ]),
      ),
    );
  }
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

