import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class _Address {
  final String label, address, city, phone;
  final IconData icon;
  bool isDefault;

  _Address({required this.label, required this.address, required this.city, required this.phone, required this.icon, this.isDefault = false});
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<_Address> _addresses = [
    _Address(label: 'Chantier Cocody', address: 'Cocody Riviera Palmeraie, lot 234', city: 'Abidjan', phone: '07 12 34 56 78', icon: Icons.construction, isDefault: true),
    _Address(label: 'Bureau', address: 'Plateau, Rue du Commerce, Imm. Alpha 3e étage', city: 'Abidjan', phone: '05 98 76 54 32', icon: Icons.business),
    _Address(label: 'Entrepôt Yopougon', address: 'Zone Industrielle, voie 3', city: 'Yopougon, Abidjan', phone: '07 55 44 33 22', icon: Icons.warehouse),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes adresses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _addresses.length) {
            // Add new address button
            return GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text('Ajouter une adresse', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
            );
          }

          final addr = _addresses[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: addr.isDefault ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: addr.isDefault ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(addr.icon, color: addr.isDefault ? AppColors.primary : Colors.grey.shade500, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('PAR DÉFAUT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(addr.address, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          Text(addr.city, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(addr.phone, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
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
                    if (!addr.isDefault)
                      GestureDetector(
                        onTap: () => setState(() => _addresses.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
