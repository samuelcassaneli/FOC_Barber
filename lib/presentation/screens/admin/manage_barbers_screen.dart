import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../providers/booking_provider.dart';
import '../../../data/models/barber_model.dart';

class ManageBarbersScreen extends ConsumerWidget {
  const ManageBarbersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barbersAsync = ref.watch(barbersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Barbeiros"),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        onPressed: () {
          // Add new barber dialog (Simplified for demo)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Funcionalidade de Adicionar em desenvolvimento")));
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: barbersAsync.when(
        data: (barbers) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: barbers.length,
          itemBuilder: (context, index) {
            final barber = barbers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white10,
                    backgroundImage: barber.avatarUrl != null ? NetworkImage(barber.avatarUrl!) : null,
                    child: barber.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  title: Text(barber.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(barber.specialties.isNotEmpty ? barber.specialties.first : 'Barbeiro', style: const TextStyle(color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.accent),
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Funcionalidade de Editar em desenvolvimento")));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Confirm delete
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Excluir Barbeiro?"),
                              content: const Text("Essa ação não pode ser desfeita."),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await ref.read(barberRepositoryProvider).deleteBarber(barber.id);
                            ref.invalidate(barbersProvider);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
