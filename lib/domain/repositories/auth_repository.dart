import 'package:proyecto/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> loginWithApi(String email, String password);
  Future<User> loginWithGoogle();
  Future<User> loginWithFacebook();
  Future<User> loginWithFirebase(String email, String password);
  Future<User> registerWithFirebase(String email, String password);
  Future<void> logout();
  Future<void> deleteAccount();
  Future<User?> getCurrentUser();
  Stream<User?> get authStateChanges;
}
