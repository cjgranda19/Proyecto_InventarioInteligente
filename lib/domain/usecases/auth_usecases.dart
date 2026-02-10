import 'package:proyecto/domain/entities/user.dart';
import 'package:proyecto/domain/repositories/auth_repository.dart';

class LoginWithApiUseCase {
  final AuthRepository repository;

  LoginWithApiUseCase(this.repository);

  Future<User> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }
    return await repository.loginWithApi(email, password);
  }
}

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<User> call() async {
    return await repository.loginWithGoogle();
  }
}

class LoginWithFacebookUseCase {
  final AuthRepository repository;

  LoginWithFacebookUseCase(this.repository);

  Future<User> call() async {
    return await repository.loginWithFacebook();
  }
}

class LoginWithFirebaseUseCase {
  final AuthRepository repository;

  LoginWithFirebaseUseCase(this.repository);

  Future<User> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }
    return await repository.loginWithFirebase(email, password);
  }
}

class RegisterWithFirebaseUseCase {
  final AuthRepository repository;

  RegisterWithFirebaseUseCase(this.repository);

  Future<User> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }
    return await repository.registerWithFirebase(email, password);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}

class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call() async {
    return await repository.deleteAccount();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}
