import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/status_style.dart';
import '../data/models/ticket_model.dart';
import '../data/ticket_repository.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/data/models/profile_model.dart';
import 'completion_report_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  final AppProfile profile;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.profile,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  TicketModel? _ticket;
  List<AppProfile> _helpdeskAgents = [];
  bool _loading = true;
  bool _acting = false;
  String? _selectedHelpdeskId;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final t = await TicketRepository.instance.getById(widget.ticketId);
    List<AppProfile> agents = [];
    if (widget.profile.role == UserRole.admin && t?.status == TicketStatus.assigned) {
      agents = await AuthService.instance.fetchHelpdeskAgents();
    }
    if (!mounted) return;
    setState(() {
      _ticket = t;
      _helpdeskAgents = agents;
      _loading = false;
    });
  }

  Future<void> _acceptByAdmin() async {
    setState(() => _acting = true);
    await TicketRepository.instance.acceptByAdmin(widget.ticketId);
    await _reload();
    if (mounted) setState(() => _acting = false);
  }

  Future<void> _assignToHelpdesk() async {
    if (_selectedHelpdeskId == null) return;
    setState(() => _acting = true);
    await TicketRepository.instance.assignToHelpdesk(widget.ticketId, _selectedHelpdeskId!);
    await _reload();
    if (mounted) setState(() => _acting = false);
  }

  Future<void> _finishByHelpdesk() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CompletionReportScreen(ticketId: widget.ticketId)),
    );
    if (result == true) await _reload();
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final text = _commentController.text;
    _commentController.clear();
    await TicketRepository.instance.addComment(widget.ticketId, text);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(appBar: AppBar(title: const Text("Detail Tiket")), body: const Center(child: CircularProgressIndicator()));
    }
    final ticket = _ticket;
    if (ticket == null) {
      return Scaffold(appBar: AppBar(title: const Text("Detail Tiket")), body: const Center(child: Text("Tiket tidak ditemukan")));
    }

    final style = StatusStyle.of(ticket.status);

    return Scaffold(
      appBar: AppBar(title: Text(ticket.id)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // ---- Header kartu tiket -------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: style.color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(style.icon, color: style.color, size: 20),
                    const SizedBox(width: 8),
                    StatusPill(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(ticket.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                _MetaRow(icon: Icons.person_outline_rounded, label: "Dilaporkan oleh", value: ticket.createdByUsername),
                if (ticket.isExternalReport) ...[
                  const SizedBox(height: 6),
                  _MetaRow(icon: Icons.contact_phone_outlined, label: "Nama pelapor", value: ticket.reporterName!),
                  const SizedBox(height: 6),
                  _MetaRow(icon: Icons.call_outlined, label: "Saluran", value: ticket.channel ?? '-'),
                ],
                if (ticket.assignedHelpdeskUsername != null) ...[
                  const SizedBox(height: 6),
                  _MetaRow(icon: Icons.support_agent_rounded, label: "Ditangani oleh", value: ticket.assignedHelpdeskUsername!),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text("Deskripsi Masalah", style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(ticket.description, style: Theme.of(context).textTheme.bodyMedium),

          const SizedBox(height: 28),
          Text("Status Tracking", style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 14),
          if (ticket.history.isEmpty)
            Text("Belum ada riwayat.", style: Theme.of(context).textTheme.bodySmall)
          else
            _Timeline(entries: ticket.history),

          if (ticket.reports.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text("Laporan Penyelesaian", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            ...ticket.reports.map((r) => _ReportCard(report: r)),
          ],

          const SizedBox(height: 24),
          _buildRoleAction(ticket),

          const SizedBox(height: 8),
          _buildCommunicationSection(ticket),
        ],
      ),
    );
  }

  Widget _buildRoleAction(TicketModel ticket) {
    final role = widget.profile.role;

    if (role == UserRole.admin && ticket.status == TicketStatus.open) {
      return _ActionCard(
        label: "Aksi Admin",
        description: "Tiket baru masuk dan belum diterima.",
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _acting ? null : _acceptByAdmin,
            icon: _acting
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.inbox_outlined, size: 18),
            label: const Text("TERIMA TIKET"),
          ),
        ),
      );
    }

    if (role == UserRole.admin && ticket.status == TicketStatus.assigned) {
      return _ActionCard(
        label: "Aksi Admin",
        description: "Pilih petugas Helpdesk untuk menangani tiket ini.",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_helpdeskAgents.isEmpty)
              Text(
                "Belum ada akun dengan role Helpdesk. Promosikan akun lewat SQL.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFB3261E)),
              )
            else ...[
              DropdownButtonFormField<String>(
                value: _selectedHelpdeskId,
                decoration: const InputDecoration(labelText: "Petugas Helpdesk"),
                items: _helpdeskAgents.map((h) => DropdownMenuItem(value: h.id, child: Text(h.username))).toList(),
                onChanged: (v) => setState(() => _selectedHelpdeskId = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_acting || _selectedHelpdeskId == null) ? null : _assignToHelpdesk,
                  icon: _acting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.assignment_turned_in_outlined, size: 18),
                  label: const Text("TUGASKAN KE HELPDESK"),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (role == UserRole.helpdesk && ticket.status == TicketStatus.inProgress && ticket.assignedHelpdeskId == widget.profile.id) {
      return _ActionCard(
        label: "Aksi Helpdesk",
        description: "Tuliskan laporan penyelesaian sebelum tiket ditutup.",
        accentColor: AppColors.statusClosed,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _finishByHelpdesk,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusClosed),
            icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
            label: const Text("SELESAI / FINISH"),
          ),
        ),
      );
    }

    String info;
    if (ticket.status == TicketStatus.closed) {
      info = "Tiket ini sudah selesai.";
    } else if (role == UserRole.user) {
      info = "Menunggu penanganan lebih lanjut.";
    } else if (role == UserRole.helpdesk) {
      info = "Tiket ini belum ditugaskan kepada Anda.";
    } else {
      info = "Tidak ada aksi yang perlu dilakukan saat ini.";
    }
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.inkMuted),
        const SizedBox(width: 8),
        Expanded(child: Text(info, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }

  Widget _buildCommunicationSection(TicketModel ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text("Komunikasi", style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        if (ticket.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text("Belum ada percakapan. Mulai dengan menulis pesan di bawah.", style: Theme.of(context).textTheme.bodySmall),
          )
        else
          ...ticket.comments.map((c) => _CommentBubble(comment: c, isMe: c.author == widget.profile.username)),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Tulis balasan...",
            suffixIcon: IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.brand),
              onPressed: _sendComment,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.inkMuted),
        const SizedBox(width: 8),
        Text("$label: ", style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.ink)),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<TicketHistoryEntry> entries;
  const _Timeline({required this.entries});

  String _formatTime(DateTime time) =>
      "${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year} · "
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entries.length, (i) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.brand : AppColors.brand.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast) Expanded(child: Container(width: 2, color: AppColors.line)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.label, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(_formatTime(entry.time), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;
  final Color accentColor;
  const _ActionCard({required this.label, required this.description, required this.child, this.accentColor = AppColors.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: accentColor)),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final TicketReport report;
  const _ReportCard({required this.report});

  String _formatTime(DateTime t) =>
      "${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year} · "
          "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.ink.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, size: 16, color: AppColors.statusClosed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${report.helpdeskUsername} • ${_formatTime(report.time)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.description, style: Theme.of(context).textTheme.bodyMedium),
          if (report.photoUrl != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: InteractiveViewer(child: Image.network(report.photoUrl!)),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  report.photoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
                  errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(height: 80, child: Center(child: Icon(Icons.broken_image_outlined))),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final TicketComment comment;
  final bool isMe;
  const _CommentBubble({required this.comment, required this.isMe});

  String _formatTime(DateTime time) =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.brand : AppColors.surface,
                border: isMe ? null : Border.all(color: AppColors.line),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isMe ? 14 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        comment.author,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.brand),
                      ),
                    ),
                  Text(
                    comment.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isMe ? Colors.white : AppColors.ink),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(comment.time),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: isMe ? Colors.white.withOpacity(0.7) : AppColors.inkMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
