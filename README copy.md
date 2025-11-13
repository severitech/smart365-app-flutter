**Prueba_b — Integración FCM (Backend + Flutter)**

Versión: 1.0

Propósito
--------
Este documento describe, paso a paso y con ejemplos concretos, cómo integrar la app Flutter con el backend Django para: autenticación, registro/upsert de tokens FCM (Android), manejo de refresh y logout, envío de notificaciones (admin) y despliegue seguro en producción (Railway). Está pensado para el equipo móvil y backend — redactado desde la perspectiva de un desarrollador senior.

Contenido rápido
-----------------
- Endpoints backend disponibles
- Modelo `FCMDevice` (DB)
- Flujo recomendado en Flutter (registro, refresh, unregister)
- Ejemplos de código Flutter (Dart)
- Pruebas locales y en producción (SIMULAR_FCM, Railway)
- Buenas prácticas de seguridad y despliegue

1) Endpoints (backend)
------------------------
Nota: las rutas están registradas en `tienda/urls.py`. Ajusta el prefijo si tu `config/urls.py` monta `tienda` bajo `/api/`.

- POST /devices/register/
  - Propósito: registrar o actualizar (upsert) un token FCM para el usuario autenticado.
  - Auth: TokenAuthentication (header `Authorization: Token <KEY>`).
  - Payload (JSON):
    {
      "registration_id": "TOKEN_FCM",
      "tipo_dispositivo": "android"
    }
  - Respuesta: objeto `FCMDevice` creado/actualizado (200/201).

- POST /devices/unregister/ (recomendado — si no existe, pedir al backend que lo añada)
  - Propósito: desactivar token al hacer logout.
  - Auth: TokenAuthentication
  - Payload: {"registration_id": "TOKEN_FCM"}

- GET /admin/devices/
  - Propósito: listar dispositivos (solo admin/staff)
  - Auth: IsAdminUser

- POST /admin/send-notification/
  - Propósito: enviar notificaciones desde admin o un job seguro.
  - Auth: IsAdminUser
  - Payload (ejemplo):
    {
      "title": "Título",
      "body": "Cuerpo del mensaje",
      "broadcast": true
    }
  - Alternativas: filtrar por `user_ids` o `device_ids`.

2) Modelo de datos (resumen)
----------------------------
- `FCMDevice` (tabla en `tienda/models.py`)
  - Campos principales: `usuario` (FK opcional a `authz.Usuario`), `registration_id` (unique), `tipo_dispositivo` (android/ios/web), `activo` (bool), timestamps.
  - Comportamiento: `registration_id` es único — al registrar hacemos `update_or_create`.
  - Limpieza: la función de envío marca `activo=False` cuando FCM reporta token no registrado.

3) Flujo recomendado en Flutter
------------------------------
1. Al iniciar la app e iniciar Firebase, pide permiso (según Android no es obligatorio para notificaciones básicas) y obtén el token:
   - `String? token = await FirebaseMessaging.instance.getToken();`
2. Si el usuario está autenticado, envía este token al backend usando `POST /devices/register/` con el header `Authorization: Token <USER_TOKEN>`.
3. Escucha `FirebaseMessaging.instance.onTokenRefresh` y vuelve a enviar el nuevo token al backend.
4. Al hacer logout del usuario: llama `POST /devices/unregister/` con el `registration_id` para desactivarlo.
5. En la app maneja `FirebaseMessaging.onMessage` (foreground), `onMessageOpenedApp` (cuando el usuario abre desde la notificación) y el background handler si necesitas lógica en background.

4) Ejemplo completo en Flutter (Dart)
-----------------------------------
Dependencias mínimas en `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.0.0
  firebase_messaging: ^14.0.0
  http: ^0.13.0
```

Código (simplificado):
```dart
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class PushService {
  final String backendBase; // e.g. http://10.0.2.2:8000 or https://api.tu-dominio
  final String authToken; // TokenAuth del usuario

  PushService(this.backendBase, this.authToken);

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token != null) await _sendTokenToBackend(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _sendTokenToBackend(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      print('Foreground message: ${m.notification?.title}');
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    final url = Uri.parse('\$backendBase/devices/register/');
    final resp = await http.post(url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token '
            '\$authToken',
      },
      body: jsonEncode({'registration_id': token, 'tipo_dispositivo': 'android'}),
    );
    if (resp.statusCode >= 400) print('Failed to register token: \\${resp.body}');
  }

  Future<void> unregister(String token) async {
    final url = Uri.parse('\$backendBase/devices/unregister/');
    await http.post(url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Token '
        '\$authToken'},
      body: jsonEncode({'registration_id': token}),
    );
  }
}
```

