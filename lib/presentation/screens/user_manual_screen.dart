import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de Usuario'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Inicio de Sesión',
            'La aplicación ofrece 4 métodos de autenticación:\n\n'
            '1. API Externa (admin@admin.com / 123123123)\n'
            '2. Google Sign-In\n'
            '3. Facebook Login\n'
            '4. Firebase Email/Password\n\n'
            'Selecciona tu método preferido y sigue las instrucciones en pantalla.',
            Icons.login,
          ),
          _buildSection(
            context,
            'Gestión de Inventario',
            'Agrega items a tu inventario:\n\n'
            'NUEVO: Detección Automática con IA\n'
            '1. Presiona el botón + en la pantalla de Inventario\n'
            '2. Toma una foto o selecciona de la galería\n'
            '3. ¡La IA detectará automáticamente el producto!\n'
            '4. La IA sugerirá el nombre y la categoría\n'
            '5. Puedes aceptar las sugerencias o modificarlas\n'
            '6. Guarda el item\n\n'
            'Editar: Toca un item para editarlo\n'
            'Eliminar: Mantén presionado un item y selecciona "Eliminar"',
            Icons.inventory_2,
          ),
          _buildSection(
            context,
            'Categorías',
            'Organiza tus items en categorías:\n\n'
            '1. Ve a la pestaña Categorías\n'
            '2. Presiona el botón + para crear una nueva\n'
            '3. Asigna nombre, descripción, icono y color\n'
            '4. Guarda la categoría\n\n'
            'Las categorías te ayudan a filtrar y organizar tus items.',
            Icons.category,
          ),
          _buildSection(
            context,
            'Búsqueda y Filtros',
            'Encuentra items rápidamente:\n\n'
            '1. Usa la barra de búsqueda en Inventario\n'
            '2. Escribe el nombre, descripción o ubicación\n'
            '3. Los resultados se filtran en tiempo real\n\n'
            'También puedes filtrar por categoría, fecha de vencimiento o ubicación.',
            Icons.search,
          ),
          _buildSection(
            context,
            'Cámara y Fotos',
            'Captura fotos de tus items:\n\n'
            '1. Al agregar/editar un item, toca el área de imagen\n'
            '2. Selecciona Cámara para tomar una foto nueva\n'
            '3. O selecciona Galería para usar una existente\n'
            '4. La foto se guarda localmente y se sube a la nube\n\n'
            'Las fotos ayudan a identificar items visualmente.',
            Icons.camera_alt,
          ),
          _buildSection(
            context,
            'Ubicaciones con GPS',
            'Guarda la ubicación de tus items:\n\n'
            '1. Al agregar un item, completa el campo Ubicación\n'
            '2. Puedes escribir la ubicación manualmente\n'
            '3. O usa el GPS para guardar coordenadas\n\n'
            'Útil para recordar dónde guardaste cada cosa.',
            Icons.location_on,
          ),
          _buildSection(
            context,
            'Sincronización',
            'Mantén tus datos actualizados:\n\n'
            '1. La app se sincroniza automáticamente con internet\n'
            '2. Puedes forzar sincronización con el botón 🔄\n'
            '3. Funciona completamente offline\n'
            '4. Los cambios offline se suben al reconectar\n\n'
            'Tus datos están seguros en la nube.',
            Icons.sync,
          ),
          _buildSection(
            context,
            'Exportar a PDF',
            'Crea reportes de tu inventario:\n\n'
            '1. Ve a la pantalla de Inventario\n'
            '2. Presiona el ícono de PDF en el AppBar\n'
            '3. El PDF se genera con todos tus items\n'
            '4. Se guarda en la carpeta de documentos\n\n'
            'Útil para compartir o imprimir tu inventario.',
            Icons.picture_as_pdf,
          ),
          _buildSection(
            context,
            'Notificaciones',
            'Recibe alertas importantes:\n\n'
            '1. Items próximos a vencer\n'
            '2. Recordatorios de mantenimiento\n'
            '3. Confirmaciones de sincronización\n\n'
            'Configura las notificaciones en Ajustes.',
            Icons.notifications,
          ),
          _buildSection(
            context,
            'Estadísticas',
            'Visualiza información sobre tu inventario:\n\n'
            '1. Total de items\n'
            '2. Número de categorías\n'
            '3. Items por vencer\n'
            '4. Estado de sincronización\n\n'
            'Mantente informado sobre tu inventario.',
            Icons.bar_chart,
          ),
          _buildSection(
            context,
            'Modo Oscuro',
            'La app se adapta a tus preferencias:\n\n'
            '1. Sigue automáticamente el tema del sistema\n'
            '2. Cambia entre modo claro y oscuro\n'
            '3. Cuida tus ojos en ambientes con poca luz\n\n'
            'Configuración en Ajustes (próximamente).',
            Icons.dark_mode,
          ),
          _buildSection(
            context,
            'Seguridad',
            'Tus datos están protegidos:\n\n'
            '1. Autenticación segura con Firebase\n'
            '2. Datos encriptados en la nube\n'
            '3. Solo tú puedes acceder a tu inventario\n'
            '4. Backup automático en Firebase\n\n'
            'Tu privacidad es nuestra prioridad.',
            Icons.security,
          ),
          _buildSection(
            context,
            'Consejos y Tips',
            '• Sincroniza regularmente para evitar pérdida de datos\n'
            '• Toma fotos claras y bien iluminadas\n'
            '• Usa categorías para organizar mejor\n'
            '• Agrega ubicaciones para encontrar items rápido\n'
            '• Configura fechas de vencimiento para recordatorios\n'
            '• Exporta a PDF periódicamente como respaldo\n'
            '• Revisa las estadísticas para mantener control',
            Icons.tips_and_updates,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Necesitas más ayuda?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Visita nuestra sección de Preguntas Frecuentes o contacta con soporte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: 'cgranda.567@gmail.com'),
                    );
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copiado al portapapeles: cgranda.567@gmail.com'),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contactar Soporte'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
