import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/service_repository.dart';
import '../../core/config/app_config.dart';
import '../models/service_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final SupabaseClient _client;

  ServiceRepositoryImpl(this._client);

  String get _tableName => 'barbershop_services';

  @override
  Future<List<ServiceModel>> getServices() async {
    var query = _client
        .from(_tableName)
        .select()
        .eq('is_active', true);

    // Filtra por barbearia se configurada
    if (AppConfig.hasBarbershop) {
      query = query.eq('barbershop_id', AppConfig.requiredBarbershopId);
    }

    final response = await query.order('display_order', ascending: true);
    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  /// Lista serviços de uma barbearia específica
  Future<List<ServiceModel>> getByBarbershop(String barbershopId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('barbershop_id', barbershopId)
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  /// Lista todos os serviços (incluindo inativos) da barbearia
  Future<List<ServiceModel>> getAllByBarbershop(String barbershopId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('barbershop_id', barbershopId)
        .order('display_order', ascending: true);

    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  /// Lista serviços por categoria
  Future<List<ServiceModel>> getByCategory(String barbershopId, String category) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('barbershop_id', barbershopId)
        .eq('category', category)
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  /// Obtém categorias distintas
  Future<List<String>> getCategories(String barbershopId) async {
    final response = await _client
        .from(_tableName)
        .select('category')
        .eq('barbershop_id', barbershopId)
        .eq('is_active', true)
        .not('category', 'is', null);

    final categories = (response as List)
        .map((e) => e['category'] as String)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ServiceModel.fromJson(response);
  }

  /// Cria um novo serviço
  Future<ServiceModel> create(ServiceModel service) async {
    final response = await _client
        .from(_tableName)
        .insert(service.toInsertJson())
        .select()
        .single();

    return ServiceModel.fromJson(response);
  }

  /// Atualiza um serviço
  Future<ServiceModel> update(ServiceModel service) async {
    final response = await _client
        .from(_tableName)
        .update(service.toJson())
        .eq('id', service.id)
        .select()
        .single();

    return ServiceModel.fromJson(response);
  }

  /// Desativa um serviço
  Future<void> deactivate(String id) async {
    await _client
        .from(_tableName)
        .update({'is_active': false})
        .eq('id', id);
  }

  /// Ativa um serviço
  Future<void> activate(String id) async {
    await _client
        .from(_tableName)
        .update({'is_active': true})
        .eq('id', id);
  }

  /// Deleta um serviço
  Future<void> delete(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  /// Atualiza ordem de exibição
  Future<void> updateOrder(List<String> serviceIds) async {
    for (int i = 0; i < serviceIds.length; i++) {
      await _client
          .from(_tableName)
          .update({'display_order': i})
          .eq('id', serviceIds[i]);
    }
  }
}
