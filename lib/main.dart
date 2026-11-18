import 'package:flutter/material.dart';

import 'modelos/visita.dart';
import 'pantallas/acerca_pantalla.dart';
import 'pantallas/detalle_pantalla.dart';
import 'pantallas/formulario_pantalla.dart';
import 'pantallas/lista_pantalla.dart';

void main() {
  runApp(const ImplantaLogApp());
}

class ImplantaLogApp extends StatelessWidget {
  const ImplantaLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImplantaLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1F4E79),
      ),

      // Rutas nombradas: cada pantalla tiene un nombre y navegamos con
      // Navigator.pushNamed(context, '/nombre')
      initialRoute: '/',
      routes: {
        '/': (context) => const ListaPantalla(),
        '/nueva': (context) => const FormularioPantalla(),
        '/acerca': (context) => const AcercaPantalla(),
      },

      // El detalle necesita recibir la visita, así que lo armamos aquí
      // leyendo los "arguments" que mandamos al navegar.
      onGenerateRoute: (settings) {
        if (settings.name == '/detalle') {
          final visita = settings.arguments as Visita;
          return MaterialPageRoute(
            builder: (context) => DetallePantalla(visita: visita),
          );
        }
        return null;
      },
    );
  }
}
