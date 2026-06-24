import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/location_service.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';

/// Lets the artist set their work location (GPS or address) so clients can find
/// them with the "nearby" filter.
class ArtistLocationPage extends StatefulWidget {
  const ArtistLocationPage({super.key});

  @override
  State<ArtistLocationPage> createState() => _ArtistLocationPageState();
}

class _ArtistLocationPageState extends State<ArtistLocationPage> {
  final _service = sl<LocationService>();
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Place> _suggestions = const [];
  bool _loading = false;
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 3) {
      setState(() => _suggestions = const []);
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final results = await _service.suggestAddresses(q);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  Future<void> _selectPlace(Place place) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = const [];
      _controller.text = place.label;
      _loading = true;
    });
    await context.read<AuthCubit>().updateProfile(
      latitude: place.lat,
      longitude: place.lng,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Localização salva!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _useGps() async {
    setState(() => _loading = true);
    final place = await _service.currentPlace();
    if (!mounted) return;
    if (place == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter o GPS (permissão negada?).'),
        ),
      );
      return;
    }
    await _selectPlace(place);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha localização')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      user?.hasLocation ?? false
                          ? Icons.location_on
                          : Icons.location_off,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user?.hasLocation ?? false
                            ? 'Localização definida '
                                '(${user!.latitude!.toStringAsFixed(4)}, '
                                '${user.longitude!.toStringAsFixed(4)})'
                            : 'Você ainda não definiu sua localização.',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              labelText: 'Endereço do estúdio',
              hintText: 'Rua, bairro, cidade...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Autocomplete suggestions.
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  for (final p in _suggestions)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 20),
                      title: Text(
                        p.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () => _selectPlace(p),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.my_location),
            label: const Text('Usar minha localização atual (GPS)'),
            onPressed: _useGps,
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
