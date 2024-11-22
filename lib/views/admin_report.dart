import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class AdminRentalsView extends StatefulWidget {
  const AdminRentalsView({Key? key}) : super(key: key);

  @override
  _AdminRentalsViewState createState() => _AdminRentalsViewState();
}

class _AdminRentalsViewState extends State<AdminRentalsView> {
  List<Map<String, dynamic>> houses = [];
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? selectedHouse;

  @override
  void initState() {
    super.initState();
    _loadRentedHouses();
  }

  Future<void> _loadRentedHouses() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    if (await file.exists()) {
      String content = await file.readAsString();
      List<dynamic> allHouses = jsonDecode(content);

      setState(() {
        houses = allHouses
            .where((house) {
              List<dynamic> reservations = house['reservaciones'] ?? [];
              return reservations.any((reservation) {
                DateTime startDate = DateTime.parse(reservation['startDate']);
                DateTime endDate = DateTime.parse(reservation['endDate']);

                return startDate.year == selectedDate.year &&
                        startDate.month == selectedDate.month ||
                    (endDate.year == selectedDate.year &&
                        endDate.month == selectedDate.month);
              });
            })
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    }
  }

  Widget _buildHouseImage(List<dynamic>? imagePaths) {
    if (imagePaths == null || imagePaths.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.home,
          size: 40,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imagePaths[0]),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  void _showHouseDetails(Map<String, dynamic> house) {
    setState(() {
      selectedHouse = house;
    });

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          width: math.min(MediaQuery.of(context).size.width * 0.9, 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detalles de la Casa',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (house['fotos'] != null &&
                    (house['fotos'] as List).isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(house['fotos'][0]),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Capacidad: ${house['capacidad']} personas'),
                Text('Habitaciones: ${house['habitaciones']}'),
                Text('Baños: ${house['banos']}'),
                if (house['caracteristicas_generales'] != null)
                  Text(
                      'Características: ${house['caracteristicas_generales']}'),
                const SizedBox(height: 16),
                // Mostrar todos los planes de pago disponibles
                if (house['planes'] != null) ...[
                  Text(
                    'Planes de Pago',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...(house['planes'] as List)
                      .map(
                          (plan) => Text('${plan['name']}: \$${plan['price']}'))
                      .toList(),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Reservaciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._buildReservationsList(house['reservaciones'] ?? []),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReservationsList(List<dynamic> reservations) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return reservations.map((reservation) {
      DateTime startDate = DateTime.parse(reservation['startDate']);
      DateTime endDate = DateTime.parse(reservation['endDate']);

      if (startDate.month == selectedDate.month ||
          endDate.month == selectedDate.month) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuario: ${reservation['maestro']}'),
                Text(
                  'Periodo: ${formatter.format(startDate)} - ${formatter.format(endDate)}',
                ),
              ],
            ),
          ),
        );
      }
      return Container();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casas Alquiladas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  selectedDate = DateTime(picked.year, picked.month);
                });
                _loadRentedHouses();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Mes seleccionado: ${DateFormat('MMMM yyyy').format(selectedDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: houses.isEmpty
                ? const Center(
                    child: Text('No hay casas alquiladas en este mes'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: houses.length,
                    itemBuilder: (context, index) {
                      final house = houses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _buildHouseImage(house['fotos']),
                          title: Text(
                            'Casa ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Capacidad: ${house['capacidad']} personas'),
                              Text('Habitaciones: ${house['habitaciones']}'),
                            ],
                          ),
                          onTap: () => _showHouseDetails(house),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
