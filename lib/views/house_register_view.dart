import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

// Creamos una clase para representar un plan de pago
class PaymentPlan {
  final String name;
  double price;

  PaymentPlan({required this.name, this.price = 0.0});

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };
}

class HouseReg extends StatefulWidget {
  @override
  _HouseRegState createState() => _HouseRegState();
}

class _HouseRegState extends State<HouseReg> {
  final _formKey = GlobalKey<FormState>();

  // Controladores existentes
  TextEditingController capacidadController = TextEditingController();
  TextEditingController habitacionesController = TextEditingController();
  TextEditingController banosController = TextEditingController();
  TextEditingController caracteristicasController = TextEditingController();
  TextEditingController otrasCaracteristicasController =
      TextEditingController();
  TextEditingController latitudController = TextEditingController();
  TextEditingController longitudController = TextEditingController();

  // Nuevos controladores para los planes de pago
  TextEditingController mensualConServiciosController = TextEditingController();
  TextEditingController mensualSinServiciosController = TextEditingController();
  TextEditingController diarioConServiciosController = TextEditingController();

  List<String> fotos = [];
  bool showPhotoError = false;
  final ImagePicker _picker = ImagePicker();

  // Lista de planes de pago predefinidos
  late List<PaymentPlan> paymentPlans;

  @override
  void initState() {
    super.initState();
    paymentPlans = [
      PaymentPlan(name: "Cuota mensual con servicios básicos"),
      PaymentPlan(name: "Cuota mensual sin servicios básicos"),
      PaymentPlan(name: "Cuota diaria con servicios básicos"),
    ];
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        fotos.add(pickedFile.path);
        showPhotoError = false;
      });
    }
  }

  void _removeImage(String path) {
    setState(() {
      fotos.remove(path);
    });
  }

  Future<void> _saveHouse() async {
    if (fotos.length < 3) {
      setState(() {
        showPhotoError = true;
      });
      return;
    }

    // Actualizar los precios de los planes
    paymentPlans[0].price = double.parse(mensualConServiciosController.text);
    paymentPlans[1].price = double.parse(mensualSinServiciosController.text);
    paymentPlans[2].price = double.parse(diarioConServiciosController.text);

    Map<String, dynamic> newHouse = {
      "capacidad": int.parse(capacidadController.text),
      "habitaciones": int.parse(habitacionesController.text),
      "banos": int.parse(banosController.text),
      "caracteristicas_generales": caracteristicasController.text,
      "otras_caracteristicas": otrasCaracteristicasController.text,
      "latitud": double.parse(latitudController.text),
      "longitud": double.parse(longitudController.text),
      "fotos": fotos,
      "disponible": true,
      "dispositivos": [],
      "comentarios": "",
      "historial": [],
      "reservaciones": [],
      "planes": paymentPlans.map((plan) => plan.toJson()).toList(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    List<dynamic> casas = [];
    if (await file.exists()) {
      String content = await file.readAsString();
      casas = jsonDecode(content);
    }

    casas.add(newHouse);
    await file.writeAsString(jsonEncode(casas));

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Casa guardada con éxito')));

    _formKey.currentState!.reset();
    // Limpiar todos los controladores...
    [
      capacidadController,
      habitacionesController,
      banosController,
      caracteristicasController,
      otrasCaracteristicasController,
      latitudController,
      longitudController,
      mensualConServiciosController,
      mensualSinServiciosController,
      diarioConServiciosController,
    ].forEach((controller) => controller.clear());

    setState(() {
      fotos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Casa"),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Capacidad
                  TextFormField(
                    controller: capacidadController,
                    decoration: InputDecoration(
                      labelText: "Capacidad (número de personas)",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese la capacidad";
                      }
                      return null;
                    },
                  ),
                  // Cantidad de habitaciones
                  TextFormField(
                    controller: habitacionesController,
                    decoration: InputDecoration(
                      labelText: "Cantidad de habitaciones",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese la cantidad de habitaciones";
                      }
                      return null;
                    },
                  ),
                  // Cantidad de baños
                  TextFormField(
                    controller: banosController,
                    decoration: InputDecoration(
                      labelText: "Cantidad de baños",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese la cantidad de baños";
                      }
                      return null;
                    },
                  ),
                  // Características generales
                  TextFormField(
                    controller: caracteristicasController,
                    decoration: InputDecoration(
                      labelText: "Características generales",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese las características generales";
                      }
                      return null;
                    },
                  ),
                  // Otras características
                  TextFormField(
                    controller: otrasCaracteristicasController,
                    decoration: InputDecoration(
                      labelText: "Otras características",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  // Latitud
                  TextFormField(
                    controller: latitudController,
                    decoration: InputDecoration(
                      labelText: "Latitud",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese la latitud";
                      }
                      return null;
                    },
                  ),
                  // Longitud
                  TextFormField(
                    controller: longitudController,
                    decoration: InputDecoration(
                      labelText: "Longitud",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese la longitud";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Planes de Pago",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: mensualConServiciosController,
                    decoration: InputDecoration(
                      labelText: "Precio mensual con servicios (USD)",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese el precio mensual con servicios";
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    controller: mensualSinServiciosController,
                    decoration: InputDecoration(
                      labelText: "Precio mensual sin servicios (USD)",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese el precio mensual sin servicios";
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    controller: diarioConServiciosController,
                    decoration: InputDecoration(
                      labelText: "Precio diario con servicios (USD)",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Por favor ingrese el precio diario con servicios";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Botón para seleccionar fotos (cuadrado)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 100, // Hacer que el selector sea cuadrado
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Validación de fotos (mostrar mensaje si no hay suficientes)
                  if (showPhotoError)
                    Text(
                      "Selecciona al menos 3 imágenes",
                      style: TextStyle(color: Colors.red),
                    ),
                  // Lista scrollable con los nombres de las fotos
                  Container(
                    height: 150, // Altura máxima
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: fotos.length,
                      itemBuilder: (context, index) {
                        String foto = fotos[index];
                        return ListTile(
                          title: Text(
                            foto
                                .split('/')
                                .last, // Mostrar solo el nombre de la imagen
                            style:
                                TextStyle(color: Colors.white), // Texto blanco
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeImage(foto),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Botón para guardar la casa
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveHouse(); // Guardar la casa en el JSON
                  }
                },
                child: Text("Guardar Casa"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
