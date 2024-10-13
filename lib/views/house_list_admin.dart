import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'house_detail_admin.dart'; // Para manejar archivos locales

class HouseListAdmin extends StatefulWidget {
  @override
  _HouseListAdminState createState() => _HouseListAdminState();
}

class _HouseListAdminState extends State<HouseListAdmin> {
  List<dynamic> houses = [];

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  // Cargar las casas desde el archivo JSON
  Future<void> _loadHouses() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    if (await file.exists()) {
      String content = await file.readAsString();
      setState(() {
        houses = jsonDecode(content);
      });
    }
  }

  // Guardar las casas actualizadas en el archivo JSON
  Future<void> _saveHouses() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    await file.writeAsString(jsonEncode(houses));
  }

  // Navegar a los detalles de una casa con opciones de administrador
  void _navigateToHouseDetailAdmin(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              HouseDetailAdmin(houseIndex: index, house: houses[index])),
    ).then((_) {
      _loadHouses(); // Recargar las casas al regresar
    });
  }

  // Eliminar una casa
  void _deleteHouse(int index) {
    setState(() {
      houses.removeAt(index);
    });
    _saveHouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Casas (Admin)'),
        backgroundColor: Colors.blue,
      ),
      body: houses.isEmpty
          ? Center(
        child: Text(
          "No hay casas disponibles",
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: houses.length,
        itemBuilder: (context, index) {
          var house = houses[index];
          String imagePath =
          house['fotos'].isNotEmpty ? house['fotos'][0] : '';

          return GestureDetector(
            onTap: () => _navigateToHouseDetailAdmin(context, index),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imagePath.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 100,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Capacidad: ${house['capacidad']} personas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Habitaciones: ${house['habitaciones']}',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Baños: ${house['banos']}',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}