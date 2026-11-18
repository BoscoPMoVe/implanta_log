import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/visita.dart';
import '../utilidades/app_error.dart';

/// Clase que se encarga de todo lo relacionado con SQLite.
///
/// Usa el patrón Singleton: solo existe una instancia en toda la app,
/// así no abrimos la base de datos varias veces.
class BaseDatos {
  static final BaseDatos instancia = BaseDatos._interno();
  BaseDatos._interno();

  static Database? _db;

  /// Regresa la base de datos. La primera vez la crea.
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final carpeta = await getDatabasesPath();
    final ruta = join(carpeta, 'implanta_log.db');

    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        // Se ejecuta solo la primera vez que se instala la app
        await db.execute('''
          CREATE TABLE visitas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente TEXT NOT NULL,
            asunto TEXT NOT NULL,
            modulo TEXT,
            fase TEXT,
            notas TEXT,
            pendientes TEXT,
            ruta_imagen TEXT,
            latitud REAL,
            longitud REAL,
            fecha TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Guarda una visita nueva y regresa su id.
  Future<int> insertarVisita(Visita visita) async {
    try {
      final database = await db;
      final datos = visita.toMap();
      datos.remove('id'); // el id lo pone SQLite solo
      return await database.insert('visitas', datos);
    } catch (e) {
      throw AppError('No se pudo guardar la visita');
    }
  }

  /// Regresa todas las visitas, de la más nueva a la más vieja.
  Future<List<Visita>> obtenerVisitas() async {
    try {
      final database = await db;
      final filas = await database.query('visitas', orderBy: 'fecha DESC');
      return filas.map((fila) => Visita.fromMap(fila)).toList();
    } catch (e) {
      throw AppError('No se pudieron cargar las visitas');
    }
  }

  /// Borra una visita por su id.
  Future<void> eliminarVisita(int id) async {
    try {
      final database = await db;
      await database.delete('visitas', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw AppError('No se pudo eliminar la visita');
    }
  }
}
