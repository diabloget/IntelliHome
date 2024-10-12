import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'user_service.dart';
import 'payment_method_view.dart';

class UpdateUserDataView extends StatefulWidget {
  final String initialAlias;

  const UpdateUserDataView({Key? key, required this.initialAlias}) : super(key: key);

  @override
  _UpdateUserDataViewState createState() => _UpdateUserDataViewState();
}

class _UpdateUserDataViewState extends State<UpdateUserDataView> {
  late TextEditingController aliasController;
  late TextEditingController nombreController;
  late TextEditingController correoController;
  late TextEditingController fechaNacimientoController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  List<String> estilosDeCasa = ["Moderno", "Rústico", "Minimalista"];
  List<String> tiposDeTransporte = ["Automóvil", "Motocicleta", "Bicicleta"];
  List<String> estilosSeleccionados = [];
  List<String> transporteSeleccionados = [];

  @override
  void initState() {
    super.initState();
    aliasController = TextEditingController(text: widget.initialAlias);
    nombreController = TextEditingController();
    correoController = TextEditingController();
    fechaNacimientoController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    List<Map<String, dynamic>> users = await UserService.getUsers();
    Map<String, dynamic>? currentUser = users.firstWhere(
          (user) => user['alias'] == widget.initialAlias,
      orElse: () => {},
    );

    if (currentUser.isNotEmpty) {
      setState(() {
        nombreController.text = currentUser['nombre'] ?? '';
        correoController.text = currentUser['correo'] ?? '';
        fechaNacimientoController.text = currentUser['fechaNacimiento'] ?? '';
        if (currentUser['fotoPerfil'] != null && currentUser['fotoPerfil'].isNotEmpty) {
          _imageFile = File(currentUser['fotoPerfil']);
        }
        estilosSeleccionados = List<String>.from(currentUser['estilosCasa'] ?? []);
        transporteSeleccionados = List<String>.from(currentUser['tiposTransporte'] ?? []);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        fechaNacimientoController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _applyChanges() async {
    // Validaciones
    if (aliasController.text.isEmpty || nombreController.text.isEmpty ||
        correoController.text.isEmpty || fechaNacimientoController.text.isEmpty ||
        estilosSeleccionados.isEmpty) {
      _showErrorSnackBar('Por favor, completa todos los campos obligatorios.');
      return;
    }

    // Actualizar datos del usuario
    List<Map<String, dynamic>> users = await UserService.getUsers();
    int userIndex = users.indexWhere((user) => user['alias'] == widget.initialAlias);

    if (userIndex != -1) {
      users[userIndex] = {
        'alias': aliasController.text,
        'nombre': nombreController.text,
        'correo': correoController.text,
        'fechaNacimiento': fechaNacimientoController.text,
        'fotoPerfil': _imageFile?.path ?? '',
        'estilosCasa': estilosSeleccionados,
        'tiposTransporte': transporteSeleccionados,
        'metodoPago': users[userIndex]['metodoPago'], // Mantener el método de pago existente
        'rol': users[userIndex]['rol'], // Mantener el rol existente
        'contrasena': users[userIndex]['contrasena'], // Mantener la contraseña existente
      };

      await UserService.updateUsers(users);
      _showSuccessSnackBar('Datos actualizados correctamente.');
    } else {
      _showErrorSnackBar('No se pudo encontrar el usuario para actualizar los datos.');
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
        title: const Text('Actualizar Datos'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: aliasController,
                decoration: const InputDecoration(labelText: 'Alias (Usuario)'),
              ),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              TextField(
                controller: correoController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
              ),
              TextField(
                controller: fechaNacimientoController,
                decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
                onTap: () => _selectDate(context),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Cambiar Foto de Perfil'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.file(_imageFile!, height: 150),
                ),
              const SizedBox(height: 20),
              const Text('Estilos de Casa:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10.0,
                children: estilosDeCasa.map((String estilo) {
                  return FilterChip(
                    label: Text(estilo),
                    selected: estilosSeleccionados.contains(estilo),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          estilosSeleccionados.add(estilo);
                        } else {
                          estilosSeleccionados.remove(estilo);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Tipos de Transporte:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10.0,
                children: tiposDeTransporte.map((String tipo) {
                  return FilterChip(
                    label: Text(tipo),
                    selected: transporteSeleccionados.contains(tipo),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          transporteSeleccionados.add(tipo);
                        } else {
                          transporteSeleccionados.remove(tipo);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentMethodView(alias: widget.initialAlias)),
                  );
                },
                child: const Text('Actualizar Método de Pago'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cancelar y volver atrás
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _applyChanges,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Aplicar Cambios'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    aliasController.dispose();
    nombreController.dispose();
    correoController.dispose();
    fechaNacimientoController.dispose();
    super.dispose();
  }
}