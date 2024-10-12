import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Para trabajar con archivos
import 'package:flutter/services.dart' show rootBundle; // Para cargar el archivo JSON
import 'package:image_picker/image_picker.dart';
import 'package:intellihome/views/email_service.dart';
import 'package:intellihome/views/password_view.dart';
import 'package:path_provider/path_provider.dart';
import 'user_service.dart';
import 'package:intellihome/views/email_service.dart';
import '../login/login_view.dart'; // Paquete para seleccionar la imagen

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController aliasController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  // Foto de perfil seleccionada
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Validación del alias y correo
  bool aliasExiste = false;
  bool correoExiste = false;

  // Opciones para estilos de casa y transporte
  List<String> estilosDeCasa = ["Moderno", "Rústico", "Minimalista"];
  List<String> tiposDeTransporte = ["Automóvil", "Motocicleta", "Bicicleta"];

  // Selecciones del usuario
  List<String> estilosSeleccionados = [];
  List<String> transporteSeleccionados = [];

  // Datos del método de pago
  String nombreTarjetahabiente = '';
  String numeroTarjeta = '';
  String fechaValidez = '';
  String numeroVerificador = '';

  // Simular la carga de usuarios desde el archivo JSON
  Future<List<Map<String, dynamic>>> _loadUsers() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/users.json');

      if (await file.exists()) {
        // Si el archivo existe en el almacenamiento local, cárgalo
        String contents = await file.readAsString();
        List<dynamic> jsonList = json.decode(contents);
        return List<Map<String, dynamic>>.from(jsonList);
      } else {
        // Si no existe, carga el archivo predeterminado de los assets
        final String response = await rootBundle.loadString('assets/users.json');
        List<dynamic> jsonList = json.decode(response);
        return List<Map<String, dynamic>>.from(jsonList);
      }
    } catch (e) {
      print("Error loading users: $e");
      return [];
    }
  }

  // Función para validar si el alias o correo ya existen y las selecciones del usuario
  Future<void> validarUsuario() async {
    List<Map<String, dynamic>> users = await UserService.getUsers();

    setState(() {
      aliasExiste = users.any((user) => user['alias'] == aliasController.text);
      correoExiste = users.any((user) => user['correo'] == correoController.text);
    });

    if (aliasController.text.isEmpty || nombreController.text.isEmpty ||
        correoController.text.isEmpty || fechaController.text.isEmpty ||
        estilosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos obligatorios.')),
      );
    } else if (aliasExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El alias ya existe.')),
      );
    } else if (correoExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo ya está registrado.')),
      );
    } else {
      bool emailSent = await EmailService.sendVerificationEmail(correoController.text);
      if (emailSent) {
        _showVerificationDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el correo de verificación. Intente nuevamente.')),
        );
      }
    }
  }

  int _attemptCount = 0; // Contador de reenvíos
  int verificationAttempts = 0; // Contador de intentos de verificación
  int remainingTime = 120; // 2 minutos en segundos
  Timer? _timer; // Temporizador
  bool canResend = true; // Permitir reenviar código
  String verificationCode = ''; // Código ingresado por el usuario

  void _showVerificationDialog() {
    // Reiniciar el tiempo si se está mostrando el diálogo por primera vez o después de un reenvío
    if (_attemptCount == 0 || !canResend) {
      remainingTime = 120;
    }
    _attemptCount++;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Crear un nuevo temporizador cada vez que se construye el diálogo
            _timer?.cancel(); // Cancelar el temporizador existente si hay uno
            _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (remainingTime > 0) {
                setState(() {
                  remainingTime--;
                });
              } else {
                timer.cancel();
                Navigator.of(context).pop();
                if (_attemptCount < 2) {
                  _showVerificationDialog();
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                }
              }
            });

            return AlertDialog(
              backgroundColor: Colors.grey[800],
              title: Text('Verificación de Correo',
                style: TextStyle(color: Colors.amber[200]),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      verificationCode = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Ingrese el código de 5 dígitos",
                      hintStyle: TextStyle(color: Colors.amber[200]?.withOpacity(0.5)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber[200]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber[200]!),
                      ),
                    ),
                    style: TextStyle(color: Colors.amber[200]),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tiempo restante: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.amber[200]),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Verificar', style: TextStyle(color: Colors.amber[200])),
                  onPressed: () async {
                    if (await EmailService.verifyCode(verificationCode)) {
                      _timer?.cancel();
                      Navigator.of(context).pop();

                      await _saveUser(withPassword: false);

                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PasswordView(alias: aliasController.text)),
                      );
                    } else {
                      // Incrementar el contador de intentos de verificación
                      verificationAttempts++;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Código incorrecto. Intente nuevamente.'),
                          backgroundColor: Colors.red,
                        ),
                      );

                      // Si se alcanza el máximo de intentos (2)
                      if (verificationAttempts >= 2) {
                        _timer?.cancel();
                        Navigator.of(context).pop();
                        // Regresar a la pantalla de login
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginView()),
                        );
                      } else {
                        // Cerrar el diálogo actual y volver a abrirlo para que el usuario intente de nuevo
                        Navigator.of(context).pop();
                        _showVerificationDialog();
                      }
                    }
                  },
                ),
                if (canResend)
                  TextButton(
                    child: Text('Reenviar código', style: TextStyle(color: Colors.amber[200])),
                    onPressed: () async {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                      bool emailSent = await EmailService.sendVerificationEmail(correoController.text);
                      if (emailSent) {
                        canResend = false;
                        _attemptCount = 0; // Reiniciar el contador de intentos de reenvío
                        _showVerificationDialog(); // Mostrar el diálogo de nuevo
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al reenviar el código. Intente nuevamente.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _showVerificationDialog(); // Mostrar el diálogo de nuevo incluso si falla el reenvío
                      }
                    },
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _timer?.cancel();
      _timer = null;
    });
  }


  Future<void> _saveUser({bool withPassword = true}) async {
    // Crear nuevo usuario
    Map<String, dynamic> newUser = {
      "alias": aliasController.text,
      "nombre": nombreController.text,
      "correo": correoController.text,
      "fechaNacimiento": fechaController.text,
      "fotoPerfil": _imageFile?.path ?? "",
      "estilosCasa": estilosSeleccionados,
      "tiposTransporte": transporteSeleccionados,
      "metodoPago": {
        "nombreTarjetahabiente": nombreTarjetahabiente,
        "numeroTarjeta": numeroTarjeta,
        "fechaValidez": fechaValidez,
        "numeroVerificador": numeroVerificador
      },
      "rol": "user",
      "contrasena": withPassword ? contrasenaController.text : "" // Solo agregar contraseña si withPassword es true
    };

    await UserService.addUser(newUser);

    if (withPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente.')),
      );

      // Redirigir a la pantalla principal (LoginView)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
  }


  // Función para seleccionar imagen desde la galería
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }


  void _mostrarMetodoPagoPopup() {
    final TextEditingController nombreTarjetahabienteController = TextEditingController(text: nombreTarjetahabiente);
    final TextEditingController numeroTarjetaController = TextEditingController(text: numeroTarjeta);
    final TextEditingController fechaValidezController = TextEditingController(text: fechaValidez);
    final TextEditingController numeroVerificadorController = TextEditingController(text: numeroVerificador);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Método de Pago',
            style: TextStyle(color: Colors.black), // Título en negro
          ),
          backgroundColor: Colors.grey, // Fondo gris
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Pop-up más grande
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Nombre del tarjetahabiente
                  TextField(
                    controller: nombreTarjetahabienteController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Tarjetahabiente',
                      labelStyle: const TextStyle(color: Colors.black), // Etiqueta negra
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                      ),
                    ),
                    style: const TextStyle(color: Colors.black), // Texto en negro
                  ),

                  // Número de tarjeta
                  TextField(
                    controller: numeroTarjetaController,
                    decoration: InputDecoration(
                      labelText: 'Número de Tarjeta',
                      labelStyle: const TextStyle(color: Colors.black), // Etiqueta negra
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black), // Texto en negro
                  ),

                  // Fecha de validez (Mes/Año)
                  TextField(
                    controller: fechaValidezController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Validez (MM/AA)',
                      labelStyle: const TextStyle(color: Colors.black), // Etiqueta negra
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    style: const TextStyle(color: Colors.black), // Texto en negro
                  ),

                  // Número verificador (4 dígitos)
                  TextField(
                    controller: numeroVerificadorController,
                    decoration: InputDecoration(
                      labelText: 'Número Verificador (4 dígitos)',
                      labelStyle: const TextStyle(color: Colors.black), // Etiqueta negra
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black), // Texto en negro
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.black)), // Texto negro
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar', style: TextStyle(color: Colors.black)), // Texto negro
              onPressed: () {
                // Validaciones de los campos
                final String numeroTarjeta = numeroTarjetaController.text;
                final String fechaValidez = fechaValidezController.text;
                final String numeroVerificador = numeroVerificadorController.text;
                final String nombreTarjetahabiente = nombreTarjetahabienteController.text;

                if (nombreTarjetahabiente.isEmpty || numeroTarjeta.isEmpty ||
                    fechaValidez.isEmpty || numeroVerificador.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, completa todos los campos del método de pago.')),
                  );
                } else if (numeroTarjeta.length != 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El número de tarjeta debe tener 16 dígitos.')),
                  );
                } else if (numeroTarjeta[0] != '1' && numeroTarjeta[0] != '2' &&
                    numeroTarjeta[0] != '3' && numeroTarjeta[0] != '5') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El número de tarjeta debe empezar con 1, 2, 3 o 5.')),
                  );
                } else if (numeroVerificador.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El número verificador debe tener 4 dígitos.')),
                  );
                } else {
                  // Guardamos los datos si la validación es exitosa
                  setState(() {
                    this.nombreTarjetahabiente = nombreTarjetahabiente;
                    this.numeroTarjeta = numeroTarjeta;
                    this.fechaValidez = fechaValidez;
                    this.numeroVerificador = numeroVerificador;
                  });
                  Navigator.of(context).pop(); // Cerramos el diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Método de pago añadido correctamente.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

// Método para mostrar el DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Fecha inicial
      firstDate: DateTime(2000), // Primera fecha seleccionable
      lastDate: DateTime(2101), // Última fecha seleccionable
    );
    if (pickedDate != null) {
      // Actualiza el texto del TextField con la fecha seleccionada
      setState(() {
        fechaController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Formato YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.secondary; // Color del botón

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Campo de alias
              TextField(
                controller: aliasController,
                decoration: InputDecoration(
                  labelText: 'Alias',
                  labelStyle: const TextStyle(color: Colors.black), // Etiqueta en negro
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                  ),
                ),
                style: const TextStyle(color: Colors.black), // Texto en negro
              ),

              // Campo de nombre completo
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  labelStyle: const TextStyle(color: Colors.black), // Etiqueta en negro
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                  ),
                ),
                style: const TextStyle(color: Colors.black), // Texto en negro
              ),

              // Campo de correo
              TextField(
                controller: correoController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: const TextStyle(color: Colors.black), // Etiqueta en negro
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                  ),
                ),
                style: const TextStyle(color: Colors.black), // Texto en negro
              ),

              // Campo de fecha
              TextField(
                controller: fechaController,
                onTap: () => _selectDate(context), // Abre el calendario al tocar
                decoration: InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  labelStyle: const TextStyle(color: Colors.black), // Etiqueta en negro
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Línea negra al enfocar
                  ),
                ),
                style: const TextStyle(color: Colors.black), // Texto en negro
              ),

              const SizedBox(height: 20),

              // Seleccionar Foto de Perfil
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Seleccionar Foto de Perfil'),
              ),

              // Mostrar imagen seleccionada
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.file(
                    _imageFile!,
                    height: 150,
                  ),
                ),

              const SizedBox(height: 20),


              // Texto explicativo de estilos de casa
              Text(
                'Selecciona tu estilo de casa (min 1):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber[200]),
              ),

              // Seleccionar estilos de casa
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

              // Texto explicativo de tipos de transporte
              Text(
                'Selecciona tu medio de transporte:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber[200]),
              ),

              // Seleccionar tipos de transporte
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

              // Seleccionar Método de Pago
              ElevatedButton.icon(
                onPressed: _mostrarMetodoPagoPopup,
                icon: const Icon(Icons.payment),
                label: const Text('Seleccionar Método de Pago'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: validarUsuario,
        backgroundColor: Colors.amber[200], // Cambiar el color de fondo
        child: const Icon(Icons.mail),
      ),
    );
  }
}
