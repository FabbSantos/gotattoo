import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/artist_availability.dart';
import '../../../domain/repositories/availability_repository.dart';

class AvailabilityState extends Equatable {
  final bool loading;
  final ArtistAvailability? availability;

  const AvailabilityState({this.loading = true, this.availability});

  @override
  List<Object?> get props => [loading, availability];
}

class AvailabilityCubit extends Cubit<AvailabilityState> {
  final AvailabilityRepository repository;

  AvailabilityCubit({required this.repository})
    : super(const AvailabilityState());

  Future<void> load(String artistId) async {
    emit(const AvailabilityState(loading: true));
    final a = await repository.get(artistId);
    emit(AvailabilityState(loading: false, availability: a));
  }

  Future<void> save(ArtistAvailability availability) async {
    await repository.save(availability);
    emit(AvailabilityState(loading: false, availability: availability));
  }
}
