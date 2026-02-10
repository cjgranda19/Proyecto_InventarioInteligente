import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:proyecto/core/constants/app_constants.dart';
import 'package:proyecto/domain/entities/user.dart';

class RemoteAuthDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;
  final http.Client httpClient;

  RemoteAuthDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.facebookAuth,
    required this.httpClient,
  });

  Future<User> loginWithApi(String email, String password) async {
    final url = '${AppConstants.baseApiUrl}${AppConstants.validationEndpoint}/$email/$password';
    
    final response = await httpClient.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Check if login is valid
      if (data['valid'] == true || data['success'] == true || 
          (email == AppConstants.validEmail && password == AppConstants.validPassword)) {
        
        // Crear sesión en Firebase para poder usar Firestore
        print('🔐 Autenticando en Firebase para usuario API...');
        String firebaseUserId;
        
        try {
          // Intentar crear/autenticar usuario en Firebase con el email de la API
          // Esto permite que los datos se guarden en Firestore
          final emailForFirebase = email.replaceAll('@', '_at_').replaceAll('.', '_dot_');
          final passwordForFirebase = 'api_user_${email.hashCode}'; // Password único basado en el email
          
          try {
            // Intentar login primero
            final firebaseUser = await firebaseAuth.signInWithEmailAndPassword(
              email: '$emailForFirebase@api.local',
              password: passwordForFirebase,
            );
            firebaseUserId = firebaseUser.user!.uid;
            print('✅ Usuario Firebase existente: $firebaseUserId');
          } catch (e) {
            // Si no existe, crearlo
            print('📝 Creando nuevo usuario en Firebase...');
            final firebaseUser = await firebaseAuth.createUserWithEmailAndPassword(
              email: '$emailForFirebase@api.local',
              password: passwordForFirebase,
            );
            firebaseUserId = firebaseUser.user!.uid;
            print('✅ Usuario Firebase creado: $firebaseUserId');
          }
        } catch (e) {
          print('⚠️ Error al autenticar en Firebase: $e');
          // Fallback a sesión anónima
          final firebaseUser = await firebaseAuth.signInAnonymously();
          firebaseUserId = firebaseUser.user!.uid;
          print('✅ Usando sesión anónima: $firebaseUserId');
        }
        
        return User(
          id: firebaseUserId, // Usar el UID de Firebase en lugar del hash
          email: email,
          displayName: data['name'] ?? 'Usuario API',
          authProvider: 'api',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
      } else {
        throw Exception('Credenciales inválidas');
      }
    } else {
      throw Exception('Error en la autenticación: ${response.statusCode}');
    }
  }

  Future<User> loginWithGoogle() async {
    try {
      // Primero cerrar sesión para asegurar que se muestre el selector de cuenta
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Inicio de sesión con Google cancelado');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Validar que tenemos los tokens necesarios
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Error: No se obtuvieron los tokens de Google. Verifica la configuración de SHA-1 en Firebase Console.');
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Error al iniciar sesión con Google');
      }

      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: 'google',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error en loginWithGoogle: $e');
      rethrow;
    }
  }

  Future<User> loginWithFacebook() async {
    try {
      final LoginResult result = await facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        throw Exception('Inicio de sesión con Facebook cancelado');
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw Exception('Error al iniciar sesión con Facebook: ${result.message ?? "Desconocido"}');
      }

      final credential = firebase_auth.FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Error al iniciar sesión con Facebook');
      }

      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: 'facebook',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error en loginWithFacebook: $e');
      rethrow;
    }
  }

  Future<User> loginWithFirebase(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Error al iniciar sesión con Firebase');
    }

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      authProvider: 'firebase',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Future<User> registerWithFirebase(String email, String password) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Error al registrar usuario en Firebase');
    }

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      authProvider: 'firebase',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Future<void> logout() async {
    await Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(),
      facebookAuth.logOut(),
    ]);
  }

  Future<void> deleteAccount() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        // Eliminar la cuenta de Firebase Authentication
        await firebaseUser.delete();
        print('✅ Cuenta eliminada de Firebase Auth');
      } catch (e) {
        print('❌ Error al eliminar cuenta de Firebase: $e');
        // Si el error es por requiere re-autenticación, lo propagamos
        if (e.toString().contains('requires-recent-login')) {
          throw Exception('Por seguridad, debes volver a iniciar sesión antes de eliminar tu cuenta');
        }
        rethrow;
      }
    }
    
    // Cerrar sesión en todos los proveedores
    await Future.wait([
      googleSignIn.signOut(),
      facebookAuth.logOut(),
    ]);
  }

  Future<User?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      authProvider: 'firebase',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Stream<User?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;

      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: 'firebase',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    });
  }
}
