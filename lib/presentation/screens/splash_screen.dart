import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/providers.dart';
import 'package:proyecto/presentation/screens/auth/login_screen.dart';
import 'package:proyecto/presentation/screens/home/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Esperar un mínimo de 1.5 segundos para el splash (reducido)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    // Esperar a que se complete la verificación de autenticación
    int attempts = 0;
    while (!ref.read(authProvider).isInitialized && attempts < 20) {
      print('⏳ Esperando inicialización... intento ${attempts + 1}');
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
      if (!mounted) return;
    }
    
    final user = ref.read(currentUserProvider);
    
    // Inicializar sincronización automática si hay un usuario logueado
    if (user != null) {
      print('👤 Usuario logueado detectado: ${user.email}');
      print('🔄 Inicializando sincronización automática...');
      try {
        final syncService = ref.read(syncServiceProvider);
        syncService.initialize(user.id);
      } catch (e) {
        print('⚠️ Error al inicializar sincronización: $e');
      }
    } else {
      print('🚪 No hay usuario logueado, redirigiendo a login');
    }
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'Inventario Inteligente',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Organiza tus objetos con IA',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
