import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/service_repository.dart';
import '../models/service_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final SupabaseClient _client;

  ServiceRepositoryImpl(this._client);

  @override
  Future<List<ServiceModel>> getServices() async {
    final response = await _client
        .from('services')
        .select()
        .eq('is_active', true)
        .order('price', ascending: true);
    
    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    final response = await _client
        .from('services')
        .select()
        .eq('id', id)
        .single();
    
    return ServiceModel.fromJson(response);
  }
}
