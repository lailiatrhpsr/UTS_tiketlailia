import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk mengambil gambar (FR-005 Flow 2) [cite: 64]
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitTicket() {
    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
      // Simulasi berhasil membuat tiket (FR-005 Flow 1) [cite: 63]
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiket berhasil dibuat!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Tiket Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Judul
            const Text("Judul Laporan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Contoh: WiFi Mati", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // Input Deskripsi
            const Text("Deskripsi Masalah", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "Jelaskan detail masalah Anda...", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // Upload Lampiran (FR-005 Flow 2) [cite: 64]
            const Text("Lampiran (Gambar/File)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Kamera"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Galeri"),
                ),
              ],
            ),

            // Preview Gambar
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),

            const SizedBox(height: 40),

            // Tombol Kirim
            ElevatedButton(
              onPressed: _submitTicket,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("KIRIM TIKET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}