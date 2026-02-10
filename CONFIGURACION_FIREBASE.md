# Configuración de Firebase

Este archivo explica cómo configurar Firebase para el proyecto **Inventario Inteligente**.

## Archivos necesarios (NO incluidos en el repositorio)

### 1. Android: `google-services.json`

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Project Settings** > **General**
4. En la sección **Your apps**, descarga `google-services.json`
5. Coloca el archivo en: `android/app/google-services.json`

### 2. iOS: `GoogleService-Info.plist`

1. En Firebase Console, descarga `GoogleService-Info.plist`
2. Coloca el archivo en: `ios/Runner/GoogleService-Info.plist`

### 3. Dart: `firebase_options.dart`

Ejecuta el siguiente comando para generar el archivo:

```bash
flutterfire configure
```

Este comando generará automáticamente `lib/firebase_options.dart` con la configuración de tu proyecto Firebase.

### 4. Android: `key.properties`

Para firmar la app en producción, crea `android/key.properties` con:

```properties
storePassword=tu_password
keyPassword=tu_password
keyAlias=tu_alias
storeFile=ruta/a/tu/keystore.jks
```

### 5. Android: `local.properties`

Este archivo se genera automáticamente, pero si necesitas crearlo manualmente:

```properties
sdk.dir=C:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\Users\\TU_USUARIO\\flutter
```

## Autenticación configurada

El proyecto soporta 4 métodos de autenticación:

1. **API Externa** - admin@admin.com / 123123123
2. **Google Sign-In** - Requiere configurar SHA-1 en Firebase
3. **Facebook Login** - Requiere Facebook App ID
4. **Firebase Email/Password** - Habilitado en Firebase Console

## Instalación del proyecto

```bash
# Clonar el repositorio
git clone https://github.com/cjgranda19/Proyecto_InventarioInteligente.git

# Entrar al directorio
cd Proyecto_InventarioInteligente

# Instalar dependencias
flutter pub get

# Configurar Firebase
flutterfire configure

# Ejecutar la app
flutter run
```

## Requisitos

- Flutter SDK 3.9.2 o superior
- Dart 3.0.0 o superior
- Android Studio / Xcode
- Cuenta de Firebase activa

## Soporte

Para más información, contacta al equipo de desarrollo:
- Carlos Granda
- Steven Molina
- Daniela Tituaña
