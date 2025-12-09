import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import '../../../../../data/services/supabase_service.dart';

// Provider to fetch services
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
            onPressed: () => _showAddServiceDialog(context),
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

  void _showAddServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController(text: "30");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Novo Serviço", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(
               controller: nameController,
               placeholder: "Nome do serviço",
               style: const TextStyle(color: Colors.white),
               placeholderStyle: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
               controller: priceController,
               placeholder: "Preço (ex: 35.00)",
               keyboardType: TextInputType.number,
               style: const TextStyle(color: Colors.white),
               placeholderStyle: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
               controller: durationController,
               placeholder: "Duração (min)",
               keyboardType: TextInputType.number,
               style: const TextStyle(color: Colors.white),
               placeholderStyle: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text("Salvar", style: TextStyle(color: AppTheme.accent)),
            onPressed: () async {
               final name = nameController.text;
               final price = double.tryParse(priceController.text);
               final duration = int.tryParse(durationController.text);

               if (name.isNotEmpty && price != null) {
                  await SupabaseService().client.from('services').insert({
                    'barber_id': SupabaseService().client.auth.currentUser!.id,
                    'name': name,
                    'price': price,
                    'duration_minutes': duration ?? 30,
                  });
                  Navigator.pop(ctx);
               }
            },
          ),
        ],
      ),
    );
  }
}
