import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gold_button.dart';
import '../auth_screen.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Super Admin"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Visão Geral", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildAdminStatCard("Total Barbeiros", "5", CupertinoIcons.person_2_fill, AppTheme.accent)),
                const SizedBox(width: 16),
                Expanded(child: _buildAdminStatCard("Assinaturas Ativas", "5", CupertinoIcons.checkmark_seal_fill, Colors.green)),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Gerenciamento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            GlassCard(
              child: ListTile(
                leading: const Icon(CupertinoIcons.scissors, color: Colors.white),
                title: const Text("Gerenciar Barbeiros", style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  // Navigate to Manage Barbers Screen
                },
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: ListTile(
                leading: const Icon(CupertinoIcons.money_dollar, color: Colors.white),
                title: const Text("Financeiro Global", style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {},
              ),
            ),
             const SizedBox(height: 10),
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip, color: Colors.white),
                title: const Text("LGPD & Privacidade", style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
