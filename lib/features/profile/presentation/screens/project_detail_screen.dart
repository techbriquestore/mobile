import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart';
import '../../data/providers/project_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  static final _fmt = NumberFormat('#,###', 'fr_FR');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProject = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text('Détail du projet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: asyncProject.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(projectDetailProvider(projectId)),
              child: const Text('Réessayer'),
            ),
          ]),
        ),
        data: (project) => _buildContent(context, ref, project),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ProjectModel project) {
    final kpis = project.kpis;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(projectDetailProvider(projectId)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── En-tête projet ───
            _buildHeader(project),
            const SizedBox(height: 16),

            // ─── KPIs ───
            if (kpis != null) ...[
              _buildKpiGrid(kpis, project.budget),
              const SizedBox(height: 16),
              if (project.budget != null && kpis.budgetProgress != null)
                _buildBudgetProgress(kpis, project.budget!),
              const SizedBox(height: 16),
            ],

            // ─── Adresse ───
            _buildAddressCard(project),
            const SizedBox(height: 16),

            // ─── Commandes liées ───
            if (project.orders != null && project.orders!.isNotEmpty) ...[
              _buildSectionTitle('Commandes', Icons.receipt_long_outlined, project.orders!.length),
              const SizedBox(height: 8),
              ...project.orders!.map((o) => _buildOrderCard(context, o)),
              const SizedBox(height: 16),
            ],

            // ─── Pré-commandes liées ───
            if (project.preorders != null && project.preorders!.isNotEmpty) ...[
              _buildSectionTitle('Pré-commandes', Icons.schedule, project.preorders!.length),
              const SizedBox(height: 8),
              ...project.preorders!.map((p) => _buildPreorderCard(context, p)),
            ],

            if ((project.orders == null || project.orders!.isEmpty) &&
                (project.preorders == null || project.preorders!.isEmpty))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Aucune commande pour ce projet',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Les commandes associées à ce projet apparaîtront ici.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                ]),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProjectModel project) {
    Color statusColor;
    switch (project.status) {
      case 'ACTIVE': statusColor = AppColors.success; break;
      case 'PAUSED': statusColor = Colors.orange; break;
      case 'COMPLETED': statusColor = Colors.grey; break;
      default: statusColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.foundation, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(project.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(project.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ]),
          ),
        ]),
        if (project.description != null && project.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(project.description!, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4)),
        ],
      ]),
    );
  }

  Widget _buildKpiGrid(ProjectKpis kpis, int? budget) {
    return Column(children: [
      Row(children: [
        Expanded(child: _kpiCard('Total dépensé', '${_fmt.format(kpis.totalSpent)} F', Icons.payments_outlined, AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: _kpiCard('Reste à payer', '${_fmt.format(kpis.totalRemaining)} F', Icons.account_balance_wallet_outlined, Colors.orange)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _kpiCard('Briques', _fmt.format(kpis.totalBricks), Icons.view_in_ar, const Color(0xFF9C27B0))),
        const SizedBox(width: 10),
        Expanded(child: _kpiCard('Commandes', '${kpis.totalOrders}', Icons.receipt_long_outlined, AppColors.info)),
      ]),
    ]);
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ]),
    );
  }

  Widget _buildBudgetProgress(ProjectKpis kpis, int budget) {
    final progress = (kpis.budgetProgress ?? 0).clamp(0, 100);
    final color = progress > 90 ? AppColors.error : progress > 70 ? Colors.orange : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.pie_chart_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Budget', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          Text('$progress%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_fmt.format(kpis.totalSpent)} F dépensés', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          Text('Budget: ${_fmt.format(budget)} F', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ]),
      ]),
    );
  }

  Widget _buildAddressCard(ProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Adresse de livraison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 10),
        Text(project.fullAddress, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        Text(project.commune != null ? '${project.commune}, ${project.city}' : project.city,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(project.contactName, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(width: 12),
          Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(project.contactPhone, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ]),
      ]),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, int count) {
    return Row(children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
    ]);
  }

  Widget _buildOrderCard(BuildContext context, ProjectOrderSummary order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.push('/orders/${order.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFF9C27B0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.receipt_long_outlined, size: 18, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.orderNumber ?? 'CMD-${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${_fmt.format(order.totalPaid)} / ${_fmt.format(order.totalAmount ?? 0)} F',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
              child: Text(order.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ]),
        ),
      ),
    );
  }

  Widget _buildPreorderCard(BuildContext context, ProjectPreorderSummary preorder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.push('/preorders/${preorder.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.schedule, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PC-${preorder.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${_fmt.format(preorder.totalPaid)} / ${_fmt.format(preorder.totalAmount)} F  •  ${preorder.paidSchedules}/${preorder.schedulesCount} échéances',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
              child: Text(preorder.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ]),
        ),
      ),
    );
  }
}
