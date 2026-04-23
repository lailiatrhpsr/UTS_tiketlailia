enum TicketStatus { open, inProgress, closed }

class TicketModel {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final String? attachmentPath; // Untuk simulasi upload file (FR-005) [cite: 64]

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.attachmentPath,
  });

  // Helper untuk mendapatkan teks status yang rapi
  String get statusText {
    switch (status) {
      case TicketStatus.open: return "Open";
      case TicketStatus.inProgress: return "In Progress";
      case TicketStatus.closed: return "Closed";
    }
  }
}