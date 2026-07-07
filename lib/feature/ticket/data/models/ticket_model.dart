import '../../../../core/models/user_role.dart';
export '../../../../core/models/user_role.dart' show UserRole, UserRoleX;

enum TicketStatus { open, assigned, inProgress, closed }

extension TicketStatusX on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open:
        return "Open";
      case TicketStatus.assigned:
        return "Assigned";
      case TicketStatus.inProgress:
        return "In Progress";
      case TicketStatus.closed:
        return "Closed";
    }
  }

  static TicketStatus fromName(String name) {
    return TicketStatus.values.firstWhere(
          (e) => e.name == name,
      orElse: () => TicketStatus.open,
    );
  }
}

class TicketComment {
  final String author;
  final String message;
  final DateTime time;

  TicketComment({required this.author, required this.message, required this.time});
}

/// riwayat perubahan status 
class TicketHistoryEntry {
  final String label;
  final DateTime time;

  TicketHistoryEntry({required this.label, required this.time});
}

class TicketReport {
  final String id;
  final String helpdeskUsername;
  final String description;
  final String? photoUrl;
  final DateTime time;

  TicketReport({
    required this.id,
    required this.helpdeskUsername,
    required this.description,
    this.photoUrl,
    required this.time,
  });
}

class TicketModel {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final String? attachmentPath; 

  final String createdById;
  final String createdByUsername;
  final String? assignedHelpdeskId;
  final String? assignedHelpdeskUsername;

  final String? reporterName;
  final String? channel;

  final List<TicketComment> comments;
  final List<TicketHistoryEntry> history;
  final List<TicketReport> reports;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.createdById,
    required this.createdByUsername,
    this.attachmentPath,
    this.assignedHelpdeskId,
    this.assignedHelpdeskUsername,
    this.reporterName,
    this.channel,
    List<TicketComment>? comments,
    List<TicketHistoryEntry>? history,
    List<TicketReport>? reports,
  })  : comments = comments ?? [],
        history = history ?? [],
        reports = reports ?? [];

  bool get isExternalReport => reporterName != null && reporterName!.isNotEmpty;

  String get statusText => status.label;

  TicketModel copyWith({
    TicketStatus? status,
    String? assignedHelpdeskId,
    String? assignedHelpdeskUsername,
    List<TicketComment>? comments,
    List<TicketHistoryEntry>? history,
    List<TicketReport>? reports,
  }) {
    return TicketModel(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
      createdById: createdById,
      createdByUsername: createdByUsername,
      attachmentPath: attachmentPath,
      assignedHelpdeskId: assignedHelpdeskId ?? this.assignedHelpdeskId,
      assignedHelpdeskUsername: assignedHelpdeskUsername ?? this.assignedHelpdeskUsername,
      reporterName: reporterName,
      channel: channel,
      comments: comments ?? this.comments,
      history: history ?? this.history,
      reports: reports ?? this.reports,
    );
  }
}
