import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_service.dart';

// Fetch list of clients associated with the barber
final myClientsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = SupabaseService().client;
  final barberId = client.auth.currentUser!.id;

  // Fetch the relation
  final response = await client
      .from('barber_clients')
      .select('client_id')
      .eq('barber_id', barberId);
  
  if (response.isEmpty) return [];

  final clientIds = (response as List).map((e) => e['client_id']).toList();

  // Fetch actual profiles
  final profiles = await client
      .from('profiles')
      .select()
      .filter('id', 'in', clientIds)
      .order('full_name');
      
  return List<Map<String, dynamic>>.from(profiles);
});

// Fetch active subscription for a client
final clientSubscriptionProvider = FutureProvider.family.autoDispose<Map<String, dynamic>?, String>((ref, clientId) async {
  final client = SupabaseService().client;
  final response = await client
      .from('subscriptions')
      .select('*, plans(*)')
      .eq('client_id', clientId)
      .eq('active', true)
      .maybeSingle();
  
  return response;
});

// Fetch the specific barbershop the client is linked to
final myBarbershopProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = SupabaseService().client;
  final userId = client.auth.currentUser!.id;

  // Find who this client follows
  final relations = await client
      .from('barber_clients')
      .select('barber_id')
      .eq('client_id', userId);
  
  if (relations.isEmpty) return [];

  final barberIds = (relations as List).map((e) => e['barber_id']).toList();

  // Fetch barber profiles
  final response = await client
      .from('profiles')
      .select()
      .filter('id', 'in', barberIds);
  
  return List<Map<String, dynamic>>.from(response);
});

// Search Barbershops (for Client App)
final barbershopsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = SupabaseService().client;
  // Fetch profiles where role is 'barber'
  final response = await client
      .from('profiles')
      .select()
      .eq('role', 'barber');
  
  return List<Map<String, dynamic>>.from(response);
});
