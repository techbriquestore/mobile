import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../../data/services/order_service.dart' as checkout;
import '../../data/services/payment_service.dart';
import '../../../orders/data/providers/order_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String orderId;
  final bool isFirstPayment;
  final int totalInstallments;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    this.isFirstPayment = false,
    this.totalInstallments = 1,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedMethod = 0;
  int _selectedProvider = 0;
  final _phoneCtrl = TextEditingController();
  bool _isProcessing = false;
  _PaymentStatus _status = _PaymentStatus.idle;
  String? _errorMessage;
  String? _realOrderId;
  String? _realOrderNumber;

  final _methods = [
    {'label': 'Mobile Money', 'icon': Icons.phone_android, 'color': const Color(0xFFFF6D00)},
    {'label': 'Carte bancaire', 'icon': Icons.credit_card, 'color': const Color(0xFF1565C0)},
  ];

  final _mobileProviders = [
    {'label': 'Orange Money', 'color': const Color(0xFFFF6D00), 'prefix': '07'},
    {'label': 'MTN Money', 'color': const Color(0xFFFFCA28), 'prefix': '05'},
    {'label': 'Moov Money', 'color': const Color(0xFF42A5F5), 'prefix': '01'},
    {'label': 'Wave', 'color': const Color(0xFF1DE9B6), 'prefix': '07'},
  ];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _getPaymentMethod() {
    if (_selectedMethod == 1) return 'VISA';
    const methods = ['ORANGE_MONEY', 'MTN_MONEY', 'MOOV_MONEY', 'WAVE'];
    return methods[_selectedProvider];
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == 0 && _phoneCtrl.text.length < 10) return;
    
    // Check if user is authenticated
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
          content: Text('Veuillez vous connecter pour passer une commande'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ));
      context.push('/login');
      return;
    }
    
    setState(() { _isProcessing = true; _status = _PaymentStatus.processing; _errorMessage = null; });

    try {
      final orderService = checkout.OrderService(ServiceLocator.apiClient);
      final paymentService = PaymentService(ServiceLocator.apiClient);

      String orderId = widget.orderId;

      // Step 1: Create order if new (from checkout)
      if (orderId == 'NEW') {
        // Get extra data passed from checkout
        final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
        final cartItems = extra['cartItems'] as List<dynamic>? ?? [];
        final deliveryModeIndex = extra['deliveryMode'] as int? ?? 0;
        final deliveryModes = ['STANDARD', 'EXPRESS', 'PICKUP'];
        final paymentDuration = extra['totalInstallments'] as int? ?? 1;

        final request = checkout.CreateOrderRequest(
          items: cartItems.map((item) {
            final m = item as Map<String, dynamic>;
            return checkout.OrderItem(
              productId: m['productId'] as String,
              quantity: m['quantity'] as int,
            );
          }).toList(),
          deliveryMode: deliveryModes[deliveryModeIndex],
          paymentDuration: paymentDuration,
        );

        final order = await orderService.createOrder(request);
        orderId = order.id;
        _realOrderNumber = order.orderNumber;
      }

      _realOrderId = orderId;

      // Step 2: Simulate payment
      await paymentService.simulatePayment(
        orderId: orderId,
        amount: widget.amount.round(),
        method: _getPaymentMethod(),
        providerPhone: _selectedMethod == 0 ? _phoneCtrl.text : null,
      );

      // Step 3: Clear cart if this was a new order
      if (widget.orderId == 'NEW') {
        ref.read(cartProvider.notifier).clear();
      }

      // Invalidate orders list to refresh
      ref.invalidate(ordersProvider);

      if (!mounted) return;
      setState(() { _isProcessing = false; _status = _PaymentStatus.success; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _status = _PaymentStatus.idle;
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('Erreur : $_errorMessage'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Success screen
    if (_status == _PaymentStatus.success) return _buildSuccess();
    // Processing screen
    if (_status == _PaymentStatus.processing) return _buildProcessing();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Amount to pay ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF6D00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.isFirstPayment ? '1er versement' : 'Montant à payer',
                          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                        const SizedBox(height: 6),
                        Text('${_fmt(widget.amount)} FCFA', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                        if (widget.isFirstPayment) ...[
                          const SizedBox(height: 4),
                          Text('Commande CMD-${widget.orderId} • ${widget.totalInstallments} échéances', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Payment method selection ───
                  Text('MODE DE PAIEMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_methods.length, (i) {
                      final m = _methods[i];
                      final sel = _selectedMethod == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMethod = i),
                          child: Container(
                            margin: EdgeInsets.only(right: i == 0 ? 8 : 0, left: i == 1 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: sel ? (m['color'] as Color).withValues(alpha: 0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: sel ? m['color'] as Color : Colors.grey.shade200, width: sel ? 2 : 1),
                            ),
                            child: Column(
                              children: [
                                Icon(m['icon'] as IconData, color: sel ? m['color'] as Color : Colors.grey.shade400, size: 28),
                                const SizedBox(height: 8),
                                Text(m['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? m['color'] as Color : Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // ─── Mobile Money details ───
                  if (_selectedMethod == 0) ...[
                    Text('OPÉRATEUR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: List.generate(_mobileProviders.length, (i) {
                        final p = _mobileProviders[i];
                        final sel = _selectedProvider == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedProvider = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? (p['color'] as Color).withValues(alpha: 0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? p['color'] as Color : Colors.grey.shade200, width: sel ? 2 : 1),
                            ),
                            child: Text(p['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? p['color'] as Color : Colors.grey.shade500)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Phone number
                    Text('NUMÉRO DE TÉLÉPHONE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '${_mobileProviders[_selectedProvider]['prefix']} XX XX XX XX',
                          hintStyle: TextStyle(color: Colors.grey.shade300),
                          prefixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('+225', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                Container(width: 1, height: 24, color: Colors.grey.shade300),
                              ],
                            ),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18, color: AppColors.info),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Vous recevrez une demande de confirmation sur votre téléphone. Validez le paiement dans les 10 minutes.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ─── Card details ───
                  if (_selectedMethod == 1) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Text('Paiement sécurisé 3D Secure', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _CardField(label: 'Numéro de carte', hint: '•••• •••• •••• ••••', icon: Icons.credit_card),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _CardField(label: 'Expiration', hint: 'MM/AA', icon: Icons.calendar_today_outlined)),
                              const SizedBox(width: 14),
                              Expanded(child: _CardField(label: 'CVV', hint: '•••', icon: Icons.lock_outline)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _CardField(label: 'Nom sur la carte', hint: 'NOM PRENOM', icon: Icons.person_outline),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _cardLogo('VISA', const Color(0xFF1A1F71)),
                              const SizedBox(width: 16),
                              _cardLogo('MC', const Color(0xFFEB001B)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ─── Pay button ───
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_selectedMethod == 0 ? Icons.phone_android : Icons.credit_card, size: 22),
                    const SizedBox(width: 10),
                    Text('Payer ${_fmt(widget.amount)} FCFA', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardLogo(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
    );
  }

  // ─── Processing screen ───
  Widget _buildProcessing() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(strokeWidth: 5, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text('Traitement en cours...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                _selectedMethod == 0
                    ? 'Veuillez confirmer le paiement\nsur votre téléphone'
                    : 'Vérification de votre carte\nen cours',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              Text('Ne fermez pas cette page', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Success screen ───
  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(
                  child: Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Paiement réussi !', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                '${_fmt(widget.amount)} FCFA',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.success),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isFirstPayment
                    ? '1er versement pour ${_realOrderNumber ?? ''}\n${widget.totalInstallments - 1} échéances restantes'
                    : 'Commande ${_realOrderNumber ?? ''}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Vous recevrez une confirmation par SMS.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const Spacer(flex: 3),

              if (widget.isFirstPayment)
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/order-payments/${_realOrderId ?? widget.orderId}'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: const Text('Voir mon échéancier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/orders'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: const Text('Voir ma commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Retour à l\'accueil', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PaymentStatus { idle, processing, success }

class _CardField extends StatelessWidget {
  final String label, hint;
  final IconData icon;
  const _CardField({required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade300),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
            filled: true, fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
