import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Informations légales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'CGV'),
            Tab(text: 'Confidentialité'),
            Tab(text: 'Mentions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCGV(),
          _buildPrivacy(),
          _buildLegal(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildCGV() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('1. Objet',
              'Les présentes Conditions Générales de Vente (CGV) régissent les ventes de produits de construction (briques, hourdis et matériaux associés) effectuées par BRIQUES.STORE via son application mobile et son site web.'),
          _buildSection('2. Prix',
              'Les prix sont affichés en Francs CFA (FCFA), toutes taxes comprises (TVA 18% incluse). Le prix applicable est celui en vigueur au moment de la validation de la commande. Pour les pré-commandes, le prix est bloqué et garanti pour toute la durée du contrat (maximum 12 mois).'),
          _buildSection('3. Commandes',
              'Toute commande implique l\'acceptation des présentes CGV. La commande est confirmée après réception du paiement. Un numéro de commande unique est attribué et communiqué par SMS et/ou email.'),
          _buildSection('4. Paiement',
              'Les moyens de paiement acceptés sont : Mobile Money (Orange Money, MTN Mobile Money, Moov Money, Wave), cartes bancaires (Visa, Mastercard via 3D Secure). Les paiements échelonnés standards (2 à 4 échéances) sont sans frais supplémentaires. Au-delà de 4 échéances, des frais de gestion s\'appliquent.'),
          _buildSection('5. Livraison',
              'Les livraisons sont effectuées sous 3 à 5 jours ouvrés en mode standard, 48 heures en mode express. Les frais de livraison sont calculés selon le volume, la distance et la zone de livraison. Le retrait en point de vente est gratuit.'),
          _buildSection('6. Retours et réclamations',
              'Délai de rétractation : 48 heures à compter de la réception. Conditions : produits non utilisés, emballage d\'origine, parfait état. Les frais de retour sont à la charge du client sauf en cas de défaut, dommage de transport ou erreur de BRIQUES.STORE. Remboursement sous 14 jours maximum. Garantie « Livré ou Remboursé ».'),
          _buildSection('7. Pré-commandes',
              'Premier paiement minimum : 15% du montant total. Les échéances suivantes doivent être réglées au plus tard 48 heures avant la date de livraison prévue. En cas de 2 échéances consécutives impayées, la pré-commande est suspendue.'),
          const SizedBox(height: 10),
          Text('Dernière mise à jour : Mars 2026', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildPrivacy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('1. Responsable du traitement',
              'BRIQUES.STORE, représentée par son responsable légal, est responsable du traitement des données personnelles collectées via l\'application mobile et le site web.'),
          _buildSection('2. Données collectées',
              'Nous collectons uniquement les données nécessaires au service : nom complet, numéro de téléphone, adresse email (optionnel), adresses de livraison, historique des commandes et paiements. Les données de paiement ne sont jamais stockées (gérées par les agrégateurs certifiés).'),
          _buildSection('3. Finalités',
              'Les données sont utilisées pour : la gestion de votre compte, le traitement des commandes, les notifications de suivi, les communications commerciales (avec votre consentement), l\'amélioration de nos services.'),
          _buildSection('4. Conservation',
              'Comptes actifs : tant qu\'ils existent. Comptes inactifs : 3 ans. Suppression : 30 jours après demande (sauf obligations légales). Factures : 10 ans (obligation légale).'),
          _buildSection('5. Vos droits',
              'Conformément à la loi n°2013-450 du 19 juin 2013 (Côte d\'Ivoire, ARTCI), vous disposez d\'un droit de consultation, modification, suppression et portabilité de vos données depuis votre espace personnel. Suppression de compte : anonymisation/effacement sous 30 jours.'),
          _buildSection('6. Sécurité',
              'Toutes les communications sont chiffrées via HTTPS (SSL/TLS). Les mots de passe sont hachés avec bcrypt. Les données de paiement ne sont jamais stockées localement.'),
          const SizedBox(height: 10),
          Text('Dernière mise à jour : Mars 2026', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildLegal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Éditeur de l\'application',
              'BRIQUES.STORE\nResponsable : OFFO ANGE EMMANUEL\nContact : support@briques.store\nTéléphone : +225 07 12 34 56 78'),
          _buildSection('Hébergement',
              'L\'application est hébergée sur des serveurs cloud sécurisés avec une garantie de disponibilité ≥ 99,9%. Les données sont stockées conformément aux normes de sécurité internationales.'),
          _buildSection('Propriété intellectuelle',
              'L\'ensemble du contenu de l\'application BRIQUES.STORE (textes, images, logos, éléments graphiques, logiciels) est protégé par le droit de la propriété intellectuelle. Toute reproduction ou utilisation non autorisée est interdite.'),
          _buildSection('Loi applicable',
              'Les présentes mentions légales sont soumises au droit ivoirien. En cas de litige, les tribunaux compétents d\'Abidjan seront seuls compétents.'),
          _buildSection('Régulation',
              'Conformité avec la loi ivoirienne n°2013-450 du 19 juin 2013 relative à la protection des données personnelles, supervisée par l\'ARTCI (Autorité de Régulation des Télécommunications/TIC de Côte d\'Ivoire). Compatible avec le système e-Facture DGI.'),
          const SizedBox(height: 10),
          Text('Dernière mise à jour : Mars 2026', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
