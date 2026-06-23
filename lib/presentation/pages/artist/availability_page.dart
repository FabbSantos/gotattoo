import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/artist_availability.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/booking/availability_cubit.dart';

const _weekdayLabels = {
  1: 'Seg',
  2: 'Ter',
  3: 'Qua',
  4: 'Qui',
  5: 'Sex',
  6: 'Sáb',
  7: 'Dom',
};

/// Lets the artist set which weekdays and hours they accept appointments.
class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final artistId = context.read<AuthCubit>().state.user?.id ?? '';
    return BlocProvider(
      create: (_) => sl<AvailabilityCubit>()..load(artistId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Disponibilidade')),
        body: BlocBuilder<AvailabilityCubit, AvailabilityState>(
          builder: (context, state) {
            if (state.loading || state.availability == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _Editor(initial: state.availability!);
          },
        ),
      ),
    );
  }
}

class _Editor extends StatefulWidget {
  final ArtistAvailability initial;

  const _Editor({required this.initial});

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late Set<int> _weekdays;
  late int _start;
  late int _end;

  @override
  void initState() {
    super.initState();
    _weekdays = {...widget.initial.weekdays};
    _start = widget.initial.startHour;
    _end = widget.initial.endHour;
  }

  void _save() {
    if (_weekdays.isEmpty || _end <= _start) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha ao menos um dia e um horário válido.'),
        ),
      );
      return;
    }
    context.read<AvailabilityCubit>().save(
      widget.initial.copyWith(
        weekdays: _weekdays,
        startHour: _start,
        endHour: _end,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disponibilidade salva!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Dias que você atende',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _weekdayLabels.entries.map((e) {
            final selected = _weekdays.contains(e.key);
            return FilterChip(
              label: Text(e.value),
              selected: selected,
              onSelected: (v) => setState(() {
                v ? _weekdays.add(e.key) : _weekdays.remove(e.key);
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Horário de atendimento',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Das '),
            _HourDropdown(
              value: _start,
              onChanged: (v) => setState(() => _start = v),
            ),
            const Text('  às '),
            _HourDropdown(
              value: _end,
              onChanged: (v) => setState(() => _end = v),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _save,
            child: const Text('Salvar disponibilidade'),
          ),
        ),
      ],
    );
  }
}

class _HourDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _HourDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      items: [
        for (int h = 0; h <= 23; h++)
          DropdownMenuItem(value: h, child: Text('${h.toString().padLeft(2, '0')}h')),
      ],
      onChanged: (v) => v == null ? null : onChanged(v),
    );
  }
}
