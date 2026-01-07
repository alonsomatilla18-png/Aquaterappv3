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
  // --- VARIABLES DE FILTRO ---
  String? _filtroClienteId;    
  String? _filtroNombreCliente;
  String? _filtroSedeId;
  String? _filtroNombreSede;
  
  // Filtros de Tiempo
  int _mesSeleccionado = DateTime.now().month;
  int _anioSeleccionado = DateTime.now().year;
  
  // Buscador de Texto
  final TextEditingController _buscadorCtrl = TextEditingController();
  String _textoBusqueda = "";

  List<DocumentSnapshot> _listaClientes = [];
  List<DocumentSnapshot> _listaSedes = [];

  final List<int> _aniosDisponibles = List.generate(5, (index) => DateTime.now().year - index); // Últimos 5 años
  final List<String> _mesesNombre = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
    // Listener para el buscador
    _buscadorCtrl.addListener(() {
      setState(() {
        _textoBusqueda = _buscadorCtrl.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _buscadorCtrl.dispose();
    super.dispose();
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

  // --- UI PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    // Seguridad para Dropdowns
    final bool clienteExiste = _listaClientes.any((doc) => doc.id == _filtroClienteId);
    final valorClienteSeguro = clienteExiste ? _filtroClienteId : null;
    final bool sedeExiste = _listaSedes.any((doc) => doc.id == _filtroSedeId);
    final valorSedeSeguro = sedeExiste ? _filtroSedeId : null;

    // Calculamos el rango de fechas para el QUERY (Optimización de lectura)
    // Pedimos datos de todo el año seleccionado para poder calcular el total anual localmente
    DateTime inicioAno = DateTime(_anioSeleccionado, 1, 1);
    DateTime finAno = DateTime(_anioSeleccionado + 1, 1, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial y Análisis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: "Limpiar Filtros",
            onPressed: () {
              setState(() {
                _filtroClienteId = null;
                _filtroNombreCliente = null;
                _filtroSedeId = null;
                _filtroNombreSede = null;
                _mesSeleccionado = DateTime.now().month;
                _anioSeleccionado = DateTime.now().year;
                _buscadorCtrl.clear();
              });
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 1. PANEL DE FILTROS EXPANDIBLE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              children: [
                // FILA 1: CLIENTE Y SEDE
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Cliente', Icons.business),
                        isExpanded: true,
                        value: valorClienteSeguro,
                        items: [
                          const DropdownMenuItem(value: null, child: Text("Todos")),
                          ..._listaClientes.map((doc) => DropdownMenuItem(value: doc.id, child: Text((doc.data() as Map)['nombre_visible'] ?? "?", overflow: TextOverflow.ellipsis)))
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
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Sede', Icons.place),
                        isExpanded: true,
                        value: valorSedeSeguro,
                        items: [
                          const DropdownMenuItem(value: null, child: Text("Todas")),
                          ..._listaSedes.map((doc) => DropdownMenuItem(value: doc.id, child: Text((doc.data() as Map)['nombre'] ?? "?", overflow: TextOverflow.ellipsis)))
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
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // FILA 2: FECHAS Y BUSCADOR
                Row(
                  children: [
                    // MES
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        decoration: _inputDecoration('Mes', Icons.calendar_month),
                        value: _mesSeleccionado,
                        items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_mesesNombre[index]))),
                        onChanged: (val) => setState(() => _mesSeleccionado = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // AÑO
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<int>(
                        decoration: _inputDecoration('Año', Icons.calendar_today),
                        value: _anioSeleccionado,
                        items: _aniosDisponibles.map((a) => DropdownMenuItem(value: a, child: Text(a.toString()))).toList(),
                        onChanged: (val) => setState(() => _anioSeleccionado = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // BUSCADOR TEXTO
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _buscadorCtrl,
                        decoration: _inputDecoration('Buscar Folio...', Icons.search),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. STREAM BUILDER (LÓGICA PRINCIPAL)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Traemos todo el año para poder calcular estadísticas anuales, aunque mostremos solo el mes
              stream: FirebaseFirestore.instance
                  .collection('informes')
                  .where('fechaCreacion', isGreaterThanOrEqualTo: inicioAno)
                  .where('fechaCreacion', isLessThan: finAno)
                  .orderBy('fechaCreacion', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // --- FILTRADO EN MEMORIA (CLIENT SIDE) ---
                // Filtramos aquí porque Firestore tiene limites con queries compuestos complejos
                var docs = snapshot.data!.docs;
                
                // 1. Filtrar por Cliente/Sede (Si aplica)
                if (_filtroNombreCliente != null) {
                  docs = docs.where((d) => (d.data() as Map)['cliente'] == _filtroNombreCliente).toList();
                }
                if (_filtroNombreSede != null) {
                  docs = docs.where((d) => (d.data() as Map)['sede'] == _filtroNombreSede).toList();
                }

                // 2. Calcular Estadísticas ANTES de filtrar por mes (Para el "Total Anual")
                int totalAnual = docs.length;

                // 3. Filtrar por MES seleccionado (Para la lista y el gráfico mensual)
                var docsMes = docs.where((d) {
                  DateTime fecha = ((d.data() as Map)['fechaCreacion'] as Timestamp).toDate();
                  return fecha.month == _mesSeleccionado;
                }).toList();

                // 4. Filtrar por TEXTO (Buscador)
                if (_textoBusqueda.isNotEmpty) {
                  docsMes = docsMes.where((d) {
                    Map data = d.data() as Map;
                    String folio = (data['codigoCorrelativo'] ?? "").toString().toLowerCase();
                    String cliente = (data['cliente'] ?? "").toString().toLowerCase();
                    return folio.contains(_textoBusqueda) || cliente.contains(_textoBusqueda);
                  }).toList();
                }

                return Column(
                  children: [
                    // --- GRÁFICO DE ESTADÍSTICAS ---
                    if (docsMes.isNotEmpty)
                      Container(
                        height: 140,
                        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Card(
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: _buildEstadisticasContent(docsMes, totalAnual),
                          ),
                        ),
                      ),

                    // --- LISTA DE RESULTADOS ---
                    Expanded(
                      child: docsMes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_off, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 10),
                                Text("No hay informes en ${_mesesNombre[_mesSeleccionado - 1]}", style: TextStyle(color: Colors.grey[600]))
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: docsMes.length,
                            itemBuilder: (context, index) {
                              final data = docsMes[index].data() as Map<String, dynamic>;
                              InformeBase informe;
                              try { informe = InformeBase.fromMap(data, docsMes[index].id); } catch (e) { return const SizedBox(); }

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  onTap: () => _verPdf(context, informe),
                                  leading: Container(
                                    width: 45, height: 45,
                                    decoration: BoxDecoration(color: _getColorPorServicio(informe.tipoServicio).withOpacity(0.1), shape: BoxShape.circle),
                                    child: Icon(_getIconoPorServicio(informe.tipoServicio), color: _getColorPorServicio(informe.tipoServicio)),
                                  ),
                                  title: Text(informe.cliente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(informe.sede, style: const TextStyle(fontSize: 12)),
                                      Text(DateFormat('dd/MM/yyyy HH:mm').format(informe.fechaCreacion), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if(informe.codigoCorrelativo != null)
                                        Text(informe.codigoCorrelativo!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                                      const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 18),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildEstadisticasContent(List<DocumentSnapshot> docsMes, int totalAnual) {
    int bomb = 0; int fosa = 0; int sani = 0; int otros = 0;
    for (var d in docsMes) {
      String t = (d.data() as Map)['tipoServicio'] ?? '';
      if (t == 'man') bomb++;
      else if (t == 'fosa') fosa++;
      else if (t == 'sani') sani++;
      else otros++;
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Resumen ${_mesesNombre[_mesSeleccionado - 1]}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("${docsMes.length} Documentos", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              const SizedBox(height: 5),
              Text("Acumulado Año $_anioSeleccionado: $totalAnual", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 15,
                sections: [
                  if(bomb>0) PieChartSectionData(color: Colors.blue, value: bomb.toDouble(), title: '$bomb', radius: 20, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
                  if(fosa>0) PieChartSectionData(color: Colors.brown, value: fosa.toDouble(), title: '$fosa', radius: 20, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
                  if(sani>0) PieChartSectionData(color: Colors.teal, value: sani.toDouble(), title: '$sani', radius: 20, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
                  if(otros>0) PieChartSectionData(color: Colors.orange, value: otros.toDouble(), title: '$otros', radius: 20, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
        // Leyenda Compacta
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(bomb>0) _legendItem("Bombas", Colors.blue),
              if(fosa>0) _legendItem("Fosas", Colors.brown),
              if(sani>0) _legendItem("Sanit.", Colors.teal),
              if(otros>0) _legendItem("Otros", Colors.orange),
            ],
          ),
        )
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: [
        CircleAvatar(radius: 3, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10))
      ]),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF0D47A1)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[50],
      isDense: true,
    );
  }

  // --- LÓGICA DE PDF (MANTENIDA) ---
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
      
      // Llamadas a tu generador existente
      if (informe is InformeFosa) pdfBytes = await pdfGen.generarPdfFosa(informe, []);
      else if (informe is InformeMantencion) pdfBytes = await pdfGen.generarPdfMantencion(informe, [], null);
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