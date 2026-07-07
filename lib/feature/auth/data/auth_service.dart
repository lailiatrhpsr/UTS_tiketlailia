import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/profile_model.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  SupabaseClient get _db => Supabase.instance.client;
  GoTrueClient get _auth => _db.auth;

  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    await _auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<AppProfile> login({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email, password: password);
    final profile = await fetchCurrentProfile();
    if (profile == null) {
      throw Exception('Profil pengguna tidak ditemukan setelah login.');
    }
    
    if (!profile.isActive) {
      await _auth.signOut();
      throw Exception('Akun ini telah dinonaktifkan. Hubungi Admin.');
    }
    return profile;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AppProfile?> fetchCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final row = await _db.from('profiles').select().eq('id', user.id).maybeSingle();
    if (row == null) return null;
    return AppProfile.fromRow(row);
  }

  Future<List<AppProfile>> fetchHelpdeskAgents() async {
    final rows = await _db.from('profiles').select().eq('role', 'helpdesk');
    return (rows as List).map((r) => AppProfile.fromRow(r as Map<String, dynamic>)).toList();
  }

  String? get currentEmail => _auth.currentUser?.email;

  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<AppProfile> updateProfile({
    required String userId,
    String? username,
    String? fullName,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (fullName != null) updates['full_name'] = fullName;

    await _db.from('profiles').update(updates).eq('id', userId);
    final row = await _db.from('profiles').select().eq('id', userId).single();
    return AppProfile.fromRow(row);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(email.trim());
  }


  /// Daftar seluruh pengguna terdaftar, untuk halaman Kelola Pengguna Admin.
  Future<List<AppProfile>> fetchAllProfiles() async {
    final rows = await _db.from('profiles').select().order('username');
    return (rows as List).map((r) => AppProfile.fromRow(r as Map<String, dynamic>)).toList();
  }

  /// Admin mengubah role seorang pengguna (user/helpdesk/admin).
  Future<AppProfile> updateUserRole(String userId, UserRole role) async {
    await _db.from('profiles').update({'role': role.name}).eq('id', userId);
    final row = await _db.from('profiles').select().eq('id', userId).single();
    return AppProfile.fromRow(row);
  }

  /// Admin menonaktifkan/mengaktifkan kembali akun pengguna.
  Future<AppProfile> setUserActive(String userId, bool isActive) async {
    await _db.from('profiles').update({'is_active': isActive}).eq('id', userId);
    final row = await _db.from('profiles').select().eq('id', userId).single();
    return AppProfile.fromRow(row);
  }
}
