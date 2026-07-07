import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/notifikasi/notification_center.dart';
import '../../auth/data/models/profile_model.dart';
import '../../ticket/presentation/ticket_detail.dart';

class NotificationScreen extends StatefulWidget {
  final AppProfile profile;
  const NotificationScreen({super.key, required this.profile});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => NotificationCenter.instance.markAllRead());
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit yang lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam yang lalu";
    return "${diff.inDays} hari yang lalu";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: NotificationCenter.instance.notifications,
        builder: (context, notifs, _) {
          if (notifs.isEmpty) {
            return Center(
              child: Text("Belum ada notifikasi.", style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final n = notifs[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.notifications_active_outlined, color: AppColors.brand, size: 20),
                  ),
                  title: Text(n.ticketTitle, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(n.label, style: Theme.of(context).textTheme.bodySmall),
                  ),
                  trailing: Text(_relativeTime(n.time), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketDetailScreen(ticketId: n.ticketId, profile: widget.profile),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
