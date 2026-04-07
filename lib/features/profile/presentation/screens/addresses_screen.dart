import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/providers/address_providers.dart';
import 'add_address_screen.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(addressProvider.notifier).loadAddresses());
  }

  IconData _iconForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('chantier')) return Icons.construction;
    if (l.contains('bureau')) return Icons.business;
    if (l.contains('entrepôt') || l.contains('entrepot')) return Icons.warehouse;
    if (l.contains('domicile') || l.contains('maison')) return Icons.home_outlined;
    return Icons.location_on_outlined;
  }

  Future<void> _confirmDelete(AddressModel addr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'adresse ?'),
        content: Text('Voulez-vous supprimer « ${addr.label} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(addressProvider.notifier).deleteAddress(addr.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adresse supprimée'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
  }

  void _navigateToEdit(AddressModel addr) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddAddressScreen(address: addr)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressProvider);
    final addresses = state.addresses;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text('Mes adresses',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ),
      body: _buildBody(state, addresses),
    );
  }

  Widget _buildBody(AddressState state, List<AddressModel> addresses) {
    if (state.status == AddressStatus.loading && addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AddressStatus.error && addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Erreur de chargement',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(addressProvider.notifier).loadAddresses(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Aucune adresse enregistrée',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez votre première adresse de livraison dans le Grand Abidjan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToAdd,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une adresse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(addressProvider.notifier).loadAddresses(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == addresses.length) {
            return GestureDetector(
              onTap: _navigateToAdd,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text('Ajouter une adresse',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            );
          }

          final addr = addresses[index];
          return _AddressCard(
            address: addr,
            icon: _iconForLabel(addr.label),
            onEdit: () => _navigateToEdit(addr),
            onDelete: () => _confirmDelete(addr),
            onSetDefault: () async {
              await ref.read(addressProvider.notifier).setDefault(addr.id);
            },
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: address.isDefault
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: address.isDefault
                        ? AppColors.primary
                        : Colors.grey.shade500,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(address.label,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('PAR DÉFAUT',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(address.fullAddress,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                    Text(
                      address.commune != null && address.commune!.isNotEmpty
                          ? '${address.commune}, ${address.city}'
                          : address.city,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Flexible(
                child: Text(address.contactName,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ),
              const SizedBox(width: 12),
              Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(address.contactPhone,
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!address.isDefault)
                GestureDetector(
                  onTap: onSetDefault,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.star_outline,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Par défaut',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary)),
                    ]),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('Modifier',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              if (!address.isDefault)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: AppColors.error),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
