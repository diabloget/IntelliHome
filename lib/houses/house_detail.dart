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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Mostrar fotos una por una
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
            // Características generales
            Text(
              'Características Generales: ${house['caracteristicas_generales']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            // Otras características
            Text(
              'Otras Características: ${house['otras_caracteristicas']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            // Dispositivos (lista con scroll)
            Text(
              'Dispositivos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: house['dispositivos'].length,
                itemBuilder: (context, index) {
                  return Text(
                    house['dispositivos'][index],
                    style: TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Latitud y Longitud
            Text(
              'Latitud: ${house['latitud']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Longitud: ${house['longitud']}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
