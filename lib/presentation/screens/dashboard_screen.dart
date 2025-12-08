import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value?.session?.user;
    final isSuperAdmin = user?.email == 'aiucmt.kiaaivmtq@gmail.com';

    if (isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Painel Master", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: AppTheme.accent),
              const SizedBox(height: 20),
              const Text(
                "Super Admin",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Acesse o painel web para gestão completa.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              GoldButton(
                label: "Gerenciar Barbearias",
                onPressed: () {
                  // Navigate to Admin features if implemented in mobile
                  // For now, show a dialog or placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Funcionalidade completa disponível na Web."))
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    final currentBarberAsync = ref.watch(currentBarberProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentBarberAsync.when(
          data: (barber) {
            if (barber == null) {
              return const Center(child: Text("Você não tem perfil de barbeiro.", style: TextStyle(color: Colors.white)));
            }
            
            final today = DateTime.now();
            final bookingsAsync = ref.watch(bookingRepositoryProvider).getBarberBookings(barber.id, today);
            
            return FutureBuilder<List<dynamic>>( // Using dynamic for simplicity, ideally BookingModel
              future: bookingsAsync,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final bookings = snapshot.data ?? [];
                
                return Column(
                  children: [
                    _buildFinancials(bookings.length),
                    const SizedBox(height: 30),
                    
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Agenda de Hoje", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("Ver tudo", style: TextStyle(color: AppTheme.accent)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    Expanded(
                      child: bookings.isEmpty 
                        ? const Center(child: Text("Sem agendamentos para hoje.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.white10,
                                      child: Text("C${index+1}", style: const TextStyle(color: Colors.white)),
                                    ),
                                    title: const Text("Cliente", style: TextStyle(color: Colors.white)), // We need client name
                                    subtitle: Text("${DateFormat('HH:mm').format(booking.startTime)} - Serviço", style: const TextStyle(color: Colors.grey)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: booking.status == 'confirmed' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Text(
                                        booking.status,
                                        style: TextStyle(
                                          color: booking.status == 'confirmed' ? Colors.green : Colors.orange,
                                          fontSize: 10
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    )
                  ],
                );
              }
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erro: $err', style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }

  Widget _buildFinancials(int count) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard("Ganhos (Est.)", "R\$ ${count * 50},00", CupertinoIcons.money_dollar, Colors.green), // Mock calc
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard("Agendamentos", "$count", CupertinoIcons.scissors, AppTheme.accent),
        ),
      ],
    );
  }

  Widget _buildBookingList(DateTime date) {
     return const SizedBox.shrink(); // Unused
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
