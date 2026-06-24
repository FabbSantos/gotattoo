import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// A resolved place: coordinates + a human-friendly label.
typedef Place = ({double lat, double lng, String label});

/// Wraps device GPS (geolocator), reverse-geocoding (geocoding) and address
/// autocomplete (OpenStreetMap Nominatim — free, no key).
class LocationService {
  /// Current GPS location with a reverse-geocoded label, or null if permission
  /// is denied / location is off. Uses medium accuracy + a time limit so it
  /// resolves fast, falling back to the last known fix.
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
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      // Timeout / no fix yet — use the last known position instead.
      pos = await Geolocator.getLastKnownPosition();
    }
    pos ??= await Geolocator.getLastKnownPosition();
    if (pos == null) return null;
    final label = await _labelFor(pos.latitude, pos.longitude) ??
        'Localização atual';
    return (lat: pos.latitude, lng: pos.longitude, label: label);
  }

  /// Address suggestions for [query] (autocomplete), newest first. Returns an
  /// empty list when the query is too short or the lookup fails.
  Future<List<Place>> suggestAddresses(String query) async {
    final q = query.trim();
    if (q.length < 3) return const [];
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': q,
      'format': 'jsonv2',
      'limit': '6',
      'accept-language': 'pt-BR',
      'countrycodes': 'br',
    });
    try {
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'GoTattoo/1.0 (support@gotattoo.app)'},
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body) as List;
      return [
        for (final item in list)
          (
            lat: double.parse(item['lat'] as String),
            lng: double.parse(item['lon'] as String),
            label: (item['display_name'] as String?) ?? q,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Resolves a typed address to coordinates + a clean label (single best hit).
  Future<Place?> searchAddress(String query) async {
    final suggestions = await suggestAddresses(query);
    if (suggestions.isNotEmpty) return suggestions.first;
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
