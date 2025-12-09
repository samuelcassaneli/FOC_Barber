import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import '../../../../../data/services/supabase_service.dart';

// Provider to fetch products
final productsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final client = SupabaseService().client;
  return client
      .from('products')
      .stream(primaryKey: ['id'])
      .eq('barber_id', client.auth.currentUser!.id)
      .order('name');
});

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Produtos"),
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
             return const Center(child: Text("Nenhum produto cadastrado.", style: TextStyle(color: Colors.grey)));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: 2,
               childAspectRatio: 0.8,
               crossAxisSpacing: 12,
               mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return AppleGlassContainer(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                           color: Colors.white10,
                           borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Icon(CupertinoIcons.bag_fill, color: Colors.white24, size: 40)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(product['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text("Estoque: ${product['stock']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("R\$ ${product['price']}", style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                  ],
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

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Novo Produto", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(controller: nameController, placeholder: "Nome do produto", style: const TextStyle(color: Colors.white), placeholderStyle: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            CupertinoTextField(controller: priceController, placeholder: "Preço", keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), placeholderStyle: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            CupertinoTextField(controller: stockController, placeholder: "Estoque", keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), placeholderStyle: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(child: const Text("Cancelar", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx)),
          TextButton(
            child: const Text("Salvar", style: TextStyle(color: AppTheme.accent)),
            onPressed: () async {
               if (nameController.text.isNotEmpty) {
                  await SupabaseService().client.from('products').insert({
                    'barber_id': SupabaseService().client.auth.currentUser!.id,
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'stock': int.tryParse(stockController.text) ?? 0,
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
