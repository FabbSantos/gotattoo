/// Which experience the app is currently showing.
///
/// In a real product this would come from authentication; here it is a toggle
/// persisted locally so the two flows can be demonstrated.
enum UserRole {
  client,
  artist;

  String get label => this == UserRole.artist ? 'Tatuador' : 'Cliente';

  static UserRole fromName(String? name) {
    return UserRole.values.firstWhere(
      (r) => r.name == name,
      orElse: () => UserRole.client,
    );
  }
}
