import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../data/ticket_repository.dart';

class CompletionReportScreen extends StatefulWidget {
  final String ticketId;
  const CompletionReportScreen({super.key, required this.ticketId});

  @override
  State<CompletionReportScreen> createState() => _CompletionReportScreenState();
}

class _CompletionReportScreenState extends State<CompletionReportScreen> {
  final _descController = TextEditingController();
  File? _photo;
  bool _submitting = false;
  String? _error;
  final _picker = ImagePicker();

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file != null) setState(() => _photo = File(file.path));
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) {
      setState(() => _error = 'Jelaskan dulu apa yang sudah Anda kerjakan.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await TicketRepository.instance.submitCompletionReport(
        ticketId: widget.ticketId,
        description: _descController.text.trim(),
        photo: _photo,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = 'Gagal mengirim laporan: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penyelesaian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apa yang sudah Anda lakukan?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Tuliskan ringkasan penanganan supaya pelapor & admin tahu apa yang telah diperbaiki.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ),

            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Contoh: Sudah mengganti kabel LAN yang putus dan menguji ulang koneksi...',
              ),
            ),
            const SizedBox(height: 20),

            Text('Foto Bukti Pengerjaan (opsional)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),

            if (_photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_photo!, height: 160, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => setState(() => _photo = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
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
                      "Setelah dikirim, status tiket otomatis berubah menjadi Closed.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.brandDeep),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusClosed),
                icon: _submitting
                    ? const SizedBox(
                    height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('KIRIM & SELESAIKAN TIKET'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
