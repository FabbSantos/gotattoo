import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/payout_account.dart';
import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';

/// Lets an artist register where they get paid. A PayPal-style stand-in until
/// real payment onboarding lands (see ROADMAP.md).
class PayoutAccountPage extends StatefulWidget {
  const PayoutAccountPage({super.key});

  @override
  State<PayoutAccountPage> createState() => _PayoutAccountPageState();
}

class _PayoutAccountPageState extends State<PayoutAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final account = context.read<SessionCubit>().state.payoutAccount;
    _emailController = TextEditingController(text: account?.identifier ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SessionCubit>().savePayoutAccount(
      PayoutAccount(provider: 'PayPal', identifier: _emailController.text),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta de recebimento salva!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conta de Recebimento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guarde sua chave Pix/PayPal de referência. No momento o '
                'pagamento das tatuagens é combinado direto com o cliente — '
                'você fica com 100%.',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail do PayPal',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o e-mail do PayPal';
                  }
                  if (!value.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<SessionCubit, SessionState>(
                builder: (context, state) {
                  if (!state.hasPayoutAccount) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Conta ativa: ${state.payoutAccount!.identifier}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salvar conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
