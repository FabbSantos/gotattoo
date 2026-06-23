import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/order.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/orders/orders_cubit.dart';

enum _Method { card, pix }

/// Mock payment screen. No real money moves — it simulates processing, then
/// records the order. Real integration (Stripe Connect) is on the roadmap.
class PaymentPage extends StatefulWidget {
  final double total;

  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  _Method _method = _Method.card;
  bool _processing = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    final cart = context.read<CartBloc>();
    final user = context.read<AuthCubit>().state.user;
    final orders = context.read<OrdersCubit>();

    // Simulate talking to a payment processor.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (user != null && cart.state.items.isNotEmpty) {
      await orders.place(
        Order(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.id,
          items: cart.state.items,
          total: cart.state.totalPrice,
          createdAt: DateTime.now(),
        ),
      );
    }
    cart.add(const ClearCart());
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Pagamento aprovado!'),
        content: const Text(
          'Pagamento simulado com sucesso. Integração real entra no roadmap.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento')),
      body: AbsorbPointer(
        absorbing: _processing,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Forma de pagamento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<_Method>(
              segments: const [
                ButtonSegment(
                  value: _Method.card,
                  label: Text('Cartão'),
                  icon: Icon(Icons.credit_card),
                ),
                ButtonSegment(
                  value: _Method.pix,
                  label: Text('Pix'),
                  icon: Icon(Icons.pix),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() => _method = s.first),
            ),
            const SizedBox(height: 24),
            if (_method == _Method.card) ...[
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Número do cartão',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Validade',
                        hintText: 'MM/AA',
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_2, size: 96, color: Colors.grey[700]),
                    const SizedBox(height: 8),
                    Text(
                      'Escaneie o QR code para pagar (simulado)',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _processing ? null : _pay,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _processing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'PAGAR R\$ ${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
