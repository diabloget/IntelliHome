import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Para obtener el directorio local
import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes

class HouseReg extends StatefulWidget {
  @override
  _HouseRegState createState() => _HouseRegState();
}

class _HouseRegState extends State<HouseReg> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  TextEditingController capacidadController = TextEditingController();
  TextEditingController habitacionesController = TextEditingController();
  TextEditingController banosController = TextEditingController();
  TextEditingController caracteristicasController = TextEditingController();
  TextEditingController otrasCaracteristicasController =
  TextEditingController();
  TextEditingController latitudController = TextEditingController();
  TextEditingController longitudController = TextEditingController();

  // Lista para las fotos seleccionadas
  List<String> fotos = [];

  // Variable para manejar la validación de las fotos
  bool showPhotoError = false;

  // Función para seleccionar fotos
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        fotos.add(pickedFile.path);
        showPhotoError =
        false; // Resetear el mensaje de error al agregar una imagen
      });
    }
  }

  // Función para eliminar una foto de la lista
  void _removeImage(String path) {
    setState(() {
      fotos.remove(path);
    });
  }

  // Función para guardar la casa en un archivo JSON
  Future<void> _saveHouse() async {
    // Verificar si hay al menos 3 fotos
    if (fotos.length < 3) {
      setState(() {
        showPhotoError = true;
      });
      return;
    }

    // Crear la casa con los datos ingresados
    Map<String, dynamic> newHouse = {
      "capacidad": int.parse(capacidadController.text),
      "habitaciones": int.parse(habitacionesController.text),
      "banos": int.parse(banosController.text),
      "caracteristicas_generales": caracteristicasController.text,
      "otras_caracteristicas": otrasCaracteristicasController.text,
      "latitud": double.parse(latitudController.text),
      "longitud": double.parse(longitudController.text),
      "fotos": fotos,
      "disponible": true, // Por defecto en verdadero
      "maestro": null, // Actualmente sin usuario asignado
      "asociado": null, // Actualmente sin usuario asociado
      "dispositivos": [], // Lista vacía de dispositivos
      "comentarios": "", // Cadena vacía
      "historial": [], // Lista vacía
    };

    // Obtener el directorio local y crear el archivo si no existe
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    List<dynamic> casas = [];

    if (await file.exists()) {
      String content = await file.readAsString();
      casas = jsonDecode(content);
    }

    // Agregar la nueva casa a la lista de casas
    casas.add(newHouse);

    // Guardar la lista de casas en el archivo
    await file.writeAsString(jsonEncode(casas));

    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Casa guardada con éxito')));

    // Limpiar el formulario después de guardar
    _formKey.currentState!.reset();
    capacidadController.clear();
    habitacionesController.clear();
    banosController.clear();
    caracteristicasController.clear();
    otrasCaracteristicasController.clear();
    latitudController.clear();
    longitudController.clear();
    setState(() {
      fotos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Casa"),
        backgroundColor: Colors.blue, // Fondo oscuro
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