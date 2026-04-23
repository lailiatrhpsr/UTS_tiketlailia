import 'package:flutter/material.dart';
import '../../ticket/presentation/ticket_list.dart';
import '../../ticket/presentation/create_ticket.dart';
import 'notification.dart';
import '../../auth/presentation/profile.dart';

class DashboardScreen extends StatelessWidget {
  final bool isAdmin;
  const DashboardScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang lebih bersih
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(isAdmin ? "Dashboard Admin" : "Dashboard User",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? "Statistik Layanan IT" : "Ringkasan Tiket Saya",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // GRID VIEW MODERN
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildModernStatCard("Total Tiket", "12", Icons.confirmation_number_outlined, [Colors.blue.shade200, Colors.blueAccent.shade400]),
                _buildModernStatCard("Pending", "5", Icons.timer, [Colors.orange, Colors.deepOrange.shade800]),
                _buildModernStatCard("Diproses", "3", Icons.sync, [Colors.indigoAccent, Colors.indigo.shade100]),
                _buildModernStatCard("Selesai", "4", Icons.check_circle_outline_rounded, [Colors.lightGreen, Colors.lightGreen.shade700]),
              ],
            ),

            const SizedBox(height: 35),
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // LIST TILE MODERN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.list_alt_rounded, color: Colors.blueAccent, size: 30),
                title: Text(isAdmin ? "Kelola Semua Tiket" : "Daftar Tiket Saya",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Ketuk untuk detail penanganan"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TicketListScreen(isAdmin: isAdmin)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTicketScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        label: const Text("Buat Tiket", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildModernStatCard(String title, String count, IconData icon, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const Spacer(),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}