import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'feature/auth/presentation/login_screen.dart';

void main() {
  runApp(const TicketingApp());
}

class TicketingApp extends StatelessWidget {
  const TicketingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,

      // Implementasi Non-Functional Requirement: Dark & Light Mode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Otomatis mengikuti settingan sistem HP

      // Entry Point: Aplikasi dimulai dari halaman Login (FR-001)
      home: const LoginScreen(),
    );
  }
}