import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'device_management.dart';

class HouseDetailAdmin extends StatefulWidget {
  final int houseIndex;
  final Map<String, dynamic> house;

  HouseDetailAdmin({required this.houseIndex, required this.house});

  @override
  _HouseDetailAdminState createState() => _HouseDetailAdminState();
}

class _HouseDetailAdminState extends State<HouseDetailAdmin> {
  late TextEditingController _commentController;
  late TextEditingController _capacidadController;
  late TextEditingController _habitacionesController;
  late TextEditingController _banosController;
  late List<dynamic> houses = [];

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.house['comentarios']);
    _capacidadController = TextEditingController(text: widget.house['capacidad'].toString());
    _habitacionesController = TextEditingController(text: widget.house['habitaciones'].toString());
    _banosController = TextEditingController(text: widget.house['banos'].toString());
    _loadHouses();
  }

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

  Future<void> _saveHouses() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    await file.writeAsString(jsonEncode(houses));
  }

  void _deleteHouse() {
    setState(() {
      houses.removeAt(widget.houseIndex);
    });
    _saveHouses();
    Navigator.pop(context);
  }

  void _saveChanges() {
    setState(() {
      houses[widget.houseIndex]['comentarios'] = _commentController.text;
      houses[widget.houseIndex]['capacidad'] = int.parse(_capacidadController.text);
      houses[widget.houseIndex]['habitaciones'] = int.parse(_habitacionesController.text);
      houses[widget.houseIndex]['banos'] = int.parse(_banosController.text);
    });
    _saveHouses();
  }

  void _navigateToDeviceManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DeviceManagement(houseIndex: widget.houseIndex, house: houses[widget.houseIndex])),
    ).then((_) {
      _loadHouses();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _capacidadController.dispose();
    _habitacionesController.dispose();
    _banosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de la Casa (Admin)"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteHouse,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Fotos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            widget.house['fotos'].isNotEmpty
                ? Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.house['fotos'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.file(
                      File(widget.house['fotos'][index]),
                      width: 300,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            )
                : Text(
              'No hay fotos disponibles',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _capacidadController,
              decoration: InputDecoration(labelText: 'Capacidad'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _habitacionesController,
              decoration: InputDecoration(labelText: 'Habitaciones'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _banosController,
              decoration: InputDecoration(labelText: 'Baños'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Comentarios del Administrador',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(),
                hintText: 'Escribe aquí...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text("Guardar Cambios"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToDeviceManagement,
              child: Text("Administrar Dispositivos IoT"),
            ),
            SizedBox(height: 8),
            Text(
              'Dispositivos IoT: ${widget.house['dispositivos'].length}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}