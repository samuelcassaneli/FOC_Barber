import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/barber_repository.dart';
import '../models/barber_model.dart';
import '../models/profile_model.dart';
import '../models/working_hours_model.dart';

class BarberRepositoryImpl implements BarberRepository {
  final SupabaseClient _client;

  BarberRepositoryImpl(this._client);

  @override
  Future<List<BarberModel>> getBarbers() async {
    final response = await _client
        .from('barbers')
        .select()
        .eq('is_available', true);
    
    return (response as List).map((e) => BarberModel.fromJson(e)).toList();
  }

  @override
  Future<BarberModel?> getBarberById(String id) async {
    final response = await _client
        .from('barbers')
        .select()
        .eq('id', id)
        .single();
    
    return BarberModel.fromJson(response);
  }

  @override
  Future<BarberModel?> getBarberByProfileId(String profileId) async {
    try {
      final response = await _client
          .from('barbers')
          .select()
          .eq('profile_id', profileId)
          .single();
      return BarberModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ProfileModel?> getBarberProfile(String profileId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', profileId)
        .single();
    
    return ProfileModel.fromJson(response);
  }

  @override
  Future<List<WorkingHoursModel>> getBarberWorkingHours(String barberId) async {
    final response = await _client
        .from('working_hours')
        .select()
        .eq('barber_id', barberId);
    
    return (response as List).map((e) => WorkingHoursModel.fromJson(e)).toList();
  }

  @override
  Future<void> createBarber(BarberModel barber) async {
    await _client.from('barbers').insert(barber.toJson());
  }

  @override
  Future<void> updateBarber(BarberModel barber) async {
    await _client.from('barbers').update(barber.toJson()).eq('id', barber.id);
  }

  @override
  Future<void> deleteBarber(String id) async {
    await _client.from('barbers').delete().eq('id', id);
  }
}
