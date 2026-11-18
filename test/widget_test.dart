import 'package:flutter_test/flutter_test.dart';
import 'package:implanta_log/modelos/visita.dart';

// Prueba sencilla: convertir una visita a Map y de regreso
// debe dar los mismos datos.
void main() {
  test('Visita se guarda y se lee igual', () {
    final visita = Visita(
      cliente: 'Cliente Demo',
      asunto: 'Kickoff del ERP',
      modulo: 'Finanzas',
      fase: 'Levantamiento',
      notas: 'Acuerdos iniciales',
      pendientes: ['Enviar catálogo de cuentas'],
      latitud: 20.97,
      longitud: -89.62,
      fecha: DateTime(2026, 11, 9),
    );

    final copia = Visita.fromMap(visita.toMap());

    expect(copia.cliente, 'Cliente Demo');
    expect(copia.pendientes, ['Enviar catálogo de cuentas']);
    expect(copia.tieneUbicacion, true);
  });
}
