import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMEI Scanner LBK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScanScreen(),
    );
  }
}

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _imei = '';
  String _model = 'Modèle inconnu';
  String _date = '';
  double _price = 0.0;

  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'imei_scanner.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE scans(id INTEGER PRIMARY KEY, imei TEXT, model TEXT, date TEXT, price REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> _scanIMEI() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
      '#FF0000', 'Annuler', true, ScanMode.BARCODE,
    );

    if (barcode != '-1') {
      setState(() {
        _imei = barcode;
        _date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });

      // Simuler la détection du modèle (remplacer par une API réelle)
      _model = _detectModelFromIMEI(_imei);
    }
  }

  String _detectModelFromIMEI(String imei) {
    // Simuler une détection de modèle (à remplacer par une API réelle)
    return 'iPhone 13 Pro Max';
  }

  Future<void> _saveScan() async {
    if (_database != null) {
      await _database!.insert(
        'scans',
        {
          'imei': _imei,
          'model': _model,
          'date': _date,
          'price': _price,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IMEI Scanner LBK'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('IMEI: $_imei'),
            Text('Modèle: $_model'),
            Text('Date du scan: $_date'),
            TextField(
              decoration: InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _price = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanIMEI,
              child: Text('Scanner IMEI'),
            ),
            ElevatedButton(
              onPressed: _saveScan,
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
