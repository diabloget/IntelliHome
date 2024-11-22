import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaymentPlanSelector extends StatefulWidget {
  final List<dynamic> plans;
  final DateTimeRange dateRange;

  const PaymentPlanSelector({
    Key? key,
    required this.plans,
    required this.dateRange,
  }) : super(key: key);

  @override
  _PaymentPlanSelectorState createState() => _PaymentPlanSelectorState();
}

class _PaymentPlanSelectorState extends State<PaymentPlanSelector> {
  int? selectedPlanIndex;
  double total = 0.0;

  int calculateMonths() {
    final days =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    return (days / 30)
        .ceil(); // Redondear hacia arriba para cobrar mes completo
  }

  int calculateDays() {
    return widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
  }

  void _calculateTotal(int index) {
    final plan = widget.plans[index];
    if (index == 2) {
      // Plan diario
      total = plan['price'] * calculateDays();
    } else {
      // Planes mensuales
      total = plan['price'] * calculateMonths();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.plans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          return RadioListTile<int>(
            title: Text(plan['name']),
            subtitle: Text(
                '\$${plan['price'].toStringAsFixed(2)} ${index == 2 ? "por día" : "por mes"}'),
            value: index,
            groupValue: selectedPlanIndex,
            onChanged: (int? value) {
              setState(() {
                selectedPlanIndex = value;
                if (value != null) {
                  _calculateTotal(value);
                }
              });
            },
          );
        }).toList(),
        if (selectedPlanIndex != null) ...[
          const SizedBox(height: 16),
          Text(
            'Resumen del pago:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(selectedPlanIndex == 2
              ? '${calculateDays()} días x \$${widget.plans[selectedPlanIndex!]['price']}'
              : '${calculateMonths()} mes(es) x \$${widget.plans[selectedPlanIndex!]['price']}'),
          const SizedBox(height: 8),
          Text(
            'Total a pagar: \$${total.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ],
    );
  }
}

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

  void _showPaymentPlanDialog() {
    if (_selectedDateRange == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Plan de Pago'),
          content: PaymentPlanSelector(
            plans: _house['planes'],
            dateRange: _selectedDateRange!,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceder al Pago'),
              onPressed: () {
                Navigator.of(context).pop();
                _showCreditCardDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreditCardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pago con Tarjeta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número de Tarjeta',
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Fecha de Vencimiento',
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre en la Tarjeta',
                  hintText: 'JOHN DOE',
                ),
              ),
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
              child: Text('Pagar'),
              onPressed: () {
                Navigator.of(context).pop();
                _processPaymentAndRent();
              },
            ),
          ],
        );
      },
    );
  }

  void _processPaymentAndRent() {
    // Aquí iría la lógica de procesamiento del pago
    // Por ahora, solo mostraremos un mensaje de éxito y procederemos con la reservación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pago procesado con éxito')),
    );
    _rentHouse();
  }

  // Modificar el método _showConfirmationDialog
  void _showConfirmationDialog() {
    if (_selectedDateRange == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Fechas'),
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
              child: Text('Continuar'),
              onPressed: () {
                Navigator.of(context).pop();
                _showPaymentPlanDialog();
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
