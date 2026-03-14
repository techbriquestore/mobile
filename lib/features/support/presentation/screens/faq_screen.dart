import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class _FaqItem {
  final String question, answer;
  final String category;
  const _FaqItem({required this.question, required this.answer, required this.category});
}

const _faqData = [
  _FaqItem(category: 'Commandes', question: 'Comment passer une commande ?', answer: 'Parcourez notre catalogue, ajoutez les produits au panier, puis validez votre commande en choisissant une adresse de livraison et un mode de paiement.'),
  _FaqItem(category: 'Commandes', question: 'Quel est le délai de livraison ?', answer: 'Les livraisons sont effectuées sous 24 à 72 heures ouvrables selon la zone géographique et la disponibilité des produits. Les zones hors Abidjan peuvent nécessiter un délai supplémentaire.'),
  _FaqItem(category: 'Commandes', question: 'Puis-je annuler ma commande ?', answer: 'Vous pouvez annuler une commande tant qu\'elle n\'est pas en cours de fabrication. Contactez notre support pour toute demande d\'annulation.'),
  _FaqItem(category: 'Paiement', question: 'Quels modes de paiement acceptez-vous ?', answer: 'Nous acceptons Mobile Money (Orange Money, MTN, Wave), les virements bancaires (SGBCI, BICICI, SIB) et le paiement à la livraison en espèces.'),
  _FaqItem(category: 'Paiement', question: 'Comment fonctionne la pré-commande ?', answer: 'La pré-commande vous permet de réserver des produits en payant en plusieurs échéances. Vous choisissez le nombre d\'échéances (2 à 6) et la livraison est effectuée après le paiement complet.'),
  _FaqItem(category: 'Produits', question: 'Quelle est la différence entre brique pleine et creuse ?', answer: 'La brique pleine est plus résistante et utilisée pour les murs porteurs. La brique creuse est plus légère, offre une meilleure isolation thermique et est utilisée pour les cloisons et murs non porteurs.'),
  _FaqItem(category: 'Produits', question: 'Qu\'est-ce qu\'un hourdis ?', answer: 'Le hourdis est un élément de construction utilisé pour les planchers. Il existe en version française (plus épaisse, meilleure isolation) et américaine (plus fine, plus économique).'),
  _FaqItem(category: 'Livraison', question: 'Livrez-vous en dehors d\'Abidjan ?', answer: 'Oui, nous livrons dans toute la Côte d\'Ivoire. Les frais de livraison varient selon la distance et la quantité commandée.'),
];

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _selectedCategory = 'Tous';
  final _categories = ['Tous', 'Commandes', 'Paiement', 'Produits', 'Livraison'];

  List<_FaqItem> get _filtered {
    if (_selectedCategory == 'Tous') return _faqData;
    return _faqData.where((f) => f.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _categories.map((c) {
                  final selected = _selectedCategory == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300, width: 1.5),
                        ),
                        child: Center(child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // FAQ items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final faq = _filtered[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
                      ),
                      title: Text(faq.question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      children: [
                        Text(faq.answer, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
