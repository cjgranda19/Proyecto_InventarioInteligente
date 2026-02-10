# Inventario Inteligente con Reconocimiento de Fotos

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0.0-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

> ⚠️ **Nota**: Este repositorio NO incluye archivos de configuración sensibles. Lee [CONFIGURACION_FIREBASE.md](CONFIGURACION_FIREBASE.md) para configurar el proyecto.

## Descripción del Proyecto

Aplicación móvil de gestión de inventario que permite organizar objetos de la casa (ropa, libros, herramientas) con fotos, categorías y reconocimiento opcional mediante IA. La aplicación funciona completamente offline y sincroniza datos con la nube cuando hay conexión.

## Características Principales

### ✅ Requerimientos Cumplidos

#### 1. Arquitectura y Diseño
- ✅ **Clean Architecture completa** (data/domain/presentation)
- ✅ **Atomic Design** aplicado a toda la interfaz
- ✅ **Manejo profesional de estado** con Riverpod
- ✅ **Temas claro/oscuro** opcionales
- ✅ **Animaciones** básicas en navegación y carga

#### 2. Funcionamiento Offline/Online (OBLIGATORIO)
- ✅ Funciona completamente sin internet
- ✅ Almacenamiento local con SQLite
- ✅ Sistema de sincronización automática con la nube
- ✅ Caché + persistencia de datos críticos

#### 3. Autenticación (OBLIGATORIA, 4 métodos)
1. ✅ **API Externa**: admin@admin.com / 123123123
2. ✅ **Google Sign-In**
3. ✅ **Facebook Login**
4. ✅ **Firebase Authentication** (email/password)

#### 4. Sincronización con la Nube
- ✅ Firebase Firestore para almacenamiento
- ✅ Subida automática de datos locales
- ✅ Resolución de conflictos (último guardado prevalece)

#### 5. Notificaciones
- ✅ Notificaciones locales (recordatorios, alertas)
- ✅ Push notifications con Firebase Cloud Messaging

#### 6. Módulos Visuales
- ✅ Listas dinámicas de items
- ✅ Grids de visualización
- ✅ Menú de navegación inferior
- ✅ Pantallas detalladas
- ✅ Búsqueda avanzada
- ✅ Filtros por categoría, ubicación, fecha

#### 7. Sensores y Funcionalidades del Dispositivo
- ✅ **Cámara**: Para capturar fotos de items
- ✅ **GPS**: Para geolocalizar items
- ✅ **Acelerómetro**: Detección de movimiento
- ✅ **Almacenamiento**: Gestión de archivos e imágenes

#### 8. Características Específicas del Proyecto
- ✅ CRUD completo de categorías
- ✅ CRUD completo de items con fotos
- ✅ Categorización automática con IA (preparado)
- ✅ OCR para leer texto de etiquetas (preparado)
- ✅ Modo offline completo
- ✅ Sincronización con nube
- ✅ Búsqueda avanzada
- ✅ Notificaciones de vencimientos
- ✅ **Exportar inventario a PDF**
- ✅ Mapeo interno para ubicación de objetos

## Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/          # Constantes de la aplicación
│   ├── errors/            # Manejo de errores
│   ├── network/           # Gestión de conectividad
│   └── theme/             # Temas claro/oscuro
├── data/
│   ├── datasources/
│   │   ├── local/        # SQLite, SharedPreferences
│   │   └── remote/       # Firebase, API
│   └── repositories/     # Implementación de repositorios
├── domain/
│   ├── entities/         # Modelos de negocio
│   ├── repositories/     # Contratos de repositorios
│   └── usecases/        # Casos de uso
└── presentation/
    ├── providers/       # Riverpod providers
    ├── screens/         # Pantallas de la app
    └── widgets/         # Componentes reutilizables
        ├── atoms/       # Componentes básicos
        ├── molecules/   # Componentes intermedios
        └── organisms/   # Componentes complejos
