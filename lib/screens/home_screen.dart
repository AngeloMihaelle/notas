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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Nota> notas = [];
  List<Nota> filteredNotas = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Do nothing while animating.
      } else {
        setState(() {
          // The selected tab has changed, so we filter the notes.
          // The filtering logic is now inside _buildNotaList.
        });
      }
    });
    loadNotas();
  }

  Future<void> loadNotas() async {
    setState(() => isLoading = true);
    // Fetch all notas regardless of status for search functionality
    final loadedNotas = await DatabaseService.instance.getAllNotas();
    setState(() {
      notas = loadedNotas;
      // Initial filter based on search query
      filterNotas(searchController.text);
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
        final statusText = nota.paymentStatus == 'pending' ? 'pendiente' : 'completado';
        final statusMatch = statusText.contains(lowercaseQuery);
        final ajustesMatch = nota.ajustes.any((ajuste) =>
            ajuste.descripcion.toLowerCase().contains(lowercaseQuery));
        return clienteMatch || facturaMatch || ajustesMatch || statusMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas de Ajuste'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pendientes'),
            Tab(text: 'Completados'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: filterNotas,
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, factura, estado...',
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
              child: TabBarView(
            controller: _tabController,
            children: [
              _buildNotaList('pending'),
              _buildNotaList('completed'),
            ],
          )),
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

  Widget _buildNotaList(String paymentStatus) {
    final notasToShow = filteredNotas
        .where((nota) => nota.paymentStatus == paymentStatus)
        .toList();

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (notasToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay notas ${paymentStatus == 'pending' ? 'pendientes' : 'completadas'}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: notasToShow.length,
      itemBuilder: (context, index) {
        final nota = notasToShow[index];
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
                      content:
                          Text('¿Estás seguro de que quieres eliminar esta nota?'),
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
    );
  }
}