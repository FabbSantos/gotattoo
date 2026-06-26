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

/// Opens an Instagram profile by [handle] in the Instagram app, falling back to
/// the web. Accepts "@user", "user" or a full instagram.com URL.
Future<void> openInstagram(String handle) async {
  var h = handle.trim().replaceAll('@', '');
  h = h.replaceFirst(
    RegExp(r'^https?://(www\.)?instagram\.com/', caseSensitive: false),
    '',
  );
  h = h.replaceAll('/', '').trim();
  if (h.isEmpty) return;
  final appUri = Uri.parse('instagram://user?username=$h');
  final webUri = Uri.parse('https://www.instagram.com/$h');
  try {
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }
  } catch (_) {
    // Fall through to the web URL.
  }
  try {
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Best-effort.
  }
}
