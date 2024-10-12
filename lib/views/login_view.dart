import 'package:flutter/material.dart';
import 'package:intellihome/views/password_recovery_view.dart';
import 'package:intellihome/views/user_service.dart';
import 'package:intellihome/views/register_view.dart';
import 'package:intellihome/views/admin_menu_view.dart';
import 'package:intellihome/views/user_menu_view.dart';

class UserView extends StatefulWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';
  List<Map<String, dynamic>> registeredUsers = [];
  bool appEnabled = true; // Variable para verificar si la app está habilitada

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _checkAppEnabled(); // Chequear si la app está habilitada al iniciar
  }

  Future<void> _checkAppEnabled() async {
    appEnabled = await UserService.isAppEnabled();
    if (!appEnabled) {
      setState(() {
        errorMessage = 'La aplicación está deshabilitada.';
      });
      _showDisabledAppDialog();
    }
  }

  void _showDisabledAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[700],
        title: const Text('Aplicación Deshabilitada'),
        content: const Text('La aplicación ha sido deshabilitada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUsers() async {
    if (!appEnabled) return;

    try {
      List<Map<String, dynamic>> users = await UserService.getUsers();
      setState(() {
        registeredUsers = users;
      });
      print("Usuarios cargados: ${registeredUsers.length}");
    } catch (e) {
      print("Error al cargar usuarios: $e");
    }
  }

  void _login() async {
    String enteredUsername = _usernameController.text;
    String enteredPassword = _passwordController.text;

    if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, ingrese usuario y contraseña.';
      });
      return;
    }

    try {
      bool appEnabled = await UserService.isAppEnabled();

      var user = registeredUsers.firstWhere(
            (user) => user['alias'] == enteredUsername,
        orElse: () => <String, dynamic>{},
      );

      if (user.isEmpty) {
        setState(() {
          errorMessage = 'Usuario no encontrado.';
        });
      } else if (user['contrasena'] != enteredPassword) {
        setState(() {
          errorMessage = 'Contraseña incorrecta.';
        });
      } else if (user['estado'] == 'Deshabilitado') {
        setState(() {
          errorMessage = 'Su cuenta ha sido deshabilitada.';
        });
        _showDisabledUserDialog(user['alias']);
      } else if (!appEnabled && user['rol'] != 'Admin') {
        setState(() {
          errorMessage = 'La aplicación está deshabilitada para usuarios regulares.';
        });
      } else {
        setState(() {
          errorMessage = '';
        });

        if (user['rol'] == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminMenuView(alias: user['alias']),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserMenuView(alias: user['alias']),
            ),
          );
        }
      }
    } catch (e) {
      print("Error durante el login: $e");
      setState(() {
        errorMessage = 'Ocurrió un error. Por favor, intente de nuevo.';
      });
    }
  }

  void _showDisabledUserDialog(String alias) async {
    String? reason = await UserService.getDisableReason(alias);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[700],
        title: const Text('Cuenta Deshabilitada'),
        content: Text('Su cuenta ha sido deshabilitada.\nRazón: ${reason ?? "No se proporcionó razón"}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login de Usuario'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Iniciar Sesión'),
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordRecoveryView()),
                    );
                  },
                  child: Text('Recuperar contraseña'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterView()),
                    );
                  },
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
