import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../data/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final AppProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _usernameController = TextEditingController(text: widget.profile.username);
  late final _fullNameController = TextEditingController(text: widget.profile.fullName ?? '');
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_usernameController.text.trim().isEmpty) {
      setState(() => _error = 'Username tidak boleh kosong.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await AuthService.instance.updateProfile(
        userId: widget.profile.id,
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      setState(() => _error = 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap (opsional)', prefixIcon: Icon(Icons.badge_outlined)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('SIMPAN'),
            ),
          ],
        ),
      ),
    );
  }
}
