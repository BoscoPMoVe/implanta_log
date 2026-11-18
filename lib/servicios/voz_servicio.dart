import 'package:speech_to_text/speech_to_text.dart';

import '../utilidades/app_error.dart';

/// GADGET 2: Micrófono y dictado (voz a texto).
///
/// Usa el paquete speech_to_text, que captura el audio del micrófono y
/// lo convierte a texto con el reconocedor de voz del teléfono.
class VozServicio {
  final SpeechToText _speech = SpeechToText();

  // Son "static" porque speech_to_text solo se inicializa una vez en toda
  // la app, aunque abramos el formulario varias veces.
  static bool _inicializado = false;
  static Function()? _alTerminar;

  bool get escuchando => _speech.isListening;

  /// Empieza a escuchar.
  /// [alOirTexto] se llama cada vez que el reconocedor entiende algo.
  /// [alTerminar] se llama cuando el micrófono se apaga.
  Future<void> empezar({
    required Function(String texto) alOirTexto,
    required Function() alTerminar,
  }) async {
    _alTerminar = alTerminar;

    // La primera vez hay que inicializar. Aquí es donde el teléfono
    // le pide al usuario el permiso del micrófono.
    if (!_inicializado) {
      final disponible = await _speech.initialize(
        onStatus: (estado) {
          if (estado == 'done' || estado == 'notListening') {
            _alTerminar?.call();
          }
        },
        onError: (error) => _alTerminar?.call(),
      );

      if (!disponible) {
        // initialize regresa false si no hay permiso o si el teléfono
        // no tiene reconocimiento de voz.
        throw AppError(
          'No se puede usar el micrófono. Revisa que diste permiso.',
          esPermiso: true,
        );
      }
      _inicializado = true;
    }

    try {
      await _speech.listen(
        localeId: 'es_MX', // español de México
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 5),
        onResult: (resultado) => alOirTexto(resultado.recognizedWords),
      );
    } catch (e) {
      throw AppError('No se pudo iniciar el dictado');
    }
  }

  Future<void> detener() async {
    _alTerminar = null;
    await _speech.stop();
  }
}
