import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _error;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Masukkan email yang valid.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await AuthService.instance.sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = 'Gagal mengirim tautan reset: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _sent ? _buildSentState(context) : _buildFormState(context),
      ),
    );
  }

  Widget _buildFormState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mail_lock_outlined, size: 18, color: AppColors.brand),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Masukkan email akun Anda. Kami akan mengirimkan tautan untuk mengatur ulang password.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.brandDeep),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _sending ? null : _sendResetLink,
          child: _sending
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("KIRIM TAUTAN RESET"),
        ),
      ],
    );
  }

  Widget _buildSentState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.brand, size: 32),
        ),
        const SizedBox(height: 20),
        Text("Tautan reset terkirim", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          "Cek kotak masuk (atau folder spam) di ${_emailController.text.trim()}, lalu ikuti tautan untuk membuat password baru.",
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("KEMBALI KE LOGIN"),
        ),
      ],
    );
  }
}
