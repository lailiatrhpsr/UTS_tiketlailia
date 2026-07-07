import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_role.dart';
import 'models/ticket_model.dart';

class TicketRepository {
  TicketRepository._internal();
  static final TicketRepository instance = TicketRepository._internal();

  static const String _tickets = 'tickets';
  static const String _comments = 'ticket_comments';
  static const String _history = 'ticket_history';
  static const String _reports = 'ticket_reports';

  SupabaseClient get _db => Supabase.instance.client;

  String get _currentUserId {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw Exception('Belum login.');
    return id;
  }

  Future<Map<String, String>> _usernameMap() async {
    final rows = await _db.from('profiles').select('id, username');
    final map = <String, String>{};
    for (final r in (rows as List)) {
      map[r['id'] as String] = r['username'] as String;
    }
    return map;
  }

  TicketModel _rowToTicket(Map<String, dynamic> row, Map<String, String> usernames) {
    final helpdeskId = row['assigned_helpdesk'] as String?;
    return TicketModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      status: TicketStatusX.fromName(row['status'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      attachmentPath: row['attachment_path'] as String?,
      createdById: row['created_by'] as String,
      createdByUsername: usernames[row['created_by']] ?? 'unknown',
      assignedHelpdeskId: helpdeskId,
      assignedHelpdeskUsername: helpdeskId != null ? (usernames[helpdeskId] ?? 'unknown') : null,
      reporterName: row['reporter_name'] as String?,
      channel: row['channel'] as String?,
    );
  }

  Future<List<TicketModel>> getForUser() async {
    final rows = await _db
        .from(_tickets)
        .select()
        .eq('created_by', _currentUserId)
        .order('created_at', ascending: false);
    final usernames = await _usernameMap();
    return (rows as List).map((r) => _rowToTicket(r as Map<String, dynamic>, usernames)).toList();
  }

  Future<List<TicketModel>> getForHelpdesk() async {
    final rows = await _db
        .from(_tickets)
        .select()
        .eq('assigned_helpdesk', _currentUserId)
        .order('created_at', ascending: false);
    final usernames = await _usernameMap();
    return (rows as List).map((r) => _rowToTicket(r as Map<String, dynamic>, usernames)).toList();
  }

  Future<List<TicketModel>> getForAdmin() async {
    final rows = await _db.from(_tickets).select().order('created_at', ascending: false);
    final usernames = await _usernameMap();
    return (rows as List).map((r) => _rowToTicket(r as Map<String, dynamic>, usernames)).toList();
  }

  Future<TicketModel?> getById(String ticketId) async {
    final row = await _db.from(_tickets).select().eq('id', ticketId).maybeSingle();
    if (row == null) return null;

    final usernames = await _usernameMap();
    final commentRows =
    await _db.from(_comments).select().eq('ticket_id', ticketId).order('created_at');
    final historyRows =
    await _db.from(_history).select().eq('ticket_id', ticketId).order('created_at');
    final reportRows =
    await _db.from(_reports).select().eq('ticket_id', ticketId).order('created_at');

    final base = _rowToTicket(row, usernames);
    return base.copyWith(
      comments: (commentRows as List)
          .map((c) => TicketComment(
        author: usernames[c['author_id']] ?? 'unknown',
        message: c['message'] as String,
        time: DateTime.parse(c['created_at'] as String),
      ))
          .toList(),
      history: (historyRows as List)
          .map((h) => TicketHistoryEntry(
        label: h['label'] as String,
        time: DateTime.parse(h['created_at'] as String),
      ))
          .toList(),
      reports: (reportRows as List)
          .map((r) => TicketReport(
        id: r['id'] as String,
        helpdeskUsername: usernames[r['helpdesk_id']] ?? 'unknown',
        description: r['description'] as String,
        photoUrl: r['photo_url'] as String?,
        time: DateTime.parse(r['created_at'] as String),
      ))
          .toList(),
    );
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    String? attachmentPath,
    String? reporterName,
    String? channel,
  }) async {
    final uid = _currentUserId;

    final inserted = await _db.from(_tickets).insert({
      'title': title,
      'description': description,
      'status': 'open',
      'attachment_path': attachmentPath,
      'created_by': uid,
      if (reporterName != null && reporterName.trim().isNotEmpty) 'reporter_name': reporterName.trim(),
      if (channel != null && channel.trim().isNotEmpty) 'channel': channel.trim(),
    }).select('id').single();

    final id = inserted['id'] as String;

    await _db.from(_history).insert({
      'ticket_id': id,
      'label': (reporterName != null && reporterName.trim().isNotEmpty)
          ? 'Tiket dibuat (laporan $channel dari $reporterName)'
          : 'Tiket dibuat',
    });

    return (await getById(id))!;
  }

