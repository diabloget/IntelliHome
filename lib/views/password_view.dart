import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Para trabajar con archivos
import 'package:flutter/services.dart' show rootBundle; // Para cargar el archivo JSON
import 'package:image_picker/image_picker.dart';
import 'package:intellihome/views/email_service.dart';
import 'package:path_provider/path_provider.dart';
import 'user_service.dart';
import 'package:intellihome/views/email_service.dart';
import '../login/login_view.dart'; // Paquete para seleccionar la imagen


class PasswordView extends StatefulWidget {
  final String alias;

  PasswordView({Key? key, required this.alias}) : super(key: key);

  @override
  _PasswordViewState createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  bool _validatePassword(String password) {
    if (password.length < 7) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  void _submitPassword() async {
    if (_validatePassword(_passwordController.text)) {
      try {
        // Buscar y actualizar el usuario por alias
        List<Map<String, dynamic>> users = await UserService.getUsers();
        int userIndex = users.indexWhere((user) => user['alias'] == widget.alias);

        if (userIndex != -1) {
          users[userIndex]['contrasena'] = _passwordController.text;
          await UserService.updateUsers(users);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario registrado satisfactoriamente.')),
          );

          // Redirigir a LoginView
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()),
          );
        } else {
          throw Exception('Usuario no encontrado');
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al guardar la contraseña: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'La contraseña no cumple con los requisitos. Debe tener al menos 7 caracteres, '
            'una mayúscula, una minúscula, un número y un símbolo especial.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary, // Fondo de AppBar similar al LoginView
        elevation: 0, // Quitar sombras del AppBar si prefieres un estilo plano
        title: Text(
          'Establecer Contraseña',
          style: TextStyle(color: Colors.black), // Letras del título en negro
        ),
        centerTitle: true, // Centrar el título
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.black), // Aquí se define el color del texto que se escribe
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(
                  color: Colors.black, // Color de la etiqueta en negro
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary), // Subrayado
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitPassword,
              child: Text('Guardar Contraseña'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary, // Fondo del botón en color consistente
                foregroundColor: Colors.white, // Texto en blanco
              ),
            ),
          ],
        ),
      ),
    );
  }
}
