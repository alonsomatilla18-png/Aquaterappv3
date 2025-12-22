import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'dart:typed_data';

// IMPORTACIONES
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
      var q = await FirebaseFirestore.instance.collection('clientes').orderBy('nombre_visible').get();
      if (mounted) setState(() => _listaClientes = q.docs);
    } catch (e) { debugPrint("Error cargando clientes: $e"); }
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
    } catch (e) { debugPrint("Error cargando sedes: $e"); }
  }

  // QUERY DINÁMICA
  Query _construirQuery() {
    Query query = FirebaseFirestore.instance.collection('informes');

    if (_filtroNombreCliente != null) {
      query = query.where('cliente', isEqualTo: _filtroNombreCliente);
    }
    if (_filtroNombreSede != null) {
      query = query.where('sede', isEqualTo: _filtroNombreSede);
    }

    // OJO: Esto requiere índice en Firebase si se usan filtros
    return query.orderBy('fechaCreacion', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Informes")),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // --- TARJETA DE ESTADÍSTICAS ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            height: 160, 
            child: _buildEstadisticasCard(),
          ),

          // --- BARRA DE FILTROS ---
          Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 5))]
            ),
            child: Column(
              children: [
                const Divider(), 
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Filtrar por Cliente', prefixIcon: Icon(Icons.business), isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10)),
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
                if (_listaSedes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Filtrar por Sede', prefixIcon: Icon(Icons.place), isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10)),
                    initialValue: _filtroSedeId,
                    items: [const DropdownMenuItem(value: null, child: Text("Todas las Sedes")), ..._listaSedes.map((doc) => DropdownMenuItem(value: doc.id, child: Text((doc.data() as Map)['nombre'] ?? "")))],
                    onChanged: (val) {
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
                ]
              ],
            ),
          ),
          
          // --- LISTA DE RESULTADOS ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _construirQuery().snapshots(), 
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Muestra el error en pantalla para saber qué pasa (ej: falta índice)
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  ));
                }
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        Icon(Icons.folder_off, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("No se encontraron informes.", style: TextStyle(color: Colors.grey[600]))
                      ]
                    )
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    InformeBase informe;
                    try { informe = InformeBase.fromMap(data, docs[index].id); } catch (e) { return const SizedBox(); }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _verPdf(context, informe), 
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: _getColorPorServicio(informe.tipoServicio).withOpacity(0.1),
                                  shape: BoxShape.circle
                                ),
                                child: Icon(_getIconoPorServicio(informe.tipoServicio), color: _getColorPorServicio(informe.tipoServicio)),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(informe.cliente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text("${informe.sede} • ${DateFormat('dd/MM/yy').format(informe.fechaCreacion)}", 
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                    if(informe.codigoCorrelativo != null) 
                                      Text("Folio: ${informe.codigoCorrelativo}", style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1), fontWeight: FontWeight.w600))
                                  ],
                                ),
                              ),
                              const Icon(Icons.picture_as_pdf, color: Colors.grey),
                            ],
                          ),
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

  // --- WIDGET DE ESTADÍSTICAS ---
  Widget _buildEstadisticasCard() {
    return StreamBuilder<QuerySnapshot>(
      // Limitamos a 50 para no saturar la memoria
      stream: _construirQuery().limit(50).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Falta Índice en Firebase", style: TextStyle(color: Colors.red, fontSize: 10)));
        if (!snapshot.hasData) return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));

        final docs = snapshot.data!.docs;
        
        int totalBombas = 0; int totalFosas = 0; int totalOtros = 0;
        DateTime now = DateTime.now();
        int totalMes = 0;

        for (var doc in docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            // PROTECCIÓN CONTRA NULOS
            if (data['fechaCreacion'] == null) continue;

            DateTime fecha = (data['fechaCreacion'] as Timestamp).toDate();
            
            // Filtramos en memoria solo el mes actual
            if (fecha.month == now.month && fecha.year == now.year) {
              totalMes++;
              String tipo = data['tipoServicio'] ?? '';
              if (tipo == 'man') {
                totalBombas++;
              } else if (tipo == 'fosa') totalFosas++;
              else totalOtros++;
            }
          } catch (e) {
            // Si falla un documento, lo saltamos y seguimos con el siguiente
            continue; 
          }
        }

        String tituloChart = "Global";
        if (_filtroNombreSede != null) {
          tituloChart = _filtroNombreSede!;
        } else if (_filtroNombreCliente != null) tituloChart = _filtroNombreCliente!;

        if (totalMes == 0) return Center(child: Text("Sin datos este mes para $tituloChart", style: const TextStyle(fontSize: 12, color: Colors.grey)));

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Resumen Mensual ($tituloChart)", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("$totalMes Informes", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                  const SizedBox(height: 8),
                  _indicador("Bombas", Colors.blue, totalBombas),
                  _indicador("Fosas", Colors.brown, totalFosas),
                  _indicador("Otros", Colors.teal, totalOtros),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2, centerSpaceRadius: 20,
                  sections: [
                    if(totalBombas>0) PieChartSectionData(color: Colors.blue, value: totalBombas.toDouble(), title: '', radius: 25),
                    if(totalFosas>0) PieChartSectionData(color: Colors.brown, value: totalFosas.toDouble(), title: '', radius: 25),
                    if(totalOtros>0) PieChartSectionData(color: Colors.teal, value: totalOtros.toDouble(), title: '', radius: 25),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _indicador(String texto, Color color, int cantidad) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text("$texto: $cantidad", style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
  
  // --- MÉTODOS AUXILIARES ---
  Color _getColorPorServicio(String tipo) {
    switch (tipo) {
      case 'fosa': return Colors.brown;
      case 'man': return Colors.blue;
      case 'sani': return Colors.teal;
      case 'recu': return Colors.orange;
      case 'cons': return Colors.blueGrey;
      default: return Colors.indigo;
    }
  }

  IconData _getIconoPorServicio(String tipo) {
    switch (tipo) {
      case 'fosa': return Icons.delete_outline;
      case 'man': return Icons.build_circle_outlined;
      case 'sani': return Icons.cleaning_services;
      case 'recu': return Icons.handyman_outlined;
      case 'cons': return Icons.assignment_outlined;
      default: return Icons.work_outline;
    }
  }

  Future<void> _verPdf(BuildContext context, InformeBase informe) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
    try {
      final pdfGen = PdfGenerator();
      Uint8List? pdfBytes;
      if (informe is InformeFosa) {
        pdfBytes = await pdfGen.generarPdfFosa(informe, []);
      } else if (informe is InformeMantencion) pdfBytes = await pdfGen.generarPdfMantencion(informe, [], null);
      else if (informe is InformeSanitizacion) pdfBytes = await pdfGen.generarPdfSanitizacion(informe, [], null);
      else if (informe is InformeRecuperacion) pdfBytes = await pdfGen.generarPdfRecuperacion(informe, [], null);
      else if (informe is InformeConstancia) pdfBytes = await pdfGen.generarPdfConstancia(informe, [], null);

      if (context.mounted) Navigator.pop(context);
      if (pdfBytes != null && context.mounted) {
        String nombreArchivo = "Reporte ${informe.codigoCorrelativo ?? 'Doc'}.pdf";
        Navigator.push(context, MaterialPageRoute(builder: (context) => PdfPreviewScreen(pdfBytes: pdfBytes!, fileName: nombreArchivo)));
      }
    } catch (e) {
      if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)); }
    }
  }
}