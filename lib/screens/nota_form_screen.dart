import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nota.dart';
import '../services/database_service.dart';

class NotaFormScreen extends StatefulWidget {
  final Nota? nota;

  const NotaFormScreen({super.key, this.nota});

  @override
  _NotaFormScreenState createState() => _NotaFormScreenState();
}

class _NotaFormScreenState extends State<NotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController clienteController;
  late TextEditingController observacionesController;
  late TextEditingController direccionController;
  late TextEditingController telefonoController;
  late TextEditingController aCuentaController;  // Cambiado de impuestosController
  
  DateTime selectedDate = DateTime.now();
  List<AjusteFormItem> ajustes = [];
  bool incluirTerminos = true;
  String paymentStatus = 'pending';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    clienteController = TextEditingController(text: widget.nota?.cliente ?? '');
    observacionesController = TextEditingController(text: widget.nota?.observaciones ?? '');
    direccionController = TextEditingController(text: widget.nota?.direccion ?? '');
    telefonoController = TextEditingController(text: widget.nota?.telefono ?? '');
    aCuentaController = TextEditingController(text: widget.nota?.aCuenta.toString() ?? '0');
    
    if (widget.nota != null) {
      selectedDate = widget.nota!.fecha;
      incluirTerminos = widget.nota!.incluirTerminos;
      paymentStatus = widget.nota!.paymentStatus;
      ajustes = widget.nota!.ajustes.map((a) => AjusteFormItem.fromAjuste(a)).toList();
    } else {
      ajustes.add(AjusteFormItem());
    }
  }

  void addAjuste() {
    setState(() {
      ajustes.add(AjusteFormItem());
    });
  }

  void removeAjuste(int index) {
    setState(() {
      ajustes.removeAt(index);
    });
  }

  double calculateSubtotal() {
    return ajustes.fold(0.0, (sum, ajuste) => sum + ajuste.getImporte());
  }

  double calculateSaldo() {
    final subtotal = calculateSubtotal();
    final aCuenta = double.tryParse(aCuentaController.text) ?? 0.0;
    return subtotal - aCuenta;  // El saldo es lo que resta pagar
  }

  Future<void> saveNota() async {
    if (!_formKey.currentState!.validate()) return;
    if (ajustes.isEmpty || !ajustes.any((a) => a.isValid())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debe agregar al menos un ajuste válido')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final facturaNo = widget.nota?.facturaNo ?? 
          await DatabaseService.instance.getNextFacturaNo();
      
      final nota = Nota(
        id: widget.nota?.id,
        facturaNo: facturaNo,
        fecha: selectedDate,
        cliente: clienteController.text,
        ajustes: ajustes.where((a) => a.isValid()).map((a) => a.toAjuste()).toList(),
        subtotal: calculateSubtotal(),
        aCuenta: double.tryParse(aCuentaController.text) ?? 0.0,
        saldo: calculateSaldo(),
        observaciones: observacionesController.text,
        direccion: direccionController.text,
        telefono: telefonoController.text,
        incluirTerminos: incluirTerminos,
        paymentStatus: paymentStatus,
      );

      if (widget.nota == null) {
        await DatabaseService.instance.insertNota(nota);
      } else {
        await DatabaseService.instance.updateNota(nota);
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nota == null ? 'Nueva Nota' : 'Editar Nota'),
        actions: [
          if (isLoading)
            Center(child: CircularProgressIndicator(color: Colors.white))
          else
            IconButton(
              icon: Icon(Icons.save),
              onPressed: saveNota,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Cliente
            TextFormField(
              controller: clienteController,
              decoration: InputDecoration(
                labelText: 'Nombre del Cliente *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El nombre del cliente es requerido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Fecha
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
              ),
            ),
            SizedBox(height: 16),

            // Teléfono
            TextFormField(
              controller: telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            // Dirección
            TextFormField(
              controller: direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Ajustes
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ajustes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: addAjuste,
                        ),
                      ],
                    ),
                    ...ajustes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ajuste = entry.value;
                      return AjusteFormWidget(
                        ajuste: ajuste,
                        onRemove: ajustes.length > 1 ? () => removeAjuste(index) : null,
                        onChanged: () => setState(() {}),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // A Cuenta (antes Impuestos)
            TextFormField(
              controller: aCuentaController,
              decoration: InputDecoration(
                labelText: 'A Cuenta (Anticipo)',
                border: OutlineInputBorder(),
                prefixText: '\$',
                helperText: 'Monto pagado por adelantado',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 16),

            // Totales
            Card(
              color: Colors.pink[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:'),
                        Text('\$${calculateSubtotal().toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('A Cuenta:'),
                        Text('\$${(double.tryParse(aCuentaController.text) ?? 0.0).toStringAsFixed(2)}'),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saldo:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${calculateSaldo().toStringAsFixed(2)}', 
                             style: TextStyle(
                               fontWeight: FontWeight.bold,
                               color: calculateSaldo() > 0 ? Colors.red[700] : Colors.green[700],
                             )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Observaciones
            TextFormField(
              controller: observacionesController,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Términos y condiciones
            CheckboxListTile(
              title: Text('Incluir términos y condiciones'),
              value: incluirTerminos,
              onChanged: (value) => setState(() => incluirTerminos = value ?? false),
            ),
            if (widget.nota != null) ...[
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Marcar como Completada'),
                value: paymentStatus == 'completed',
                onChanged: (value) {
                  setState(() {
                    paymentStatus = value ? 'completed' : 'pending';
                  });
                },
              ),
            ],
            SizedBox(height: 32),

            // Botón guardar
            ElevatedButton(
              onPressed: isLoading ? null : saveNota,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  widget.nota == null ? 'Crear Nota' : 'Actualizar Nota',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AjusteFormItem {
  TextEditingController cantidadController;
  TextEditingController descripcionController;
  TextEditingController valorUnitarioController;
  TextEditingController importeController;
  bool isImporteManual;

  AjusteFormItem({
    int cantidad = 1,
    String descripcion = '',
    double valorUnitario = 0.0,
    double importe = 0.0,
    this.isImporteManual = false,
  }) : cantidadController = TextEditingController(text: cantidad.toString()),
       descripcionController = TextEditingController(text: descripcion),
       valorUnitarioController = TextEditingController(text: valorUnitario.toString()),
       importeController = TextEditingController(text: importe.toString());

  factory AjusteFormItem.fromAjuste(Ajuste ajuste) {
    return AjusteFormItem(
      cantidad: ajuste.cantidad,
      descripcion: ajuste.descripcion,
      valorUnitario: ajuste.valorUnitario,
      importe: ajuste.importe,
      isImporteManual: ajuste.valorUnitario == 0.0 || ajuste.importe != (ajuste.cantidad * ajuste.valorUnitario),
    );
  }

  bool isValid() {
    return descripcionController.text.isNotEmpty;
  }

  double getImporte() {
    if (isImporteManual) {
      return double.tryParse(importeController.text) ?? 0.0;
    } else {
      final cantidad = int.tryParse(cantidadController.text) ?? 0;
      final valorUnitario = double.tryParse(valorUnitarioController.text) ?? 0.0;
      return cantidad * valorUnitario;
    }
  }

  Ajuste toAjuste() {
    return Ajuste(
      cantidad: int.tryParse(cantidadController.text) ?? 0,
      descripcion: descripcionController.text,
      valorUnitario: double.tryParse(valorUnitarioController.text) ?? 0.0,
      importe: getImporte(),
    );
  }

  void dispose() {
    cantidadController.dispose();
    descripcionController.dispose();
    valorUnitarioController.dispose();
    importeController.dispose();
  }
}

class AjusteFormWidget extends StatefulWidget {
  final AjusteFormItem ajuste;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const AjusteFormWidget({super.key, 
    required this.ajuste,
    this.onRemove,
    required this.onChanged,
  });

  @override
  _AjusteFormWidgetState createState() => _AjusteFormWidgetState();
}

class _AjusteFormWidgetState extends State<AjusteFormWidget> {
  @override
  void initState() {
    super.initState();
    widget.ajuste.cantidadController.addListener(_updateImporte);
    widget.ajuste.valorUnitarioController.addListener(_updateImporte);
  }

  void _updateImporte() {
    if (!widget.ajuste.isImporteManual) {
      final cantidad = int.tryParse(widget.ajuste.cantidadController.text) ?? 0;
      final valorUnitario = double.tryParse(widget.ajuste.valorUnitarioController.text) ?? 0.0;
      final importe = cantidad * valorUnitario;
      widget.ajuste.importeController.text = importe.toStringAsFixed(2);
    }
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: widget.ajuste.cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cant.',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: widget.ajuste.descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.ajuste.valorUnitarioController,
                    decoration: InputDecoration(
                      labelText: 'Valor Unit.',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixText: '\$'
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: widget.ajuste.importeController,
                    decoration: InputDecoration(
                      labelText: 'Importe',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixText: '\$'
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      widget.ajuste.isImporteManual = true;
                      widget.onChanged();
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    widget.ajuste.isImporteManual ? Icons.edit : Icons.calculate,
                    color: widget.ajuste.isImporteManual ? Colors.orange : Colors.pink,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.ajuste.isImporteManual = !widget.ajuste.isImporteManual;
                      if (!widget.ajuste.isImporteManual) {
                        _updateImporte();
                      }
                    });
                  },
                  tooltip: widget.ajuste.isImporteManual ? 'Calcular automático' : 'Editar manual',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}