import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/config/app_config.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClient _client;

  BookingRepositoryImpl(this._client);

  String get _tableName => 'barbershop_bookings';

  @override
  Future<List<BookingModel>> getClientBookings(String clientId) async {
    var query = _client
        .from(_tableName)
        .select('*, barbers(*), barbershop_services(*), clients(*)');

    // Filtra por barbearia se configurada
    if (AppConfig.hasBarbershop) {
      query = query.eq('barbershop_id', AppConfig.requiredBarbershopId);
    }

    final response = await query
        .eq('client_id', clientId)
        .order('start_time', ascending: false);

    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  @override
  Future<List<BookingModel>> getBarberBookings(String barberId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from(_tableName)
        .select('*, barbers(*), barbershop_services(*), clients(*)')
        .eq('barber_id', barberId)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .order('start_time', ascending: true);

    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  /// Lista agendamentos por barbearia
  Future<List<BookingModel>> getByBarbershop(String barbershopId, {DateTime? date}) async {
    var query = _client
        .from(_tableName)
        .select('*, barbers(*), barbershop_services(*), clients(*)')
        .eq('barbershop_id', barbershopId);

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String());
    }

    final response = await query.order('start_time', ascending: true);
    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  /// Lista agendamentos da barbearia atual
  Future<List<BookingModel>> getCurrentBarbershopBookings({DateTime? date}) async {
    if (!AppConfig.hasBarbershop) return [];
    return getByBarbershop(AppConfig.requiredBarbershopId, date: date);
  }

  /// Lista próximos agendamentos de um cliente
  Future<List<BookingModel>> getUpcomingClientBookings(String clientId) async {
    var query = _client
        .from(_tableName)
        .select('*, barbers(*), barbershop_services(*)')
        .eq('client_id', clientId)
        .gte('start_time', DateTime.now().toIso8601String())
        .neq('status', 'cancelled')
        .neq('status', 'completed');

    if (AppConfig.hasBarbershop) {
      query = query.eq('barbershop_id', AppConfig.requiredBarbershopId);
    }

    final response = await query.order('start_time', ascending: true);
    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  /// Obtém o próximo agendamento de um cliente
  Future<BookingModel?> getNextClientBooking(String clientId) async {
    final bookings = await getUpcomingClientBookings(clientId);
    return bookings.isNotEmpty ? bookings.first : null;
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    await _client.from(_tableName).insert(booking.toInsertJson());
  }

  /// Cria agendamento com retorno do modelo
  Future<BookingModel> create(BookingModel booking) async {
    final response = await _client
        .from(_tableName)
        .insert(booking.toInsertJson())
        .select('*, barbers(*), barbershop_services(*), clients(*)')
        .single();

    return BookingModel.fromJson(response);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _client
        .from(_tableName)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  /// Atualiza status com enum
  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    await updateBookingStatus(bookingId, status.toDbValue());
  }

  /// Confirma agendamento
  Future<void> confirm(String bookingId) async {
    await updateStatus(bookingId, BookingStatus.confirmed);
  }

  /// Inicia atendimento
  Future<void> startService(String bookingId) async {
    await updateStatus(bookingId, BookingStatus.inProgress);
  }

  /// Completa atendimento
  Future<void> complete(String bookingId) async {
    await updateStatus(bookingId, BookingStatus.completed);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final userId = _client.auth.currentUser?.id;
    await _client
        .from(_tableName)
        .update({
          'status': 'cancelled',
          'cancelled_by': userId,
          'cancelled_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  /// Cancela com motivo
  Future<void> cancelWithReason(String bookingId, String reason) async {
    final userId = _client.auth.currentUser?.id;
    await _client
        .from(_tableName)
        .update({
          'status': 'cancelled',
          'cancelled_by': userId,
          'cancelled_at': DateTime.now().toIso8601String(),
          'cancellation_reason': reason,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  /// Marca como no-show
  Future<void> markNoShow(String bookingId) async {
    await updateStatus(bookingId, BookingStatus.noShow);
  }

  /// Atualiza pagamento
  Future<void> updatePayment(String bookingId, PaymentStatus status, {String? method}) async {
    await _client
        .from(_tableName)
        .update({
          'payment_status': status.toDbValue(),
          if (method != null) 'payment_method': method,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  /// Stream de agendamentos em tempo real
  Stream<List<BookingModel>> watchBarberBookings(String barberId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('barber_id', barberId)
        .order('start_time', ascending: true)
        .map((data) {
          return data
            .map((e) => BookingModel.fromJson(e))
            .where((b) => b.startTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                          b.startTime.isBefore(endOfDay))
            .toList();
        });
  }

  /// Estatísticas do dia
  Future<Map<String, dynamic>> getDayStats(String barbershopId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from(_tableName)
        .select('status, total_price')
        .eq('barbershop_id', barbershopId)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String());

    final bookings = response as List;
    final completed = bookings.where((b) => b['status'] == 'completed').toList();
    final revenue = completed.fold<double>(
      0,
      (sum, b) => sum + (b['total_price'] ?? 0).toDouble(),
    );

    return {
      'total': bookings.length,
      'completed': completed.length,
      'pending': bookings.where((b) => b['status'] == 'pending').length,
      'cancelled': bookings.where((b) => b['status'] == 'cancelled').length,
      'revenue': revenue,
    };
  }
}
