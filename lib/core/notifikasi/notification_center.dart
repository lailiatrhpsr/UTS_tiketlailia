import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../feature/auth/data/models/profile_model.dart';

class AppNotification {
  final String id;
  final String ticketId;
  final String ticketTitle;
  final String label;
  final DateTime time;

  AppNotification({
    required this.id,
    required this.ticketId,
    required this.ticketTitle,
    required this.label,
    required this.time,
  });
}

class NotificationCenter {
  NotificationCenter._internal();
  static final NotificationCenter instance = NotificationCenter._internal();

  final ValueNotifier<List<AppNotification>> notifications = ValueNotifier([]);
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  RealtimeChannel? _channel;
  String? _activeProfileId;

  SupabaseClient get _db => Supabase.instance.client;

  Future<void> start(AppProfile profile) async {
    if (_channel != null && _activeProfileId == profile.id) return; // sudah jalan
    await stop();
    _activeProfileId = profile.id;

    await _loadInitial();

    _channel = _db.channel('notif-${profile.id}')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'ticket_history',
        callback: (payload) => _handleInsert(payload.newRecord),
      )
      ..subscribe();
  }

  Future<void> stop() async {
    if (_channel != null) {
      await _db.removeChannel(_channel!);
      _channel = null;
    }
    notifications.value = [];
    unreadCount.value = 0;
    _activeProfileId = null;
  }

  Future<void> _loadInitial() async {
    try {
      final rows = await _db
          .from('ticket_history')
          .select('id, ticket_id, label, created_at, tickets(title)')
          .order('created_at', ascending: false)
          .limit(20);

      notifications.value = (rows as List).map((r) {
        final ticketData = r['tickets'] as Map<String, dynamic>?;
        return AppNotification(
          id: r['id'] as String,
          ticketId: r['ticket_id'] as String,
          ticketTitle: ticketData?['title'] as String? ?? r['ticket_id'] as String,
          label: r['label'] as String,
          time: DateTime.parse(r['created_at'] as String),
        );
      }).toList();
    } catch (_) {
      notifications.value = [];
    }
  }

  Future<void> _handleInsert(Map<String, dynamic> row) async {
    String title = row['ticket_id'] as String;
    try {
      final t = await _db.from('tickets').select('title').eq('id', row['ticket_id']).maybeSingle();
      if (t != null) title = t['title'] as String;
    } catch (_) {}

    final n = AppNotification(
      id: row['id'] as String,
      ticketId: row['ticket_id'] as String,
      ticketTitle: title,
      label: row['label'] as String,
      time: DateTime.parse(row['created_at'] as String),
    );
    notifications.value = [n, ...notifications.value];
    unreadCount.value = unreadCount.value + 1;
  }

  void markAllRead() {
    unreadCount.value = 0;
  }
}
