import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/status_style.dart';
import '../data/models/ticket_model.dart';
import '../data/ticket_repository.dart';
import '../../auth/data/models/profile_model.dart';
import 'ticket_detail.dart';
import 'create_ticket.dart';

class TicketListScreen extends StatefulWidget {
  final AppProfile profile;
  final TicketStatus? initialFilter;

  const TicketListScreen({super.key, required this.profile, this.initialFilter});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<TicketModel> _all = [];
  TicketStatus? _filter;
  bool _loading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _load();
  
    _channel = TicketRepository.instance.watchTable('tickets', _load);
  }

  @override
  void dispose() {
    if (_channel != null) TicketRepository.instance.unwatch(_channel!);
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    List<TicketModel> data;
    switch (widget.profile.role) {
      case UserRole.admin:
        data = await TicketRepository.instance.getForAdmin();
        break;
      case UserRole.helpdesk:
        data = await TicketRepository.instance.getForHelpdesk();
        break;
      case UserRole.user:
        data = await TicketRepository.instance.getForUser();
        break;
    }
    if (!mounted) return;
    setState(() {
      _all = data;
      _loading = false;
    });
  }

  List<TicketModel> get _visible => _filter == null ? _all : _all.where((t) => t.status == _filter).toList();

  String get _title {
    switch (widget.profile.role) {
      case UserRole.admin:
        return "Kelola Semua Tiket";
      case UserRole.helpdesk:
        return "Tiket Ditugaskan ke Saya";
      case UserRole.user:
        return "Daftar Tiket Saya";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip(null, "Semua"),
                  ...TicketStatus.values.map((s) => _filterChip(s, StatusStyle.of(s).label)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _visible.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ticket = _visible[index];
                  return StatusRailCard(
                    status: ticket.status,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailScreen(ticketId: ticket.id, profile: widget.profile),
                        ),
                      );
                      _load();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ticket.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusPill(status: ticket.status, compact: true),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ticket.assignedHelpdeskUsername != null
                              ? "${ticket.id} • ${ticket.assignedHelpdeskUsername}"
                              : ticket.id,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTicketScreen(profile: widget.profile)),
          );
          _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(widget.profile.role == UserRole.user ? "Buat Tiket" : "Buat Tiket untuk Pelapor"),
      ),
    );
  }

  Widget _filterChip(TicketStatus? status, String label) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = status),
        selectedColor: status == null ? AppColors.brand.withOpacity(0.16) : StatusStyle.of(status).color.withOpacity(0.16),
        labelStyle: TextStyle(
          color: selected ? (status == null ? AppColors.brand : StatusStyle.of(status).color) : AppColors.inkMuted,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide(color: selected ? Colors.transparent : AppColors.line),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  Widget _buildEmptyState() {
    final isUser = widget.profile.role == UserRole.user;
    final hasFilter = _filter != null;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.inbox_outlined, color: AppColors.brand, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            hasFilter ? "Tidak ada tiket dengan status ini" : (isUser ? "Belum ada tiket" : "Antrean masih kosong"),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            hasFilter
                ? "Coba pilih filter status lain."
                : (isUser
                ? "Laporkan kendala IT pertama Anda lewat tombol Buat Tiket."
                : "Tidak ada tiket yang perlu ditangani saat ini. Anda tetap bisa membuatkan tiket untuk laporan dari saluran luar aplikasi."),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (!hasFilter) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTicketScreen(profile: widget.profile)),
                );
                _load();
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(isUser ? "Buat Tiket" : "Buat Tiket untuk Pelapor"),
            ),
          ],
        ],
      ),
    );
  }
}
