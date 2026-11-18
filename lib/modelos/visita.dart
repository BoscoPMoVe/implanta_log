import 'dart:convert';

/// Representa una visita al cliente (una entrada de la bitácora).
///
/// Esta clase solo guarda datos y sabe convertirse a Map para SQLite
/// (Responsabilidad Única: no abre la base de datos ni pinta nada).
class Visita {
  int? id;
  String cliente;
  String asunto;
  String modulo;
  String fase;
  String notas;
  List<String> pendientes;
  String? rutaImagen;
  double? latitud;
  double? longitud;
  DateTime fecha;

  Visita({
    this.id,
    required this.cliente,
    required this.asunto,
    required this.modulo,
    required this.fase,
    required this.notas,
    required this.pendientes,
    this.rutaImagen,
    this.latitud,
    this.longitud,
    required this.fecha,
  });

  /// true si al guardar se pudo obtener el GPS
  bool get tieneUbicacion => latitud != null && longitud != null;

  /// Convierte la visita a un Map para guardarla en SQLite.
  /// La lista de pendientes se guarda como texto JSON porque SQLite
  /// no tiene un tipo de dato "lista".
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'asunto': asunto,
      'modulo': modulo,
      'fase': fase,
      'notas': notas,
      'pendientes': jsonEncode(pendientes),
      'ruta_imagen': rutaImagen,
      'latitud': latitud,
      'longitud': longitud,
      'fecha': fecha.toIso8601String(),
    };
  }

  /// Crea una visita a partir de una fila de SQLite.
  factory Visita.fromMap(Map<String, dynamic> map) {
    // Si el JSON de pendientes viene mal, no tronamos la app,
    // simplemente dejamos la lista vacía.
    List<String> listaPendientes = [];
    try {
      final decodificado = jsonDecode(map['pendientes'] ?? '[]');
      listaPendientes = List<String>.from(decodificado);
    } catch (e) {
      listaPendientes = [];
    }

    return Visita(
      id: map['id'],
      cliente: map['cliente'] ?? '',
      asunto: map['asunto'] ?? '',
      modulo: map['modulo'] ?? '',
      fase: map['fase'] ?? '',
      notas: map['notas'] ?? '',
      pendientes: listaPendientes,
      rutaImagen: map['ruta_imagen'],
      latitud: map['latitud'],
      longitud: map['longitud'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}

/// Opciones para los menús desplegables del formulario.
const List<String> modulosDisponibles = [
  'Finanzas',
  'Ventas',
  'Inventario',
  'Compras',
  'Recursos Humanos',
  'CRM',
  'Integración / API',
];

const List<String> fasesDisponibles = [
  'Levantamiento',
  'Configuración',
  'Migración de datos',
  'Pruebas',
  'Capacitación',
  'Go-live',
  'Soporte',
];