  Future<TicketModel?> acceptByAdmin(String ticketId) async {
    final current = await getById(ticketId);
    if (current == null || current.status != TicketStatus.open) return current;

    await _db.from(_tickets).update({'status': 'assigned'}).eq('id', ticketId);
    await _db.from(_history).insert({'ticket_id': ticketId, 'label': 'Diterima Admin'});

    return getById(ticketId);
  }

  Future<TicketModel?> assignToHelpdesk(String ticketId, String helpdeskId) async {
    final current = await getById(ticketId);
    if (current == null || current.status != TicketStatus.assigned) return current;

    await _db.from(_tickets).update({
      'status': 'inProgress',
      'assigned_helpdesk': helpdeskId,
    }).eq('id', ticketId);

    final helpdeskProfile =
    await _db.from('profiles').select('username').eq('id', helpdeskId).maybeSingle();
    final helpdeskUsername = helpdeskProfile?['username'] as String? ?? helpdeskId;

    await _db.from(_history).insert({
      'ticket_id': ticketId,
      'label': 'Ditugaskan ke $helpdeskUsername',
    });

    return getById(ticketId);
  }

  Future<TicketModel?> finishByHelpdesk(String ticketId) async {
    final current = await getById(ticketId);
    if (current == null || current.status != TicketStatus.inProgress) return current;

    await _db.from(_tickets).update({'status': 'closed'}).eq('id', ticketId);
    await _db.from(_history).insert({'ticket_id': ticketId, 'label': 'Tiket diselesaikan (Closed)'});

    return getById(ticketId);
  }

  Future<TicketModel?> addComment(String ticketId, String message) async {
    if (message.trim().isEmpty) return null;
    final uid = _currentUserId;

    await _db.from(_comments).insert({
      'ticket_id': ticketId,
      'author_id': uid,
      'message': message.trim(),
    });

    return getById(ticketId);
  }

  Future<Map<TicketStatus, int>> statsFor(UserRole role) async {
    List<TicketModel> scoped;
    switch (role) {
      case UserRole.user:
        scoped = await getForUser();
        break;
      case UserRole.helpdesk:
        scoped = await getForHelpdesk();
        break;
      case UserRole.admin:
        scoped = await getForAdmin();
        break;
    }
    final map = {for (final s in TicketStatus.values) s: 0};
    for (final t in scoped) {
      map[t.status] = (map[t.status] ?? 0) + 1;
    }
    return map;
  }

  Future<String> _uploadReportPhoto(String ticketId, File photo) async {
    final ext = photo.path.split('.').last;
    final path = '$ticketId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _db.storage.from('ticket-photos').upload(path, photo);
    return _db.storage.from('ticket-photos').getPublicUrl(path);
  }

  Future<TicketModel?> submitCompletionReport({
    required String ticketId,
    required String description,
    File? photo,
  }) async {
    final uid = _currentUserId;

    String? photoUrl;
    if (photo != null) {
      photoUrl = await _uploadReportPhoto(ticketId, photo);
    }

    await _db.from(_reports).insert({
      'ticket_id': ticketId,
      'helpdesk_id': uid,
      'description': description.trim(),
      'photo_url': photoUrl,
    });

    return finishByHelpdesk(ticketId);
  }

  RealtimeChannel watchTable(String table, void Function() onChange) {
    final channel = _db.channel('$table-watch-${DateTime.now().microsecondsSinceEpoch}')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (payload) => onChange(),
      )
      ..subscribe();
    return channel;
  }

  Future<void> unwatch(RealtimeChannel channel) => _db.removeChannel(channel);
}