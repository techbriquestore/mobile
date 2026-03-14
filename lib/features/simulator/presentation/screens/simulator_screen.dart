import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double _linearMeter = 12.5;
  double _wallHeight = 2.8;
  String _selectedBrick = 'Brique de 15 (Standard)';
  bool _showResult = false;
  int _quantity = 0;
  int _cost = 0;

  final _brickTypes = [
    'Brique de 15 (Standard)',
    'Brique de 20 (Standard)',
    'Brique de 10 (Cloison)',
    'Parpaing creux 20x20x50',
    'Brique pleine',
  ];

  void _calculate() {
    // Formule simplifiée : surface * densité par m²
    final surface = _linearMeter * _wallHeight;
    int density;
    int pricePerUnit;

    switch (_selectedBrick) {
      case 'Brique de 20 (Standard)':
        density = 30;
        pricePerUnit = 450;
        break;
      case 'Brique de 10 (Cloison)':
        density = 40;
        pricePerUnit = 250;
        break;
      case 'Parpaing creux 20x20x50':
        density = 10;
        pricePerUnit = 800;
        break;
      case 'Brique pleine':
        density = 35;
        pricePerUnit = 500;
        break;
      default: // Brique de 15
        density = 36;
        pricePerUnit = 350;
    }

    setState(() {
      _quantity = (surface * density).round();
      _cost = _quantity * pricePerUnit;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Estimez vos besoins',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Illustration simulateur mural ───
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mini illustration mur en briques
                  SizedBox(
                    width: 120,
                    height: 80,
                    child: CustomPaint(painter: _WallPainter()),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SIMULATEUR MURAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Mètre linéaire ───
            Text(
              'Mètre linéaire (m)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            _NumberInput(
              value: _linearMeter,
              step: 0.5,
              min: 0.5,
              max: 100,
              onChanged: (v) => setState(() => _linearMeter = v),
            ),
            const SizedBox(height: 20),

            // ─── Hauteur du mur ───
            Text(
              'Hauteur du mur (m)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            _NumberInput(
              value: _wallHeight,
              step: 0.1,
              min: 0.5,
              max: 10,
              onChanged: (v) => setState(() => _wallHeight = v),
            ),
            const SizedBox(height: 20),

            // ─── Type de brique ───
            Text(
              'Type de brique',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBrick,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  items: _brickTypes
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedBrick = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ─── Bouton Calculer ───
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Calculer mes besoins',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Résultat ───
            if (_showResult) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Titre résultat
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.assessment_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Résultat de l'estimation",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quantité + Coût
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Quantité',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: '$_quantity',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' briques',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade200,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Coût estimé',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatPrice(_cost),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'FCFA',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Ajouter au panier
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: ajouter au panier
                        },
                        icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                        label: const Text(
                          'Ajouter au panier',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ─── Input numérique avec +/- ───
class _NumberInput extends StatelessWidget {
  final double value;
  final double step;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _NumberInput({
    required this.value,
    required this.step,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Bouton -
          GestureDetector(
            onTap: () {
              final newVal = value - step;
              if (newVal >= min) onChanged(double.parse(newVal.toStringAsFixed(1)));
            },
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, color: AppColors.primary, size: 22),
            ),
          ),
          // Valeur
          Expanded(
            child: Center(
              child: Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Bouton +
          GestureDetector(
            onTap: () {
              final newVal = value + step;
              if (newVal <= max) onChanged(double.parse(newVal.toStringAsFixed(1)));
            },
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(right: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Illustration mur en briques ───
class _WallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final brickPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.7);
    final lightBrickPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.3);
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    // Fond mur
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      lightBrickPaint,
    );

    // Rangée 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(4, 4, 36, 16), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(44, 4, 36, 16), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(84, 4, 32, 16), const Radius.circular(3)),
      brickPaint,
    );

    // Rangée 2 (décalée)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(4, 24, 20, 16), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(28, 24, 36, 16), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(68, 24, 36, 16), const Radius.circular(3)),
      brickPaint,
    );

    // Rangée 3
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(4, 44, 36, 16), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(44, 44, 36, 16), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(84, 44, 32, 16), const Radius.circular(3)),
      brickPaint,
    );

    // Rangée 4 (décalée)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(4, 64, 20, 12), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(28, 64, 36, 12), const Radius.circular(3)),
      brickPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(68, 64, 36, 12), const Radius.circular(3)),
      brickPaint,
    );

    // Croix de mesure
    final crossPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5;
    // Vertical
    canvas.drawLine(Offset(size.width / 2, 4), Offset(size.width / 2, size.height - 4), crossPaint);
    // Horizontal
    canvas.drawLine(Offset(4, size.height / 2), Offset(size.width - 4, size.height / 2), crossPaint);
    // Petite croix au centre
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 6, cy - 6), Offset(cx + 6, cy + 6), crossPaint);
    canvas.drawLine(Offset(cx + 6, cy - 6), Offset(cx - 6, cy + 6), crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
