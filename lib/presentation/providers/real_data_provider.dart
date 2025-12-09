import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_service.dart';
import '../../core/config/app_config.dart';

// Provider to fetch bookings for the specific user (Client or Barber)
final bookingsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final client = SupabaseService().client;
  final user = client.auth.currentUser;

  if (user == null) return Stream.value([]);

  final isBarber = AppConfig.isBarber;
  final column = isBarber ? 'barber_id' : 'client_id';

  // Real-time subscription
  return client
      .from('bookings')
      .stream(primaryKey: ['id'])
      .eq(column, user.id)
      .order('booking_date', ascending: true) // Upcoming first
      .map((data) => data);
});

// Provider for specific day (for Agenda)
final bookingsForDayProvider = Provider.family.autoDispose<List<Map<String, dynamic>>, DateTime>((ref, date) {
  final allBookings = ref.watch(bookingsProvider).asData?.value ?? [];
  
  return allBookings.where((booking) {
    final bookingDate = DateTime.parse(booking['booking_date']);
    return bookingDate.year == date.year && 
           bookingDate.month == date.month && 
           bookingDate.day == date.day;
  }).toList();
});

// Provider for Dashboard Stats (Barber only)
final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = SupabaseService().client;
  final user = client.auth.currentUser;

  if (user == null) return {'revenue': 0.0, 'appointments': 0, 'rating': 5.0};

  // Get today's bookings count
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

  final todayBookings = await client
      .from('bookings')
      .select()
      .eq('barber_id', user.id)
      .gte('booking_date', startOfDay)
      .lte('booking_date', endOfDay);
  
  // Calculate mockup revenue (since we don't have a payments table yet, we assume avg ticket)
  // In a real app, you would sum the 'price' column from a joined services table.
  final revenue = todayBookings.length * 35.0; // Assuming R$ 35,00 per cut

  return {
    'revenue': revenue,
    'appointments': todayBookings.length,
    'rating': 4.9, // Hardcoded for now until we have reviews table
  };
});
