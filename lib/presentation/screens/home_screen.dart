import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final nextBookingAsync = ref.watch(nextClientBookingProvider);
    final clientBookingsAsync = ref.watch(clientBookingsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: AppTheme.background,
            title: profileAsync.when(
              data: (profile) => Text(
                "Olá, ${profile?.fullName?.split(' ').first ?? 'Cliente'}",
                style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              loading: () => Text("Olá...", style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(fontSize: 28)),
              error: (_, __) => Text("Olá, Cliente", style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(fontSize: 28)),
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.bell, color: Colors.white),
                onPressed: () {},
              ),
              profileAsync.when(
                data: (profile) => CircleAvatar(
                  backgroundImage: profile?.avatarUrl != null 
                    ? NetworkImage(profile!.avatarUrl!)
                    : const NetworkImage('https://i.pravatar.cc/150?img=12'),
                  radius: 18,
                ),
                loading: () => const CircleAvatar(radius: 18, backgroundColor: AppTheme.surface),
                error: (_, __) => const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cartão de Fidelidade (com contagem real de bookings completados)
                  clientBookingsAsync.when(
                    data: (bookings) {
                      final completedCount = bookings.where((b) => b.status == 'completed').length;
                      final progress = (completedCount % 10) / 10;
                      final remaining = 10 - (completedCount % 10);
                      
                      return Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("LOYALTY CARD", style: TextStyle(color: AppTheme.accent, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                Icon(Icons.stars, color: AppTheme.accent),
                              ],
                            ),
                            Text("${completedCount % 10} / 10 Cortes", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.black,
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(10),
                              minHeight: 8,
                            ),
                            Text(
                              remaining == 10 
                                ? "Complete 10 cortes para ganhar 1 grátis!" 
                                : "Faltam $remaining cortes para o próximo grátis!",
                              style: AppTheme.darkTheme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => _buildLoyaltyCardPlaceholder(),
                    error: (_, __) => _buildLoyaltyCardPlaceholder(),
                  ),
                  const SizedBox(height: 30),
                  
                  // Próximo Agendamento
                  const Text("Próximo Agendamento", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  nextBookingAsync.when(
                    data: (booking) {
                      if (booking == null) {
                        return GlassCard(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle
                              ),
                              child: const Icon(CupertinoIcons.calendar, color: Colors.grey),
                            ),
                            title: const Text("Nenhum agendamento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: const Text("Agende seu próximo corte!", style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }
                      
                      final isToday = DateUtils.isSameDay(booking.startTime, DateTime.now());
                      final dateStr = isToday 
                        ? "Hoje, ${DateFormat('HH:mm').format(booking.startTime)}"
                        : DateFormat("dd/MM, HH:mm").format(booking.startTime);
                      
                      return GlassCard(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.2),
                              shape: BoxShape.circle
                            ),
                            child: const Icon(CupertinoIcons.time, color: AppTheme.accent),
                          ),
                          title: Text(dateStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("Serviço agendado • ${booking.status}", style: const TextStyle(color: Colors.grey)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking.status == 'confirmed' 
                                ? Colors.green.withOpacity(0.2) 
                                : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              booking.status == 'confirmed' ? 'Confirmado' : 'Pendente',
                              style: TextStyle(
                                color: booking.status == 'confirmed' ? Colors.green : Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const GlassCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircularProgressIndicator(),
                        title: Text("Carregando...", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    error: (err, _) => GlassCard(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: const Text("Erro ao carregar", style: TextStyle(color: Colors.white)),
                        subtitle: Text(err.toString(), style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoyaltyCardPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LOYALTY CARD", style: TextStyle(color: AppTheme.accent, letterSpacing: 2, fontWeight: FontWeight.bold)),
              Icon(Icons.stars, color: AppTheme.accent),
            ],
          ),
          const Text("0 / 10 Cortes", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          LinearProgressIndicator(
            value: 0,
            backgroundColor: Colors.black,
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          Text("Complete 10 cortes para ganhar 1 grátis!", style: AppTheme.darkTheme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
