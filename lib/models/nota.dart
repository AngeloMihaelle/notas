class Ajuste {
  int cantidad;
  String descripcion;
  double valorUnitario;
  double importe;

  Ajuste({
    required this.cantidad,
    required this.descripcion,
    required this.valorUnitario,
    required this.importe,
  });

  Map<String, dynamic> toMap() {
    return {
      'cantidad': cantidad,
      'descripcion': descripcion,
      'valor_unitario': valorUnitario,
      'importe': importe,
    };
  }

  factory Ajuste.fromMap(Map<String, dynamic> map) {
    return Ajuste(
      cantidad: map['cantidad'] ?? 0,
      descripcion: map['descripcion'] ?? '',
      valorUnitario: (map['valor_unitario'] ?? 0.0).toDouble(),
      importe: (map['importe'] ?? 0.0).toDouble(),
    );
  }
}

class Nota {
  int? id;
  String facturaNo;
  DateTime fecha;
  
  String cliente;
  List<Ajuste> ajustes;
  double subtotal;
  double aCuenta;  // Monto pagado por adelantado
  double saldo;    // Lo que resta por pagar (subtotal - aCuenta)
  String observaciones;
  String direccion;
  String telefono;
  bool incluirTerminos;

  Nota({
    this.id,
    required this.facturaNo,
    required this.fecha,
    required this.cliente,
    required this.ajustes,
    required this.subtotal,
    required this.aCuenta,
    required this.saldo,
    required this.observaciones,
    required this.direccion,
    required this.telefono,
    required this.incluirTerminos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'factura_no': facturaNo,
      'fecha': fecha.toIso8601String(),
      'cliente': cliente,
      'ajustes': ajustes.map((a) => a.toMap()).toList(),
      'subtotal': subtotal,
      'a_cuenta': aCuenta,
      'saldo': saldo,
      'observaciones': observaciones,
      'direccion': direccion,
      'telefono': telefono,
      'incluir_terminos': incluirTerminos ? 1 : 0,
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'],
      facturaNo: map['factura_no'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      cliente: map['cliente'] ?? '',
      ajustes: (map['ajustes'] as List<dynamic>)
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

  void calcularTotales() {
    subtotal = ajustes.fold(0.0, (sum, ajuste) => sum + ajuste.importe);
    saldo = subtotal - aCuenta;  // El saldo es lo que resta pagar
  }
}