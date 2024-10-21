import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HouseDetail extends StatefulWidget {
  final Map<String, dynamic> house;
  final String alias;
  final int houseIndex;

  const HouseDetail({
    Key? key,
    required this.house,
    required this.alias,
    required this.houseIndex,
  }) : super(key: key);

  @override
  _HouseDetailState createState() => _HouseDetailState();
}

class _HouseDetailState extends State<HouseDetail> {
  late Map<String, dynamic> _house;

  @override
  void initState() {
    super.initState();
    _house = Map<String, dynamic>.from(widget.house);
  }

  Future<void> _rentHouse() async {
    setState(() {
      _house['maestro'] = widget.alias;
      _house['disponible'] = false;
    });

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    if (await file.exists()) {
      String content = await file.readAsString();
      List<dynamic> houses = jsonDecode(content);
      houses[widget.houseIndex] = _house;
      await file.writeAsString(jsonEncode(houses));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Casa alquilada con éxito')),
      );
      Navigator.pop(context, true); // Pass true to indicate changes were made
    }
  }

  Future<void> _openGoogleMaps() async {
    final lat = _house['latitud'];
    final lng = _house['longitud'];
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      if (await canLaunchUrlString(url)) {
        final bool launched = await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          throw 'Could not launch $url';
        }
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir Google Maps: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de la Casa"),
        backgroundColor: Colors.blue,
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
            _house['fotos'].isNotEmpty
                ? Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _house['fotos'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.file(
                            File(_house['fotos'][index]),
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
              'Capacidad: ${_house['capacidad']} personas',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Habitaciones: ${_house['habitaciones']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Baños: ${_house['banos']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Ubicación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Latitud: ${_house['latitud']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Longitud: ${_house['longitud']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            ElevatedButton(
              child: Text('Ver en Google Maps'),
              onPressed: _openGoogleMaps,
            ),
            SizedBox(height: 16),
            Text(
              'Características Generales',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _house['caracteristicas_generales'],
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Otras Características',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _house['otras_caracteristicas'],
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Dispositivos Activos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: (_house['dispositivos'] as List)
                  .where((d) => d['activo'])
                  .length,
              itemBuilder: (context, index) {
                var device = (_house['dispositivos'] as List)
                    .where((d) => d['activo'])
                    .toList()[index];
                return ListTile(
                  title: Text(device['nombre'],
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text('${device['tipo']} - ${device['ubicacion']}',
                      style: TextStyle(color: Colors.white70)),
                  trailing: ElevatedButton(
                    child: Text('Info'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Información del Dispositivo'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Nombre: ${device['nombre']}'),
                                Text('Tipo: ${device['tipo']}'),
                                Text('Ubicación: ${device['ubicacion']}'),
                                Text('Estado: Activo'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: Text('Cerrar'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Alquilar'),
              onPressed: _house['disponible'] ? _rentHouse : null,
            ),
          ],
        ),
      ),
    );
  }
}
