import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../utilidades/app_error.dart';

/// GADGET 1: Cámara y galería.
///
/// Esta clase solo se encarga de conseguir la foto. La pantalla no sabe
/// nada de image_picker, solo llama a tomarFoto() o elegirDeGaleria().
class CamaraServicio {
  final ImagePicker _picker = ImagePicker();

  Future<String?> tomarFoto() => _obtenerImagen(ImageSource.camera);

  Future<String?> elegirDeGaleria() => _obtenerImagen(ImageSource.gallery);

  /// Regresa la ruta de la imagen guardada, o null si el usuario canceló.
  Future<String?> _obtenerImagen(ImageSource origen) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: origen,
        maxWidth: 1200, // para que la foto no pese tanto
        imageQuality: 80,
      );

      if (foto == null) return null; // el usuario canceló

      // image_picker guarda la foto en una carpeta temporal que el
      // sistema puede borrar. Por eso la copiamos a la carpeta de
      // documentos de la app, y ESA ruta es la que guardamos en SQLite.
      final carpeta = await getApplicationDocumentsDirectory();
      final nombre = 'visita_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final rutaFinal = join(carpeta.path, nombre);
      await File(foto.path).copy(rutaFinal);

      return rutaFinal;
    } on PlatformException catch (e) {
      // Estos códigos los manda image_picker cuando el usuario
      // no dio permiso de cámara o de fotos.
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        throw AppError('No diste permiso para usar la cámara o la galería',
            esPermiso: true);
      }
      throw AppError('No se pudo abrir la cámara');
    } catch (e) {
      throw AppError('Ocurrió un error al obtener la imagen');
    }
  }
}
