/// Google Sign-In configuration.
///
/// The **Web** OAuth client id (used as `serverClientId` so the Google ID token's
/// audience matches what Supabase expects). It's a public value — safe in the
/// app. Overridable at build time with --dart-define=GOOGLE_WEB_CLIENT_ID=...
abstract class GoogleAuthConfig {
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '14900184551-io57vvld378j1uvlb98hslrh91dah1oq.apps.googleusercontent.com',
  );

  static bool get isConfigured => webClientId.isNotEmpty;
}
