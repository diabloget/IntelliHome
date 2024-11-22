import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
                decoration:
                    InputDecoration(labelText: 'Nombre del dispositivo'),
                onChanged: (value) => name = value,
                style: TextStyle(color: Colors.black), // Texto siempre negro
                cursorColor: Colors.black, // Cursor negro
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Tipo de dispositivo'),
                onChanged: (value) => type = value,
                style: TextStyle(color: Colors.black), // Texto siempre negro
                cursorColor: Colors.black, // Cursor negro
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Ubicación en la casa'),
                onChanged: (value) => location = value,
                style: TextStyle(color: Colors.black), // Texto siempre negro
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
    // Estado inicial del Switch, puedes definirlo como quieras
    bool deviceState = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Configurar Dispositivo'),
          backgroundColor: Colors.grey[50], // Fondo gris claro
          content: StatefulBuilder(
            builder: (context, setState) {
              // Usar StatefulBuilder para manejar el estado del Switch
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Aquí iría la configuración específica para ${devices[index]['nombre']}'),
                  SwitchListTile(
                    title: Text('Encender/Apagar dispositivo'),
                    value: deviceState,
                    onChanged: (bool value) {
                      setState(() {
                        deviceState = value; // Actualizar el estado local
                      });
                      _sendCommand(devices[index]['tipo'], value);
                      // Aquí puedes enviar el comando según el tipo de dispositivo
                    },
                  ),
                ],
              );
            },
          ),
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

  void _sendCommand(String type, bool isOn) async {
    int command;

    // Asignar el comando dependiendo del tipo de dispositivo
    if (type == 'LED') {
      command = isOn ? 1 : 2; // 1 para encender, 2 para apagar
    } else if (type == 'Motor') {
      command = isOn ? 3 : 4; // 3 para encender, 4 para apagar
    } else if (type == 'Alarma') {
      command = isOn ? 5 : 6; // 5 para encender, 6 para apagar
    } else {
      return; // Si no es un tipo reconocido, no hacer nada
    }

    // URL del servidor (cambia 'IP_DE_TU_COMPUTADORA' por la IP real de tu computadora)
    String serverUrl = 'http://192.168.100.2:5000/led/$command';

    // Realiza la solicitud HTTP GET al servidor
    try {
      final response = await http.get(Uri.parse(serverUrl));
      if (response.statusCode == 200) {
        print("Comando enviado correctamente: $command");
      } else {
        print("Error al enviar comando: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al conectar al servidor: $e");
    }
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
            title:
                Text(device['nombre'], style: TextStyle(color: Colors.white)),
            subtitle: Text('${device['tipo']} - ${device['ubicacion']}',
                style: TextStyle(color: Colors.white70)),
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
