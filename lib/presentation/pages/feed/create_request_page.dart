import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/tattoo_request.dart';
import '../../../domain/repositories/tattoo_request_repository.dart';
import '../../bloc/auth/auth_cubit.dart';

/// Form to publish a tattoo idea — or edit an existing one when [existing] is
/// passed (the author editing their own post).
class CreateRequestPage extends StatefulWidget {
  final TattooRequest? existing;

  const CreateRequestPage({super.key, this.existing});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _placement = TextEditingController();
  final _budget = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _saving = false;
  bool _sensitive = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _description.text = e.description;
      _placement.text = e.placement ?? '';
      _budget.text = e.budget == null ? '' : e.budget!.toStringAsFixed(0);
      _imageUrl.text = e.imageUrl ?? '';
      _sensitive = e.sensitive;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _placement.dispose();
    _budget.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final repo = sl<TattooRequestRepository>();
    final existing = widget.existing;
    final request = TattooRequest(
      id: existing?.id ?? '',
      authorId: user.id,
      authorName: user.displayName,
      authorAvatar: existing?.authorAvatar ?? user.avatarPath,
      title: _title.text.trim(),
      description: _description.text.trim(),
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      placement:
          _placement.text.trim().isEmpty ? null : _placement.text.trim(),
      budget: double.tryParse(_budget.text.replaceAll(',', '.')),
      sensitive: _sensitive,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    try {
      if (_isEdit) {
        await repo.updateRequest(request);
      } else {
        await repo.create(request);
      }
      navigator.pop(true);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Não foi possível salvar. Tente de novo.'
                : 'Não foi possível publicar. Tente de novo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar pedido' : 'Publicar ideia')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex.: Leão geométrico no antebraço',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Dê um título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Estilo, tamanho, referências, cores...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _placement,
              decoration: const InputDecoration(
                labelText: 'Local do corpo',
                hintText: 'Ex.: antebraço esquerdo',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Orçamento (R\$)',
                hintText: 'Quanto pretende investir (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrl,
              decoration: const InputDecoration(
                labelText: 'URL de referência (opcional)',
                hintText: 'link de uma imagem de inspiração',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _sensitive,
              onChanged: (v) => setState(() => _sensitive = v),
              title: const Text('Conteúdo sensível (+18)'),
              subtitle: const Text(
                'A imagem aparece borrada até a pessoa tocar pra ver.',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ao publicar, você concorda em não postar conteúdo sexual '
              'explícito real, ofensivo ou ilegal. Denúncias são revisadas.',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _isEdit ? 'SALVAR' : 'PUBLICAR',
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
