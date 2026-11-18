# ImplantaLog

Bitácora de visitas para consultores que implementan sistemas integrados (ERP, CRM).
Cada visita guarda foto, minuta dictada por voz, pendientes y ubicación GPS.

Pedro Guillermo Moguel Vela · Ingeniería en Sistemas · Universidad Anáhuac Mayab

## Estructura

lib/
main.dart        rutas y tema
modelos/         clase Visita
datos/           SQLite
servicios/       cámara, micrófono y GPS
pantallas/       lista, detalle, formulario, acerca de
widgets/         menú lateral y foto
utilidades/      errores y mensajes

## Cómo correrlo

flutter pub get
flutter run

## Permisos (android/app/src/main/AndroidManifest.xml)

INTERNET, RECORD_AUDIO, ACCESS_FINE_LOCATION y ACCESS_COARSE_LOCATION.