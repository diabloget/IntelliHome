import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HouseDetailAdmin extends StatefulWidget {
  final int houseIndex;
  final Map<String, dynamic> house;

  HouseDetailAdmin({required this.houseIndex, required this.house});

  @override
  _HouseDetailAdminState createState() => _HouseDetailAdminState();
}

class _HouseDetailAdminState extends State<HouseDetailAdmin> {
  late TextEditingController _commentController;
  late List<dynamic> houses = [];

  @override
  void initState() {
    super.initState();
    _commentController =
        TextEditingController(text: widget.house['comentarios']);
    _loadHouses();
  }

  // Cargar casas desde el archivo JSON
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

  // Guardar cambios en el archivo JSON
  Future<void> _saveHouses() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    await file.writeAsString(jsonEncode(houses));
  }

  // Eliminar la casa actual
  void _deleteHouse() {
    setState(() {
      houses.removeAt(widget.houseIndex);
    });
    _saveHouses();
    Navigator.pop(context);
  }

  // Guardar el comentario actualizado
  void _saveComment() {
    setState(() {
      houses[widget.houseIndex]['comentarios'] = _commentController.text;
    });
    _saveHouses();
  }

  @override
  void dispose() {
    _commentController.dispose();
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
            Text(
              'Capacidad: ${widget.house['capacidad']} personas',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Habitaciones: ${widget.house['habitaciones']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            // Campo de texto para los comentarios
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
              onChanged: (value) => _saveComment(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveComment,
              child: Text("Guardar Comentario"),
            ),
          ],
        ),
      ),
    );
  }
}