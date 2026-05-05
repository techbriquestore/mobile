import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/preorder_providers.dart';
import '../../domain/models/preorder.dart';

class PreorderDetailScreen extends ConsumerWidget {
  final String preorderId;
  const PreorderDetailScreen({super.key, required this.preorderId});

  static Color _statusColor(String s) {
    switch (s) {
      case 'PENDING_DEPOSIT': return Colors.amber;
      case 'ACTIVE': return AppColors.info;
      case 'COMPLETED': return AppColors.success;
      case 'CONVERTED': return Colors.purple;
      case 'SUSPENDED': return Colors.orange;
      case 'CANCELLED': return AppColors.error;
      default: return Colors.grey;
    }
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'PENDING_DEPOSIT': return 'Acompte requis';
      case 'ACTIVE': return 'En cours';
      case 'COMPLETED': return 'Complétée';
      case 'CONVERTED': return 'Convertie en commande';
      case 'SUSPENDED': return 'Suspendue';
      case 'CANCELLED': return 'Annulée';
      default: return s;
    }
  }

  static IconData _statusIcon(String s) {
    switch (s) {
      case 'PENDING_DEPOSIT': return Icons.account_balance_wallet_rounded;
      case 'ACTIVE': return Icons.hourglass_top_rounded;
      case 'COMPLETED': return Icons.check_circle_rounded;
      case 'CONVERTED': return Icons.swap_horiz_rounded;
      case 'SUSPENDED': return Icons.pause_circle_rounded;
      case 'CANCELLED': return Icons.cancel_rounded;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(preorderByIdProvider(preorderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/orders?tab=preorders');
            }
          },
        ),
        centerTitle: true,
        title: const Text('Pré-commande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Impossible de charger', style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => ref.invalidate(preorderByIdProvider(preorderId)),
              child: const Text('Réessayer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        data: (preorder) => _PreorderDetailBody(preorder: preorder),
      ),
    );
  }
}

class _PreorderDetailBody extends ConsumerWidget {
  final PreorderDetail preorder;
  const _PreorderDetailBody({required this.preorder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('dd MMM yyyy', 'fr_FR');
    final schedules = preorder.schedules;
    final paidSchedulesCount = schedules.where((s) => s.status == 'PAID').length;
    final paidSchedulesAmount = schedules.where((s) => s.status == 'PAID').fold<int>(0, (sum, s) => sum + s.amount);
    
    // Calcul du montant total payé (acompte + échéances)
    final depositPaid = preorder.isDepositPaid ? preorder.depositAmount : 0;
    final totalPaid = depositPaid + paidSchedulesAmount;
    
    // Progression basée sur le montant total payé vs montant total
    final progress = preorder.totalAmount > 0 ? totalPaid / preorder.totalAmount : 0.0;
    
    final statusColor = PreorderDetailScreen._statusColor(preorder.status);
    final isPendingDeposit = preorder.status == 'PENDING_DEPOSIT';
    final isCompleted = preorder.status == 'COMPLETED';
    final isSuspended = preorder.status == 'SUSPENDED';
    final isCancelled = preorder.status == 'CANCELLED';
    final isConverted = preorder.status == 'CONVERTED';
    final canPaySchedules = !isPendingDeposit && !isSuspended && !isCancelled && !isConverted && !isCompleted;

    // Prochaine échéance non payée
    final nextSchedule = schedules
        .where((s) => s.status == 'UPCOMING' || s.status == 'DUE' || s.status == 'OVERDUE')
        .isNotEmpty
        ? schedules.firstWhere((s) => s.status == 'UPCOMING' || s.status == 'DUE' || s.status == 'OVERDUE')
        : null;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ═══ En-tête avec cercle de progression ═══
          Container(
            color: Colors.white, width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Badge type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('PRÉ-COMMANDE ÉCHELONNÉE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.info, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 10),
                Text(
                  'PC-${preorder.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(PreorderDetailScreen._statusIcon(preorder.status), size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(PreorderDetailScreen._statusLabel(preorder.status), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: statusColor)),
                  ]),
                ),
                const SizedBox(height: 24),

                // Cercle de progression
                SizedBox(
                  width: 120, height: 120,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 120, height: 120,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: statusColor),
                            ),
                            Text('payé', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Montants (utilise totalPaid calculé avec acompte)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_fmt(totalPaid.toDouble())} FCFA',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: statusColor),
                    ),
                    Text(
                      ' / ${_fmt(preorder.totalAmount.toDouble())} FCFA',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  preorder.isDepositPaid 
                    ? 'Acompte + $paidSchedulesCount/${schedules.length} échéances'
                    : '$paidSchedulesCount/${schedules.length} échéances payées',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),

