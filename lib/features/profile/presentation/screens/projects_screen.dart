import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart';
import '../../data/providers/project_providers.dart';
import 'add_project_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(projectProvider.notifier).loadProjects());
  }

  IconData _iconForProject(ProjectModel project) {
    final l = project.name.toLowerCase();
    if (l.contains('maison') || l.contains('domicile')) return Icons.home_outlined;
    if (l.contains('immeuble') || l.contains('r+')) return Icons.apartment;
    if (l.contains('bureau')) return Icons.business;
    if (l.contains('entrepôt') || l.contains('entrepot')) return Icons.warehouse;
    if (l.contains('chantier')) return Icons.construction;
    return Icons.foundation;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE': return AppColors.success;
      case 'PAUSED': return Colors.orange;
      case 'COMPLETED': return Colors.grey;
      default: return AppColors.primary;
    }
  }

  Future<void> _confirmDelete(ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le projet ?'),
        content: Text('Voulez-vous supprimer « ${project.name} » ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(projectProvider.notifier).deleteProject(project.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projet supprimé'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
        );
      } else if (mounted) {
        final err = ref.read(projectProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? 'Impossible de supprimer'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _navigateToAdd() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProjectScreen()));
  }

  void _navigateToEdit(ProjectModel project) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddProjectScreen(project: project)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectProvider);
    final projects = state.projects;

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
        title: const Text('Mes projets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: _buildBody(state, projects),
    );
  }

  Widget _buildBody(ProjectState state, List<ProjectModel> projects) {
    if (state.status == ProjectStatus.loading && projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ProjectStatus.error && projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(state.errorMessage ?? 'Erreur de chargement',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(projectProvider.notifier).loadProjects(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.foundation, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('Aucun projet',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text('Créez votre premier projet de construction',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToAdd,
                icon: const Icon(Icons.add),
                label: const Text('Créer un projet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(projectProvider.notifier).loadProjects(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == projects.length) {
            return GestureDetector(
              onTap: _navigateToAdd,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text('Créer un projet',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
            );
          }

          final project = projects[index];
          return _ProjectCard(
            project: project,
            icon: _iconForProject(project),
            statusColor: _statusColor(project.status),
            onTap: () => context.push('/projects/${project.id}'),
            onEdit: () => _navigateToEdit(project),
            onDelete: () => _confirmDelete(project),
            onSetDefault: () async {
              await ref.read(projectProvider.notifier).setDefault(project.id);
            },
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final IconData icon;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _ProjectCard({
    required this.project,
    required this.icon,
    required this.statusColor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: project.isDefault ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: project.isDefault ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: project.isDefault ? AppColors.primary : Colors.grey.shade500, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(project.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ),
                          if (project.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                              child: const Text('PAR DÉFAUT',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(project.statusLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(project.displayAddress,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
            if (project.description != null && project.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(project.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Flexible(child: Text(project.contactName, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
                const SizedBox(width: 12),
                Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(project.contactPhone, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!project.isDefault)
                  GestureDetector(
                    onTap: onSetDefault,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.star_outline, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Par défaut', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ]),
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.edit_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('Modifier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                if (!project.isDefault)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
