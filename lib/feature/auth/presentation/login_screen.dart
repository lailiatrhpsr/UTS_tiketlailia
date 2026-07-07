import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_logo_mark.dart';
import '../data/auth_service.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorText;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final profile = await AuthService.instance.login(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(profile: profile)),
      );
    } catch (e) {
      final message = e.toString();
      setState(() => _errorText = message.contains('dinonaktifkan')
          ? 'Akun ini telah dinonaktifkan. Hubungi Admin.'
          : 'Email atau password salah. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // ---- Panel hero brand -------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
                        decoration: const BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppLogoMark(size: 56),
                            const SizedBox(height: 24),
                            Text(
                              "Layanan\nIT Terpadu",
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontSize: 30,
                                height: 1.15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Lapor kendala, pantau progres, selesai tanpa ribet.",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ---- Form -------------------------------------------
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("MASUK", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted)),
                              const SizedBox(height: 6),
                              Text("Masuk ke akun Anda", style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 28),

                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                                  },
                                  child: const Text("Lupa Password?"),
                                ),
                              ),

                              if (_errorText != null) ...[
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFB3261E)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(_errorText!, style: const TextStyle(color: Color(0xFFB3261E), fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("MASUK"),
                              ),
                              const SizedBox(height: 8),

                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                                  },
                                  child: const Text("Belum punya akun? Daftar"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
