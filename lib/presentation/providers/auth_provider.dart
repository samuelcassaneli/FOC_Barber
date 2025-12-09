import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/supabase_service.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(SupabaseService().client);
}

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges.map((event) => event.session?.user);
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithEmailPassword(email, password)
    );
  }

  Future<void> signUp(String email, String password, String fullName, String role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signUpWithEmailPassword(email, password, fullName, role)
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signOut()
    );
  }
}
