import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../../core/config/app_config.dart';

class BarbershopRepository {
  final SupabaseClient _client;

  BarbershopRepository(this._client);

  /// Obtém uma barbearia pelo ID
  Future<BarbershopModel?> getById(String id) async {
    final response = await _client
        .from('barbershops')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return BarbershopModel.fromJson(response);
  }

  /// Obtém uma barbearia pelo slug
  Future<BarbershopModel?> getBySlug(String slug) async {
    final response = await _client
        .from('barbershops')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    if (response == null) return null;
    return BarbershopModel.fromJson(response);
  }

  /// Lista todas as barbearias ativas
  Future<List<BarbershopModel>> getAll() async {
    final response = await _client
        .from('barbershops')
        .select()
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((json) => BarbershopModel.fromJson(json))
        .toList();
  }

  /// Cria uma nova barbearia
  Future<BarbershopModel> create(BarbershopModel barbershop) async {
    final response = await _client
        .from('barbershops')
        .insert(barbershop.toInsertJson())
        .select()
        .single();

    return BarbershopModel.fromJson(response);
  }

  /// Atualiza uma barbearia
  Future<BarbershopModel> update(BarbershopModel barbershop) async {
    final response = await _client
        .from('barbershops')
        .update(barbershop.toJson())
        .eq('id', barbershop.id)
        .select()
        .single();

    return BarbershopModel.fromJson(response);
  }

  /// Desativa uma barbearia
  Future<void> deactivate(String id) async {
    await _client
        .from('barbershops')
        .update({'is_active': false})
        .eq('id', id);
  }

  /// Obtém barbearias do dono
  Future<List<BarbershopModel>> getByOwner(String ownerId) async {
    final response = await _client
        .from('barbershops')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BarbershopModel.fromJson(json))
        .toList();
  }

  /// Obtém a barbearia atual (baseado no AppConfig)
  Future<BarbershopModel?> getCurrent() async {
    final id = AppConfig.barbershopId;
    if (id == null || id.isEmpty) return null;
    return getById(id);
  }
}

class BarberRepository {
  final SupabaseClient _client;

  BarberRepository(this._client);

  /// Obtém um barbeiro pelo ID
  Future<BarberModel?> getById(String id) async {
    final response = await _client
        .from('barbers')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return BarberModel.fromJson(response);
  }

  /// Obtém barbeiro pelo user_id
  Future<BarberModel?> getByUserId(String userId) async {
    final response = await _client
        .from('barbers')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return BarberModel.fromJson(response);
  }

  /// Lista barbeiros de uma barbearia
  Future<List<BarberModel>> getByBarbershop(String barbershopId) async {
    final response = await _client
        .from('barbers')
        .select()
        .eq('barbershop_id', barbershopId)
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((json) => BarberModel.fromJson(json))
        .toList();
  }

  /// Lista barbeiros da barbearia atual
  Future<List<BarberModel>> getCurrentBarbershopBarbers() async {
    final barbershopId = AppConfig.barbershopId;
    if (barbershopId == null) return [];
    return getByBarbershop(barbershopId);
  }

  /// Cria um novo barbeiro
  Future<BarberModel> create(BarberModel barber) async {
    final response = await _client
        .from('barbers')
        .insert(barber.toInsertJson())
        .select()
        .single();

    return BarberModel.fromJson(response);
  }

  /// Atualiza um barbeiro
  Future<BarberModel> update(BarberModel barber) async {
    final response = await _client
        .from('barbers')
        .update(barber.toJson())
        .eq('id', barber.id)
        .select()
        .single();

    return BarberModel.fromJson(response);
  }

  /// Desativa um barbeiro
  Future<void> deactivate(String id) async {
    await _client
        .from('barbers')
        .update({'is_active': false})
        .eq('id', id);
  }

  /// Obtém o barbeiro atual (logado)
  Future<BarberModel?> getCurrentBarber() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    return getByUserId(userId);
  }
}

class ClientRepository {
  final SupabaseClient _client;

  ClientRepository(this._client);

  /// Obtém um cliente pelo ID
  Future<ClientModel?> getById(String id) async {
    final response = await _client
        .from('clients')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ClientModel.fromJson(response);
  }

