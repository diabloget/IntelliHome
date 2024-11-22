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
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _house = Map<String, dynamic>.from(widget.house);
  }

  bool _isDayAvailable(DateTime day) {
    // Don't allow past dates
    if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return false;
    }

    // If there are no reservations, all future dates are available
    if (_house['reservaciones'] == null || _house['reservaciones'].isEmpty) {
      return true;
    }

    // Convert the day to start of day for accurate comparison
    final date = DateTime(day.year, day.month, day.day);

    // Check if this date falls within any existing reservation
    for (var reservation in _house['reservaciones']) {
      DateTime startDate = DateTime.parse(reservation['startDate']);
      DateTime endDate = DateTime.parse(reservation['endDate']);

      // Convert reservation dates to start of day for accurate comparison
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      endDate = DateTime(endDate.year, endDate.month, endDate.day);

      if (!date.isBefore(startDate) && !date.isAfter(endDate)) {
        return false; // Date is not available
      }
    }
    return true; // Date is available
  }

  bool _isDateRangeAvailable(DateTimeRange range) {
    // Check each day in the range
    for (var date = range.start;
        date.isBefore(range.end.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      if (!_isDayAvailable(date)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final lastDate = now.add(const Duration(days: 365));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.blueGrey,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.blueGrey[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (_isDateRangeAvailable(picked)) {
        setState(() {
          _selectedDateRange = picked;
        });
        _showConfirmationDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('El rango de fechas seleccionado no está disponible'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _showConfirmationDialog() {
    if (_selectedDateRange == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Reservación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fechas seleccionadas:'),
              Text(
                  'Desde: ${_selectedDateRange!.start.toString().split(' ')[0]}'),
              Text(
                  'Hasta: ${_selectedDateRange!.end.toString().split(' ')[0]}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                _rentHouse();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _rentHouse() async {
    if (_selectedDateRange == null) return;

    // Nueva reservación
    Map<String, dynamic> newReservation = {
      'startDate': _selectedDateRange!.start.toString().split(' ')[0],
      'endDate': _selectedDateRange!.end.toString().split(' ')[0],
      'maestro': widget.alias,
      'asociado': widget.alias,
    };

    setState(() {
      if (_house['reservaciones'] == null) {
        _house['reservaciones'] = [];
      }
      _house['reservaciones'].add(newReservation);
    });

    // Obtener el archivo JSON
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/casas.json';
    File file = File(filePath);

    if (await file.exists()) {
      String content = await file.readAsString();
      List<dynamic> houses = jsonDecode(content);

      // Verificar y actualizar solo las reservas de la casa especificada
      if (houses[widget.houseIndex] != null) {
        houses[widget.houseIndex]['reservaciones'] = _house['reservaciones'];
        await file.writeAsString(jsonEncode(houses));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservación realizada con éxito')),
        );
        Navigator.pop(context, true);
      }
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
              child: Text('Reservar'),
              onPressed: _selectDateRange,
            ),
            if (_house['reservaciones']?.isNotEmpty ?? false) ...[
              SizedBox(height: 16),
              Text(
                'Reservaciones Existentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _house['reservaciones'].length,
                itemBuilder: (context, index) {
                  var reservation = _house['reservaciones'][index];
                  return ListTile(
                    title: Text(
                      'Reservado por: ${reservation['maestro']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Desde: ${reservation['startDate']} - Hasta: ${reservation['endDate']}',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
