import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signInWithEmailPassword(String email, String password);
  Future<AuthResponse> signUpWithEmailPassword(String email, String password, String fullName, String role);
  Future<void> signOut();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
}
