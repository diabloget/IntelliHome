import 'package:flutter/material.dart';
import '../user/user_view.dart'; // Asegúrate de tener una pantalla principal llamada `MainView`

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Para que el botón ocupe todo el ancho
          children: <Widget>[
            // Puedes agregar más widgets aquí (campos de texto, etc.)

            // Botón de Login
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserView()),
                );
              },
              child: const Text('Login'),
            ),

            // Otros botones o elementos pueden agregarse fácilmente aquí
          ],
        ),
      ),
    );
  }
}
