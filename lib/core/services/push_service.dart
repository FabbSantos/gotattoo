import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'local_notifications_service.dart';

/// Background/terminated messages: FCM displays `notification`-type payloads
/// itself, so there's nothing to render here. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {}

/// Firebase Cloud Messaging integration: registers this device's token with the
/// backend and shows foreground pushes via [LocalNotificationsService].
///
/// Fully guarded: if Firebase isn't configured yet (no `google-services.json`)
/// or the backend is local/offline, every method is a harmless no-op, so the
/// app keeps working with just the in-app/local notifications.
class PushService {
  final LocalNotificationsService localNotifications;

  bool _ready = false;
  StreamSubscription? _refreshSub;

  PushService(this.localNotifications);

  Future<void> init() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      await FirebaseMessaging.instance.requestPermission();

      // Foreground messages aren't auto-displayed by the OS — show them.
      FirebaseMessaging.onMessage.listen((message) {
        final n = message.notification;
        if (n != null) {
          localNotifications.show(n.title ?? 'GoTattoo', n.body ?? '');
        }
      });
      _ready = true;
    } catch (_) {
      // Firebase not set up yet — push stays dormant.
      _ready = false;
    }
  }

  /// Save this device's FCM token for [userId] so the backend can target it.
  Future<void> registerFor(String userId) async {
    if (!_ready) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(userId, token);

      await _refreshSub?.cancel();
      _refreshSub = FirebaseMessaging.instance.onTokenRefresh
          .listen((t) => _saveToken(userId, t));
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      await Supabase.instance.client.from('device_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': 'android',
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
    } catch (_) {}
  }

  /// Drop this device's token (on logout) so it stops receiving pushes.
  Future<void> unregister() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    if (!_ready) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await Supabase.instance.client
            .from('device_tokens')
            .delete()
            .eq('token', token);
      }
    } catch (_) {}
  }
}
