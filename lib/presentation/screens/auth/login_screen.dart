import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/widgets/atoms/custom_button.dart';
import 'package:proyecto/presentation/widgets/atoms/custom_textfield.dart';
import 'package:proyecto/presentation/screens/home/home_screen.dart';
import 'package:proyecto/presentation/screens/auth/register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  int _selectedMethod = 0; // 0: API, 1: Google, 3: Firebase (Facebook deshabilitado)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_selectedMethod == 0 || _selectedMethod == 3) {
      if (!_formKey.currentState!.validate()) return;
    }

    final authNotifier = ref.read(authProvider.notifier);

    switch (_selectedMethod) {
      case 0:
        await authNotifier.loginWithApi(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        break;
      case 1:
        await authNotifier.loginWithGoogle();
        break;
      case 2:
        await authNotifier.loginWithFacebook();
        break;
      case 3:
        await authNotifier.loginWithFirebase(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        break;
    }

    final authState = ref.read(authProvider);
    if (authState.user != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Icon(
                  Icons.inventory_2,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Inventario Inteligente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Selector de método de autenticación
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMethodOption(0, 'API Externa', Icons.api),
                      _buildMethodOption(1, 'Google', Icons.g_mobiledata),
                      // Facebook deshabilitado - requiere verificación del negocio
                      // _buildMethodOption(2, 'Facebook', Icons.facebook),
                      _buildMethodOption(3, 'Firebase Email', Icons.email),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Advertencia para Google que requiere SHA-1
                if (_selectedMethod == 1) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Se sincronizarán sus datos reales de Google',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campos de email y password (solo para API y Firebase)
                if (_selectedMethod == 0 || _selectedMethod == 3) ...[
                  CustomTextField(
                    label: 'Email',
                    hint: 'ejemplo@correo.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Contraseña',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_selectedMethod == 0)
                    Text(
                      'Credenciales válidas:\nadmin@admin.com / 123123123',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Botón de login
                CustomButton(
                  text: _getLoginButtonText(),
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading,
                  icon: _getLoginButtonIcon(),
                ),

                // Link a registro (solo para Firebase Email)
                if (_selectedMethod == 3) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                ],

                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                
                // Modo offline
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implementar modo offline demo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modo offline: usa las credenciales guardadas'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.offline_bolt),
                  label: const Text('Continuar en modo offline'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodOption(int value, String title, IconData icon) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          border: Border(
            bottom: value < 3
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  String _getLoginButtonText() {
    switch (_selectedMethod) {
      case 0:
        return 'Iniciar con API';
      case 1:
        return 'Iniciar con Google';
      case 2:
        return 'Iniciar con Facebook';
      case 3:
        return 'Iniciar con Firebase';
      default:
        return 'Iniciar Sesión';
    }
  }

  IconData _getLoginButtonIcon() {
    switch (_selectedMethod) {
      case 0:
        return Icons.api;
      case 1:
        return Icons.g_mobiledata;
      case 2:
        return Icons.facebook;
      case 3:
        return Icons.email;
      default:
        return Icons.login;
    }
  }
}
