import 'package:flutter/material.dart';
import 'user_service.dart';

class PaymentMethodView extends StatefulWidget {
  final String alias;

  const PaymentMethodView({Key? key, required this.alias}) : super(key: key);

  @override
  _PaymentMethodViewState createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  late TextEditingController nombreTarjetahabienteController;
  late TextEditingController numeroTarjetaController;
  late TextEditingController fechaValidezController;
  late TextEditingController numeroVerificadorController;

  @override
  void initState() {
    super.initState();
    nombreTarjetahabienteController = TextEditingController();
    numeroTarjetaController = TextEditingController();
    fechaValidezController = TextEditingController();
    numeroVerificadorController = TextEditingController();
    _loadCurrentPaymentMethod();
  }

  Future<void> _loadCurrentPaymentMethod() async {
    List<Map<String, dynamic>> users = await UserService.getUsers();
    Map<String, dynamic>? currentUser = users.firstWhere((user) => user['alias'] == widget.alias, orElse: () => {});

    if (currentUser != null && currentUser['metodoPago'] != null) {
      setState(() {
        nombreTarjetahabienteController.text = currentUser['metodoPago']['nombreTarjetahabiente'] ?? '';
        numeroTarjetaController.text = currentUser['metodoPago']['numeroTarjeta'] ?? '';
        fechaValidezController.text = currentUser['metodoPago']['fechaValidez'] ?? '';
        numeroVerificadorController.text = currentUser['metodoPago']['numeroVerificador'] ?? '';
      });
    }
  }

  Future<void> _updatePaymentMethod() async {
    // Validaciones
    if (nombreTarjetahabienteController.text.isEmpty ||
        numeroTarjetaController.text.isEmpty ||
        fechaValidezController.text.isEmpty ||
        numeroVerificadorController.text.isEmpty) {
      _showErrorSnackBar('Por favor, completa todos los campos del método de pago.');
      return;
    }

    if (numeroTarjetaController.text.length != 16) {
      _showErrorSnackBar('El número de tarjeta debe tener 16 dígitos.');
      return;
    }

    if (!['1', '2', '3', '5'].contains(numeroTarjetaController.text[0])) {
      _showErrorSnackBar('El número de tarjeta debe empezar con 1, 2, 3 o 5.');
      return;
    }

    if (numeroVerificadorController.text.length != 4) {
      _showErrorSnackBar('El número verificador debe tener 4 dígitos.');
      return;
    }

    // Actualizar el método de pago
    List<Map<String, dynamic>> users = await UserService.getUsers();
    int userIndex = users.indexWhere((user) => user['alias'] == widget.alias);

    if (userIndex != -1) {
      users[userIndex]['metodoPago'] = {
        'nombreTarjetahabiente': nombreTarjetahabienteController.text,
        'numeroTarjeta': numeroTarjetaController.text,
        'fechaValidez': fechaValidezController.text,
        'numeroVerificador': numeroVerificadorController.text,
      };

      await UserService.updateUsers(users);
      _showSuccessSnackBar('Método de pago actualizado correctamente.');
    } else {
      _showErrorSnackBar('No se pudo encontrar el usuario para actualizar el método de pago.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Método de Pago'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: nombreTarjetahabienteController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Tarjetahabiente',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: numeroTarjetaController,
                decoration: const InputDecoration(
                  labelText: 'Número de Tarjeta',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: fechaValidezController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Validez (MM/AA)',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: numeroVerificadorController,
                decoration: const InputDecoration(
                  labelText: 'Número Verificador (4 dígitos)',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePaymentMethod,
                child: const Text('Actualizar Método de Pago'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nombreTarjetahabienteController.dispose();
    numeroTarjetaController.dispose();
    fechaValidezController.dispose();
    numeroVerificadorController.dispose();
    super.dispose();
  }
}