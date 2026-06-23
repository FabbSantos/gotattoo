/// Supabase connection settings, injected at build time via `--dart-define`
/// so secrets stay out of source control and tests run in local mode.
///
/// Build with:
///   flutter build apk --release \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_KEY=sb_publishable_xxx
///
/// The publishable key is safe to ship in the client — access is guarded by
/// Row Level Security. NEVER use the secret key here.
///
/// While these are empty the app stays in fully local mode (in-memory + shared
/// preferences); once provided, the DI wires the Supabase-backed repositories.
abstract class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
