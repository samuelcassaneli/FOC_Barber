import 'package:barber_premium/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/apple_glass_container.dart';
import '../../../data/services/supabase_service.dart';

// Provider to get client profile data
final clientProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = SupabaseService().client;
  final user = client.auth.currentUser;
  if (user == null) throw Exception("User not logged in");
  
  return await client.from('profiles').select().eq('id', user.id).single();
});

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(clientProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: AppTheme.background,
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profile['avatar_url'] != null 
                    ? NetworkImage(profile['avatar_url'])
                    : const NetworkImage("https://i.pravatar.cc/300?img=8"),
              ),
              const SizedBox(height: 16),
              Text(
                profile['full_name'] ?? 'Cliente',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                profile['email'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              _buildSection(context, "Configurações", [
                _buildTile("Editar Perfil", CupertinoIcons.pencil, () {}),
                _buildTile("Notificações", CupertinoIcons.bell, () {}),
              ]),
              
              const SizedBox(height: 24),
              _buildSection(context, "Conta", [
                _buildTile("Sair", CupertinoIcons.square_arrow_left, () {
                  ref.read(authControllerProvider.notifier).signOut();
                }, isDestructive: true),
              ]),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,__) => Center(child: Text("Erro: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        AppleGlassContainer(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.white)),
      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }
}
