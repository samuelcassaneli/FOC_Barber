import 'package:barber_premium/presentation/providers/real_data_provider.dart';
import 'package:barber_premium/presentation/providers/profile_provider.dart'; // Added
import 'package:barber_premium/presentation/screens/barber/clients/barber_clients_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/apple_glass_container.dart';

class BarberDashboardScreen extends ConsumerWidget {
  const BarberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    final profileAsync = ref.watch(profileProvider); // Added

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            backgroundColor: AppTheme.background,
            title: const Text("Painel"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: profileAsync.when(
                  data: (profile) => CircleAvatar(
                    radius: 18,
                    backgroundImage: profile['avatar_url'] != null 
                        ? NetworkImage(profile['avatar_url']) 
                        : null,
                    backgroundColor: AppTheme.surfaceSecondary,
                    child: profile['avatar_url'] == null 
                        ? const Icon(CupertinoIcons.person_solid, color: Colors.white, size: 20)
                        : null,
                  ),
                  loading: () => const CircleAvatar(radius: 18, backgroundColor: AppTheme.surfaceSecondary),
                  error: (_,__) => const CircleAvatar(radius: 18, backgroundColor: AppTheme.surfaceSecondary, child: Icon(Icons.error, size: 16)),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Text(
                    "RESUMO DE HOJE",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Revenue Card (Big Impact)
                  statsAsync.when(
                    data: (stats) => _buildRevenueCard(context, stats['revenue']),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_,__) => const Text("Erro ao carregar"),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Stats Grid
                  statsAsync.when(
                    data: (stats) => Row(
                      children: [
                        Expanded(child: _buildSmallStatCard("Agendamentos", "${stats['appointments']}", CupertinoIcons.calendar_today, Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSmallStatCard("Avaliação", "${stats['rating']}", CupertinoIcons.star_fill, Colors.orange)),
                      ],
                    ),
                    loading: () => const SizedBox(height: 100),
                    error: (_,__) => const SizedBox(),
                  ),
                  const SizedBox(height: 32),
                  
                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Próximos Clientes", style: Theme.of(context).textTheme.titleLarge),
                      GestureDetector(
                        onTap: () {
                           Navigator.push(context, CupertinoPageRoute(builder: (c) => const BarberClientsScreen()));
                        },
                        child: const Text("Ver Todos", style: TextStyle(color: AppTheme.accent, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Appointments List
          bookingsAsync.when(
            data: (bookings) {
               if (bookings.isEmpty) {
                 return const SliverToBoxAdapter(
                   child: Padding(padding: EdgeInsets.all(20), child: Text("Nenhum agendamento futuro.", style: TextStyle(color: Colors.grey))),
                 );
               }
               return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = bookings[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: _buildAppointmentRow(context, booking),
                    );
                  },
                  childCount: bookings.length > 5 ? 5 : bookings.length, // Limit on dashboard
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e,__) => SliverToBoxAdapter(child: Text("Erro: $e")),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(BuildContext context, double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(CupertinoIcons.graph_square_fill, color: AppTheme.accent, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Hoje", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Faturamento Estimado", style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          Text("R\$ ${revenue.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAppointmentRow(BuildContext context, Map<String, dynamic> booking) {
    final date = DateTime.parse(booking['booking_date']);
    final timeStr = "${date.hour}:${date.minute.toString().padLeft(2,'0')}";
    final clientName = booking['client_name'] ?? 'Cliente';

    return AppleGlassContainer(
      opacity: 1.0, // Solid background
      padding: const EdgeInsets.all(0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.surfaceSecondary,
          child: Text(clientName[0], style: const TextStyle(color: Colors.white)),
        ),
        title: Text(clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: const Text("Corte + Barba", style: TextStyle(color: AppTheme.textSecondary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(timeStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Agendado", 
              style: TextStyle(
                color: Colors.green, 
                fontSize: 12
              )
            ),
          ],
        ),
      ),
    );
  }
}
