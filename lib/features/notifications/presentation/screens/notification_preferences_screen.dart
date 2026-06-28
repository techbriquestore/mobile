import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers/notification_providers.dart';

/// Écran de préférences de notifications.
///
/// Gère : mode Ne pas déranger, consentement marketing, et les canaux globaux
/// (push, SMS, WhatsApp, email). Les overrides par type sont supportés par
/// l'API (`types`) et pourront être exposés ici ultérieurement.
class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  bool _dnd = false;
  bool _marketing = false;
  bool _push = true;
  bool _sms = false;
  bool _whatsapp = false;
  bool _email = false;
  bool _loaded = false;
  bool _saving = false;

  void _hydrate(Map<String, dynamic> data) {
    if (_loaded) return;
    _dnd = data['doNotDisturb'] as bool? ?? false;
    _marketing = data['marketingOptIn'] as bool? ?? false;
    final g = (data['global'] as Map<String, dynamic>?) ?? const {};
    _push = g['push'] as bool? ?? true;
    _sms = g['sms'] as bool? ?? false;
    _whatsapp = g['whatsapp'] as bool? ?? false;
    _email = g['email'] as bool? ?? false;
    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(notificationServiceProvider).updatePreferences({
        'doNotDisturb': _dnd,
        'marketingOptIn': _marketing,
        'global': {
          'push': _push,
          'sms': _sms,
          'whatsapp': _whatsapp,
          'email': _email,
        },
      });
      ref.invalidate(notificationPreferencesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préférences enregistrées'), backgroundColor: AppColors.primary),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);

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
        title: const Text('Préférences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade600))),
        data: (data) {
          _hydrate(data);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('GÉNÉRAL'),
              _card([
                _switch(
                  icon: Icons.do_not_disturb_on_outlined,
                  color: const Color(0xFFD32F2F),
                  title: 'Ne pas déranger',
                  subtitle: 'Coupe tous les envois sauf les alertes critiques',
                  value: _dnd,
                  onChanged: (v) => setState(() => _dnd = v),
                ),
                _divider(),
                _switch(
                  icon: Icons.campaign_outlined,
                  color: const Color(0xFFFF6D00),
                  title: 'Offres et nouveautés',
                  subtitle: 'Recevoir les promotions et actualités (marketing)',
                  value: _marketing,
                  onChanged: (v) => setState(() => _marketing = v),
                ),
              ]),
              const SizedBox(height: 20),
              _section('CANAUX'),
              _card([
                _switch(
                  icon: Icons.notifications_outlined,
                  color: const Color(0xFF9C27B0),
                  title: 'Push',
                  subtitle: 'Notifications sur l\'appareil',
                  value: _push,
                  onChanged: _dnd ? null : (v) => setState(() => _push = v),
                ),
                _divider(),
                _switch(
                  icon: Icons.sms_outlined,
                  color: AppColors.info,
                  title: 'SMS',
                  subtitle: 'Notifications par SMS',
                  value: _sms,
                  onChanged: _dnd ? null : (v) => setState(() => _sms = v),
                ),
                _divider(),
                _switch(
                  icon: Icons.chat_bubble_outline,
                  color: const Color(0xFF25D366),
                  title: 'WhatsApp',
                  subtitle: 'Notifications via WhatsApp',
                  value: _whatsapp,
                  onChanged: _dnd ? null : (v) => setState(() => _whatsapp = v),
                ),
                _divider(),
                _switch(
                  icon: Icons.email_outlined,
                  color: AppColors.primary,
                  title: 'Email',
                  subtitle: 'Notifications par email',
                  value: _email,
                  onChanged: _dnd ? null : (v) => setState(() => _email = v),
                ),
              ]),
              if (_dnd)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 4),
                  child: Text(
                    'Le mode Ne pas déranger est actif : seules les alertes critiques (sécurité, échéances en retard) sont envoyées.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4),
                  ),
                ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enregistrer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      );

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100, indent: 60);

  Widget _switch({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
