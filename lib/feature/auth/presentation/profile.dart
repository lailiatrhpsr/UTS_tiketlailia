import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/notifikasi/notification_center.dart';
import '../data/auth_service.dart';
import '../data/models/profile_model.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppProfile profile;
  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppProfile _profile = widget.profile;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Anda perlu login kembali untuk mengakses aplikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFB3261E))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await NotificationCenter.instance.stop();
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted)),
  );

  @override
  Widget build(BuildContext context) {
    final initial = _profile.username.isNotEmpty ? _profile.username[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: CustomScrollView(
        slivers: [
          // ---- Header ala aplikasi nyata: cover gradient + avatar bulat --
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.brand,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.brand, AppColors.brandDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: GoogleFonts.sora(color: AppColors.brand, fontSize: 34, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _profile.username,
                        style: GoogleFonts.sora(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      if (_profile.fullName != null && _profile.fullName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(_profile.fullName!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _profile.role.label,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionLabel("AKUN"),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.badge_outlined),
                          title: const Text("Edit Profil"),
                          subtitle: const Text("Ubah username & nama lengkap"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () async {
                            final updated = await Navigator.push<AppProfile>(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfileScreen(profile: _profile)),
                            );
                            if (updated != null && mounted) setState(() => _profile = updated);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: const Text("Email"),
                          subtitle: Text(AuthService.instance.currentEmail ?? '-'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock_outline_rounded),
                          title: const Text("Ubah Password"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _sectionLabel("PREFERENSI"),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: ThemeController.mode,
                      builder: (context, mode, _) => ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: const Text("Dark Mode"),
                        subtitle: Text(mode == ThemeMode.dark ? "Aktif" : "Nonaktif"),
                        trailing: Switch(
                          value: mode == ThemeMode.dark,
                          onChanged: (val) => ThemeController.toggle(val),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _sectionLabel("LAINNYA"),
                  const Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text("Tentang Aplikasi"),
                      subtitle: Text("E-Ticketing Helpdesk • v1.0"),
                    ),
                  ),

                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _confirmLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB3261E),
                      side: const BorderSide(color: Color(0xFFB3261E)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text("KELUAR"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
