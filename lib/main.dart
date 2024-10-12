import 'package:flutter/material.dart';

import 'house_reg/house_register_view.dart';
import 'houses/house_list.dart';
import 'theme.dart';

//import 'src/settings/settings_controller.dart';
//import 'src/settings/settings_service.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme(), // Usa el tema definido en theme.dart
      home: HouseList(), // Inicia con la pantalla de LoginView
    );
  }
}
