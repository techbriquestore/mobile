import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../data/providers/preferences_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Paramètres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Impossible de charger les paramètres', style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => ref.invalidate(preferencesProvider),
                child: const Text('Réessayer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        data: (prefs) => _SettingsBody(prefs: prefs),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final UserPreferences prefs;
  const _SettingsBody({required this.prefs});

  void _update(WidgetRef ref, String key, dynamic value) {
    ref.read(preferencesProvider.notifier).updatePreference(key, value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Communication Preferences ───
          const _SectionTitle('PRÉFÉRENCES DE COMMUNICATION'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _SwitchTile(icon: Icons.sms_outlined, color: AppColors.info, title: 'SMS', subtitle: 'Recevoir les notifications par SMS', value: prefs.preferSms, onChanged: (v) => _update(ref, 'preferSms', v)),
                _divider(),
                _SwitchTile(icon: Icons.chat_bubble_outline, color: const Color(0xFF25D366), title: 'WhatsApp', subtitle: 'Recevoir les notifications WhatsApp', value: prefs.preferWhatsapp, onChanged: (v) => _update(ref, 'preferWhatsapp', v)),
                _divider(),
                _SwitchTile(icon: Icons.email_outlined, color: AppColors.primary, title: 'Email', subtitle: 'Recevoir les notifications par email', value: prefs.preferEmail, onChanged: (v) => _update(ref, 'preferEmail', v)),
                _divider(),
                _SwitchTile(icon: Icons.notifications_outlined, color: const Color(0xFF9C27B0), title: 'Push', subtitle: 'Notifications push sur l\'appareil', value: prefs.preferPush, onChanged: (v) => _update(ref, 'preferPush', v)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Notification Types ───
          const _SectionTitle('TYPES DE NOTIFICATIONS'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _SwitchTile(icon: Icons.inventory_2_outlined, color: AppColors.info, title: 'Commandes', subtitle: 'Statut et suivi des commandes', value: prefs.notifOrders, onChanged: (v) => _update(ref, 'notifOrders', v)),
                _divider(),
                _SwitchTile(icon: Icons.local_offer_outlined, color: AppColors.primary, title: 'Promotions', subtitle: 'Offres spéciales et réductions', value: prefs.notifPromotions, onChanged: (v) => _update(ref, 'notifPromotions', v)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── App Settings ───
          const _SectionTitle('APPLICATION'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _SwitchTile(icon: Icons.dark_mode_outlined, color: Colors.blueGrey, title: 'Mode sombre', subtitle: 'Apparence de l\'application', value: prefs.darkMode, onChanged: (v) => _update(ref, 'darkMode', v)),
                _divider(),
                _TapTile(
                  icon: Icons.language,
                  color: AppColors.info,
                  title: 'Langue',
                  trailing: prefs.language == 'fr' ? 'Français' : 'English',
                  onTap: () {
                    final newLang = prefs.language == 'fr' ? 'en' : 'fr';
                    _update(ref, 'language', newLang);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Security ───
          const _SectionTitle('SÉCURITÉ'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _TapTile(icon: Icons.lock_outline, color: AppColors.primary, title: 'Changer le mot de passe', onTap: () => context.push('/profile/change-password')),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Legal ───
          const _SectionTitle('LÉGAL'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _TapTile(icon: Icons.description_outlined, color: Colors.grey, title: 'Conditions Générales de Vente', onTap: () => context.push('/legal')),
                _divider(),
                _TapTile(icon: Icons.privacy_tip_outlined, color: Colors.grey, title: 'Politique de confidentialité', onTap: () => context.push('/legal')),
                _divider(),
                _TapTile(icon: Icons.info_outline, color: Colors.grey, title: 'Mentions légales', onTap: () => context.push('/legal')),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Danger zone ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _TapTile(icon: Icons.logout, color: AppColors.error, title: 'Se déconnecter', titleColor: AppColors.error, onTap: () {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: const Text('Se déconnecter ?', style: TextStyle(fontWeight: FontWeight.w700)),
                    content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        },
                        child: const Text('Déconnexion', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ));
                }),
                _divider(),
                _TapTile(icon: Icons.delete_forever_outlined, color: AppColors.error, title: 'Supprimer mon compte', titleColor: AppColors.error, onTap: () {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: const Text('Supprimer le compte ?', style: TextStyle(fontWeight: FontWeight.w700)),
                    content: const Text('Cette action est irréversible. Toutes vos données seront supprimées.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ));
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App version
          Center(child: Text('BRIQUES.STORE v1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey.shade400))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _divider() => Divider(height: 1, color: Colors.grey.shade100, indent: 64);
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 1)),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _TapTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? trailing;
  final Color? titleColor;
  final VoidCallback onTap;

  const _TapTile({required this.icon, required this.color, required this.title, this.trailing, this.titleColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor ?? AppColors.textPrimary))),
            if (trailing != null) Text(trailing!, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
