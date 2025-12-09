import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_service.dart';

final profileProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final client = SupabaseService().client;
  final user = client.auth.currentUser;
  
  if (user == null) {
    return const Stream.empty();
  }

  // Listen to realtime changes on the profiles table for this user
  return client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((event) => event.first);
});
