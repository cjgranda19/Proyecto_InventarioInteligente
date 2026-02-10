import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto/domain/entities/user.dart';
import 'package:proyecto/domain/repositories/auth_repository.dart';
import 'package:proyecto/domain/usecases/auth_usecases.dart';
import 'package:proyecto/presentation/providers/providers.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isInitialized; // Nueva bandera para saber si ya se completó la carga inicial
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isInitialized,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final Ref ref;

  AuthNotifier(this.authRepository, this.ref) : super(AuthState()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    print('\n### INICIANDO VERIFICACIÓN DE AUTENTICACIÓN ###');
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        print('✅ USUARIO ENCONTRADO:');
        print('   Email: ${user.email}');
        print('   Provider: ${user.authProvider}');
        state = state.copyWith(user: user, isInitialized: true);
      } else {
        print('❌ NO HAY USUARIO AUTENTICADO');
        state = state.copyWith(user: null, isInitialized: true);
      }
    } catch (e) {
      print('❌ ERROR EN _checkAuthState: $e');
      state = state.copyWith(user: null, isInitialized: true);
    }
    print('### FIN VERIFICACIÓN DE AUTENTICACIÓN ###\n');
  }

  Future<void> loginWithApi(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = LoginWithApiUseCase(authRepository);
      final user = await useCase.call(email, password);
      state = state.copyWith(user: user, isLoading: false);
      
      // Inicializar sincronización automática
      final syncService = ref.read(syncServiceProvider);
      syncService.initialize(user.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = LoginWithGoogleUseCase(authRepository);
      final user = await useCase.call();
      state = state.copyWith(user: user, isLoading: false);
      
      // Inicializar sincronización automática
      final syncService = ref.read(syncServiceProvider);
      syncService.initialize(user.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = LoginWithFacebookUseCase(authRepository);
      final user = await useCase.call();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginWithFirebase(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = LoginWithFirebaseUseCase(authRepository);
      final user = await useCase.call(email, password);
      state = state.copyWith(user: user, isLoading: false);
      
      // Inicializar sincronización automática
      final syncService = ref.read(syncServiceProvider);
      syncService.initialize(user.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> registerWithFirebase(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = RegisterWithFirebaseUseCase(authRepository);
      final user = await useCase.call(email, password);
      state = state.copyWith(user: user, isLoading: false);
      
      // Inicializar sincronización automática
      final syncService = ref.read(syncServiceProvider);
      syncService.initialize(user.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      // Detener sincronización automática
      final syncService = ref.read(syncServiceProvider);
      syncService.dispose();
      
      final useCase = LogoutUseCase(authRepository);
      await useCase.call();
      state = AuthState(isInitialized: true); // Mantener isInitialized en true
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Detener sincronización automática
      final syncService = ref.read(syncServiceProvider);
      syncService.dispose();
      
      final useCase = DeleteAccountUseCase(authRepository);
      await useCase.call();
      state = AuthState(isInitialized: true); // Limpiar estado después de eliminar
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow; // Re-lanzar para que la UI pueda manejarlo
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
