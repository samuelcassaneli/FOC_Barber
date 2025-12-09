import 'package:barber_premium/presentation/providers/management_provider.dart';
import 'package:barber_premium/presentation/screens/client/barber_detail_screen.dart'; // Correctly placed import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:barber_premium/core/theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../widgets/apple_glass_container.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final nextBookingAsync = ref.watch(nextClientBookingProvider);
    final clientBookingsAsync = ref.watch(clientBookingsProvider);
    final barbershopsAsync = ref.watch(barbershopsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            backgroundColor: AppTheme.background,
            title: profileAsync.when(
              data: (profile) => Text(profile?.fullName?.split(' ').first ?? 'Cliente'),
              loading: () => const Text("Olá..."),
              error: (_, __) => const Text("Barber Premium"),
            ),
            actions: [
              IconButton(icon: const Icon(CupertinoIcons.bell_fill, color: Colors.white), onPressed: () {}),
              const SizedBox(width: 8),
              profileAsync.when(
                data: (profile) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : const NetworkImage('https://i.pravatar.cc/150?img=12'), radius: 18),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BARBEARIAS", style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  
                  // Horizontal list of Barbershops
                  SizedBox(
                    height: 140,
                    child: barbershopsAsync.when(
                      data: (shops) {
                        if (shops.isEmpty) return const Center(child: Text("Nenhuma barbearia encontrada", style: TextStyle(color: Colors.grey)));
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: shops.length,
                          separatorBuilder: (_,__) => const SizedBox(width: 16),
                          itemBuilder: (ctx, i) {
                             final shop = shops[i];
                             return GestureDetector(
                               onTap: () {
                                  Navigator.push(context, CupertinoPageRoute(builder: (_) => BarberDetailScreen(barber: shop)));
                               },
                               child: Container(
// ... rest of code
                                 width: 120,
                                 decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                                 padding: const EdgeInsets.all(12),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     CircleAvatar(radius: 30, backgroundImage: NetworkImage(shop['avatar_url'] ?? 'https://i.pravatar.cc/150')),
                                     const SizedBox(height: 8),
                                     Text(shop['full_name'] ?? 'Barbearia', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center, maxLines: 2),
                                   ],
                                 ),
                               ),
                             );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_,__) => const Center(child: Icon(Icons.error, color: Colors.red)),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text("CARTEIRA", style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  _buildLoyaltyCard(clientBookingsAsync),
                  
                  const SizedBox(height: 32),
                  Text("PRÓXIMO AGENDAMENTO", style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  _buildNextBooking(nextBookingAsync),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(AsyncValue<List<dynamic>> bookingsAsync) {
    return bookingsAsync.when(
      data: (bookings) {
        final completedCount = bookings.where((b) => b.status == 'completed').length;
        final count = completedCount % 10;
        final remaining = 10 - count;

        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFA08220)], // Gold Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -50, top: -50,
                child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(CupertinoIcons.scissors, color: Colors.black, size: 30),
                        Text("GOLD MEMBER", style: GoogleFonts.inter(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$count / 10", style: const TextStyle(color: Colors.black, fontSize: 42, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(remaining == 10 ? "Comece sua jornada!" : "Faltam $remaining para um corte grátis", 
                          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const AppleGlassContainer(child: SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))),
      error: (_,__) => const SizedBox(),
    );
  }

  Widget _buildNextBooking(AsyncValue<dynamic> bookingAsync) {
    return bookingAsync.when(
      data: (booking) {
        if (booking == null) {
          return AppleGlassContainer(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(CupertinoIcons.calendar_badge_plus, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sem agendamentos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("Toque para marcar um horário", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                )
              ],
            ),
          );
        }
        
        final isToday = DateUtils.isSameDay(booking.startTime, DateTime.now());
        final dateStr = isToday 
          ? "Hoje, ${DateFormat('HH:mm').format(booking.startTime)}"
          : DateFormat("dd MMM • HH:mm", 'pt_BR').format(booking.startTime).toUpperCase();

        return AppleGlassContainer(
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Date Column
                Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('dd').format(booking.startTime), style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 20)),
                      Text(DateFormat('MMM').format(booking.startTime).toUpperCase(), style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Corte Masculino", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.time, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(dateStr, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.status == 'confirmed' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    booking.status == 'confirmed' ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                    size: 16,
                    color: booking.status == 'confirmed' ? Colors.green : Colors.orange,
                  ),
                )
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_,__) => const SizedBox(),
    );
  }
}

