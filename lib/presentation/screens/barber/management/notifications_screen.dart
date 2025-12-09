import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/services/supabase_service.dart';

final notificationsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final client = SupabaseService().client;
  return client
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', client.auth.currentUser!.id)
      .order('created_at', ascending: false); // Newest first
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Notificações"), backgroundColor: AppTheme.background),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) return const Center(child: Text("Sem notificações", style: TextStyle(color: Colors.grey)));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final note = notifications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppleGlassContainer(
                   child: ListTile(
                     leading: CircleAvatar(
                       backgroundColor: AppTheme.accent.withOpacity(0.2),
                       child: const Icon(CupertinoIcons.bell_fill, color: AppTheme.accent, size: 18),
                     ),
                     title: Text(note['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     subtitle: Text(note['message'], style: const TextStyle(color: Colors.grey)),
                   ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,__) => Center(child: Text("Erro: $e")),
      ),
    );
  }
}
