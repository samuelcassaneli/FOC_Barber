import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/barber_model.dart';
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
