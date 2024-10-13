import 'package:flutter/material.dart';
import 'package:intellihome/views/house_list.dart';
import 'package:intellihome/views/payment_method_view.dart';
import 'package:intellihome/views/update_user_data_view.dart';


// Definimos los colores como constantes
const Color kPrimaryColor = Color(0xFF176c95); // Azul
const Color kAccentColor = Color(0xFFede98a); // Amarillo ámbar

class UserMenuView extends StatelessWidget {
  final String alias;

  const UserMenuView({Key? key, required this.alias}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú de Usuario'),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, $alias',
              style: TextStyle(fontSize: 24, color: kAccentColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateUserDataView(initialAlias: alias)),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: kAccentColor, backgroundColor: kPrimaryColor,
              ),
              child: const Text('Configuración de Datos'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentMethodView(alias: alias)),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: kAccentColor, backgroundColor: kPrimaryColor,
              ),
              child: const Text('Método de Pago'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HouseList()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: kAccentColor, backgroundColor: kPrimaryColor,
              ),
              child: const Text('Ver Casas'),
            ),
            // ... Otros botones con el mismo estilo
          ],
        ),
      ),
    );
  }
}