import 'package:url_launcher/url_launcher.dart';

/// Opens [raw] in the browser/external app. Prepends `https://` when the link
/// has no scheme (e.g. "instagram.com/foo"). Best-effort: never throws.
Future<void> openUrl(String raw) async {
  var s = raw.trim();
  if (s.isEmpty) return;
  if (!s.startsWith('http://') && !s.startsWith('https://')) {
    s = 'https://$s';
  }
  final uri = Uri.tryParse(s);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Ignore — opening a link is best-effort.
  }
}
