import 'dart:io';

import 'package:flutter/widgets.dart';

/// Resolves an avatar reference to an [ImageProvider], transparently handling
/// both a remote URL (Supabase storage) and a local file path (offline mode).
/// Returns null when there's no avatar, so callers can show a placeholder.
ImageProvider? avatarImage(String? pathOrUrl) {
  if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
  if (pathOrUrl.startsWith('http')) return NetworkImage(pathOrUrl);
  return FileImage(File(pathOrUrl));
}