```

## Tecnologías Utilizadas

### Framework y Lenguaje
- Flutter 3.9+
- Dart 3.0+

### Gestión de Estado
- Riverpod 2.5+

### Base de Datos
- SQLite (local)
- Firebase Firestore (nube)

### Autenticación
- Firebase Auth
- Google Sign-In
- Facebook Auth
- API REST personalizada

### Funcionalidades
- Image Picker (Cámara y Galería)
- Google ML Kit (OCR y reconocimiento)
- Geolocator (GPS)
- Sensors Plus (Acelerómetro)
- PDF Generation
- Flutter Local Notifications
- Firebase Cloud Messaging

## Instalación y Configuración

### 1. Clonar el repositorio
```bash
git clone [URL_DEL_REPOSITORIO]
cd proyecto
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar Firebase
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase
flutterfire configure
```

### 4. Configurar autenticación de Google
1. Ir a Firebase Console
2. Habilitar Google Sign-In en Authentication
3. Descargar `google-services.json` para Android
4. Colocar en `android/app/`

### 5. Configurar autenticación de Facebook
1. Crear app en Facebook Developers
2. Agregar Facebook App ID en `AndroidManifest.xml`
3. Configurar en Firebase Console

### 6. Ejecutar la aplicación
```bash
flutter run
```

## Credenciales de Prueba

### API Externa
- **Email**: admin@admin.com
- **Password**: 123123123

### Firebase (crear tu propia cuenta)
- Registro libre con cualquier email

## Características Técnicas

### Clean Architecture
El proyecto sigue los principios de Clean Architecture con tres capas principales:

1. **Domain**: Entidades y lógica de negocio
2. **Data**: Implementación de repositorios y fuentes de datos
3. **Presentation**: UI y gestión de estado

### Atomic Design
Los componentes UI están organizados según Atomic Design:

- **Átomos**: Botones, campos de texto, iconos
- **Moléculas**: Tarjetas de items, formularios
- **Organismos**: Listas completas, grids
- **Plantillas**: Layouts de pantallas
- **Páginas**: Pantallas completas con lógica

### Offline First
La aplicación está diseñada para funcionar sin conexión:

1. Todos los datos se guardan localmente primero
2. Las operaciones se marcan como "no sincronizadas"
3. Cuando hay conexión, se sincronizan automáticamente
4. Los conflictos se resuelven con "último gana"

## Pantallas Principales

### 1. Login
- 4 métodos de autenticación
- Validación de formularios
- Modo offline

### 2. Home / Inventario
- Lista/Grid de items
- Búsqueda en tiempo real
- Filtros avanzados
- Exportación a PDF

### 3. Categorías
- CRUD completo
- Iconos y colores personalizados
- Contador de items por categoría

### 4. Agregar/Editar Item
- Formulario completo
- Captura de fotos
- Selector de categoría
- Geolocalización
- OCR de etiquetas

### 5. Perfil
- Información del usuario
- Configuraciones
- Manual de usuario
- Cerrar sesión

### 6. Estadísticas
- Total de items
- Items por categoría
- Items próximos a vencer
- Estado de sincronización

## Próximas Funcionalidades

- [x] Reconocimiento automático de objetos con IA
- [ ] Compartir inventarios entre usuarios
- [ ] Códigos QR para items
- [x] Reportes personalizados
- [ ] Modo oscuro automático
- [ ] Widgets para pantalla de inicio
- [ ] Backup y restauración completa

## Manual de Usuario

(Ver pantalla de "Manual de Usuario" en la app)

## Manual de Desarrollo

### Agregar una nueva pantalla
1. Crear en `lib/presentation/screens/`
2. Definir rutas en el router
3. Conectar con providers si es necesario

### Agregar una nueva entidad
1. Crear en `lib/domain/entities/`
2. Crear repositorio en `lib/domain/repositories/`
3. Implementar en `lib/data/repositories/`
4. Crear use cases en `lib/domain/usecases/`

### Agregar sincronización
1. Marcar campos como `isSynced`
2. Implementar en el repositorio
3. Llamar al método sync cuando haya conexión

## Testing

```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Tests de widgets
flutter test test/widget_test.dart
```

## Publicación en Google Play

### 1. Generar keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configurar key.properties
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

### 3. Build release
```bash
flutter build appbundle
```

### 4. Subir a Play Console
1. Crear app en Play Console
2. Subir el AAB
3. Completar ficha de la tienda
4. Agregar capturas de pantalla
5. Crear política de privacidad
6. Publicar

## Política de Privacidad

La aplicación recopila y almacena:
- Datos de autenticación (email, nombre)
- Fotos de items (almacenadas localmente y en Firebase)
- Ubicación de items (opcional)
- Datos de uso para mejorar la experiencia

Los datos se almacenan de forma segura y solo son accesibles por el usuario.

## Licencia

MIT License - Ver archivo LICENSE para más detalles

## Contacto y Soporte

Para reportar bugs o solicitar características:
- Issues en GitHub
- Email: cgranda.567@gmail.com

## Créditos

Desarrollado como proyecto final para el curso de Desarrollo Móvil.

---

**Versión**: 1.0.0
**Última actualización**: Enero 2026
