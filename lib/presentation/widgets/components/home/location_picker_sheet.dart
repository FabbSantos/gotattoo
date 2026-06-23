import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/location_service.dart';

/// Bottom sheet to set the user's location via GPS or by searching an address.
class LocationPickerSheet {
  static Future<void> show(
    BuildContext context, {
    required void Function(Place place) onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LocationSheet(onSelected: onSelected),
    );
  }
}

class _LocationSheet extends StatefulWidget {
  final void Function(Place place) onSelected;

  const _LocationSheet({required this.onSelected});

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _service = sl<LocationService>();
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(Future<Place?> Function() action, String emptyMsg) async {
    setState(() => _loading = true);
    final place = await action();
    if (!mounted) return;
    setState(() => _loading = false);
    if (place == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emptyMsg)));
      return;
    }
    widget.onSelected(place);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Sua localização',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar endereço, bairro, cidade...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (q) => _run(
              () => _service.searchAddress(q),
              'Endereço não encontrado.',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.my_location, color: primary),
            ),
            title: const Text('Usar localização atual'),
            subtitle: const Text('Via GPS do aparelho'),
            onTap: () => _run(
              () => _service.currentPlace(),
              'Não foi possível obter o GPS (permissão negada?).',
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
