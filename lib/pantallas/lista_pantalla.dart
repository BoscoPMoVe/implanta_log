import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/visita.dart';
import '../widgets/foto_visita.dart';
import '../widgets/menu_lateral.dart';

/// Pantalla principal: muestra todas las visitas guardadas.
class ListaPantalla extends StatefulWidget {
  const ListaPantalla({super.key});

  @override
  State<ListaPantalla> createState() => _ListaPantallaState();
}

class _ListaPantallaState extends State<ListaPantalla> {
  late Future<List<Visita>> _visitas;

  @override
  void initState() {
    super.initState();
    // El Future se crea aquí y NO en build(), porque build() se llama
    // muchas veces y estaríamos consultando la base de datos a cada rato.
    _visitas = BaseDatos.instancia.obtenerVisitas();
  }

  void _recargar() {
    setState(() {
      _visitas = BaseDatos.instancia.obtenerVisitas();
    });
  }

  Future<void> _irAFormulario() async {
    // Esperamos a que el formulario se cierre. Si regresa true es que
    // se guardó una visita, entonces recargamos la lista.
    final guardo = await Navigator.pushNamed(context, '/nueva');
    if (guardo == true) _recargar();
  }

  Future<void> _irADetalle(Visita visita) async {
    final borro =
        await Navigator.pushNamed(context, '/detalle', arguments: visita);
    if (borro == true) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis visitas')),
      drawer: const MenuLateral(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irAFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Nueva visita'),
      ),

      // FutureBuilder: mientras la base de datos responde mostramos un
      // circulito de carga; cuando llegan los datos, la lista.
      body: FutureBuilder<List<Visita>>(
        future: _visitas,
        builder: (context, snapshot) {
          // 1. Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Hubo un error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snapshot.error}'),
                  TextButton(
                    onPressed: _recargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final visitas = snapshot.data ?? [];

          // 3. No hay visitas todavía
          if (visitas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no tienes visitas.\nToca "Nueva visita" para registrar la primera.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 4. Mostramos la lista
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: visitas.length,
            itemBuilder: (context, i) {
              final visita = visitas[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  // Hero: la misma "etiqueta" (tag) está en el detalle,
                  // así Flutter anima la foto de una pantalla a otra.
                  leading: Hero(
                    tag: 'foto_${visita.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: FotoVisita(ruta: visita.rutaImagen),
                      ),
                    ),
                  ),
                  title: Text(visita.asunto),
                  subtitle: Text(
                    '${visita.cliente} · ${visita.fase}\n'
                    '${DateFormat('dd/MM/yyyy').format(visita.fecha)}',
                  ),
                  isThreeLine: true,
                  trailing: visita.tieneUbicacion
                      ? const Icon(Icons.location_on, color: Colors.red)
                      : null,
                  onTap: () => _irADetalle(visita),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
