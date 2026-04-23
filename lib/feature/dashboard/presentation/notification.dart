import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Notifikasi")),
        body: ListView(
    padding: const EdgeInsets.all(10),
    children: [
    _buildNotifyItem(
    "Update Status",
    "Tiket TKT-2026-001 Anda kini sedang dalam proses perbaikan.",
    "10 menit yang lalu",
    Icons.info_outline,
    Colors.blue,
    ),
    _buildNotifyItem(
    "Tiket Selesai",
    "Masalah WiFi Mati telah dinyatakan selesai oleh petugas.",
    "2 jam yang lalu",
    Icons.check_circle_outline,
    Colors.green,
    ),
    ],
    ),
    );
  }

  Widget _buildNotifyItem(String title, String desc, String time, IconData icon, Color color) {
    return Card(
      child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(desc),
          trailing: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          onTap: () {
            // Navigasi ke halaman terkait (FR-007 Flow 2)
          },
      ),
    );
  }
}