  /// Obtém cliente pelo user_id
  Future<ClientModel?> getByUserId(String userId) async {
    final response = await _client
        .from('clients')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return ClientModel.fromJson(response);
  }

  /// Cria um novo cliente
  Future<ClientModel> create(ClientModel client) async {
    final response = await _client
        .from('clients')
        .insert(client.toInsertJson())
        .select()
        .single();

    return ClientModel.fromJson(response);
  }

  /// Cria ou obtém cliente para o usuário atual
  Future<ClientModel> getOrCreateForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Tenta obter cliente existente
    var client = await getByUserId(user.id);
    if (client != null) return client;

    // Cria novo cliente
    final newClient = ClientModel(
      id: '',
      userId: user.id,
      name: user.userMetadata?['full_name'] ?? 'Cliente',
      email: user.email,
      phone: user.phone,
      createdAt: DateTime.now(),
    );

    return create(newClient);
  }

  /// Atualiza um cliente
  Future<ClientModel> update(ClientModel client) async {
    final response = await _client
        .from('clients')
        .update(client.toJson())
        .eq('id', client.id)
        .select()
        .single();

    return ClientModel.fromJson(response);
  }

  /// Obtém o cliente atual (logado)
  Future<ClientModel?> getCurrentClient() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    return getByUserId(userId);
  }
}

class BarbershopClientRepository {
  final SupabaseClient _client;

  BarbershopClientRepository(this._client);

  /// Lista clientes de uma barbearia
  Future<List<BarbershopClientModel>> getByBarbershop(String barbershopId) async {
    final response = await _client
        .from('barbershop_clients')
        .select('*, clients(*)')
        .eq('barbershop_id', barbershopId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BarbershopClientModel.fromJson(json))
        .toList();
  }

  /// Lista clientes exclusivos de um barbeiro
  Future<List<BarbershopClientModel>> getExclusiveByBarber(String barberId) async {
    final response = await _client
        .from('barbershop_clients')
        .select('*, clients(*)')
        .eq('exclusive_barber_id', barberId)
        .eq('is_exclusive', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BarbershopClientModel.fromJson(json))
        .toList();
  }

  /// Vincula cliente a uma barbearia
  Future<BarbershopClientModel> linkClient({
    required String barbershopId,
    required String clientId,
    String? exclusiveBarberId,
    bool isExclusive = false,
  }) async {
    final response = await _client
        .from('barbershop_clients')
        .upsert({
          'barbershop_id': barbershopId,
          'client_id': clientId,
          'exclusive_barber_id': exclusiveBarberId,
          'is_exclusive': isExclusive,
        }, onConflict: 'barbershop_id,client_id')
        .select('*, clients(*)')
        .single();

    return BarbershopClientModel.fromJson(response);
  }

  /// Define cliente como exclusivo de um barbeiro
  Future<void> setExclusive({
    required String barbershopClientId,
    required String barberId,
    required bool isExclusive,
  }) async {
    await _client
        .from('barbershop_clients')
        .update({
          'exclusive_barber_id': isExclusive ? barberId : null,
          'is_exclusive': isExclusive,
        })
        .eq('id', barbershopClientId);
  }

  /// Atualiza pontos de fidelidade
  Future<void> updateLoyaltyPoints(String id, int points) async {
    await _client
        .from('barbershop_clients')
        .update({'loyalty_points': points})
        .eq('id', id);
  }

  /// Adiciona pontos de fidelidade
  Future<void> addLoyaltyPoints(String id, int points) async {
    await _client.rpc('increment_loyalty_points', params: {
      'client_id': id,
      'points': points,
    });
  }

  /// Atualiza estatísticas após visita
  Future<void> recordVisit({
    required String id,
    required double amountSpent,
  }) async {
    await _client
        .from('barbershop_clients')
        .update({
          'last_visit': DateTime.now().toIso8601String(),
          'total_visits': _client.rpc('increment', params: {'row_id': id, 'column': 'total_visits'}),
          'total_spent': _client.rpc('add_amount', params: {'row_id': id, 'amount': amountSpent}),
        })
        .eq('id', id);
  }
}
