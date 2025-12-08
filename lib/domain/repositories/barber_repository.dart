import '../../data/models/barber_model.dart';
import '../../data/models/working_hours_model.dart';
import '../../data/models/profile_model.dart';

abstract class BarberRepository {
  Future<List<BarberModel>> getBarbers();
  Future<BarberModel?> getBarberById(String id);
  Future<BarberModel?> getBarberByProfileId(String profileId);
  Future<ProfileModel?> getBarberProfile(String profileId);
  Future<List<WorkingHoursModel>> getBarberWorkingHours(String barberId);
  Future<void> createBarber(BarberModel barber);
  Future<void> updateBarber(BarberModel barber);
  Future<void> deleteBarber(String id);
}
