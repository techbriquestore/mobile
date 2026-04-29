import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../../../catalog/providers/catalog_providers.dart';
import '../../domain/estimator_data.dart';
import '../../domain/models/estimator_models.dart';
import '../widgets/estimator_widgets.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  // ─── État global ───
  int _step = 0;
  String? _projectType;

  // Maison
  String _houseMode = 'pieces'; // 'pieces' | 'perimetre'
  final List<RoomItem> _rooms = [];
  final TextEditingController _perimeterCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController(text: '3');
  int _generalOpenings = 4;

  // Clôture
  final TextEditingController _fenceLengthCtrl = TextEditingController();
  final TextEditingController _fenceHeightCtrl = TextEditingController(text: '2');
  int _fenceGates = 1;

  // Dalle
  final TextEditingController _slabLengthCtrl = TextEditingController();
  final TextEditingController _slabWidthCtrl = TextEditingController();

  // Global
  double _margin = 10;
  final Map<String, BrickProduct> _brickOverrides = {};

  static final NumberFormat _fmt = NumberFormat.decimalPattern('fr_FR');

  // ─── Helpers ───
  String _formatNumber(num n) => _fmt.format(n.round());
  double _parseDouble(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;

  void _addRoom(RoomPreset preset) {
    setState(() {
      _rooms.add(RoomItem(
        uid: '${DateTime.now().microsecondsSinceEpoch}_${_rooms.length}',
        presetId: preset.id,
        name: preset.name,
        icon: preset.icon,
        length: preset.defLength,
        width: preset.defWidth,
        height: preset.defHeight,
        openings: preset.openings,
        type: preset.type,
        qty: 1,
      ));
    });
  }

  void _updateRoom(String uid, void Function(RoomItem r) update) {
    final i = _rooms.indexWhere((r) => r.uid == uid);
    if (i < 0) return;
    setState(() => update(_rooms[i]));
  }

  void _removeRoom(String uid) {
    setState(() => _rooms.removeWhere((r) => r.uid == uid));
  }

  // ─── Mapping backend Product → domaine BrickProduct ───
  BrickProduct _fromProduct(Product p) {
    return BrickProduct(
      id: p.id,
      name: p.name,
      category: p.category?.label ?? '',
      dim: BrickDimensions(
        length: p.lengthCm ?? 40,
        height: p.heightCm ?? 20,
        thickness: p.widthCm ?? 15,
      ),
      unitPrice: p.unitPrice,
      bulkPrice: p.bulkPrice ?? p.unitPrice * 1000,
      usage: p.description ?? p.name,
      joint: 1.5,
      auto: p.usages,
    );
  }

  // ─── Calcul des lignes du devis ───
  List<EstimateLine> _computeLines(List<BrickProduct> catalogue) {
    final lines = <EstimateLine>[];

    if (_projectType == 'maison') {
      if (_houseMode == 'pieces') {
        double extSurface = 0, intSurface = 0, extOpenings = 0, intOpenings = 0;
        for (final p in _rooms) {
          final perim = 2 * (p.length + p.width);
          final surf = perim * p.height * p.qty;
          final ouv = (p.openings * p.qty).toDouble();
          if (p.type == 'ext') {
            extSurface += surf;
            extOpenings += ouv;
          } else {
            intSurface += surf;
            intOpenings += ouv;
          }
        }
        if (extSurface > 0 || intSurface > 0) {
          final combinedSurf = extSurface + intSurface;
          final combinedOuv = extOpenings + intOpenings;
          const extRatio = 0.35;
          final extSurf = combinedSurf * extRatio - (combinedOuv * extRatio * 1.8);
          final intSurf = combinedSurf * (1 - extRatio) - (combinedOuv * (1 - extRatio) * 1.5);

          final extBrick = _brickOverrides['maison_ext'] ?? EstimatorMath.suggestBrick('mur_ext', catalogue);
          final intBrick = _brickOverrides['maison_int'] ?? EstimatorMath.suggestBrick('cloison', catalogue);
          final extQty = (extSurf.clamp(0, double.infinity) * EstimatorMath.bricksPerSquareMeter(extBrick) * (1 + _margin / 100)).ceil();
          final intQty = (intSurf.clamp(0, double.infinity) * EstimatorMath.bricksPerSquareMeter(intBrick) * (1 + _margin / 100)).ceil();
          if (extQty > 0) {
            lines.add(EstimateLine(key: 'maison_ext', label: 'Murs extérieurs (porteurs)', brick: extBrick, qty: extQty, surface: extSurf.clamp(0, double.infinity).toDouble()));
          }
          if (intQty > 0) {
            lines.add(EstimateLine(key: 'maison_int', label: 'Cloisons intérieures', brick: intBrick, qty: intQty, surface: intSurf.clamp(0, double.infinity).toDouble()));
          }
        }
      } else {
        final p = _parseDouble(_perimeterCtrl.text);
        final h = _parseDouble(_heightCtrl.text);
        final surf = p * h - (_generalOpenings * 1.8);
        final brick = _brickOverrides['maison_ext'] ?? EstimatorMath.suggestBrick('mur_ext', catalogue);
        final qty = (surf.clamp(0, double.infinity) * EstimatorMath.bricksPerSquareMeter(brick) * (1 + _margin / 100)).ceil();
        if (qty > 0) {
          lines.add(EstimateLine(key: 'maison_ext', label: 'Murs extérieurs', brick: brick, qty: qty, surface: surf.clamp(0, double.infinity).toDouble()));
        }
      }
    }

    if (_projectType == 'cloture') {
      final l = _parseDouble(_fenceLengthCtrl.text);
      final h = _parseDouble(_fenceHeightCtrl.text);
      final surf = l * h - (_fenceGates * 3.5);
      final brick = _brickOverrides['cloture'] ?? EstimatorMath.suggestBrick('cloture', catalogue);
      final qty = (surf.clamp(0, double.infinity) * EstimatorMath.bricksPerSquareMeter(brick) * (1 + _margin / 100)).ceil();
      if (qty > 0) {
        lines.add(EstimateLine(key: 'cloture', label: 'Mur de clôture', brick: brick, qty: qty, surface: surf.clamp(0, double.infinity).toDouble()));
      }
    }

    if (_projectType == 'dalle') {
      final l = _parseDouble(_slabLengthCtrl.text);
      final w = _parseDouble(_slabWidthCtrl.text);
      final surf = l * w;
      final brick = _brickOverrides['dalle'] ?? EstimatorMath.suggestBrick('dalle', catalogue);
      final perM2 = 1 / ((brick.dim.length / 100) * (brick.dim.thickness / 100));
      final qty = (surf * perM2 * (1 + _margin / 100)).ceil();
      if (qty > 0) {
        lines.add(EstimateLine(key: 'dalle', label: 'Dalle / Plancher', brick: brick, qty: qty, surface: surf));
      }
    }

    if (_projectType == 'autre') {
      final p = _parseDouble(_perimeterCtrl.text);
      final h = _parseDouble(_heightCtrl.text);
      final surf = p * h - (_generalOpenings * 1.8);
      final brick = _brickOverrides['autre'] ?? EstimatorMath.suggestBrick('mur_ext', catalogue);
      final qty = (surf.clamp(0, double.infinity) * EstimatorMath.bricksPerSquareMeter(brick) * (1 + _margin / 100)).ceil();
      if (qty > 0) {
        lines.add(EstimateLine(key: 'autre', label: 'Murs du bâtiment', brick: brick, qty: qty, surface: surf.clamp(0, double.infinity).toDouble()));
      }
    }

    return lines;
  }

  bool _canNext(int totalBricks) {
    if (_step == 0) return _projectType != null;
    if (_step == 1) return totalBricks > 0;
    return true;
  }

  @override
  void dispose() {
    _perimeterCtrl.dispose();
    _heightCtrl.dispose();
    _fenceLengthCtrl.dispose();
    _fenceHeightCtrl.dispose();
    _slabLengthCtrl.dispose();
    _slabWidthCtrl.dispose();
    super.dispose();
  }

  Scaffold _scaffoldShell({required Widget body}) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Estimateur de projet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(estimatorProductsProvider);

    return productsAsync.when(
      loading: () => _scaffoldShell(
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => _scaffoldShell(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                const Text(
                  'Impossible de charger les produits',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.refresh(estimatorProductsProvider),
                  child: const Text('Réessayer', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (products) {
        final catalogue = products.map(_fromProduct).toList();
        final lines = _computeLines(catalogue);
        final totalBricks = lines.fold<int>(0, (s, l) => s + l.qty);
        final totalPrice = lines.fold<double>(0, (s, l) => s + EstimatorMath.computePrice(l.qty, l.brick));
        return _scaffoldShell(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: StepIndicator(
                    currentStep: _step,
                    labels: const ['Type', 'Dimensions', 'Devis & Paiement'],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStep(lines, totalBricks, totalPrice, catalogue),
                      ),
                    ),
                  ),
                ),
                _buildBottomNav(totalBricks),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(List<EstimateLine> lines, int totalBricks, double totalPrice, List<BrickProduct> catalogue) {
    switch (_step) {
      case 0:
        return _buildStepProjectType();
      case 1:
        return _buildStepDimensions(totalBricks, totalPrice);
      case 2:
        return _buildStepResults(lines, totalBricks, totalPrice, catalogue);
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════ STEP 0: Type de projet ═══════
  Widget _buildStepProjectType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quel est votre projet ?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sélectionnez le type de construction pour une estimation adaptée',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.92,
          children: kProjectTypes.map((t) {
            final selected = _projectType == t.id;
            return _ProjectCard(
              type: t,
              selected: selected,
              onTap: () => setState(() => _projectType = t.id),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═══════ STEP 1: Dimensions ═══════
  Widget _buildStepDimensions(int totalBricks, double totalPrice) {
    String title;
    switch (_projectType) {
      case 'maison':
        title = 'Décrivez votre maison';
        break;
      case 'cloture':
        title = 'Votre clôture';
        break;
      case 'dalle':
        title = 'Votre dalle';
        break;
      default:
        title = 'Votre projet';
    }
    final subtitle = _projectType == 'maison'
        ? 'Ajoutez les pièces de votre maison ou entrez le périmètre total'
        : 'Renseignez les dimensions de votre projet';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        const SizedBox(height: 22),

        if (_projectType == 'maison') _buildHouseSection(),
        if (_projectType == 'cloture') _buildFenceSection(),
        if (_projectType == 'dalle') _buildSlabSection(),
        if (_projectType == 'autre') _buildOtherSection(),

        if (_projectType != null) ...[
          const SizedBox(height: 26),
          _buildMarginSlider(),
        ],

        if (totalBricks > 0) ...[
          const SizedBox(height: 22),
          _buildLivePreview(totalBricks, totalPrice),
        ],
      ],
    );
  }

  Widget _buildHouseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        Row(
          children: [
            _TabButton(
              label: 'Pièce par pièce',
              icon: Icons.home_rounded,
              active: _houseMode == 'pieces',
              onTap: () => setState(() => _houseMode = 'pieces'),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: 'Périmètre total',
              icon: Icons.straighten_rounded,
              active: _houseMode == 'perimetre',
              onTap: () => setState(() => _houseMode = 'perimetre'),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (_houseMode == 'pieces') ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              'Ajouter une pièce',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kRoomPresets.map((p) => _RoomChip(preset: p, onTap: () => _addRoom(p))).toList(),
          ),
          const SizedBox(height: 16),
          if (_rooms.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.08), style: BorderStyle.solid, width: 1.5),
                color: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.home_outlined, color: AppColors.textHint, size: 38),
                  SizedBox(height: 10),
                  Text(
                    'Ajoutez les pièces de votre maison',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cliquez sur les pièces ci-dessus pour commencer',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textHint),
                  ),
                ],
              ),
            )
          else
            ..._rooms.map((r) => _buildRoomRow(r)),
        ] else
          _buildPerimeterForm(),
      ],
    );
  }

  Widget _buildPerimeterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledNumberField(
          label: 'Périmètre total de la maison (m)',
          suffix: 'm',
          hint: 'ex: 40',
          controller: _perimeterCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        LabeledNumberField(
          label: 'Hauteur des murs (m)',
          suffix: 'm',
          hint: '3',
          controller: _heightCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.only(bottom: 8, left: 2),
          child: Text("Nombre d'ouvertures (portes + fenêtres)",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: CounterField(value: _generalOpenings, onChanged: (v) => setState(() => _generalOpenings = v)),
        ),
        const SizedBox(height: 12),
        _InfoBubble(
          text: '💡 Le périmètre = tour complet de la maison. Ex: maison 10m × 8m → périmètre = 36m',
        ),
      ],
    );
  }

  Widget _buildFenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledNumberField(
          label: 'Longueur totale de la clôture (m)',
          suffix: 'm',
          hint: 'ex: 80',
          controller: _fenceLengthCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        LabeledNumberField(
          label: 'Hauteur de la clôture (m)',
          suffix: 'm',
          hint: '2',
          controller: _fenceHeightCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.only(bottom: 8, left: 2),
          child: Text('Nombre de portails / entrées',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: CounterField(value: _fenceGates, onChanged: (v) => setState(() => _fenceGates = v)),
        ),
        const SizedBox(height: 12),
        const _InfoBubble(text: '💡 Mesurez tout le tour du terrain. Chaque portail déduit environ 3,5 m de mur.'),
      ],
    );
  }

  Widget _buildSlabSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: LabeledNumberField(
                label: 'Longueur (m)',
                suffix: 'm',
                hint: '12',
                controller: _slabLengthCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledNumberField(
                label: 'Largeur (m)',
                suffix: 'm',
                hint: '10',
                controller: _slabWidthCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _InfoBubble(text: '💡 Le système vous suggère automatiquement les hourdis adaptés à votre projet.'),
      ],
    );
  }

  Widget _buildOtherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledNumberField(
          label: 'Périmètre total des murs (m)',
          suffix: 'm',
          hint: 'ex: 30',
          controller: _perimeterCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        LabeledNumberField(
          label: 'Hauteur des murs (m)',
          suffix: 'm',
          hint: '3',
          controller: _heightCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.only(bottom: 8, left: 2),
          child: Text("Nombre d'ouvertures",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: CounterField(value: _generalOpenings, onChanged: (v) => setState(() => _generalOpenings = v)),
        ),
      ],
    );
  }

  Widget _buildRoomRow(RoomItem r) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(r.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: r.presetId == 'custom'
                    ? TextFormField(
                        initialValue: r.name == 'Pièce personnalisée' ? '' : r.name,
                        onChanged: (v) => _updateRoom(r.uid, (rr) => rr.name = v.isEmpty ? 'Pièce personnalisée' : v),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Nom de la pièce',
                          border: InputBorder.none,
                        ),
                      )
                    : Text(r.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              if (r.qty > 1)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                  child: Text('×${r.qty}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              CounterField(value: r.qty, onChanged: (v) => _updateRoom(r.uid, (rr) => rr.qty = v), min: 1, max: 10),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.error,
                visualDensity: VisualDensity.compact,
                onPressed: () => _removeRoom(r.uid),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _RoomNumberCell(label: 'Long.', suffix: 'm', value: r.length, onChanged: (v) => _updateRoom(r.uid, (rr) => rr.length = v))),
              const SizedBox(width: 8),
              Expanded(child: _RoomNumberCell(label: 'Larg.', suffix: 'm', value: r.width, onChanged: (v) => _updateRoom(r.uid, (rr) => rr.width = v))),
              const SizedBox(width: 8),
              Expanded(child: _RoomNumberCell(label: 'Haut.', suffix: 'm', value: r.height, onChanged: (v) => _updateRoom(r.uid, (rr) => rr.height = v))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text('Ouvertures', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ),
              CounterField(value: r.openings, onChanged: (v) => _updateRoom(r.uid, (rr) => rr.openings = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarginSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Marge pour pertes et casse',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            Text('${_margin.round()}%',
                style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w800)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.black.withOpacity(0.08),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: _margin,
            min: 5,
            max: 20,
            divisions: 15,
            onChanged: (v) => setState(() => _margin = v),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('5%', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            Text('20%', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ],
    );
  }

  Widget _buildLivePreview(int totalBricks, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.10), AppColors.primaryLight.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimation en direct', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: _formatNumber(totalBricks),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const TextSpan(
                      text: ' briques',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Budget estimé', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: _formatNumber(totalPrice),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const TextSpan(
                    text: ' FCFA',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════ STEP 2: Devis & Paiement ═══════
  Widget _buildStepResults(List<EstimateLine> lines, int totalBricks, double totalPrice, List<BrickProduct> catalogue) {
    final projet = kProjectTypes.firstWhere((t) => t.id == _projectType, orElse: () => kProjectTypes.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Votre devis estimatif',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Récapitulatif de votre estimation — ajoutez au panier pour commander',
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        const SizedBox(height: 22),

        // Bloc devis
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(projet.icon, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(projet.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 14),
              for (final line in lines) _buildLineCard(line, catalogue),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total estimé', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('${_formatNumber(totalBricks)} briques au total',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textHint)),
                    ],
                  ),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: _formatNumber(totalPrice),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      const TextSpan(
                        text: ' FCFA',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Garantie
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppColors.success),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Garantie « Livré ou Remboursé »',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.success, fontSize: 14)),
                    SizedBox(height: 4),
                    Text(
                      'Prix garanti pendant toute la durée. En cas de paiement partiel à la fin, les briques réglées vous sont livrées ou vous êtes remboursé.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        PrimaryButton(
          label: 'Ajouter au panier',
          fullWidth: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          trailingIcon: Icons.shopping_cart_outlined,
          onTap: lines.isEmpty
              ? null
              : () {
                  final products = ref.read(estimatorProductsProvider).when(
                    data: (v) => v,
                    loading: () => <Product>[],
                    error: (_, __) => <Product>[],
                  );
                  final cartNotifier = ref.read(cartProvider.notifier);
                  for (final line in lines) {
                    final matching = products.where((p) => p.id == line.brick.id);
                    if (matching.isNotEmpty) {
                      cartNotifier.addProduct(matching.first, quantity: line.qty);
                    }
                  }
                  context.push('/cart');
                },
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Les options de paiement échelonné sont disponibles lors de la commande',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLineCard(EstimateLine line, List<BrickProduct> catalogue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (line.surface > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('${_formatNumber(line.surface)} m² de surface',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textHint)),
                      ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: _formatNumber(line.qty),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const TextSpan(
                    text: ' briques',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Sélecteur de brique
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.textHint),
              const SizedBox(width: 6),
              const Text('Brique :', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: catalogue.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(line.brick.name,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: catalogue.any((b) => b.id == line.brick.id) ? line.brick.id : catalogue.first.id,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint, size: 18),
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                            items: catalogue.map((b) {
                              return DropdownMenuItem(
                                value: b.id,
                                child: Text(
                                  '${b.name} — ${b.unitPrice.round()} FCFA/u',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id == null) return;
                              final newBrick = catalogue.firstWhere((b) => b.id == id, orElse: () => line.brick);
                              setState(() => _brickOverrides[line.key] = newBrick);
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _detailQty(line.qty),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  '${_formatNumber(EstimatorMath.computePrice(line.qty, line.brick))} FCFA',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _detailQty(int qty) {
    final m = qty ~/ 1000;
    final r = qty % 1000;
    final parts = <String>[];
    if (m > 0) parts.add('$m millier${m > 1 ? "s" : ""}');
    if (r > 0) parts.add('$r unités');
    return parts.join(' + ');
  }


  // ─── Bottom navigation ───
  Widget _buildBottomNav(int totalBricks) {
    final canNext = _canNext(totalBricks);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          if (_step > 0)
            GhostButton(
              label: 'Retour',
              leadingIcon: Icons.arrow_back_rounded,
              onTap: () => setState(() => _step--),
            ),
          const Spacer(),
          if (_step < 2)
            PrimaryButton(
              label: 'Continuer',
              trailingIcon: Icons.arrow_forward_rounded,
              onTap: canNext ? () => setState(() => _step++) : null,
            ),
        ],
      ),
    );
  }
}

// ═══════ COMPOSANTS PRIVÉS ═══════

class _ProjectCard extends StatelessWidget {
  final ProjectType type;
  final bool selected;
  final VoidCallback onTap;
  const _ProjectCard({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.black.withOpacity(0.06),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    size: 26,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  type.label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  type.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                ),
                if (selected) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomChip extends StatelessWidget {
  final RoomPreset preset;
  final VoidCallback onTap;
  const _RoomChip({required this.preset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(preset.icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(preset.name, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(width: 4),
              const Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withOpacity(0.10) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppColors.primary : Colors.black.withOpacity(0.08),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomNumberCell extends StatefulWidget {
  final String label;
  final String suffix;
  final double value;
  final ValueChanged<double> onChanged;
  const _RoomNumberCell({
    required this.label,
    required this.suffix,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_RoomNumberCell> createState() => _RoomNumberCellState();
}

class _RoomNumberCellState extends State<_RoomNumberCell> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value > 0 ? widget.value.toString() : '');
  }

  @override
  void didUpdateWidget(covariant _RoomNumberCell old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      final newText = widget.value > 0 ? widget.value.toString() : '';
      if (_ctrl.text != newText) _ctrl.text = newText;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textHint, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: _ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => widget.onChanged(double.tryParse(v.replaceAll(',', '.')) ?? 0),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            suffixText: widget.suffix,
            suffixStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBubble extends StatelessWidget {
  final String text;
  final Color? color;
  const _InfoBubble({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
      ),
    );
  }
}
