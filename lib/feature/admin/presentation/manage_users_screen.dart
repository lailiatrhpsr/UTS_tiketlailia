import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/data/models/profile_model.dart';

class ManageUsersScreen extends StatefulWidget {
  final AppProfile currentAdmin;
  const ManageUsersScreen({super.key, required this.currentAdmin});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<AppProfile> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await AuthService.instance.fetchAllProfiles();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
        "Gagal memuat daftar pengguna. Jika ini pertama kali dibuka, pastikan "
            "migrasi kolom is_active sudah dijalankan (lihat backend/migration_v2_fitur_baru.sql).\n\nDetail: $e";
        _loading = false;
      });
    }
  }

  Future<void> _changeRole(AppProfile user) async {
    final selected = await showDialog<UserRole>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("Ubah role ${user.username}"),
        children: UserRole.values.map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, r),
            child: Row(
              children: [
                if (r == user.role) const Icon(Icons.check_rounded, size: 18, color: AppColors.brand),
                if (r == user.role) const SizedBox(width: 8),
                Text(r.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (selected == null || selected == user.role) return;

    try {
      await AuthService.instance.updateUserRole(user.id, selected);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Role ${user.username} diubah menjadi ${selected.label}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengubah role: $e")));
    }
  }

  Future<void> _toggleActive(AppProfile user) async {
    if (user.id == widget.currentAdmin.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda tidak bisa menonaktifkan akun Anda sendiri.")),
      );
      return;
    }

    final willDeactivate = user.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(willDeactivate ? 'Nonaktifkan akun?' : 'Aktifkan kembali akun?'),
        content: Text(
          willDeactivate
              ? '${user.username} tidak akan bisa login sampai diaktifkan kembali. Data & tiket lama tetap tersimpan.'
              : '${user.username} akan bisa login kembali seperti biasa.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              willDeactivate ? 'Nonaktifkan' : 'Aktifkan',
              style: TextStyle(color: willDeactivate ? const Color(0xFFB3261E) : AppColors.brand),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await AuthService.instance.setUserActive(user.id, !willDeactivate);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memperbarui status: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Pengguna")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: _users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _UserCard(
            user: _users[index],
            isSelf: _users[index].id == widget.currentAdmin.id,
            onChangeRole: () => _changeRole(_users[index]),
            onToggleActive: () => _toggleActive(_users[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFB3261E)),
          const SizedBox(height: 16),
          Text(_error ?? '', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppProfile user;
  final bool isSelf;
  final VoidCallback onChangeRole;
  final VoidCallback onToggleActive;

  const _UserCard({
    required this.user,
    required this.isSelf,
    required this.onChangeRole,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final initial = user.username.isNotEmpty ? user.username[0].toUpperCase() : "?";
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: user.isActive ? AppColors.brandTint : AppColors.line,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: user.isActive ? AppColors.brand : AppColors.inkMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.username,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 6),
                            Text("(Anda)", style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ],
                      ),
                      if (user.fullName != null && user.fullName!.isNotEmpty)
                        Text(user.fullName!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (!user.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3261E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Nonaktif",
                      style: TextStyle(color: Color(0xFFB3261E), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChangeRole,
                    icon: const Icon(Icons.badge_outlined, size: 16),
                    label: Text(user.role.label),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSelf ? null : onToggleActive,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.isActive ? const Color(0xFFB3261E) : AppColors.brand,
                      side: BorderSide(color: user.isActive ? const Color(0xFFB3261E) : AppColors.brand),
                    ),
                    icon: Icon(user.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, size: 16),
                    label: Text(user.isActive ? "Nonaktifkan" : "Aktifkan"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
