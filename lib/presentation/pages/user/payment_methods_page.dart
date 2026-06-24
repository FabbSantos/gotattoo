import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/payment_service.dart';

/// Manage the client's saved cards: list, add (Payment Sheet) and remove.
class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final _payments = sl<PaymentService>();
  bool _loading = true;
  List<SavedCard> _cards = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cards = await _payments.listCards();
      if (mounted) setState(() => _cards = cards);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final saved = await _payments.collectCard();
    if (saved) await _load();
  }

  Future<void> _remove(SavedCard card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover cartão?'),
        content: Text('Cartão ${_brandLabel(card.brand)} •••• ${card.last4}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _payments.removeCard(card.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formas de pagamento')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar cartão'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? _empty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _cardTile(_cards[i]),
                  ),
                ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Nenhum cartão salvo.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Adicione um para agilizar seus agendamentos.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );

  Widget _cardTile(SavedCard card) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.credit_card, color: Theme.of(context).primaryColor),
        ),
        title: Text('${_brandLabel(card.brand)} •••• ${card.last4}'),
        subtitle: Text(
          'Validade ${card.expMonth.toString().padLeft(2, '0')}/${card.expYear}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _remove(card),
        ),
      ),
    );
  }

  String _brandLabel(String brand) {
    switch (brand) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'Amex';
      case 'elo':
        return 'Elo';
      default:
        return brand.isEmpty ? 'Cartão' : '${brand[0].toUpperCase()}${brand.substring(1)}';
    }
  }
}
