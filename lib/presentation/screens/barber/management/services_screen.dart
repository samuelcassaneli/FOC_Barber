import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/services/supabase_service.dart';

final servicesProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final client = SupabaseService().client;
  return client
      .from('services')
      .stream(primaryKey: ['id'])
      .eq('barber_id', client.auth.currentUser!.id)
      .order('name');
});

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Serviços"),
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            onPressed: () => _showAddServiceSheet(context),
          ),
        ],
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
             return const Center(child: Text("Nenhum serviço cadastrado.", style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppleGlassContainer(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(CupertinoIcons.scissors, color: Colors.orange),
                    ),
                    title: Text(service['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${service['duration_minutes']} min", style: const TextStyle(color: Colors.grey)),
                    trailing: Text("R\$ ${service['price']}", style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text("Erro: $e")),
      ),
    );
  }

  void _showAddServiceSheet(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController(text: "30");

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AppleGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          opacity: 0.95,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Novo Serviço", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text("Nome do Serviço", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                CupertinoTextField(
                   controller: nameController,
                   placeholder: "Ex: Corte Degradê",
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                   style: const TextStyle(color: Colors.white),
                   placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Preço (R\$)", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                             controller: priceController,
                             placeholder: "0.00",
                             keyboardType: const TextInputType.numberWithOptions(decimal: true),
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                             style: const TextStyle(color: Colors.white),
                             placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Duração (Minutos)", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                             controller: durationController,
                             placeholder: "30",
                             keyboardType: TextInputType.number,
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                             style: const TextStyle(color: Colors.white),
                             placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    child: const Text("Salvar Serviço"),
                    onPressed: () async {
                       final name = nameController.text;
                       final price = double.tryParse(priceController.text.replaceAll(',', '.'));
                       final duration = int.tryParse(durationController.text);

                       if (name.isNotEmpty && price != null) {
                          try {
                            await SupabaseService().client.from('services').insert({
                              'barber_id': SupabaseService().client.auth.currentUser!.id,
                              'name': name,
                              'price': price,
                              'duration_minutes': duration ?? 30, // Matches SQL standard
                            });
                            if (context.mounted) Navigator.pop(ctx);
                          } catch(e) {
                             if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
                          }
                       }
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
