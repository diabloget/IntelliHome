import 'package:flutter/material.dart';
import '../views/user_view.dart';
import '../views/register_view.dart'; // Asegúrate de tener una pantalla principal llamada `UserView`

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // Quita el título de la AppBar
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Imagen como logo
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Asegúrate de tener la imagen en la carpeta assets
                width: 350,
                height: 350,
              ),
            ),
            const SizedBox(height: 5), // Espacio entre el logo y los botones

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

            const SizedBox(height: 20), // Espacio entre los botones

            // Botón de Register
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterView()),
                );
              },
              child: const Text('Register'),
            ),

            // Espacio grande para que el botón de admin quede abajo
            const SizedBox(height: 80),

            // Botón de Admin más pequeño
          ],
        ),
      ),
    );
  }
}