Notas Flutter:
- Emulador Android (AVD): usa `10.0.2.2` como host si tu backend corre en localhost.
- Dispositivo físico: usa la IP de la máquina donde corre el backend (ej. `http://192.168.1.42:8000`).
- Asegúrate de incluir `google-services.json` en `android/app/` y configurar Firebase correctamente.

5) Pruebas locales y controladas
--------------------------------
- Modo simulado (no envía a FCM): exporta la variable de entorno `SIMULAR_FCM=1` en el servidor antes de ejecutar el backend. `core.notifications` detecta esta variable y devuelve respuestas simuladas.
- Scripts útiles incluidos en repo:
  - `scripts/test_firebase.py` — verifica que `iniciar_firebase()` inicializa la app con las credenciales.
  - `scripts/test_send_push.py` — llama a `enviar_tokens_push` en modo simulado (usa `SIMULAR_FCM=1`).

Comandos PowerShell (local):
```powershell
& '.\venv\Scripts\Activate.ps1'
#$env:FIREBASE_CREDENTIALS_BASE64 = Get-Content .\firebase_b64.txt -Raw  # opcional
python scripts/test_firebase.py
#$env:SIMULAR_FCM='1'
python scripts/test_send_push.py
Remove-Item Env:\SIMULAR_FCM
```

6) Producción — Railway (FIREBASE_CREDENTIALS_BASE64)
---------------------------------------------------
1. Codifica tu JSON de Service Account a Base64 (ya se proporcionó `firebase_b64.txt`):
   - PowerShell: `$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes('smart365b-firebase-adminsdk-...json'))`
2. En Railway > Project > Variables: crea variable `FIREBASE_CREDENTIALS_BASE64` con el valor Base64 (marcar secret).
3. Añade también `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `GROQ_API_KEY` como secrets.
4. Railway arrancará/redeployará la app y tu backend podrá inicializar Firebase.

Verificación en Railway (CLI):
```powershell
# leer el base64 desde el fichero local
$val = Get-Content .\firebase_b64.txt -Raw
railway variables set FIREBASE_CREDENTIALS_BASE64 $val
railway variables set STRIPE_SECRET_KEY "sk_test_..."
railway run python scripts/test_firebase.py
```

7) Seguridad y buenas prácticas
--------------------------------
- NO subir el JSON ni `firebase_b64.txt` al repositorio. Añade `*firebase-adminsdk*.json` y `firebase_b64.txt` a `.gitignore`.
- Usa `FIREBASE_CREDENTIALS_BASE64` en producción (evita problemas de comillas/newlines).
- Marca variables como secret/encrypted en Railway.
- Revoca cualquier service account key que haya estado expuesto.

8) Monitoring y operaciones
---------------------------
- Registra `success_count` y `failure_count` de los envíos de FCM.
- Programa limpieza regular de `FCMDevice` marcados `activo=False` por más de X días.
- Añade métricas/logging para notificaciones enviadas y errores (stack traces guardados mínimo 7-30 días según política).

9) Troubleshooting rápido
-------------------------
- Si `scripts/test_firebase.py` falla con error de parsing: asegúrate `FIREBASE_CREDENTIALS_BASE64` es la cadena Base64 completa sin saltos de línea.
- Si `enviar_tokens_push` marca muchos tokens como inválidos: los tokens expiran o la app no reenvía tokens tras reinstalar; solicita re-registro en la app.
- Si las notificaciones no llegan: revisa `google-services.json`, permisos del emulador/dispositivo y que el token enviado al backend coincida con el del dispositivo.

10) Siguientes tareas (opcional)
--------------------------------
- Añadir endpoint `POST /devices/unregister/` si aún no existe (te puedo implementarlo).
- Añadir tests unitarios e2e para el flujo token → backend → envío simulado.
- Añadir documentación corta en `README.md` del repo y un `CONTRIBUTING.md` para el equipo.

Contacto y apoyo
----------------
Si tienes dudas concretas durante la integración con Flutter (ej.: comportamiento del token en un modelo de login concreto, AVD vs. dispositivo físico, problemas CORS, o errores de FCM), copia aquí la salida de logs y te ayudo a resolverlo paso a paso.

---
Archivo generado por: equipo backend (Senior Dev)
Fecha: 2025-11-13
