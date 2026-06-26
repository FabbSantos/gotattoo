import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_role.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _instagramController = TextEditingController();
  UserRole _role = UserRole.client;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _portfolioController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final isArtist = _role == UserRole.artist;
    context.read<AuthCubit>().signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _role,
      portfolio: isArtist ? _portfolioController.text.trim() : null,
      instagram: isArtist ? _instagramController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The auth gate (in main.dart) swaps to the home page once authenticated,
    // so on success we just pop back to let the gate take over.
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr.status == AuthStatus.authenticated,
      listener: (context, state) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Criar conta')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 4)
                      ? 'Mínimo 4 caracteres'
                      : null,
                ),
                const SizedBox(height: 20),
                const Text('Quero usar como:'),
                const SizedBox(height: 8),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.client,
                      label: Text('Cliente'),
                      icon: Icon(Icons.shopping_bag_outlined),
                    ),
                    ButtonSegment(
                      value: UserRole.artist,
                      label: Text('Tatuador'),
                      icon: Icon(Icons.brush),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (selection) =>
                      setState(() => _role = selection.first),
                ),
                if (_role == UserRole.artist) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _portfolioController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Link do portfólio',
                      hintText: 'Site, Behance, drive...',
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: (v) {
                      if (_role != UserRole.artist) return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe um link do seu trabalho';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram (opcional)',
                      hintText: '@seu_perfil',
                      prefixIcon: Icon(Icons.camera_alt_outlined),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Contas de tatuador passam por aprovação. O portfólio '
                            'ajuda o GoTattoo a te aprovar. Você entra como '
                            'cliente e é avisado quando for aprovado.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              state.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.submitting ? null : _submit,
                            child: state.submitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Cadastrar'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
