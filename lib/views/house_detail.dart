import 'dart:io';
import 'package:flutter/material.dart';

class HouseDetail extends StatelessWidget {
  final Map<String, dynamic> house;

  HouseDetail({required this.house});

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
            house['fotos'].isNotEmpty
                ? Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: house['fotos'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.file(
                      File(house['fotos'][index]),
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
              'Capacidad: ${house['capacidad']} personas',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Habitaciones: ${house['habitaciones']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Baños: ${house['banos']}',
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
              itemCount: (house['dispositivos'] as List).where((d) => d['activo']).length,
              itemBuilder: (context, index) {
                var device = (house['dispositivos'] as List).where((d) => d['activo']).toList()[index];
                return ListTile(
                  title: Text(device['nombre'], style: TextStyle(color: Colors.white)),
                  subtitle: Text('${device['tipo']} - ${device['ubicacion']}', style: TextStyle(color: Colors.white70)),
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
          ],
        ),
      ),
    );
  }
}