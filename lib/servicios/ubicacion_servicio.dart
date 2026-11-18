import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilidades/app_error.dart';

/// GADGET 3: GPS y mapas.
class UbicacionServicio {
  /// Obtiene la ubicación actual del teléfono.
  /// Revisa paso a paso: GPS encendido -> permiso -> posición.
  Future<Position> obtenerUbicacion() async {
    // 1. ¿Está prendido el GPS?
    final gpsPrendido = await Geolocator.isLocationServiceEnabled();
    if (!gpsPrendido) {
      throw AppError('El GPS está apagado');
    }

    // 2. ¿Tenemos permiso? Si no, lo pedimos.
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      throw AppError('No diste permiso de ubicación', esPermiso: true);
    }

    // 3. Pedimos la posición con un límite de 15 segundos
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      throw AppError('No se pudo obtener la ubicación');
    }
  }

  /// Abre Google Maps con las coordenadas guardadas.
  Future<void> abrirEnGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      final abrio = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!abrio) throw AppError('No se pudo abrir Google Maps');
    } catch (e) {
      throw AppError('No se pudo abrir Google Maps');
    }
  }

  /// Abre los ajustes de la app para que el usuario active un permiso
  /// que negó antes.
  Future<void> abrirAjustes() async {
    await Geolocator.openAppSettings();
  }
}
