import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nota.dart';
import '../services/database_service.dart';
import 'nota_form_screen.dart';
import 'nota_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Nota> notas = [];
  List<Nota> filteredNotas = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotas();
  }

  Future<void> loadNotas() async {
    setState(() => isLoading = true);
    final loadedNotas = await DatabaseService.instance.getAllNotas();
    setState(() {
      notas = loadedNotas;
      filteredNotas = loadedNotas;
      isLoading = false;
    });
  }

  void filterNotas(String query) {
    if (query.isEmpty) {
      setState(() => filteredNotas = notas);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      filteredNotas = notas.where((nota) {
        final clienteMatch = nota.cliente.toLowerCase().contains(lowercaseQuery);
        final facturaMatch = nota.facturaNo.toLowerCase().contains(lowercaseQuery);
        final ajustesMatch = nota.ajustes.any((ajuste) =>
            ajuste.descripcion.toLowerCase().contains(lowercaseQuery));
        return clienteMatch || facturaMatch || ajustesMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas de Ajuste'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: filterNotas,
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, factura o descripción...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredNotas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              searchController.text.isEmpty
                                  ? 'No hay notas registradas'
                                  : 'No se encontraron resultados',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredNotas.length,
                        itemBuilder: (context, index) {
                          final nota = filteredNotas[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.pink,
                                child: Text(
                                  nota.cliente.isNotEmpty ? nota.cliente[0] : 'N',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                nota.cliente,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Factura: ${nota.facturaNo}'),
                                  Text(
                                    'Fecha: ${DateFormat('dd/MM/yyyy').format(nota.fecha)}',
                                  ),
                                  Text(
                                    'Saldo: \$${nota.saldo.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: nota.saldo > 0 ? Colors.red[700] : Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirmar eliminación'),
                                        content: Text('¿Estás seguro de que quieres eliminar esta nota?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await DatabaseService.instance.deleteNota(nota.id!);
                                      loadNotas();
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotaDetailScreen(nota: nota),
                                  ),
                                );
                                if (result == true) {
                                  loadNotas();
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotaFormScreen()),
          );
          if (result == true) {
            loadNotas();
          }
        },
        backgroundColor: Colors.pink,
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}