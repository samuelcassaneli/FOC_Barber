import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/booking_model.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);
    final user = authStateAsync.value;
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
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentBarberProvider);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentBarberAsync.when(
          data: (barber) {
            if (barber == null) {
              return const Center(child: Text("Você não tem perfil de barbeiro.", style: TextStyle(color: Colors.white)));
            }
            
            return FutureBuilder<List<BookingModel>>(
              future: ref.watch(bookingRepositoryProvider).getBarberBookings(barber.id, DateTime.now()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final bookings = snapshot.data ?? [];
                
                // Calculate real earnings using service prices
                return servicesAsync.when(
                  data: (services) {
                    double totalEarnings = 0;
                    for (var booking in bookings.where((b) => b.status != 'cancelled')) {
                      final service = services.where((s) => s.id == booking.serviceId).firstOrNull;
                      if (service != null) {
                        totalEarnings += service.price;
                      }
                    }
                    
                    return Column(
                      children: [
                        _buildFinancials(bookings.length, totalEarnings),
                        const SizedBox(height: 30),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Agenda de Hoje", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text("${bookings.length} agendamentos", style: const TextStyle(color: AppTheme.accent)),
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
                                  final service = services.where((s) => s.id == booking.serviceId).firstOrNull;
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: GlassCard(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: _getStatusColor(booking.status).withOpacity(0.2),
                                          child: Text(
                                            DateFormat('HH').format(booking.startTime),
                                            style: TextStyle(color: _getStatusColor(booking.status)),
                                          ),
                                        ),
                                        title: Text(
                                          service?.name ?? "Serviço",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          "${DateFormat('HH:mm').format(booking.startTime)} - ${DateFormat('HH:mm').format(booking.endTime)}",
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        trailing: _buildStatusActions(booking),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        )
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Erro: $err', style: const TextStyle(color: Colors.red))),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusActions(BookingModel booking) {
    if (booking.status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
            onPressed: () => _updateBookingStatus(booking.id, 'confirmed'),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
            onPressed: () => _updateBookingStatus(booking.id, 'cancelled'),
          ),
        ],
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(booking.status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4)
      ),
      child: Text(
        _getStatusLabel(booking.status),
        style: TextStyle(
          color: _getStatusColor(booking.status),
          fontSize: 10
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmado';
      case 'pending':
        return 'Pendente';
      case 'cancelled':
        return 'Cancelado';
      case 'completed':
        return 'Concluído';
      default:
        return status;
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      if (status == 'cancelled') {
        await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
      } else {
        await ref.read(bookingRepositoryProvider).updateBookingStatus(bookingId, status);
      }
      setState(() {}); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para: ${_getStatusLabel(status)}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Widget _buildFinancials(int count, double earnings) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard("Ganhos (Hoje)", "R\$ ${earnings.toStringAsFixed(0)}", CupertinoIcons.money_dollar, Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard("Agendamentos", "$count", CupertinoIcons.scissors, AppTheme.accent),
        ),
      ],
    );
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
