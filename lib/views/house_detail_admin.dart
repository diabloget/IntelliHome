import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir Google Maps en el navegador
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
  late TextEditingController _maestroController;
  late TextEditingController _asociadoController;
  late List<dynamic> houses = [];
  bool isAvailable = true; // Para el switch

  @override
  void initState() {
    super.initState();
    _commentController =
        TextEditingController(text: widget.house['comentarios'] ?? '');
    _capacidadController = TextEditingController(
        text: widget.house['capacidad']?.toString() ?? '');
    _habitacionesController = TextEditingController(
        text: widget.house['habitaciones']?.toString() ?? '');
    _banosController =
        TextEditingController(text: widget.house['banos']?.toString() ?? '');
    _maestroController =
        TextEditingController(text: widget.house['maestro'] ?? '');
    _asociadoController =
        TextEditingController(text: widget.house['asociado'] ?? '');
    isAvailable = widget.house['disponible'] ?? true;
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
      houses[widget.houseIndex]['capacidad'] =
          int.parse(_capacidadController.text);
      houses[widget.houseIndex]['habitaciones'] =
          int.parse(_habitacionesController.text);
      houses[widget.houseIndex]['banos'] = int.parse(_banosController.text);
      houses[widget.houseIndex]['maestro'] = _maestroController.text;
      houses[widget.houseIndex]['asociado'] = _asociadoController.text;
      houses[widget.houseIndex]['disponible'] = isAvailable;
    });
    _saveHouses();
  }

  void _navigateToDeviceManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeviceManagement(
              houseIndex: widget.houseIndex, house: houses[widget.houseIndex])),
    ).then((_) {
      _loadHouses();
    });
  }

  void _clearMaestro() {
    setState(() {
      _maestroController.text = '';
    });
  }

  void _clearAsociado() {
    setState(() {
      _asociadoController.text = '';
    });
  }

  Future<void> _openInGoogleMaps() async {
    final lat = widget.house['latitud'];
    final lng = widget.house['longitud'];
    if (lat != null && lng != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      Uri uri = Uri.parse(url); // Convierte el String a Uri
      if (await canLaunchUrl(uri)) {
        debugPrint(url);
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coordenadas no disponibles')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _capacidadController.dispose();
    _habitacionesController.dispose();
    _banosController.dispose();
    _maestroController.dispose();
    _asociadoController.dispose();
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
              'Disponibilidad',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text(
                'Casa disponible',
                style: TextStyle(color: Colors.white),
              ),
              value: isAvailable,
              onChanged: (bool value) {
                setState(() {
                  isAvailable = value;
                });
              },
            ),
            SizedBox(height: 16),
            _buildTextField(_capacidadController, 'Capacidad'),
            _buildTextField(_habitacionesController, 'Habitaciones'),
            _buildTextField(_banosController, 'Baños'),
            SizedBox(height: 16),
            _buildLabeledTextField(
                _maestroController, 'Maestro', _clearMaestro),
            _buildLabeledTextField(
                _asociadoController, 'Asociado', _clearAsociado),
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
              onPressed: _openInGoogleMaps,
              child: Text("Ver en Google Maps"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToDeviceManagement,
              child: Text("Administrar Dispositivos IoT"),
            ),
            SizedBox(height: 8),
            Text(
              'Dispositivos IoT: ${widget.house['dispositivos']?.length ?? 0}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildLabeledTextField(TextEditingController controller, String label,
      VoidCallback clearFunction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: label),
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: clearFunction,
            ),
          ],
        ),
      ],
    );
  }
}
