import 'package:equatable/equatable.dart';

/// When an artist accepts appointments: which weekdays and the daily time
/// window. Weekdays use Dart's convention (1 = Monday … 7 = Sunday).
class ArtistAvailability extends Equatable {
  final String artistId;
  final Set<int> weekdays;
  final int startHour;
  final int endHour;

  const ArtistAvailability({
    required this.artistId,
    this.weekdays = const {1, 2, 3, 4, 5},
    this.startHour = 9,
    this.endHour = 18,
  });

  bool isAvailableOn(DateTime day) => weekdays.contains(day.weekday);

  /// Selectable start-of-hour slots within the daily window.
  List<int> get hourSlots =>
      [for (int h = startHour; h < endHour; h++) h];

  ArtistAvailability copyWith({
    Set<int>? weekdays,
    int? startHour,
    int? endHour,
  }) {
    return ArtistAvailability(
      artistId: artistId,
      weekdays: weekdays ?? this.weekdays,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }

  @override
  List<Object?> get props => [artistId, weekdays, startHour, endHour];
}
