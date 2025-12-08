import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClient _client;

  BookingRepositoryImpl(this._client);

  @override
  Future<List<BookingModel>> getClientBookings(String clientId) async {
    final response = await _client
        .from('bookings')
        .select()
        .eq('client_id', clientId)
        .order('start_time', ascending: false);
    
    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  @override
  Future<List<BookingModel>> getBarberBookings(String barberId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('bookings')
        .select()
        .eq('barber_id', barberId)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .order('start_time', ascending: true);
    
    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    await _client.from('bookings').insert({
      'client_id': booking.clientId,
      'barber_id': booking.barberId,
      'service_id': booking.serviceId,
      'start_time': booking.startTime.toIso8601String(),
      'end_time': booking.endTime.toIso8601String(),
      'status': booking.status,
      'payment_status': booking.paymentStatus,
      'notes': booking.notes,
    });
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }
}
