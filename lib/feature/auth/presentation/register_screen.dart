import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Semua field wajib diisi.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = 'Konfirmasi password tidak sama.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorText = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.register(email: email, password: password, username: username);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil. Silakan masuk.')),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      // Pesan asli dari Supabase Auth (mis. "User already registered",
      // "Password should be at least 6 characters", dll) -- sebelumnya
      // ini ditelan jadi teks generik yang tidak membantu diagnosa.
      setState(() => _errorText = e.message);
    } catch (e) {
      setState(() => _errorText = 'Registrasi gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Akun")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Daftar sebagai pelapor", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              "Akun baru terdaftar dengan peran User untuk melaporkan kendala.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 28),

            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.badge_outlined, size: 20)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail_outline_rounded, size: 20)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline_rounded, size: 20)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration:
              const InputDecoration(labelText: "Konfirmasi Password", prefixIcon: Icon(Icons.lock_outline_rounded, size: 20)),
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFB3261E)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_errorText!, style: const TextStyle(color: Color(0xFFB3261E), fontSize: 13))),
                ],
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("DAFTAR"),
            ),

            const SizedBox(height: 16),
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
                      "Akun Admin dan Helpdesk disiapkan oleh pengelola sistem, bukan lewat pendaftaran ini.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.brandDeep),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}