import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/nota.dart';

class PDFService {
  static Future<void> generateAndSharePDF(Nota nota) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  children: [
                    pw.Icon(pw.IconData(0xe0af), size: 48, color: PdfColors.blue700),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'SASTRERÍA PROFESIONAL',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'NOTA DE SERVICIO DE AJUSTE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Información básica
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Factura No:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(nota.facturaNo, style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Fecha:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(DateFormat('dd/MM/yyyy').format(nota.fecha), 
                               style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              pw.Row(
                children: [
                  pw.Text('Cliente: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                    child: pw.Text(nota.cliente, style: pw.TextStyle(fontSize: 16)),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Tabla de ajustes
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Encabezado
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Cant.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Valor Unit.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Importe', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de ajustes
                  ...nota.ajustes.map((ajuste) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.cantidad.toString()),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.descripcion),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.valorUnitario.toStringAsFixed(2)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.importe.toStringAsFixed(2)),
                      ),
                    ],
                  )),
                ],
              ),

              pw.SizedBox(height: 20),

              // Totales
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 16)),
                        pw.Text(nota.subtotal.toStringAsFixed(2), style: pw.TextStyle(fontSize: 16)),
                      ],
                    ),
                    if (nota.aCuenta > 0) ...[
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('A Cuenta:', style: pw.TextStyle(fontSize: 16)),
                          pw.Text(nota.aCuenta.toStringAsFixed(2), style: pw.TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                    pw.Divider(color: PdfColors.blue300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text(nota.saldo.toStringAsFixed(2), 
                                 style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Información adicional
              if (nota.observaciones.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Observaciones:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(nota.observaciones),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
              ],

              if (nota.direccion.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Dirección:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(nota.direccion),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
              ],

              if (nota.telefono.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Teléfono:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(nota.telefono),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
              ],

              // Términos y condiciones
              if (nota.incluirTerminos) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow50,
                    border: pw.Border.all(color: PdfColors.yellow300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Términos y Condiciones:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '• El trabajo se entrega en un plazo de 3 a 5 días hábiles.\n'
                        '• Se requiere el 50% de anticipo para iniciar el trabajo.\n'
                        '• Las modificaciones adicionales tendrán costo extra.\n'
                        '• La empresa no se hace responsable por daños en prendas muy deterioradas.\n'
                        '• Conserve este recibo para recoger su prenda.',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    // Guardar los bytes generados por el PDF
    final bytes = await pdf.save();

    // Verificar si el plugin de printing está disponible
    bool printingAvailable = await _isPrintingAvailable();
    
    if (printingAvailable) {
      try {
        // Intenta usar Printing.sharePdf (opción preferida: vista previa + compartir + imprimir)
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'nota_${nota.facturaNo}.pdf',
        );
        return;
      } catch (e) {
        print('Error al usar Printing.sharePdf: $e');
        // Continúa con el método alternativo
      }
    }

    // Método alternativo: usar share_plus
    await _shareUsingSharePlus(bytes, nota.facturaNo);
  }

  // Método para verificar si el plugin de printing está disponible
  static Future<bool> _isPrintingAvailable() async {
    try {
      // Intenta acceder a una función básica del plugin
      await Printing.info();
      return true;
    } catch (e) {
      print('Plugin de printing no disponible: $e');
      return false;
    }
  }

  // Método alternativo usando share_plus
  static Future<void> _shareUsingSharePlus(List<int> bytes, String facturaNo) async {
    try {
      // Obtener directorio temporal
      final outputDir = await getTemporaryDirectory();
      final file = File('${outputDir.path}/nota_$facturaNo.pdf');
      
      // Escribir bytes al archivo
      await file.writeAsBytes(bytes);

      // Compartir usando share_plus
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Nota de servicio: $facturaNo',
        subject: 'Nota de Servicio - Sastrería Profesional',
      );
    } catch (e) {
      print('Error al compartir con share_plus: $e');
      throw Exception('No se pudo compartir el PDF: $e');
    }
  }

  // Método alternativo que solo usa share_plus (más confiable)
  static Future<void> generateAndSharePDFSimple(Nota nota) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  children: [
                    pw.Icon(pw.IconData(0xe0af), size: 48, color: PdfColors.blue700),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'SASTRERÍA PROFESIONAL',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'NOTA DE SERVICIO DE AJUSTE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Información básica
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Factura No:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(nota.facturaNo, style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Fecha:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(DateFormat('dd/MM/yyyy').format(nota.fecha), 
                               style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              pw.Row(
                children: [
                  pw.Text('Cliente: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                    child: pw.Text(nota.cliente, style: pw.TextStyle(fontSize: 16)),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Tabla de ajustes
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Encabezado
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Cant.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Valor Unit.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Importe', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Filas de ajustes
                  ...nota.ajustes.map((ajuste) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.cantidad.toString()),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.descripcion),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.valorUnitario.toStringAsFixed(2)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(ajuste.importe.toStringAsFixed(2)),
                      ),
                    ],
                  )),
                ],
              ),

              pw.SizedBox(height: 20),

              // Totales
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 16)),
                        pw.Text(nota.subtotal.toStringAsFixed(2), style: pw.TextStyle(fontSize: 16)),
                      ],
                    ),
                    if (nota.aCuenta > 0) ...[
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('A Cuenta:', style: pw.TextStyle(fontSize: 16)),
                          pw.Text(nota.aCuenta.toStringAsFixed(2), style: pw.TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                    pw.Divider(color: PdfColors.blue300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text(nota.saldo.toStringAsFixed(2), 
                                 style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Información adicional
              if (nota.observaciones.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Observaciones:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(nota.observaciones),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
              ],

              if (nota.direccion.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Dirección:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(nota.direccion),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
              ],

              if (nota.telefono.isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Teléfono:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(nota.telefono),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
              ],

              // Términos y condiciones
              if (nota.incluirTerminos) ...[
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow50,
                    border: pw.Border.all(color: PdfColors.yellow300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Términos y Condiciones:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '• El trabajo se entrega en un plazo de 3 a 5 días hábiles.\n'
                        '• Se requiere el 50% de anticipo para iniciar el trabajo.\n'
                        '• Las modificaciones adicionales tendrán costo extra.\n'
                        '• La empresa no se hace responsable por daños en prendas muy deterioradas.\n'
                        '• Conserve este recibo para recoger su prenda.',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    // Guardar los bytes generados por el PDF
    final bytes = await pdf.save();

    // Solo usar share_plus (más confiable)
    await _shareUsingSharePlus(bytes, nota.facturaNo);
  }
}