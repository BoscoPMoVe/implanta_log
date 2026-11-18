import 'dart:io';

import 'package:flutter/material.dart';

/// Muestra la foto de una visita. Si no tiene foto, o el archivo ya no
/// existe, muestra un ícono en su lugar (para que no truene).
class FotoVisita extends StatelessWidget {
  final String? ruta;

  const FotoVisita({super.key, this.ruta});

  @override
  Widget build(BuildContext context) {
    if (ruta == null) {
      return _sinFoto(context);
    }

    return Image.file(
      File(ruta!),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stack) => _sinFoto(context),
    );
  }

  Widget _sinFoto(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
    );
  }
}
