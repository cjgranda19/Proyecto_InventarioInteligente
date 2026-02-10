import 'package:proyecto/domain/entities/user.dart';
import 'package:proyecto/domain/repositories/auth_repository.dart';
import 'package:proyecto/data/datasources/local/local_user_datasource.dart';
import 'package:proyecto/data/datasources/remote/remote_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource remoteDataSource;
  final LocalUserDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> loginWithApi(String email, String password) async {
    try {
      final user = await remoteDataSource.loginWithApi(email, password);
      await localDataSource.saveUser(user);
      await localDataSource.updateLastLogin(user.id, DateTime.now());
      return user;
    } catch (e) {
      // Try to get from local if offline
      final localUser = await localDataSource.getUserByEmail(email);
      if (localUser != null) {
        await localDataSource.updateLastLogin(localUser.id, DateTime.now());
        return localUser;
      }
      rethrow;
    }
  }

  @override
  Future<User> loginWithGoogle() async {
    final user = await remoteDataSource.loginWithGoogle();
    await localDataSource.saveUser(user);
    await localDataSource.updateLastLogin(user.id, DateTime.now());
    return user;
  }

  @override
  Future<User> loginWithFacebook() async {
    final user = await remoteDataSource.loginWithFacebook();
    await localDataSource.saveUser(user);
    await localDataSource.updateLastLogin(user.id, DateTime.now());
    return user;
  }

  @override
  Future<User> loginWithFirebase(String email, String password) async {
    final user = await remoteDataSource.loginWithFirebase(email, password);
    await localDataSource.saveUser(user);    await localDataSource.updateLastLogin(user.id, DateTime.now());    await localDataSource.updateLastLogin(user.id, DateTime.now());
    return user;
  }

  @override
  Future<User> registerWithFirebase(String email, String password) async {
    final user = await remoteDataSource.registerWithFirebase(email, password);
    await localDataSource.saveUser(user);
    await localDataSource.updateLastLogin(user.id, DateTime.now());
    return user;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await localDataSource.clearAllUsers();
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final currentUser = await remoteDataSource.getCurrentUser();
      if (currentUser != null) {
        // Eliminar cuenta en Firebase/remoto primero
        await remoteDataSource.deleteAccount();
      }
      // Limpiar todos los usuarios locales
      await localDataSource.clearAllUsers();
    } catch (e) {
      // Limpiar local incluso si falla Firebase
      await localDataSource.clearAllUsers();
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    User? foundUser;
    
    print('\n=== INICIO getCurrentUser ===');
    
    // 1. Primero intentar obtener de LOCAL (más rápido y confiable)
    try {
      print('💾 [1/2] Buscando usuario en base de datos local...');
      final localUser = await localDataSource.getLastLoggedInUser();
      if (localUser != null) {
        print('✅ Usuario encontrado en LOCAL:');
        print('   - Email: ${localUser.email}');
        print('   - ID: ${localUser.id}');
        print('   - Provider: ${localUser.authProvider}');
        foundUser = localUser;
        
        // Retornar inmediatamente el usuario local
        print('=== FIN getCurrentUser: EXITO (LOCAL) ===\n');
        return foundUser;
      } else {
        print('❌ No se encontró ningún usuario en local');
      }
    } catch (e) {
      print('❌ Error al obtener usuario local: $e');
    }
    
    // 2. Si no hay en local, intentar Firebase (con timeout corto)
    try {
      print('🔍 [2/2] Intentando obtener usuario de Firebase...');
      final remoteUser = await remoteDataSource.getCurrentUser().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('⏱️ Timeout al conectar con Firebase (3s)');
          return null;
        },
      );
      
      if (remoteUser != null) {
        print('✅ Usuario obtenido de Firebase: ${remoteUser.email}');
        foundUser = remoteUser;
        
        // Guardar en local para la próxima vez
        try {
          await localDataSource.saveUser(remoteUser);
          await localDataSource.updateLastLogin(remoteUser.id, DateTime.now());
          print('💾 Usuario guardado en local');
        } catch (e) {
          print('⚠️ Error al guardar usuario en local: $e');
        }
        
        print('=== FIN getCurrentUser: EXITO (FIREBASE) ===\n');
        return foundUser;
      } else {
        print('❌ Firebase no tiene usuario autenticado');
      }
    } catch (e) {
      print('⚠️ Error al obtener usuario de Firebase: $e');
    }
    
    print('🚫 No hay usuario autenticado (ni local ni Firebase)');
    print('=== FIN getCurrentUser: SIN USUARIO ===\n');
    return null;
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }
}
