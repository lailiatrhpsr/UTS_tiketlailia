import 'package:flutter/material.dart';
import '../../feature/ticket/data/models/ticket_model.dart';
import 'app_colors.dart';

class StatusStyle {
  final Color color;
  final String label;
  final IconData icon;

  const StatusStyle._(this.color, this.label, this.icon);

  factory StatusStyle.of(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const StatusStyle._(AppColors.statusOpen, "Open", Icons.mark_email_unread_outlined);
      case TicketStatus.assigned:
        return const StatusStyle._(AppColors.statusAssigned, "Assigned", Icons.move_to_inbox_outlined);
      case TicketStatus.inProgress:
        return const StatusStyle._(AppColors.statusInProgress, "In Progress", Icons.autorenew_rounded);
      case TicketStatus.closed:
        return const StatusStyle._(AppColors.statusClosed, "Closed", Icons.verified_outlined);
    }
  }
}

class StatusPill extends StatelessWidget {
  final TicketStatus status;
  final bool compact;
  const StatusPill({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusRailCard extends StatelessWidget {
  final TicketStatus status;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const StatusRailCard({
    super.key,
    required this.status,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusStyle.of(status).color;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(child: Padding(padding: padding, child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
