import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/barber_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/barber_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../data/services/supabase_service.dart';
import 'auth_provider.dart';

part 'booking_provider.g.dart';

@riverpod
ServiceRepositoryImpl serviceRepository(ServiceRepositoryRef ref) {
  return ServiceRepositoryImpl(SupabaseService().client);
}

@riverpod
BarberRepositoryImpl barberRepository(BarberRepositoryRef ref) {
  return BarberRepositoryImpl(SupabaseService().client);
}

@riverpod
BookingRepositoryImpl bookingRepository(BookingRepositoryRef ref) {
  return BookingRepositoryImpl(SupabaseService().client);
}

@riverpod
Future<List<ServiceModel>> services(ServicesRef ref) async {
  return ref.watch(serviceRepositoryProvider).getServices();
}

@riverpod
Future<List<BarberModel>> barbers(BarbersRef ref) async {
  return ref.watch(barberRepositoryProvider).getBarbers();
}

@riverpod
Future<BarberModel?> currentBarber(CurrentBarberRef ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  
  return ref.watch(barberRepositoryProvider).getBarberByProfileId(user.id);
}

// Client bookings provider
@riverpod
Future<List<BookingModel>> clientBookings(ClientBookingsRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  
  return ref.watch(bookingRepositoryProvider).getClientBookings(user.id);
}

// Next upcoming booking for client
@riverpod
Future<BookingModel?> nextClientBooking(NextClientBookingRef ref) async {
  final bookings = await ref.watch(clientBookingsProvider.future);
  final now = DateTime.now();
  
  // Filter for future confirmed/pending bookings and get the nearest one
  final upcomingBookings = bookings
      .where((b) => b.startTime.isAfter(now) && (b.status == 'pending' || b.status == 'confirmed'))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  
  return upcomingBookings.isNotEmpty ? upcomingBookings.first : null;
}

// User profile provider
@riverpod
Future<ProfileModel?> userProfile(UserProfileRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  
  try {
    final response = await SupabaseService().client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return ProfileModel.fromJson(response);
  } catch (e) {
    return null;
  }
}
