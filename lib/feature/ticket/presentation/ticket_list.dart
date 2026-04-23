import 'package:flutter/material.dart';
import '../data/models/ticket_model.dart';
import 'ticket_detail.dart';

class TicketListScreen extends StatelessWidget {
  final bool isAdmin;
  TicketListScreen({super.key, required this.isAdmin});

  // Simulasi Mock Data (Frontend-only)
  final List<TicketModel> mockTickets = [
    TicketModel(
      id: "TKT-2026-001",
      title: "Masalah Koneksi WiFi",
      description: "WiFi di lantai 2 sering terputus tiba-tiba.",
      status: TicketStatus.open,
      createdAt: DateTime.now(),
    ),
    TicketModel(
      id: "TKT-2026-002",
      title: "Keyboard Rusak",
      description: "Beberapa tombol di keyboard laptop inventaris macet.",
      status: TicketStatus.inProgress,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Tiket Saya")),
      body: ListView.builder(
        // Implementasi dasar Lazy Loading (FR-011)
        itemCount: mockTickets.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final ticket = mockTickets[index];
          return Card(
            child: ListTile(
              leading: _buildStatusIcon(ticket.status),
              title: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(ticket.id),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigasi ke Detail Tiket (FR-005 / FR-011)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailScreen(ticket: ticket, isAdmin: isAdmin),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(TicketStatus status) {
    Color color;
    switch (status) {
      case TicketStatus.open: color = Colors.orange; break;
      case TicketStatus.inProgress: color = Colors.green; break;
      case TicketStatus.closed: color = Colors.grey; break;
    }
    return CircleAvatar(backgroundColor: color, radius: 8);
  }
}