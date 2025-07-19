import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nota.dart';
import '../services/pdf_service.dart';
import 'nota_form_screen.dart';

class NotaDetailScreen extends StatelessWidget {
  final Nota nota;

  const NotaDetailScreen({super.key, required this.nota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nota ${nota.facturaNo}'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotaFormScreen(nota: nota),
                ),
              );
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              try {
                await PDFService.generateAndSharePDFSimple(nota);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al generar PDF: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Encabezado
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  border: Border(bottom: BorderSide(color: Colors.pink[200]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.business, size: 48, color: Colors.pink[700]),
                    SizedBox(height: 8),
                    Text(
                      'Andrea Gomez: Alta Costura',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'NOTA DE SERVICIO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Información básica
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Factura No:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(nota.facturaNo, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Fecha:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(DateFormat('dd/MM/yyyy').format(nota.fecha), 
                                 style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Cliente: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(nota.cliente, style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tabla de ajustes
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    // Encabezado de tabla
                    Container(
                      padding: EdgeInsets.all(12),
                      color: Colors.grey[100],
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 4, child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Valor Unit.', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Importe', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    // Filas de ajustes
                    ...nota.ajustes.map((ajuste) => Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: Text(ajuste.cantidad.toString())),
                          Expanded(flex: 4, child: Text(ajuste.descripcion)),
                          Expanded(flex: 2, child: Text('\$${ajuste.valorUnitario.toStringAsFixed(2)}')),
                          Expanded(flex: 2, child: Text('\$${ajuste.importe.toStringAsFixed(2)}')),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

              // Totales
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  border: Border.all(color: Colors.pink[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:', style: TextStyle(fontSize: 16)),
                        Text('\$${nota.subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    if (nota.aCuenta > 0) ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('A Cuenta:', style: TextStyle(fontSize: 16)),
                          Text('\$${nota.aCuenta.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                    Divider(color: Colors.pink[300]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saldo:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('\$${nota.saldo.toStringAsFixed(2)}', 
                             style: TextStyle(
                               fontSize: 18, 
                               fontWeight: FontWeight.bold, 
                               color: nota.saldo > 0 ? Colors.red[700] : Colors.green[700]
                             )),
                      ],
                    ),
                  ],
                ),
              ),

              // Información adicional
              if (nota.observaciones.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(nota.observaciones),
                    ],
                  ),
                ),
              ],

              if (nota.direccion.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dirección:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(nota.direccion),
                    ],
                  ),
                ),
              ],

              if (nota.telefono.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teléfono:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(nota.telefono),
                    ],
                  ),
                ),
              ],

              // Términos y condiciones
              if (nota.incluirTerminos) ...[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    border: Border.all(color: Colors.yellow[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Términos y Condiciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        '• El trabajo se entrega en un plazo de 3 a 5 días hábiles.\n'
                        '• Se requiere el 50% de anticipo para iniciar el trabajo.\n'
                        '• Las modificaciones adicionales tendrán costo extra.\n'
                        '• La empresa no se hace responsable por daños en prendas muy deterioradas.\n'
                        '• Conserve este recibo para recoger su prenda.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}