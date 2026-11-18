/// Error propio de la app con un mensaje entendible para el usuario.
///
/// Lo usamos en vez de dejar que truene la app: los servicios y la base
/// de datos atrapan el error real con try-catch y lanzan un AppError.
class AppError implements Exception {
  final String mensaje;

  /// true cuando el problema es que el usuario negó un permiso
  /// (cámara, micrófono o GPS). Sirve para mostrar el botón "Ajustes".
  final bool esPermiso;

  AppError(this.mensaje, {this.esPermiso = false});

  @override
  String toString() => mensaje;
}
