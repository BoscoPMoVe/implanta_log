import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../modelos/visita.dart';
import '../servicios/camara_servicio.dart';
import '../servicios/ubicacion_servicio.dart';
import '../servicios/voz_servicio.dart';
import '../utilidades/mensajes.dart';
import '../widgets/foto_visita.dart';

/// Formulario para registrar una visita nueva.
/// Aquí se usan los 3 gadgets: cámara, micrófono y GPS.
class FormularioPantalla extends StatefulWidget {
  const FormularioPantalla({super.key});

  @override
  State<FormularioPantalla> createState() => _FormularioPantallaState();
}

class _FormularioPantallaState extends State<FormularioPantalla> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos de texto
  final _clienteCtrl = TextEditingController();
  final _asuntoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _pendienteCtrl = TextEditingController();

  // Servicios (gadgets)
  final _camara = CamaraServicio();
  final _voz = VozServicio();
  final _ubicacion = UbicacionServicio();

  String _modulo = modulosDisponibles.first;
  String _fase = fasesDisponibles.first;
  final List<String> _pendientes = [];
  String? _rutaImagen;

  bool _escuchando = false;
  bool _guardando = false;

  // Lo que ya estaba escrito antes de empezar a dictar
  String _textoAntes = '';

  @override
  void dispose() {
    _voz.detener();
    _clienteCtrl.dispose();
    _asuntoCtrl.dispose();
    _notasCtrl.dispose();
    _pendienteCtrl.dispose();
    super.dispose();
  }

  // ---------------- GADGET 1: Cámara / Galería ----------------

  Future<void> _tomarFoto() async {
    try {
      final ruta = await _camara.tomarFoto();
      if (ruta != null && mounted) setState(() => _rutaImagen = ruta);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  Future<void> _elegirFoto() async {
    try {
      final ruta = await _camara.elegirDeGaleria();
      if (ruta != null && mounted) setState(() => _rutaImagen = ruta);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  // ---------------- GADGET 2: Micrófono ----------------

  Future<void> _dictar() async {
    // Si ya está escuchando, el botón sirve para detener
    if (_escuchando) {
      await _voz.detener();
      if (mounted) setState(() => _escuchando = false);
      return;
    }

    // Guardamos lo que ya estaba escrito para no borrarlo
    _textoAntes = _notasCtrl.text.isEmpty ? '' : '${_notasCtrl.text} ';

    try {
      await _voz.empezar(
        alOirTexto: (texto) {
          if (mounted) setState(() => _notasCtrl.text = _textoAntes + texto);
        },
        alTerminar: () {
          if (mounted) setState(() => _escuchando = false);
        },
      );
      if (mounted) setState(() => _escuchando = true);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  // ---------------- Pendientes ----------------

  void _agregarPendiente() {
    if (_pendienteCtrl.text.trim().isEmpty) return;
    setState(() {
      _pendientes.add(_pendienteCtrl.text.trim());
      _pendienteCtrl.clear();
    });
  }

  // ---------------- Guardar (+ GADGET 3: GPS) ----------------

  Future<void> _guardar() async {
    // Revisa que los campos obligatorios estén llenos
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    // 1. Intentamos obtener el GPS. Si falla NO detenemos el guardado,
    //    la visita se guarda sin ubicación y avisamos al usuario.
    double? lat;
    double? lng;
    try {
      final posicion = await _ubicacion.obtenerUbicacion();
      lat = posicion.latitude;
      lng = posicion.longitude;
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }

    // 2. Armamos la visita con todos los datos
    final visita = Visita(
      cliente: _clienteCtrl.text.trim(),
      asunto: _asuntoCtrl.text.trim(),
      modulo: _modulo,
      fase: _fase,
      notas: _notasCtrl.text.trim(),
      pendientes: _pendientes,
      rutaImagen: _rutaImagen,
      latitud: lat,
      longitud: lng,
      fecha: DateTime.now(),
    );

    // 3. La guardamos en SQLite
    try {
      await BaseDatos.instancia.insertarVisita(visita);
      if (mounted) Navigator.pop(context, true); // true = sí se guardó
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        mostrarError(context, e);
      }
    }
  }

  // ---------------- Interfaz ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva visita')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Foto
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: FotoVisita(ruta: _rutaImagen),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _tomarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirFoto,
                    icon: const Icon(Icons.photo),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Datos generales
            TextFormField(
              controller: _clienteCtrl,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
              validator: (valor) =>
                  valor == null || valor.isEmpty ? 'Escribe el cliente' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _asuntoCtrl,
              decoration: const InputDecoration(
                labelText: 'Asunto de la visita',
                border: OutlineInputBorder(),
              ),
              validator: (valor) =>
                  valor == null || valor.isEmpty ? 'Escribe el asunto' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _modulo,
              decoration: const InputDecoration(
                labelText: 'Módulo',
                border: OutlineInputBorder(),
              ),
              items: modulosDisponibles
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (valor) => setState(() => _modulo = valor!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _fase,
              decoration: const InputDecoration(
                labelText: 'Fase',
                border: OutlineInputBorder(),
              ),
              items: fasesDisponibles
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (valor) => setState(() => _fase = valor!),
            ),
            const SizedBox(height: 12),

            // Minuta con botón de micrófono
            TextFormField(
              controller: _notasCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Minuta (escribe o dicta)',
                border: const OutlineInputBorder(),
                helperText: _escuchando ? 'Escuchando...' : null,
                suffixIcon: IconButton(
                  onPressed: _dictar,
                  icon: Icon(
                    _escuchando ? Icons.stop_circle : Icons.mic,
                    color: _escuchando ? Colors.red : null,
                  ),
                ),
              ),
              validator: (valor) =>
                  valor == null || valor.isEmpty ? 'Escribe la minuta' : null,
            ),
            const SizedBox(height: 16),

            // Pendientes
            const Text('Pendientes', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pendienteCtrl,
                    decoration:
                        const InputDecoration(hintText: 'Agregar pendiente'),
                    onSubmitted: (_) => _agregarPendiente(),
                  ),
                ),
                IconButton(
                  onPressed: _agregarPendiente,
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),
            for (int i = 0; i < _pendientes.length; i++)
              ListTile(
                dense: true,
                leading: const Icon(Icons.check_box_outline_blank),
                title: Text(_pendientes[i]),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _pendientes.removeAt(i)),
                ),
              ),
            const SizedBox(height: 24),

            // Botón guardar
            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar visita'),
            ),
            const SizedBox(height: 8),
            const Text(
              'La ubicación GPS se guarda automáticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
