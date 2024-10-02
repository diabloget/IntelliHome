import 'package:flutter/material.dart';
import 'login/login_view.dart';
import 'theme.dart';

//import 'src/settings/settings_controller.dart';
//import 'src/settings/settings_service.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme(), // Usa el tema definido en theme.dart
      home: const LoginView(), // Inicia con la pantalla de LoginView
    );
  }
}
