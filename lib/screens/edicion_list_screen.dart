import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/informe_model.dart';
// Importamos HomeScreen para navegar hacia ella
import 'home_screen.dart';

class EdicionListScreen extends StatefulWidget {
  const EdicionListScreen({super.key});

  @override
  State<EdicionListScreen> createState() => _EdicionListScreenState();
}

class _EdicionListScreenState extends State<EdicionListScreen> {
  // VARIABLES PARA FILTROS
  String? _filtroClienteId;    
  String? _filtroNombreCliente; 
  String? _filtroSedeId;
  String? _filtroNombreSede;

  List<DocumentSnapshot> _listaClientes = [];
  List<DocumentSnapshot> _listaSedes = [];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      var q = await FirebaseFirestore.instance.collection('clientes').get();
      if (mounted) setState(() => _listaClientes = q.docs);
    } catch (e) { print("Error cargando clientes: $e"); }
  }

  Future<void> _cargarSedes(String clienteId) async {
    try {
      var q = await FirebaseFirestore.instance.collection('clientes').doc(clienteId).collection('sedes').get();
      if (mounted) {
        setState(() {
          _listaSedes = q.docs;
          _filtroSedeId = null; 
          _filtroNombreSede = null;
        });
      }
    } catch (e) { print("Error cargando sedes: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Informes"),
        backgroundColor: Colors.orange[800], // Color distintivo para edición
      ),
      body: Column(
        children: [
          // --- BARRA DE FILTROS ---
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange[50],
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Filtrar por Cliente', fillColor: Colors.white, filled: true, border: OutlineInputBorder()),
                  initialValue: _filtroClienteId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Todos los Clientes")),
                    ..._listaClientes.map((doc) => DropdownMenuItem(value: doc.id, child: Text((doc.data() as Map)['nombre_visible'] ?? "Sin Nombre")))
                  ],
                  onChanged: (val) {
                    setState(() {
                      _filtroClienteId = val;
                      if (val != null) {
                         var doc = _listaClientes.firstWhere((d) => d.id == val);
                         _filtroNombreCliente = (doc.data() as Map)['nombre_visible'];
                         _cargarSedes(val); 
                      } else {
                        _filtroNombreCliente = null; _listaSedes = []; _filtroSedeId = null; _filtroNombreSede = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Filtrar por Sede', fillColor: Colors.white, filled: true, border: OutlineInputBorder()),
                  initialValue: _filtroSedeId,
                  items: _listaSedes.isEmpty 
                    ? [const DropdownMenuItem(value: null, child: Text("Seleccione Cliente..."))]
                    : [const DropdownMenuItem(value: null, child: Text("Todas las Sedes")), ..._listaSedes.map((doc) => DropdownMenuItem(value: doc.id, child: Text((doc.data() as Map)['nombre'] ?? "")))],
                  onChanged: _listaSedes.isEmpty ? null : (val) {
                    setState(() {
                      _filtroSedeId = val;
                      if (val != null) {
                        var doc = _listaSedes.firstWhere((d) => d.id == val);
                        _filtroNombreSede = (doc.data() as Map)['nombre'];
                      } else {
                        _filtroNombreSede = null;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          
          // --- LISTA DE RESULTADOS ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('informes').orderBy('fechaCreacion', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var docs = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  bool pasaCliente = _filtroNombreCliente == null || (data['cliente'] == _filtroNombreCliente);
                  bool pasaSede = _filtroNombreSede == null || (data['sede'] == _filtroNombreSede);
                  return pasaCliente && pasaSede;
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("No se encontraron informes para editar."));

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    InformeBase informe;
                    try { informe = InformeBase.fromMap(data, docs[index].id); } catch (e) { return const SizedBox(); }

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Icon(Icons.edit, color: Colors.orange[800]),
                        ),
                        title: Text(informe.cliente, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${informe.sede}\n${DateFormat('dd/MM/yyyy HH:mm').format(informe.fechaCreacion)}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // AQUÍ ESTÁ LA MAGIA: Navegamos al HomeScreen pasándole el informe a editar
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen(informeParaEditar: informe)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}