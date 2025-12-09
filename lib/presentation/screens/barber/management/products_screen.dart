import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/services/supabase_service.dart';

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
            onPressed: () => _showAddProductSheet(context),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
             return const Center(child: Text("Nenhum produto.", style: TextStyle(color: Colors.grey)));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: 2,
               childAspectRatio: 0.75,
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
                        width: double.infinity,
                        decoration: BoxDecoration(
                           color: Colors.white10,
                           borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(CupertinoIcons.bag_fill, color: Colors.white24, size: 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(product['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("Estoque: ${product['stock']} unid.", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text("R\$ ${product['price']}", style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 18)),
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

  void _showAddProductSheet(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

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
                    const Text("Novo Produto", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text("Nome do Produto", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                CupertinoTextField(
                   controller: nameController,
                   placeholder: "Ex: Pomada Modeladora",
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
                          const Text("Estoque (Qtd)", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                             controller: stockController,
                             placeholder: "0",
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
                    child: const Text("Salvar Produto"),
                    onPressed: () async {
                       if (nameController.text.isNotEmpty) {
                          await SupabaseService().client.from('products').insert({
                            'barber_id': SupabaseService().client.auth.currentUser!.id,
                            'name': nameController.text,
                            'price': double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0,
                            'stock': int.tryParse(stockController.text) ?? 0,
                          });
                          Navigator.pop(ctx);
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

  // Removed unused _buildLabel method
}