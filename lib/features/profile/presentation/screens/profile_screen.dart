import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Build user display name and email from auth state
    final String userName = user != null 
        ? '${user.firstName} ${user.lastName}'
        : 'Utilisateur';
    final String userEmail = user?.email ?? user?.phone ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Avatar + Nom + Email ───
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Column(
                children: [
                  // Avatar avec badge edit
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Section MON COMPTE ───
            _SectionHeader(title: 'MON COMPTE'),
            _ProfileMenuCard(
              children: [
                _ProfileMenuItem(
                  icon: Icons.person_outline,
                  label: 'Mes informations',
                  onTap: () => context.push('/profile/edit'),
                ),
                _ProfileMenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Mes commandes',
                  onTap: () => context.go('/orders'),
                ),
                _ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'Mes adresses',
                  onTap: () => context.push('/profile/addresses'),
                ),
                _ProfileMenuItem(
                  icon: Icons.payment_outlined,
                  label: 'Historique paiements',
                  onTap: () => context.push('/profile/payments'),
                ),
                _ProfileMenuItem(
                  icon: Icons.favorite_outline,
                  label: 'Mes favoris',
                  onTap: () => context.push('/favorites'),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Section APPLICATION ───
            _SectionHeader(title: 'APPLICATION'),
            _ProfileMenuCard(
              children: [
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  onTap: () => context.push('/profile/settings'),
                ),
                _ProfileMenuItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Promotions',
                  onTap: () => context.push('/promotions'),
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  label: 'Aide & Support',
                  onTap: () => context.push('/support'),
                ),
                _ProfileMenuItem(
                  icon: Icons.description_outlined,
                  label: 'Informations légales',
                  onTap: () => context.push('/legal'),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Bouton Déconnexion ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Déconnexion',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Version ───
            Text(
              'BRIQUE STORE V2.4.8 (2025)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets internes ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final List<Widget> children;
  const _ProfileMenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
      ],
    );
  }
}
