import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/services/supabase_service.dart';

final financialProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = SupabaseService().client;
  final user = client.auth.currentUser;
  
  // Calculate Date Range (Current Month)
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
  final endOfMonth = DateTime(now.year, now.month + 1, 0).toIso8601String();

  // Fetch completed bookings
  final bookings = await client
      .from('bookings')
      .select()
      .eq('barber_id', user!.id)
      .gte('booking_date', startOfMonth)
      .lte('booking_date', endOfMonth); // Removed filter for 'completed' to show all for now

  double totalRevenue = 0;
  int totalClients = bookings.length;

  for (var b in bookings) {
     totalRevenue += (b['price'] ?? 35.0); // Fallback price
  }

  return {
    'revenue': totalRevenue,
    'clients': totalClients,
    'average_ticket': totalClients > 0 ? totalRevenue / totalClients : 0.0,
    'history': bookings
  };
});

class FinancialScreen extends ConsumerWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(financialProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Financeiro"), backgroundColor: AppTheme.background),
      body: statsAsync.when(
        data: (data) {
           return SingleChildScrollView(
             padding: const EdgeInsets.all(16),
             child: Column(
               children: [
                 // Month Header
                 Text(DateFormat('MMMM yyyy', 'pt_BR').format(DateTime.now()).toUpperCase(), style: const TextStyle(color: Colors.grey, letterSpacing: 2)),
                 const SizedBox(height: 24),
                 
                 // Main Card
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     gradient: const LinearGradient(colors: [AppTheme.accent, Color(0xFFA08220)]),
                     borderRadius: BorderRadius.circular(24),
                   ),
                   child: Column(
                     children: [
                       const Text("Receita Total", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                       Text("R\$ ${data['revenue'].toStringAsFixed(2)}", style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w800)),
                     ],
                   ),
                 ),
                 const SizedBox(height: 16),
                 Row(
                   children: [
                      Expanded(child: _buildStatItem("Clientes", "${data['clients']}")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatItem("Ticket Médio", "R\$ ${data['average_ticket'].toStringAsFixed(0)}")),
                   ],
                 ),
                 const SizedBox(height: 32),
                 const Align(alignment: Alignment.centerLeft, child: Text("EXTRATO", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                 const SizedBox(height: 12),
                 
                 ListView.builder(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: (data['history'] as List).length,
                   itemBuilder: (ctx, i) {
                     final item = data['history'][i];
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 8),
                       child: AppleGlassContainer(
                         child: ListTile(
                           dense: true,
                           contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                           leading: const Icon(CupertinoIcons.scissors, color: Colors.white, size: 18),
                           title: Text(item['client_name'] ?? 'Cliente', style: const TextStyle(color: Colors.white)),
                           subtitle: Text(DateFormat('dd/MM HH:mm').format(DateTime.parse(item['booking_date'])), style: const TextStyle(color: Colors.grey)),
                           trailing: Text("+ R\$ ${(item['price'] ?? 35.0).toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                         ),
                       ),
                     );
                   },
                 )
               ],
             ),
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text("Erro: $e")),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return AppleGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}