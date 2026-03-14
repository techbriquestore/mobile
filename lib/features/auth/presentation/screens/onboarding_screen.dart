import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.store,
      title: 'Bienvenue sur\nBRIQUES.STORE',
      description: 'Achetez vos briques et matériaux de construction en ligne, livrés directement sur votre chantier.',
      color: Color(0xFFFF9800),
    ),
    _OnboardingPage(
      icon: Icons.calculate_outlined,
      title: 'Simulateur\nintelligent',
      description: 'Calculez facilement le nombre de briques nécessaires pour votre projet grâce à notre simulateur intégré.',
      color: Color(0xFF2196F3),
    ),
    _OnboardingPage(
      icon: Icons.calendar_month_outlined,
      title: 'Pré-commande\n& paiement échelonné',
      description: 'Constituez votre stock progressivement avec un paiement échelonné sur plusieurs mois. Prix bloqué et garanti.',
      color: Color(0xFF4CAF50),
    ),
    _OnboardingPage(
      icon: Icons.local_shipping_outlined,
      title: 'Livraison fiable\nsur tout le territoire',
      description: 'Livraison rapide à Abidjan et dans toutes les grandes villes. Garantie « Livré ou Remboursé ».',
      color: Color(0xFF9C27B0),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text('Passer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        index == 0
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset('assets/images/logo.png', width: 120, height: 120, fit: BoxFit.contain),
                            )
                          : Container(
                              width: 120, height: 120,
                              decoration: BoxDecoration(
                                color: page.color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(page.icon, size: 56, color: page.color),
                            ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? _pages[_currentPage].color : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title, description;
  final Color color;

  const _OnboardingPage({required this.icon, required this.title, required this.description, required this.color});
}
