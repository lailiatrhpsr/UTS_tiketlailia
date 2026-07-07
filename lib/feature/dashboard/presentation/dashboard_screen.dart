import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/status_style.dart';
import '../../../core/notifikasi/notification_center.dart';
import '../../ticket/presentation/ticket_list.dart';
import '../../ticket/presentation/create_ticket.dart';
import '../../ticket/data/models/ticket_model.dart';
import '../../ticket/data/ticket_repository.dart';
import '../../auth/data/models/profile_model.dart';
import 'notification.dart';
import '../../auth/presentation/profile.dart';
import '../../admin/presentation/manage_users_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AppProfile profile;
  const DashboardScreen({super.key, required this.profile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<TicketStatus, int> _stats = {for (final s in TicketStatus.values) s: 0};
  bool _loading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadStats();
    NotificationCenter.instance.start(widget.profile);
    _channel = TicketRepository.instance.watchTable('tickets', _loadStats);
  }

  @override
  void dispose() {
    if (_channel != null) TicketRepository.instance.unwatch(_channel!);
    super.dispose();
  }

  Future<void> _loadStats() async {
    if (mounted) setState(() => _loading = true);
    final stats = await TicketRepository.instance.statsFor(widget.profile.role);
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Selamat pagi";
    if (hour < 15) return "Selamat siang";
    if (hour < 18) return "Selamat sore";
    return "Selamat malam";
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats.values.fold<int>(0, (a, b) => a + b);
    final role = widget.profile.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: NotificationCenter.instance.unreadCount,
            builder: (context, count, _) => IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen(profile: widget.profile)));
              },
              icon: Badge(
                label: Text('$count'),
                isLabelVisible: count > 0,
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: widget.profile)));
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${_greeting()},", style: Theme.of(context).textTheme.bodyMedium),
              Text(widget.profile.username, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                role == UserRole.user
                    ? "Berikut ringkasan tiket yang Anda laporkan."
                    : role == UserRole.helpdesk
                    ? "Tiket yang sedang Anda tangani."
                    : "Ringkasan seluruh tiket masuk hari ini.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // ---- Banner total (hero KPI) ---------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOTAL TIKET",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$total",
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text("Rincian Status", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),

              ...TicketStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StatRailTile(
                  status: s,
                  count: _stats[s] ?? 0,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketListScreen(profile: widget.profile, initialFilter: s),
                      ),
                    );
                    _loadStats();
                  },
                ),
              )),

              const SizedBox(height: 20),
              Text("Menu Utama", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.list_alt_rounded, color: AppColors.brand),
                  ),
                  title: Text(
                    role == UserRole.admin
                        ? "Kelola Semua Tiket"
                        : role == UserRole.helpdesk
                        ? "Tiket Ditugaskan ke Saya"
                        : "Daftar Tiket Saya",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: const Text("Ketuk untuk detail penanganan"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TicketListScreen(profile: widget.profile)),
                    );
                    _loadStats();
                  },
                ),
              ),

              if (role == UserRole.admin) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.manage_accounts_rounded, color: AppColors.brand),
                    ),
                    title: Text("Kelola Pengguna", style: Theme.of(context).textTheme.titleMedium),
                    subtitle: const Text("Ubah role & nonaktifkan akun"),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageUsersScreen(currentAdmin: widget.profile)),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTicketScreen(profile: widget.profile)),
          );
          _loadStats();
        },
        label: Text(role == UserRole.user ? "Buat Tiket" : "Buat Tiket untuk Pelapor"),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _StatRailTile extends StatelessWidget {
  final TicketStatus status;
  final int count;
  final VoidCallback? onTap;
  const _StatRailTile({required this.status, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(status);
    return StatusRailCard(
      status: status,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(style.icon, color: style.color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(style.label, style: Theme.of(context).textTheme.titleMedium)),
          Text(
            "$count",
            style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted, size: 20),
        ],
      ),
    );
  }
}