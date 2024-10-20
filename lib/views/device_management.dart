import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
const Color kAccentColor = Color(0xFFede98a); // Amarillo ámbar

class DeviceManagement extends StatefulWidget {
  final int houseIndex;
  final Map<String, dynamic> house;

  DeviceManagement({required this.houseIndex, required this.house});

  @override
  _DeviceManagementState createState() => _DeviceManagementState();
}

class _DeviceManagementState extends State<DeviceManagement> {
  List<dynamic> houses = [];
  List<dynamic> devices = [];

  @override
  void initState() {
    super.initState();
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
        devices = houses[widget.houseIndex]['dispositivos'] ?? [];
      });
    }
  }

  Future<void> _saveHouses() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    houses[widget.houseIndex]['dispositivos'] = devices;
    await file.writeAsString(jsonEncode(houses));
  }

  void _addDevice() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String type = '';
        String location = '';

        return AlertDialog(
          title: Text('Agregar Dispositivo IoT'),
          backgroundColor: Colors.grey[50], // Fondo gris claro
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nombre del dispositivo'),
                onChanged: (value) => name = value,
                style: TextStyle(color: Colors.black),  // Texto siempre negro
                cursorColor: Colors.black, // Cursor negro
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Tipo de dispositivo'),
                onChanged: (value) => type = value,
                style: TextStyle(color: Colors.black),  // Texto siempre negro
                cursorColor: Colors.black, // Cursor negro
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Ubicación en la casa'),
                onChanged: (value) => location = value,
                style: TextStyle(color: Colors.black),  // Texto siempre negro
                cursorColor: Colors.black, // Cursor negro
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () {
                setState(() {
                  devices.add({
                    'nombre': name,
                    'tipo': type,
                    'ubicacion': location,
                    'activo': true,
                  });
                });
                _saveHouses();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _removeDevice(int index) {
    setState(() {
      devices.removeAt(index);
    });
    _saveHouses();
  }

  void _toggleDeviceStatus(int index) {
    setState(() {
      devices[index]['activo'] = !devices[index]['activo'];
    });
    _saveHouses();
  }

  void _configureDevice(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Configurar Dispositivo'),
          backgroundColor: Colors.grey[50], // Fondo gris claro
          content: Text('Aquí iría la configuración específica para ${devices[index]['nombre']}'),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Dispositivos IoT'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          var device = devices[index];
          return ListTile(
            title: Text(device['nombre'], style: TextStyle(color: Colors.white)),
            subtitle: Text('${device['tipo']} - ${device['ubicacion']}', style: TextStyle(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: device['activo'],
                  onChanged: (bool value) {
                    _toggleDeviceStatus(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: kAccentColor),
                  onPressed: () => _configureDevice(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: kAccentColor),
                  onPressed: () => _removeDevice(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: Icon(Icons.add),
        tooltip: 'Agregar Dispositivo IoT',
      ),
    );
  }
}