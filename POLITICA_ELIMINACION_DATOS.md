# Política de Eliminación de Datos - Inventario Inteligente

## 📋 Información General

Esta app cumple con las regulaciones de privacidad (GDPR, CCPA) al proporcionar una forma clara y fácil de eliminar tu cuenta y todos tus datos.

---

## 🗑️ Cómo Eliminar tu Cuenta y Datos

### Paso 1: Abre la aplicación
Inicia sesión en tu cuenta de Inventario Inteligente

### Paso 2: Accede a tu perfil
Toca el icono de **Perfil** ubicado en la barra de navegación inferior

### Paso 3: Desplázate hacia abajo
Busca el botón rojo que dice **"Eliminar mi cuenta y datos"**

### Paso 4: Lee la advertencia
Se mostrará un diálogo explicando que esta acción es **IRREVERSIBLE**

### Paso 5: Confirma la eliminación
Toca **"Sí, Eliminar Todo"** para confirmar

### Paso 6: Espera la confirmación
La app eliminará todos tus datos y te redirigirá a la pantalla de inicio de sesión

---

## ✅ Qué se elimina cuando borras tu cuenta

Al eliminar tu cuenta, se borran **TODOS** tus datos:

### 🔐 Datos de autenticación
- ✓ Tu cuenta de usuario en Firebase Authentication
- ✓ Información de login (Google, Email/Password)
- ✓ Tokens de acceso

### 📦 Datos del inventario
- ✓ Todos los items de tu inventario
- ✓ Categorías creadas
- ✓ Fotos de productos
- ✓ Descripciones y detalles

### 💾 Datos locales
- ✓ Base de datos local (SQLite)
- ✓ Caché de imágenes
- ✓ Preferencias guardadas

### ☁️ Datos en la nube
- ✓ Documentos en Firestore
- ✓ Imágenes en Firebase Storage
- ✓ Sincronización eliminada

---

## ⏱️ Tiempo de procesamiento

- **Inmediato**: Los datos se eliminan al instante
- **Irreversible**: No hay período de gracia o recuperación
- **Permanente**: Los datos no se pueden restaurar

---

## ⚠️ Advertencias Importantes

### 🚫 Esta acción es IRREVERSIBLE
Una vez que confirmes, **no hay forma de recuperar tus datos**. Asegúrate de que realmente quieres eliminar tu cuenta.

### 📱 Si tienes múltiples dispositivos
La eliminación se sincroniza en todos tus dispositivos. Si tienes la app abierta en otro dispositivo, se cerrará la sesión automáticamente.

### 🔄 Si quieres volver
Puedes crear una nueva cuenta en cualquier momento, pero empezarás **desde cero** sin ningún dato previo.

---

## 🔒 Seguridad

### Re-autenticación requerida
Si tu sesión es antigua, Firebase puede pedirte que vuelvas a iniciar sesión antes de eliminar tu cuenta. Esto es una medida de seguridad para evitar eliminaciones no autorizadas.

### Mensaje de error común
```
"Por seguridad, debes volver a iniciar sesión antes de eliminar tu cuenta"
```

**Solución**: 
1. Cierra sesión
2. Vuelve a iniciar sesión
3. Intenta eliminar la cuenta nuevamente

---

## 📞 Soporte

Si tienes problemas para eliminar tu cuenta:

1. **Verifica tu conexión a internet**: La eliminación requiere conexión
2. **Re-inicia sesión**: Cierra e inicia sesión nuevamente
3. **Contacta al soporte**: Si el problema persiste

---

## 🌍 Cumplimiento Legal

Esta funcionalidad cumple con:

- ✅ **GDPR** (Reglamento General de Protección de Datos - UE)
- ✅ **CCPA** (Ley de Privacidad del Consumidor de California - USA)
- ✅ **LGPD** (Lei Geral de Proteção de Dados - Brasil)

Derechos garantizados:
- Derecho al olvido
- Derecho a la eliminación de datos
- Derecho a la portabilidad (exporta tus datos antes de eliminar)

---

## 📝 Alternativas a la Eliminación

### ¿Solo quieres desconectarte temporalmente?
Usa **"Cerrar Sesión"** en lugar de eliminar tu cuenta. Así conservas tus datos y puedes volver cuando quieras.

### ¿Quieres exportar tus datos antes?
Por ahora, la app no tiene función de exportación automática. Si necesitas tus datos:
1. Toma capturas de pantalla de tu inventario
2. Descarga las fotos importantes
3. Luego elimina la cuenta

---

## 📊 Qué NO se elimina

La app **NO comparte** tus datos con terceros, por lo que no hay datos que eliminar fuera de:
- Firebase Authentication
- Firebase Firestore
- Firebase Storage

**Nota**: Los logs anónimos de errores (Crashlytics) no contienen información personal identificable.

---

## ✨ Resumen

| Acción | Resultado |
|--------|-----------|
| Eliminar cuenta | Se borran TODOS los datos permanentemente |
| Cerrar sesión | Los datos se conservan, puedes volver |
| Re-instalar app | Si no eliminaste la cuenta, tus datos están ahí |

---

## 🆘 Eliminación accidental

Si eliminaste tu cuenta por error:
- ❌ **No es posible recuperar los datos**
- ✅ **Puedes crear una nueva cuenta**
- ℹ️ **Empezarás desde cero**

**Consejo**: Antes de eliminar, asegúrate de que realmente quieres hacerlo.

---

*Última actualización: Enero 2026*
