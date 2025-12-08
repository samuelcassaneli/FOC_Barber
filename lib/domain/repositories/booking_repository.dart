import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getClientBookings(String clientId);
  Future<List<BookingModel>> getBarberBookings(String barberId, DateTime date);
  Future<void> createBooking(BookingModel booking);
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<void> cancelBooking(String bookingId);
}
