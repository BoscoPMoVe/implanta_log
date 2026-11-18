import 'package:flutter/material.dart';

/// Drawer (menú lateral) que se usa en las pantallas principales.
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colores.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.engineering, size: 48, color: colores.onPrimary),
                const SizedBox(height: 8),
                Text(
                  'ImplantaLog',
                  style: TextStyle(
                      color: colores.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bitácora de implementación',
                  style: TextStyle(color: colores.onPrimary),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Mis visitas'),
            onTap: () {
              Navigator.pop(context); // cierra el menú
              // regresa hasta la pantalla principal
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nueva visita'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/nueva');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/acerca');
            },
          ),
        ],
      ),
    );
  }
}
