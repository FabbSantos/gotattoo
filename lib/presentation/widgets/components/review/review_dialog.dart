import 'package:flutter/material.dart';

import 'star_rating.dart';

/// Shows a "leave a review" dialog (stars + comment) and calls [onSubmit].
Future<void> showReviewDialog(
  BuildContext context, {
  required void Function(int rating, String comment) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ReviewDialog(onSubmit: onSubmit),
  );
}

class _ReviewDialog extends StatefulWidget {
  final void Function(int rating, String comment) onSubmit;

  const _ReviewDialog({required this.onSubmit});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _rating = 5;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Avaliar tatuador'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StarSelector(
            value: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comentário (opcional)',
              hintText: 'Conte como foi a experiência...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSubmit(_rating, _controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