                // Badge conversion prête
                if (isCompleted) ...[  
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      const Text('Paiement complet · Conversion en commande possible', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ═══ Prochaine échéance ═══
          if (nextSchedule != null)
            Container(
              color: nextSchedule.status == 'OVERDUE' ? Colors.red.shade50 : const Color(0xFFF0F4FF),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: nextSchedule.status == 'OVERDUE' ? Colors.red.shade100 : AppColors.info.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      nextSchedule.status == 'OVERDUE' ? Icons.warning_rounded : Icons.event_rounded,
                      color: nextSchedule.status == 'OVERDUE' ? AppColors.error : AppColors.info,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextSchedule.status == 'OVERDUE' ? 'Échéance en retard !' : 'Prochaine échéance',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: nextSchedule.status == 'OVERDUE' ? AppColors.error : AppColors.info,
                          ),
                        ),
                        Text(
                          '${fmt.format(nextSchedule.dueDate)} · ${_fmt(nextSchedule.amount.toDouble())} FCFA',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ═══ Bandeau acompte ═══
          if (isPendingDeposit)
            Container(
              color: Colors.amber.shade50,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Colors.amber.shade800, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acompte requis pour activer',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.amber.shade900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_fmt(preorder.depositAmount.toDouble())} FCFA (${preorder.depositPercentage}%)',
                            style: TextStyle(fontSize: 13, color: Colors.amber.shade700),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final service = ref.read(preorderServiceProvider);
                        try {
                          await service.confirmDeposit(preorder.id);
                          ref.invalidate(preorderByIdProvider(preorder.id));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Acompte confirmé ! Pré-commande activée.'), backgroundColor: AppColors.success),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.payment_rounded, size: 18),
                      label: const Text('Confirmer le paiement de l\'acompte'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (isPendingDeposit) const SizedBox(height: 12),

          // ═══ Produits commandés ═══
          if (preorder.items.isNotEmpty)
            _Section(
              title: 'Produits (${preorder.items.length})',
              child: Column(
                children: preorder.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.inventory_2_rounded, size: 20, color: AppColors.info),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('${item.quantity} x ${_fmt(item.lockedPrice.toDouble())} FCFA', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Text('${_fmt(item.subtotal.toDouble())} F', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          if (preorder.items.isNotEmpty) const SizedBox(height: 12),

          // ═══ Résumé financier ═══
          _Section(
            title: 'Résumé financier',
            child: Column(children: [
              _InfoRow(label: 'Montant total', value: '${_fmt(preorder.totalAmount.toDouble())} FCFA', bold: true),
              _InfoRow(label: 'Acompte (${preorder.depositPercentage}%)', value: '${_fmt(preorder.depositAmount.toDouble())} FCFA', valueColor: preorder.isDepositPaid ? AppColors.success : Colors.amber.shade700),
              _InfoRow(label: 'Déjà payé', value: '${_fmt(preorder.amountPaid.toDouble())} FCFA', valueColor: AppColors.success),
              _InfoRow(label: 'Reste à payer', value: '${_fmt(preorder.remaining.toDouble())} FCFA', valueColor: preorder.remaining > 0 ? AppColors.error : AppColors.success),
              _InfoRow(label: 'Durée', value: '${preorder.durationMonths} mois'),
            ]),
          ),
          const SizedBox(height: 12),

          // ═══ Dates ═══
          _Section(
            title: 'Période',
            child: Column(children: [
              _InfoRow(label: 'Début', value: fmt.format(preorder.startDate)),
              _InfoRow(label: 'Fin prévue', value: fmt.format(preorder.endDate)),
              _InfoRow(label: 'Créée le', value: fmt.format(preorder.createdAt)),
            ]),
          ),
          const SizedBox(height: 12),

          // ═══ Banner si suspendue ═══
          if (isSuspended)
            Container(
              color: Colors.orange.shade50,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                Icon(Icons.pause_circle_rounded, color: Colors.orange.shade700, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pré-commande suspendue. Les paiements sont temporairement bloqués.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade800),
                  ),
                ),
              ]),
            ),

          if (isSuspended) const SizedBox(height: 12),

          // ═══ Historique des paiements ═══
          _Section(
            title: 'Paiements',
            child: Column(
              children: [
                // Acompte (toujours affiché en premier)
                _DepositRow(
                  depositAmount: preorder.depositAmount,
                  depositPercentage: preorder.depositPercentage,
                  isPaid: preorder.isDepositPaid,
                  paidAt: preorder.depositPaidAt,
                  fmt: fmt,
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // Échéances
                ...List.generate(schedules.length, (i) {
                  final s = schedules[i];
                  final isNext = s == nextSchedule;
                  return _ScheduleRow(
                    index: i + 1,
                    schedule: s,
                    isNext: isNext,
                    fmt: fmt,
                    preorderId: preorder.id,
                    canPay: canPaySchedules,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, width: double.infinity, padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
      ]),
    );
  }
}

class _ScheduleRow extends ConsumerWidget {
  final int index;
  final PreorderSchedule schedule;
  final bool isNext;
  final DateFormat fmt;
  final String preorderId;
  final bool canPay;

  const _ScheduleRow({
    required this.index,
    required this.schedule,
    required this.isNext,
    required this.fmt,
    required this.preorderId,
    this.canPay = true,
  });

  Color get _color {
    switch (schedule.status) {
      case 'PAID': return AppColors.success;
      case 'OVERDUE': return AppColors.error;
      case 'DUE': return Colors.orange;
      default: return isNext ? AppColors.info : Colors.grey.shade400;
    }
  }

  IconData get _icon {
    switch (schedule.status) {
      case 'PAID': return Icons.check_rounded;
      case 'OVERDUE': return Icons.warning_rounded;
      case 'DUE': return Icons.schedule_rounded;
      default: return Icons.circle_outlined;
    }
  }

  String get _statusLabel {
    switch (schedule.status) {
      case 'PAID': return 'Payée';
      case 'OVERDUE': return 'En retard';
      case 'DUE': return 'Due';
      case 'UPCOMING': return isNext ? 'Prochaine' : 'À venir';
      case 'CANCELLED': return 'Annulée';
      default: return schedule.status;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaid = schedule.status == 'PAID';
    final isPayable = canPay && ['UPCOMING', 'DUE', 'OVERDUE'].contains(schedule.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isNext ? AppColors.info.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: isNext ? Border.all(color: AppColors.info.withValues(alpha: 0.3)) : null,
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, size: 16, color: _color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Versement $index', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(_statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _color)),
            ),
          ]),
          const SizedBox(height: 2),
          Text(
            isPaid && schedule.paidAt != null
                ? 'Payé le ${fmt.format(schedule.paidAt!)}'
                : 'Échéance : ${fmt.format(schedule.dueDate)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ])),
        if (isPaid)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              '${_fmt(schedule.amount.toDouble())} F',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success),
            ),
          ])
        else
          ElevatedButton.icon(
            onPressed: isPayable
                ? () => context.push('/payment', extra: {
                    'amount': schedule.amount.toDouble(),
                    'orderId': '',
                    'scheduleId': schedule.id,
                    'preorderId': preorderId,
                    'scheduleIndex': index,
                  })
                : null,
            icon: const Icon(Icons.payment_rounded, size: 16),
            label: Text('${_fmt(schedule.amount.toDouble())} F'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _color,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 36),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
      ]),
    );
  }
}

class _DepositRow extends StatelessWidget {
  final int depositAmount;
  final int depositPercentage;
  final bool isPaid;
  final DateTime? paidAt;
  final DateFormat fmt;

  const _DepositRow({
    required this.depositAmount,
    required this.depositPercentage,
    required this.isPaid,
    this.paidAt,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.success : Colors.amber.shade700;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.success.withValues(alpha: 0.05) : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPaid ? Icons.check_rounded : Icons.account_balance_wallet_rounded,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Acompte ($depositPercentage%)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(
                isPaid ? 'Payé' : 'En attente',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ]),
          const SizedBox(height: 2),
          Text(
            isPaid && paidAt != null
                ? 'Payé le ${fmt.format(paidAt!)}'
                : 'Requis pour activer la pré-commande',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ])),
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (isPaid) Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
          if (isPaid) const SizedBox(width: 4),
          Text(
            '${_fmt(depositAmount.toDouble())} F',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ]),
      ]),
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
