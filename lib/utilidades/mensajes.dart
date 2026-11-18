import 'package:flutter/material.dart';

import '../servicios/ubicacion_servicio.dart';
import 'app_error.dart';

/// Muestra un error abajo en la pantalla (SnackBar).
///
/// Si el error es de un permiso negado, agrega un botón "Ajustes" para
/// que el usuario lo pueda activar sin salirse a buscarlo.
void mostrarError(BuildContext context, Object error) {
  String mensaje = 'Ocurrió un error inesperado';
  bool esPermiso = false;

  if (error is AppError) {
    mensaje = error.mensaje;
    esPermiso = error.esPermiso;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      action: esPermiso
          ? SnackBarAction(
              label: 'Ajustes',
              onPressed: () => UbicacionServicio().abrirAjustes(),
            )
          : null,
    ),
  );
}

/// Muestra un mensaje normal (por ejemplo "Visita guardada").
void mostrarMensaje(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensaje)),
  );
}
