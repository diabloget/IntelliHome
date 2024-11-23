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
  String tarjetaTipo = '';
  List<Map<String, dynamic>> paymentMethods = [];
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    nombreTarjetahabienteController = TextEditingController();
    numeroTarjetaController = TextEditingController();
    fechaValidezController = TextEditingController();
    numeroVerificadorController = TextEditingController();
    numeroTarjetaController.addListener(() {
      setState(() {
        tarjetaTipo = _getCardType(numeroTarjetaController.text);
      });
    });
    _loadCurrentPaymentMethods();
  }

  Future<void> _loadCurrentPaymentMethods() async {
    List<Map<String, dynamic>> users = await UserService.getUsers();
    Map<String, dynamic>? currentUser = users.firstWhere(
          (user) => user['alias'] == widget.alias,
      orElse: () => {},
    );

    if (currentUser != null && currentUser['metodoPago'] != null) {
      setState(() {
        paymentMethods = List<Map<String, dynamic>>.from(
            currentUser['metodoPago'] ?? []);
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

    // Si estamos editando un método de pago
    if (editingIndex != null) {
      setState(() {
        paymentMethods[editingIndex!] = {
          'nombreTarjetahabiente': nombreTarjetahabienteController.text,
          'numeroTarjeta': numeroTarjetaController.text,
          'fechaValidez': fechaValidezController.text,
          'numeroVerificador': numeroVerificadorController.text,
        };
      });
      _showSuccessSnackBar('Método de pago actualizado correctamente.');
    } else {
      // Agregar un nuevo método de pago
      setState(() {
        paymentMethods.add({
          'nombreTarjetahabiente': nombreTarjetahabienteController.text,
          'numeroTarjeta': numeroTarjetaController.text,
          'fechaValidez': fechaValidezController.text,
          'numeroVerificador': numeroVerificadorController.text,
        });
        _showSuccessSnackBar('Método de pago agregado correctamente.');
      });
    }

    // Actualizar los métodos de pago en el servicio
    List<Map<String, dynamic>> users = await UserService.getUsers();
    int userIndex = users.indexWhere((user) => user['alias'] == widget.alias);

    if (userIndex != -1) {
      users[userIndex]['metodoPago'] = paymentMethods;
      await UserService.updateUsers(users);
    } else {
      _showErrorSnackBar('No se pudo encontrar el usuario para actualizar el método de pago.');
    }

    // Limpiar el formulario y cancelar la edición
    _clearForm();
  }

  void _deletePaymentMethod(int index) async {
    setState(() {
      paymentMethods.removeAt(index);
    });

    // Actualizar los métodos de pago en el servicio
    List<Map<String, dynamic>> users = await UserService.getUsers();
    int userIndex = users.indexWhere((user) => user['alias'] == widget.alias);

    if (userIndex != -1) {
      users[userIndex]['metodoPago'] = paymentMethods;
      await UserService.updateUsers(users);
      _showSuccessSnackBar('Método de pago eliminado correctamente.');
    } else {
      _showErrorSnackBar('No se pudo encontrar el usuario para actualizar el método de pago.');
    }
  }

  void _editPaymentMethod(int index) {
    setState(() {
      var method = paymentMethods[index];
      nombreTarjetahabienteController.text = method['nombreTarjetahabiente'];
      numeroTarjetaController.text = method['numeroTarjeta'];
      fechaValidezController.text = method['fechaValidez'];
      numeroVerificadorController.text = method['numeroVerificador'];
      editingIndex = index;
    });
  }

  void _clearForm() {
    nombreTarjetahabienteController.clear();
    numeroTarjetaController.clear();
    fechaValidezController.clear();
    numeroVerificadorController.clear();
    editingIndex = null;
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

  String _getCardType(String cardNumber) {
    String firstDigit = cardNumber.isNotEmpty ? cardNumber[0] : '';
    switch (firstDigit) {
      case '1':
        return 'Visa';
      case '2':
        return 'MasterCard';
      case '3':
        return 'American Express';
      case '5':
        return 'TicaPay';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
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
              // Muestra la tarjeta tipo debajo de todos los campos
              if (tarjetaTipo.isNotEmpty)
                Text(
                  'Tipo de Tarjeta: $tarjetaTipo',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePaymentMethod,
                child: Text(editingIndex == null ? 'Agregar Método de Pago' : 'Actualizar Método de Pago'),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  var method = paymentMethods[index];
                  return ListTile(
                    title: Text('${method['nombreTarjetahabiente']} - ${method['numeroTarjeta']}'),
                    subtitle: Text('Validez: ${method['fechaValidez']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPaymentMethod(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deletePaymentMethod(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
