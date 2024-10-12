import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'house_detail.dart'; // Para manejar archivos locales

class HouseList extends StatefulWidget {
  @override
  _HouseListState createState() => _HouseListState();
}

class _HouseListState extends State<HouseList> {
  List<dynamic> houses = [];

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  // Función para cargar las casas desde el archivo JSON
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

  // Navegar a la vista personalizada de una casa
  void _navigateToHouseDetail(
      BuildContext context, Map<String, dynamic> house) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HouseDetail(house: house)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Casas'),
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

                // Descomentar esto cuando se añada la propiedad "disponible" en el JSON
                // if (house['disponible'] == false) return SizedBox.shrink();

                String imagePath = house['fotos'].isNotEmpty
                    ? house['fotos'][0] // Usar la primera imagen como banner
                    : '';

                return GestureDetector(
                  onTap: () => _navigateToHouseDetail(context, house),
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
                                  width:
                                      double.infinity, // Llenar horizontalmente
                                  height: 200, // Definir una altura fija
                                  fit: BoxFit.cover, // Que cubra sin estirarse
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
