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
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _set(Future<Place?> Function() action, String emptyMsg) async {
    setState(() => _loading = true);
    final place = await action();
    if (!mounted) return;
    if (place == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emptyMsg)));
      return;
    }
    await context.read<AuthCubit>().updateProfile(
      latitude: place.lat,
      longitude: place.lng,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Localização salva: ${place.label}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            decoration: InputDecoration(
              labelText: 'Endereço do estúdio',
              hintText: 'Rua, bairro, cidade...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (q) =>
                _set(() => _service.searchAddress(q), 'Endereço não encontrado.'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.my_location),
            label: const Text('Usar minha localização atual (GPS)'),
            onPressed: () => _set(
              () => _service.currentPlace(),
              'Não foi possível obter o GPS (permissão negada?).',
            ),
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
