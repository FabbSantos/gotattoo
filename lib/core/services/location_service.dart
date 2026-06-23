import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// A resolved place: coordinates + a human-friendly label.
typedef Place = ({double lat, double lng, String label});

/// Wraps device GPS (geolocator) and address↔coordinates (geocoding). Both use
/// the OS providers — no paid API / key.
class LocationService {
  /// Current GPS location with a reverse-geocoded label, or null if permission
  /// is denied / location is off.
  Future<Place?> currentPlace() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final pos = await Geolocator.getCurrentPosition();
    final label = await _labelFor(pos.latitude, pos.longitude) ??
        'Localização atual';
    return (lat: pos.latitude, lng: pos.longitude, label: label);
  }

  /// Resolves a typed address to coordinates + a clean label.
  Future<Place?> searchAddress(String query) async {
    if (query.trim().isEmpty) return null;
    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty) return null;
      final loc = results.first;
      final label =
          await _labelFor(loc.latitude, loc.longitude) ?? query.trim();
      return (lat: loc.latitude, lng: loc.longitude, label: label);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _labelFor(double lat, double lng) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return null;
      final m = marks.first;
      final parts = [
        m.subLocality,
        m.locality,
        m.administrativeArea,
      ].where((p) => p != null && p.isNotEmpty).toList();
      return parts.isEmpty ? null : parts.take(2).join(', ');
    } catch (_) {
      return null;
    }
  }

  /// Straight-line distance in kilometers.
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
