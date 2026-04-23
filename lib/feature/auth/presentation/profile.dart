import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Profil Pengguna")),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
              const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text("User UNAIR", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("user@student.unair.ac.id", style: TextStyle(color: Colors.grey)),
        const Divider(height: 40),

    // Menu Opsi Profil
    ListTile(
    leading: const Icon(Icons.dark_mode),
    title: const Text("Dark Mode"),
    trailing: Switch(value: false, onChanged: (val) {}),
    ),
    const ListTile(
    leading: const Icon(Icons.lock_outline),
    title: const Text("Ubah Password"),
    ),
    const Spacer(),

    // Tombol Logout (FR-002)
    ElevatedButton(
    onPressed: () {
    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
    );
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.redAccent,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    ),
    child: const Text("LOGOUT"),
    ),
    ],
    ),
    ),
    );
  }
}