import 'package:flutter/material.dart';

import '../widgets/menu_lateral.dart';

class AcercaPantalla extends StatelessWidget {
  const AcercaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      drawer: const MenuLateral(),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ImplantaLog',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              'App para consultores que implementan sistemas integrados '
              '(ERP, CRM). Sirve para registrar cada visita al cliente con '
              'foto, minuta dictada, pendientes y la ubicación GPS como '
              'evidencia de que la visita se hizo en sitio.',
            ),
            SizedBox(height: 24),
            Text('Pedro Guillermo Moguel Vela'),
            Text('Ingeniería en Sistemas · Universidad Anáhuac Mayab'),
          ],
        ),
      ),
    );
  }
}
