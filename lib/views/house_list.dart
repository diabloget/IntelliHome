import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'house_detail.dart';

class HouseList extends StatefulWidget {
  final String alias;

  const HouseList({Key? key, required this.alias}) : super(key: key);
  @override
  _HouseListState createState() => _HouseListState();
}

class _HouseListState extends State<HouseList> {
  List<dynamic> houses = [];
  DateTimeRange? selectedDateRange;

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
        houses = jsonDecode(content)
            .where((house) => house['disponible'] == true)
            .toList();
      });
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final lastDate = now.add(const Duration(days: 365));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  bool _hasDateConflict(Map<String, dynamic> house) {
    if (selectedDateRange == null) return false;

    List<dynamic> reservations = house['reservaciones'] ?? [];

    for (var reservation in reservations) {
      DateTime reservationStart = DateTime.parse(reservation['startDate']);
      DateTime reservationEnd = DateTime.parse(reservation['endDate']);

      // Check if selected range overlaps with any existing reservation
      bool hasOverlap = !(selectedDateRange!.end.isBefore(reservationStart) ||
          selectedDateRange!.start.isAfter(reservationEnd));

      if (hasOverlap) return true;
    }

    return false;
  }

  void _navigateToHouseDetail(
      BuildContext context, Map<String, dynamic> house, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HouseDetail(
          house: house,
          alias: widget.alias,
          houseIndex: index,
        ),
      ),
    );

    if (result == true) {
      _loadHouses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Casas Disponibles'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          if (selectedDateRange != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => setState(() {
                selectedDateRange = null;
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          if (selectedDateRange != null)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Período seleccionado: ${selectedDateRange!.start.toString().split(' ')[0]} - ${selectedDateRange!.end.toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          Expanded(
            child: houses.isEmpty
                ? Center(
                    child: Text(
                      "No hay casas disponibles",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: houses.length,
                    itemBuilder: (context, index) {
                      var house = houses[index];
                      String imagePath =
                          house['fotos'].isNotEmpty ? house['fotos'][0] : '';
                      bool hasConflict = _hasDateConflict(house);

                      return GestureDetector(
                        onTap: () =>
                            _navigateToHouseDetail(context, house, index),
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: hasConflict
                                ? Colors.orange[900]
                                : Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              imagePath.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(imagePath),
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[800],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[400],
                                        size: 100,
                                      ),
                                    ),
                              SizedBox(height: 8),
                              if (hasConflict)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Conflicto de fechas',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 8),
                              Text(
                                'Capacidad: ${house['capacidad']} personas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Habitaciones: ${house['habitaciones']}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Baños: ${house['banos']}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Dispositivos activos: ${(house['dispositivos'] as List).where((d) => d['activo']).length}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
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
