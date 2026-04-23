import 'package:flutter/material.dart';
import '../data/models/ticket_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;
  final bool isAdmin;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Tiket")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.id, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(ticket.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Deskripsi Masalah:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(ticket.description),
            const SizedBox(height: 30),

            const Divider(),
            const Text("Status Tracking:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Simulasi Tracking UI (FR-011)
            _buildTrackingStep("Tiket Dibuat", "User telah mengirim laporan", true),
            _buildTrackingStep("Diverifikasi", "Helpdesk sedang mengecek laporan", ticket.status != TicketStatus.open),
            _buildTrackingStep("Selesai", "Masalah telah diperbaiki", ticket.status == TicketStatus.closed),

            const SizedBox(height: 30),

            // KONTROL ADMIN (Poin 1.2.2)
            if (isAdmin) _buildAdminControls(context),

            // KOMUNIKASI (Poin 1.2.1 & 1.2.2)
            _buildCommunicationSection(),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat baris tracking status (FR-011)
  Widget _buildTrackingStep(String title, String subtitle, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.blue : Colors.grey,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 15),
          ],
        )
      ],
    );
  }

  // Widget untuk Mengubah Status Tiket (Poin 1.2.2)
  Widget _buildAdminControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text("Aksi Helpdesk:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text("PROSES TIKET"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("SELESAIKAN"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget untuk Berkomunikasi/Respon (Poin 1.2.1 & 1.2.2)
  Widget _buildCommunicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("Komentar / Balasan:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(
            hintText: "Tulis balasan di sini...",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text("Kirim Respon"),
          ),
        ),
      ],
    );
  }
}