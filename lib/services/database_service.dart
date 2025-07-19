import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/nota.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incrementamos la versión para activar la migración
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        factura_no TEXT NOT NULL,
        fecha TEXT NOT NULL,
        cliente TEXT NOT NULL,
        ajustes TEXT NOT NULL,
        subtotal REAL NOT NULL,
        a_cuenta REAL NOT NULL,
        saldo REAL NOT NULL,
        observaciones TEXT,
        direccion TEXT,
        telefono TEXT,
        incluir_terminos INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrar de version 1 a 2: cambiar impuestos -> a_cuenta, total -> saldo
      await db.execute('ALTER TABLE notas RENAME COLUMN impuestos TO a_cuenta');
      await db.execute('ALTER TABLE notas RENAME COLUMN total TO saldo');
    }
  }

  Future<void> init() async {
    await database;
  }

  Future<int> insertNota(Nota nota) async {
    final db = await database;
    final map = _notaToDbMap(nota);
    return await db.insert('notas', map);
  }

  Future<List<Nota>> getAllNotas() async {
    final db = await database;
    final maps = await db.query('notas', orderBy: 'fecha DESC');
    
    return maps.map((map) {
      return _dbMapToNota(map);
    }).toList();
  }

  Future<void> updateNota(Nota nota) async {
    final db = await database;
    final map = _notaToDbMap(nota);
    await db.update('notas', map, where: 'id = ?', whereArgs: [nota.id]);
  }

  Future<void> deleteNota(int id) async {
    final db = await database;
    await db.delete('notas', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> getNextFacturaNo() async {
    final db = await database;
    final year = DateTime.now().year;
    final result = await db.rawQuery(
      'SELECT factura_no FROM notas WHERE factura_no LIKE ? ORDER BY factura_no DESC LIMIT 1',
      ['$year-%']
    );
    
    if (result.isEmpty) {
      return '$year-001';
    }
    
    final lastNo = result.first['factura_no'] as String;
    final parts = lastNo.split('-');
    final nextNumber = int.parse(parts[1]) + 1;
    return '$year-${nextNumber.toString().padLeft(3, '0')}';
  }

  // Método auxiliar para convertir Nota a Map de BD
  Map<String, dynamic> _notaToDbMap(Nota nota) {
    return {
      'id': nota.id,
      'factura_no': nota.facturaNo,
      'fecha': nota.fecha.toIso8601String(),
      'cliente': nota.cliente,
      'ajustes': jsonEncode(nota.ajustes.map((a) => a.toMap()).toList()),
      'subtotal': nota.subtotal,
      'a_cuenta': nota.aCuenta,
      'saldo': nota.saldo,
      'observaciones': nota.observaciones,
      'direccion': nota.direccion,
      'telefono': nota.telefono,
      'incluir_terminos': nota.incluirTerminos ? 1 : 0,
    };
  }

  // Método auxiliar para convertir Map de BD a Nota
  Nota _dbMapToNota(Map<String, dynamic> map) {
    return Nota(
      id: map['id'],
      facturaNo: map['factura_no'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      cliente: map['cliente'] ?? '',
      ajustes: (jsonDecode(map['ajustes'] as String) as List<dynamic>)
          .map((a) => Ajuste.fromMap(a))
          .toList(),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      aCuenta: (map['a_cuenta'] ?? 0.0).toDouble(),
      saldo: (map['saldo'] ?? 0.0).toDouble(),
      observaciones: map['observaciones'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      incluirTerminos: (map['incluir_terminos'] ?? 0) == 1,
    );
  }
}