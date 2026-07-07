import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/models/profile_model.dart';
import '../data/ticket_repository.dart';

const List<String> kExternalChannels = ["Telepon", "WhatsApp", "Email", "Datang Langsung"];

class CreateTicketScreen extends StatefulWidget {
  final AppProfile? profile;

  const CreateTicketScreen({super.key, this.profile});

  bool get _isStaffCreatingForExternal =>
      profile != null && profile!.role != UserRole.user;

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _reporterNameController = TextEditingController();
  String _channel = kExternalChannels.first;
  File? _selectedImage;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  String? _errorText;

  Future<void> _submitTicket() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) return;
    final isStaff = widget._isStaffCreatingForExternal;
    if (isStaff && _reporterNameController.text.trim().isEmpty) return;

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await TicketRepository.instance.createTicket(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        attachmentPath: _selectedImage?.path,
        reporterName: isStaff ? _reporterNameController.text.trim() : null,
        channel: isStaff ? _channel : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiket berhasil dibuat dengan status Open")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = "Gagal membuat tiket: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = widget._isStaffCreatingForExternal;

    return Scaffold(
      appBar: AppBar(title: Text(isStaff ? "Buat Tiket untuk Pelapor" : "Buat Tiket Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStaff ? "Laporan dari saluran luar aplikasi" : "Laporkan kendala Anda",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              isStaff
                  ? "Untuk laporan yang diterima lewat telepon, WhatsApp, atau datang langsung."
                  : "Semakin detail, semakin cepat ditangani.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            if (isStaff) ...[
              Text("Nama Pelapor", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _reporterNameController,
                decoration: const InputDecoration(
                  hintText: "Nama orang yang melaporkan",
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              Text("Saluran Laporan", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _channel,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.call_outlined, size: 20)),
                items: kExternalChannels.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _channel = v ?? _channel),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 4),
            ],

            Text("Judul Laporan", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Contoh: WiFi Mati di Lab 3"),
            ),
            const SizedBox(height: 20),

            Text("Deskripsi Masalah", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "Jelaskan detail masalah Anda..."),
            ),
            const SizedBox(height: 20),

            Text("Lampiran (opsional)", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text("Kamera"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text("Galeri"),
                  ),
                ),
              ],
            ),

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              ),

            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.brand),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tiket akan otomatis berstatus Open setelah dikirim, lalu diteruskan ke Admin.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.brandDeep),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(_errorText!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _submitTicket,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isStaff ? "BUAT TIKET" : "KIRIM TIKET"),
            ),
          ],
        ),
      ),
    );
  }
}