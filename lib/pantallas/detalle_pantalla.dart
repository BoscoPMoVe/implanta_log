import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../datos/base_datos.dart';
import '../modelos/visita.dart';
import '../servicios/ubicacion_servicio.dart';
import '../utilidades/mensajes.dart';
import '../widgets/foto_visita.dart';

/// Muestra toda la información de una visita.
class DetallePantalla extends StatelessWidget {
  final Visita visita;

  const DetallePantalla({super.key, required this.visita});

  Future<void> _eliminar(BuildContext context) async {
    // Primero preguntamos para que no la borre por accidente
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar visita?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await BaseDatos.instancia.eliminarVisita(visita.id!);
      // Regresamos true para que la lista sepa que debe recargarse
      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) mostrarError(context, e);
    }
  }

  Future<void> _abrirMaps(BuildContext context) async {
    try {
      await UbicacionServicio()
          .abrirEnGoogleMaps(visita.latitud!, visita.longitud!);
    } catch (e) {
      if (context.mounted) mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(
        title: Text(visita.cliente),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _eliminar(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Misma etiqueta que en la lista -> animación Hero
          Hero(
            tag: 'foto_${visita.id}',
            child: SizedBox(
              height: 250,
              child: FotoVisita(ruta: visita.rutaImagen),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visita.asunto,
                    style: Theme.of(context).textTheme.headlineSmall),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(visita.fecha)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(visita.modulo)),
                    Chip(label: Text(visita.fase)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Minuta', style: titulo),
                const SizedBox(height: 4),
                Text(visita.notas),
                const SizedBox(height: 16),
                Text('Pendientes', style: titulo),
                if (visita.pendientes.isEmpty) const Text('Sin pendientes'),
                for (final pendiente in visita.pendientes)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_box_outline_blank),
                    title: Text(pendiente),
                  ),
                const SizedBox(height: 16),
                Text('Ubicación', style: titulo),
                const SizedBox(height: 8),
                if (visita.tieneUbicacion) ...[
                  _mapa(),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _abrirMaps(context),
                    icon: const Icon(Icons.map),
                    label: const Text('Abrir en Google Maps'),
                  ),
                ] else
                  const Text('Esta visita se guardó sin ubicación.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mapa interactivo con OpenStreetMap (se puede mover y hacer zoom).
  Widget _mapa() {
    final punto = LatLng(visita.latitud!, visita.longitud!);

    return SizedBox(
      height: 220,
      child: FlutterMap(
        options: MapOptions(initialCenter: punto, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'mx.anahuac.implanta_log',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: punto,
                child: const Icon(Icons.location_on,
                    color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
