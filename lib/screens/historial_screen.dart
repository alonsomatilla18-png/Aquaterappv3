import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

import '../models/informe_model.dart';
import '../utils/pdf_generator.dart';
import 'pdf_preview_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  // VARIABLES PARA FILTROS
  String? _filtroClienteId;    // ID del documento del cliente
  String? _filtroNombreCliente; // Nombre real (guardado en el informe)
  String? _filtroSedeId;
  String? _filtroNombreSede;

  List<DocumentSnapshot> _listaClientes = [];
  List<DocumentSnapshot> _listaSedes = [];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  // --- CARGA DE DATOS PARA FILTROS ---
  Future<void> _cargarClientes() async {
    try {
      var q = await FirebaseFirestore.instance.collection('clientes').get();
      if (mounted) setState(() => _listaClientes = q.docs);
    } catch (e) { print("Error cargando clientes filtro: $e"); }
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
    } catch (e) { print("Error cargando sedes filtro: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Informes"),
      ),
      body: Column(
        children: [
          // --- BARRA DE FILTROS ---
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Filtro Cliente
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Cliente',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(),
                    fillColor: Colors.white, filled: true
                  ),
                  initialValue: _filtroClienteId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Todos los Clientes")),
                    ..._listaClientes.map((doc) {
                      String nombre = (doc.data() as Map)['nombre_visible'] ?? "Sin Nombre";
                      return DropdownMenuItem(value: doc.id, child: Text(nombre));
                    })
                  ],
                  onChanged: (val) {
                    setState(() {
                      _filtroClienteId = val;
                      // Buscamos el nombre visible para filtrar el texto del informe
                      if (val != null) {
                         var doc = _listaClientes.firstWhere((d) => d.id == val);
                         _filtroNombreCliente = (doc.data() as Map)['nombre_visible'];
                         _cargarSedes(val); // Cargar sedes de este cliente
                      } else {
                        _filtroNombreCliente = null;
                        _listaSedes = [];
                        _filtroSedeId = null;
                        _filtroNombreSede = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Filtro Sede
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Sede',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(),
                    fillColor: Colors.white, filled: true
                  ),
                  initialValue: _filtroSedeId,
                  // Deshabilitar si no hay cliente seleccionado o no hay sedes
                  items: _listaSedes.isEmpty 
                    ? [const DropdownMenuItem(value: null, child: Text("Seleccione Cliente primero..."))]
                    : [
                        const DropdownMenuItem(value: null, child: Text("Todas las Sedes")),
                        ..._listaSedes.map((doc) {
                          String nombre = (doc.data() as Map)['nombre'] ?? "Sin Nombre";
                          return DropdownMenuItem(value: doc.id, child: Text(nombre));
                        })
                      ],
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
              stream: FirebaseFirestore.instance
                  .collection('informes')
                  .orderBy('fechaCreacion', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay informes registrados."));
                }

                // APLICAMOS EL FILTRO EN MEMORIA (CLIENTE-SIDE FILTERING)
                // Esto es más seguro y rápido que crear índices compuestos en Firestore para cada combinación
                var docs = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  bool pasaCliente = true;
                  bool pasaSede = true;

                  if (_filtroNombreCliente != null) {
                    pasaCliente = (data['cliente'] == _filtroNombreCliente);
                  }
                  if (_filtroNombreSede != null) {
                    pasaSede = (data['sede'] == _filtroNombreSede);
                  }

                  return pasaCliente && pasaSede;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        Text("No se encontraron informes con esos filtros."),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String id = docs[index].id;

                    InformeBase informe;
                    try {
                      informe = InformeBase.fromMap(data, id);
                    } catch (e) {
                      return const SizedBox();
                    }

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: _getColorPorServicio(informe.tipoServicio),
                          child: Icon(_getIconoPorServicio(informe.tipoServicio), color: Colors.white),
                        ),
                        title: Text(
                          informe.cliente,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(informe.sede),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(informe.fechaCreacion),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if(informe.codigoCorrelativo != null)
                              Text(
                                "Folio: ${informe.codigoCorrelativo}",
                                style: TextStyle(fontSize: 11, color: Colors.blue[800], fontWeight: FontWeight.bold),
                              )
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF0D47A1)),
                          onPressed: () => _verPdf(context, informe),
                        ),
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

  // --- AYUDAS VISUALES ---
  Color _getColorPorServicio(String tipo) {
    switch (tipo) {
      case 'fosa': return Colors.brown;
      case 'man': return Colors.blue;
      case 'sani': return Colors.teal;
      case 'recu': return Colors.orange;
      case 'cons': return Colors.grey;
      default: return Colors.indigo;
    }
  }

  IconData _getIconoPorServicio(String tipo) {
    switch (tipo) {
      case 'fosa': return Icons.delete_outline;
      case 'man': return Icons.build;
      case 'sani': return Icons.cleaning_services;
      case 'recu': return Icons.handyman;
      case 'cons': return Icons.description;
      default: return Icons.work;
    }
  }

  Future<void> _verPdf(BuildContext context, InformeBase informe) async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator())
    );

    try {
      final pdfGen = PdfGenerator();
      Uint8List? pdfBytes;
      
      if (informe is InformeFosa) {
        pdfBytes = await pdfGen.generarPdfFosa(informe, []); 
      } else if (informe is InformeMantencion) {
        pdfBytes = await pdfGen.generarPdfMantencion(informe, [], null);
      } else if (informe is InformeSanitizacion) {
        pdfBytes = await pdfGen.generarPdfSanitizacion(informe, [], null);
      } else if (informe is InformeRecuperacion) {
        pdfBytes = await pdfGen.generarPdfRecuperacion(informe, [], null);
      } else if (informe is InformeConstancia) {
        pdfBytes = await pdfGen.generarPdfConstancia(informe, [], null);
      }

      if (context.mounted) Navigator.pop(context);

      if (pdfBytes != null && context.mounted) {
        String nombreArchivo = "Reporte ${informe.codigoCorrelativo ?? 'SinFolio'}.pdf";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(pdfBytes: pdfBytes!, fileName: nombreArchivo),
          ),
        );
      }

    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar PDF: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }
}