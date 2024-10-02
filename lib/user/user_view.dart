import 'package:flutter/material.dart';
import '../profile/profile_view.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        backgroundColor:
            Theme.of(context).colorScheme.secondary, // Usa el color del tema
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Botón de configuración
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const ProfileView()), // Navega a la vista del perfil
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 botones por fila
          crossAxisSpacing: 20, // Espacio entre columnas
          mainAxisSpacing: 20, // Espacio entre filas
          children: [
            buildButtonWithLabel(context, 'Option 1', 'Catálogo'),
            buildButtonWithLabel(context, 'Option 2', 'Historial'),
            buildButtonWithLabel(context, 'Option 3', 'etc'),
            buildButtonWithLabel(context, 'Option 4', 'etc'),
          ],
        ),
      ),
    );
  }

  // Función para crear un botón cuadrado con texto debajo
  Widget buildButtonWithLabel(
      BuildContext context, String label, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Aquí puedes agregar la lógica para cada botón
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 120), // Tamaño mínimo cuadrado
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Esquinas redondeadas
            ),
            backgroundColor: Theme.of(context)
                .colorScheme
                .primary, // Usa el color primario del tema
          ),
          child: Text(label),
        ),
        const SizedBox(height: 10), // Espacio entre el botón y el texto
        Text(
          description,
          style: Theme.of(context)
              .textTheme
              .bodyLarge, // Asegurando que use el estilo de texto del tema
        ),
      ],
    );
  }
}
