# ImplantaLog

Bitácora de visitas para consultores que implementan sistemas integrados (ERP, CRM).
Cada visita guarda foto, minuta dictada por voz, pendientes y ubicación GPS.

Pedro Guillermo Moguel Vela · Ingeniería en Sistemas · Universidad Anáhuac Mayab

## Estructura

```
lib/
├── main.dart          rutas y tema
├── modelos/           clase Visita (datos + toMap/fromMap)
├── datos/             SQLite
├── servicios/         cámara, micrófono, GPS
├── pantallas/         lista, detalle, formulario, acerca de
├── widgets/           menú lateral y foto
└── utilidades/        errores y mensajes
```

## Cómo correrlo

```bash
flutter create . --org mx.anahuac --project-name implanta_log --platforms android,ios
./tool/configure_platforms.sh
flutter pub get
flutter run
```

El script agrega los permisos de cámara, micrófono y ubicación en Android e iOS.
