import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// An authenticated user. The [role] is chosen at sign-up and decides whether
/// the app shows the client or the artist experience.
class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// Optional public nickname/handle.
  final String? nickname;

  /// Local file path of the chosen avatar (until a backend stores it as a URL).
  final String? avatarPath;

  /// Artist's work location (for the "nearby" filter).
  final double? latitude;
  final double? longitude;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nickname,
    this.avatarPath,
    this.latitude,
    this.longitude,
  });

  bool get isArtist => role == UserRole.artist;

  bool get hasLocation => latitude != null && longitude != null;

  /// Name shown in the UI: the nickname if set, otherwise the full name.
  String get displayName =>
      (nickname != null && nickname!.isNotEmpty) ? nickname! : name;

  AuthUser copyWith({
    String? name,
    String? nickname,
    String? avatarPath,
    double? latitude,
    double? longitude,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'nickname': nickname,
    'avatarPath': avatarPath,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromName(json['role'] as String?),
      nickname: json['nickname'] as String?,
      avatarPath: json['avatarPath'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    nickname,
    avatarPath,
    latitude,
    longitude,
  ];
}
