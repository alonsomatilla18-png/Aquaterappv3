import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart'; // ✅ IMPORTANTE PARA OFFLINE

// SERVICIOS Y MODELOS
import '../services/email_service.dart';
import '../models/informe_model.dart';
import '../services/firebase_service.dart';
import '../services/report_logic.dart'; 
import '../utils/constants.dart';      
import '../utils/pdf_generator.dart';
import '../utils/data_sedes.dart';

// WIDGETS
import '../widgets/custom_input.dart';
import '../widgets/signature_pad.dart';
import '../widgets/photo_selector.dart';

// PANTALLAS
import '../screens/pdf_preview_screen.dart';

// FORMULARIOS ESPECÍFICOS
import 'forms/fosa_form.dart';
import 'forms/bombas_form.dart';
import 'forms/sani_form.dart';
import 'forms/recu_form.dart';
import 'forms/cons_form.dart';

class HomeScreen extends StatefulWidget {
  final InformeBase? informeParaEditar;

  const HomeScreen({super.key, this.informeParaEditar});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CLAVE PARA VALIDACIÓN DE FORMULARIO
  final _formKey = GlobalKey<FormState>();

  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color(0xFF0D47A1),
    exportBackgroundColor: Colors.white,
  );

  String _rolUsuario = 'cargando';
  String _nombreUsuario = '';
  
  bool _estaCargando = false;
  String _textoCarga = "Procesando...";

  String? clienteSeleccionado;
  String? sedeSeleccionada;
  
  List<String> _emailsDestino = [];

  String? servicioSeleccionado;
  String? tecnicoSeleccionado;

  Uint8List? _firmaExistenteBytes;

  List<DocumentSnapshot> listaClientes = [];
  List<DocumentSnapshot> listaSedes = [];
  final List<DetalleMantencionBomba> _detallesBombas = [];
  
  final List<String> listaTecnicos = AppConstants.listaTecnicos;

  DateTime _fechaServicio = DateTime.now();
  DateTime _fechaFinRecu = DateTime.now();
  final List<XFile> _fotos = [];

  final _guiaCtrl = TextEditingController();
  final _certCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _obsMantencionCtrl = TextEditingController();
  final _nombreInspeccionaCtrl = TextEditingController();
  final _rutInspeccionaCtrl = TextEditingController();
  final _descConstanciaCtrl = TextEditingController();

  bool get esModoEdicion => widget.informeParaEditar != null;

  @override
  void initState() {
    super.initState();
    _obtenerDatosUsuario();
    _inicializarFormulario();
  }

  @override
  void dispose() {
    _guiaCtrl.dispose();
    _certCtrl.dispose();
    _obsCtrl.dispose();
    _obsMantencionCtrl.dispose();
    _nombreInspeccionaCtrl.dispose();
    _rutInspeccionaCtrl.dispose();
    _descConstanciaCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _inicializarFormulario() async {
    await _cargarClientes();
    if (esModoEdicion) {
      await _cargarDatosDeEdicion(widget.informeParaEditar!);
    }
  }

  Future<void> _cargarDatosDeEdicion(InformeBase informe) async {
    setState(() {
      _estaCargando = true;
      _textoCarga = "Cargando datos...";
    });
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      String? idClienteEncontrado;
      String? idSedeEncontrado;

      try {
        var docCliente = listaClientes.firstWhere(
          (doc) => (doc.data() as Map)['nombre_visible'] == informe.cliente
        );
        idClienteEncontrado = docCliente.id;
        await _cargarSedes(idClienteEncontrado);
      } catch (_) {}

      if (idClienteEncontrado != null) {
        try {
          var docSede = listaSedes.firstWhere(
            (doc) => (doc.data() as Map)['nombre'] == informe.sede
          );
          idSedeEncontrado = docSede.id;
          var dataSede = docSede.data() as Map;
          _emailsDestino = [];
          if(dataSede['contactos'] != null) {
             _emailsDestino = List<String>.from(dataSede['contactos']);
          } else if (dataSede['email_jefe'] != null) {
             _emailsDestino.add(dataSede['email_jefe']);
          }
        } catch (_) {}
      }

      if (informe.firmaUrl != null && informe.firmaUrl!.isNotEmpty) {
        try { _firmaExistenteBytes = base64Decode(informe.firmaUrl!); } catch (_) {}
      }

      setState(() {
        clienteSeleccionado = idClienteEncontrado;
        sedeSeleccionada = idSedeEncontrado;
        tecnicoSeleccionado = informe.tecnicoId;
        
        switch(informe.tipoServicio) {
          case 'fosa': servicioSeleccionado = AppConstants.servFosa; break;
          case 'man': servicioSeleccionado = AppConstants.servBombas; break;
          case 'recu': servicioSeleccionado = AppConstants.servRecu; break;
          case 'sani': servicioSeleccionado = AppConstants.servSani; break;
          case 'cons': servicioSeleccionado = AppConstants.servCons; break;
        }
      });

      if (informe is InformeFosa) {
        _guiaCtrl.text = informe.guia;
        _certCtrl.text = informe.numCertificado;
        _obsCtrl.text = informe.observaciones;
        _fechaServicio = informe.fechaServicio;
      }
      else if (informe is InformeMantencion) {
        _obsMantencionCtrl.text = informe.observaciones;
        _fechaServicio = informe.fechaServicio;
        _nombreInspeccionaCtrl.text = informe.nombreInspecciona ?? "";
        _rutInspeccionaCtrl.text = informe.rutInspecciona ?? "";
        setState(() {
          _detallesBombas.clear();
          _detallesBombas.addAll(informe.equipos);
        });
      }
      else if (informe is InformeSanitizacion) {
        _obsCtrl.text = informe.observaciones;
        _fechaServicio = informe.fechaServicio;
        _nombreInspeccionaCtrl.text = informe.nombreInspecciona ?? "";
        _rutInspeccionaCtrl.text = informe.rutInspecciona ?? "";
      }
      else if (informe is InformeRecuperacion) {
        _obsCtrl.text = informe.observaciones;
        _fechaServicio = informe.fechaInicio;
        _fechaFinRecu = informe.fechaFin;
        _nombreInspeccionaCtrl.text = informe.nombreInspecciona ?? "";
        _rutInspeccionaCtrl.text = informe.rutInspecciona ?? "";
      }
      else if (informe is InformeConstancia) {
        _descConstanciaCtrl.text = informe.descripcionTrabajo;
        _obsCtrl.text = informe.observaciones;
        _fechaServicio = informe.fechaServicio;
        _nombreInspeccionaCtrl.text = informe.nombreInspecciona ?? "";
        _rutInspeccionaCtrl.text = informe.rutInspecciona ?? "";
      }

    } catch (e) {
      print("Error cargando datos: $e");
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  Future<void> _obtenerDatosUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _rolUsuario = (doc.data() as Map)['rol'] ?? 'tecnico';
            _nombreUsuario = (doc.data() as Map)['nombre'] ?? user.email ?? 'Usuario';
          });
        } else { if (mounted) setState(() => _rolUsuario = 'tecnico'); }
      } else { if (mounted) setState(() { _rolUsuario = 'tecnico'; _nombreUsuario = 'Técnico Local'; }); }
    } catch (e) { if (mounted) setState(() => _rolUsuario = 'tecnico'); }
  }

  Future<void> _cargarClientes() async {
    try {
      var query = await FirebaseFirestore.instance.collection('clientes').get();
      if (mounted) setState(() => listaClientes = query.docs);
    } catch (e) { print("Error clientes: $e"); }
  }

  Future<void> _cargarSedes(String clienteId) async {
    try {
      var query = await FirebaseFirestore.instance.collection('clientes').doc(clienteId).collection('sedes').get();
      if (mounted) {
        setState(() {
          listaSedes = query.docs;
          if (!esModoEdicion) {
             sedeSeleccionada = null;
             _emailsDestino = [];
             _detallesBombas.clear();
          }
        });
      }
    } catch (e) { print("Error sedes: $e"); }
  }

  void _configurarBombasSede(String sedeId) {
    if (esModoEdicion && _detallesBombas.isNotEmpty) return;
    _detallesBombas.clear();
    Map<String, Map<String, String>> initCheck() {
      Map<String, Map<String, String>> m = {};
      for (int i = 1; i <= 10; i++) { m['mec_$i'] = {'estado': '', 'obs': ''}; m['elec_$i'] = {'estado': '', 'obs': ''}; }
      return m;
    }

    if (configuracionBombas.containsKey(sedeId)) {
      List<EquipoConfig> configs = configuracionBombas[sedeId]!;
      for (var cfg in configs) {
        for (int i = 1; i <= cfg.cantidad; i++) {
          _detallesBombas.add(DetalleMantencionBomba(tipoBomba: cfg.tipo, nombreEquipo: "${cfg.nombre} $i", ubicacion: cfg.ubicacion, checklist: initCheck()));
        }
        if (sedeId == 'PIRQ' && cfg.tipo == 'bomsen') continue;
        String tTab = "tabom";
        if (cfg.tipo == 'bomser') tTab = 'taser'; if (cfg.tipo == 'grasa') tTab = 'tagra';
        if (cfg.tipo == 'bomllu') tTab = 'tallu'; if (cfg.tipo == 'bomsen') tTab = 'tasen';
        if (cfg.tipo == 'sopla') tTab = 'tasop';
        _detallesBombas.add(DetalleMantencionBomba(tipoBomba: tTab, nombreEquipo: "Tablero ${cfg.nombre}", ubicacion: cfg.ubicacion, checklist: initCheck()));
      }
    } else {
      _detallesBombas.add(DetalleMantencionBomba(tipoBomba: 'bom', nombreEquipo: "Bomba 1 (Genérica)", checklist: initCheck()));
    }
    setState(() {});
  }

  Future<void> _tomarFoto(ImageSource origen) async {
    try {
        if(origen == ImageSource.camera) {
            final f = await _picker.pickImage(source: origen);
            if (f != null) setState(() => _fotos.add(f));
        } else {
            final f = await _picker.pickMultiImage();
            if (f.isNotEmpty) setState(() => _fotos.addAll(f));
        }
    } catch (_) {}
  }

  Future<void> _seleccionarFecha(BuildContext context, {bool esFin = false}) async {
    final p = await showDatePicker(context: context, initialDate: esFin ? _fechaFinRecu : _fechaServicio, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (p != null) { setState(() { if (esFin) _fechaFinRecu = p; else _fechaServicio = p; }); }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_rolUsuario == 'cargando' || _estaCargando) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LinearProgressIndicator(color: Color(0xFF0D47A1), backgroundColor: Color(0xFFE3F2FD), minHeight: 6),
                const SizedBox(height: 30),
                Text(_rolUsuario == 'cargando' ? "Cargando perfil..." : "Generando Informe", textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                const SizedBox(height: 15),
                if (_estaCargando) Text(_textoCarga, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: esModoEdicion
          ? const Text("Editando Informe", style: TextStyle(fontWeight: FontWeight.bold))
          : Image.asset('assets/images/logo_aquater.png', height: 40, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Text("Aquater")),
        backgroundColor: esModoEdicion ? Colors.orange[800] : const Color(0xFF0D47A1),
        centerTitle: true,
        actions: [
          if (!esModoEdicion) ...[
            IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.pushNamed(context, '/historial'), tooltip: "Historial"),
            IconButton(icon: const Icon(Icons.logout), onPressed: _cerrarSesion, tooltip: "Salir")
          ]
        ],
      ),
      body: _buildVistaFormulario()
    );
  }

  // --- VISTA ÚNICA DE FORMULARIO ---
  Widget _buildVistaFormulario() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form( // ✅ FORMULARIO CON VALIDACIÓN
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        decoration: const InputDecoration(labelText: 'Cliente', prefixIcon: Icon(Icons.business)),
                        initialValue: clienteSeleccionado,
                        items: listaClientes.map((d) => DropdownMenuItem(value: d.id, child: Text((d.data() as Map)['nombre_visible'] ?? ""))).toList(),
                        onChanged: (v) { if (v != null) setState(() { clienteSeleccionado = v; _cargarSedes(v); }); },
                        validator: (v) => v == null ? 'Seleccione Cliente' : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField(
                        decoration: const InputDecoration(labelText: 'Sede', prefixIcon: Icon(Icons.place)),
                        initialValue: sedeSeleccionada,
                        items: listaSedes.map((d) => DropdownMenuItem(value: d.id, child: Text((d.data() as Map)['nombre'] ?? ""))).toList(),
                        onChanged: (v) {
                          setState(() {
                            sedeSeleccionada = v;
                            _emailsDestino = [];
                            if (v != null) {
                               try {
                                 var doc = listaSedes.firstWhere((d) => d.id == v);
                                 var data = doc.data() as Map;
                                 if (data['contactos'] != null) {
                                   _emailsDestino = List<String>.from(data['contactos']);
                                 } else if (data['email_jefe'] != null && data['email_jefe'].toString().isNotEmpty) {
                                   _emailsDestino.add(data['email_jefe']);
                                 }
                               } catch(_){}
                            }
                          });
                          if (v != null) _configurarBombasSede(v);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Tipo de Servicio:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _botonServicio(AppConstants.servFosa, 'Fosa'), const SizedBox(width: 8),
                    _botonServicio(AppConstants.servBombas, 'Bombas'), const SizedBox(width: 8),
                    _botonServicio(AppConstants.servRecu, 'Recuperación'), const SizedBox(width: 8),
                    _botonServicio(AppConstants.servSani, 'Sanitización'), const SizedBox(width: 8),
                    _botonServicio(AppConstants.servCons, 'Constancia'),
                  ],
                ),
              ),
              const Divider(height: 30),

              if (servicioSeleccionado != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        ListTile(title: Text("Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaServicio)}"), trailing: const Icon(Icons.calendar_month), onTap: () => _seleccionarFecha(context)),
                        if (servicioSeleccionado == AppConstants.servRecu)
                          ListTile(title: Text("Fecha Fin: ${DateFormat('dd/MM/yyyy').format(_fechaFinRecu)}"), trailing: const Icon(Icons.calendar_month, color: Colors.teal), onTap: () => _seleccionarFecha(context, esFin: true)),
                        const SizedBox(height: 10),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(labelText: 'Técnico Responsable', prefixIcon: Icon(Icons.person_pin)),
                          initialValue: tecnicoSeleccionado,
                          items: listaTecnicos.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                          onChanged: (v) => setState(() => tecnicoSeleccionado = v),
                          validator: (v) => v == null ? 'Requerido' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (servicioSeleccionado == AppConstants.servBombas) BombasForm(detallesBombas: _detallesBombas, onUpdate: () {}),
                if (servicioSeleccionado == AppConstants.servFosa) FosaForm(guiaController: _guiaCtrl, certificadoController: _certCtrl, obsController: _obsCtrl),
                if (servicioSeleccionado == AppConstants.servSani) SaniForm(obsController: _obsCtrl),
                if (servicioSeleccionado == AppConstants.servRecu) RecuForm(obsController: _obsCtrl),
                if (servicioSeleccionado == AppConstants.servCons) ConsForm(descController: _descConstanciaCtrl, obsController: _obsCtrl),

                const SizedBox(height: 20),

                if (servicioSeleccionado != AppConstants.servFosa) ...[
                  CustomInput(
                    label: 'Nombre quien inspecciona', 
                    icon: Icons.person_outline, 
                    controller: _nombreInspeccionaCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Debe ingresar nombre' : null,
                  ),
                  
                  CustomInput(
                    label: 'RUT quien inspecciona',
                    icon: Icons.badge_outlined,
                    controller: _rutInspeccionaCtrl,
                    inputFormatters: [RutFormatter()],
                    validator: (v) => v == null || v.length < 8 ? 'RUT incompleto' : null,
                  ),

                  const SizedBox(height: 10),
                  _buildSignatureSection(),
                ],

                if (servicioSeleccionado == AppConstants.servBombas)
                  CustomInput(label: 'Observaciones Generales Bombas', icon: Icons.comment, controller: _obsMantencionCtrl, maxLines: 5),

                const SizedBox(height: 20),
                
                PhotoSelector(
                  fotos: _fotos,
                  onCameraTap: () => _tomarFoto(ImageSource.camera),
                  onGalleryTap: () => _tomarFoto(ImageSource.gallery),
                  onRemove: (index) { setState(() { _fotos.removeAt(index); }); },
                ),

                const SizedBox(height: 40),
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _estaCargando ? null : _guardarInforme,
                    icon: const Icon(Icons.save),
                    label: Text(esModoEdicion ? "ACTUALIZAR INFORME" : "FINALIZAR INFORME"),
                    style: ElevatedButton.styleFrom(backgroundColor: esModoEdicion ? Colors.orange[800] : const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                )
              ]
            ],
          ),
        ),
      );
  }

  Widget _buildSignatureSection() {
    if (_firmaExistenteBytes != null && _signatureController.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Firma Registrada:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(8)),
            child: Column(children: [Image.memory(_firmaExistenteBytes!, height: 100), const SizedBox(height: 5), TextButton.icon(icon: const Icon(Icons.delete, color: Colors.red), label: const Text("Eliminar y Firmar de Nuevo", style: TextStyle(color: Colors.red)), onPressed: () { setState(() { _firmaExistenteBytes = null; }); })]),
          ),
          const SizedBox(height: 15),
        ],
      );
    }
    return SignaturePad(controller: _signatureController);
  }

  Widget _botonServicio(String t, String l) {
    bool s = servicioSeleccionado == t;
    return ChoiceChip(
      label: Text(l, style: TextStyle(color: s ? Colors.white : Colors.black, fontWeight: s ? FontWeight.bold : FontWeight.normal)),
      selected: s, selectedColor: esModoEdicion ? Colors.orange[800] : const Color(0xFF0D47A1), backgroundColor: Colors.white,
      side: BorderSide(color: s ? (esModoEdicion ? Colors.orange[800]! : const Color(0xFF0D47A1)) : Colors.grey.shade300),
      onSelected: (sel) => setState(() => servicioSeleccionado = sel ? t : null),
    );
  }

  // --- LÓGICA DE GUARDADO MEJORADA (OFFLINE/ONLINE) ---
  void _guardarInforme() async {
    // 1. VALIDACIONES
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Por favor complete los campos obligatorios marcados en rojo'), backgroundColor: Colors.red));
       return;
    }
    if (clienteSeleccionado == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Falta seleccionar Cliente'))); return; }
    
    bool esVentisquero = false; String nombreCliente = "";
    try { var docC = listaClientes.firstWhere((d) => d.id == clienteSeleccionado); nombreCliente = (docC.data() as Map)['nombre_visible'] ?? ""; esVentisquero = nombreCliente.toLowerCase().contains("ventisquero") || nombreCliente.toLowerCase().contains("viña"); } catch (_) {}
    if (sedeSeleccionada == null && !esVentisquero) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Falta seleccionar Sede'))); return; }
    if ((_firmaExistenteBytes == null && _signatureController.isEmpty) && servicioSeleccionado != AppConstants.servFosa) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Falta la FIRMA de quien inspecciona'), backgroundColor: Colors.red));
       return;
    }

    // 2. DETECCIÓN DE INTERNET
    setState(() { _estaCargando = true; _textoCarga = "Analizando conexión..."; });
    bool hayInternet = false;
    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      hayInternet = !connectivityResult.contains(ConnectivityResult.none);
    } catch (_) {
      hayInternet = false; // Asumimos offline por defecto si falla el plugin
    }

    try {
      String nombreSede = esVentisquero && sedeSeleccionada == null ? "Instalaciones Cliente" : "General";
      if (sedeSeleccionada != null) { try { var docS = listaSedes.firstWhere((d) => d.id == sedeSeleccionada); nombreSede = (docS.data() as Map)['nombre'] ?? "General"; } catch (_) {} }

      DateTime ahora = DateTime.now();
      String corre = esModoEdicion ? (widget.informeParaEditar!.codigoCorrelativo ?? "S/N") : "GENE${Random().nextInt(9000) + 1000}";
      
      if (!esModoEdicion) {
         String p = "GENE"; 
         if (servicioSeleccionado == AppConstants.servFosa) p = "CERT"; 
         if (servicioSeleccionado == AppConstants.servBombas) p = "MANT"; 
         if (servicioSeleccionado == AppConstants.servRecu) p = "RECU"; 
         if (servicioSeleccionado == AppConstants.servSani) p = "SANI"; 
         if (servicioSeleccionado == AppConstants.servCons) p = "CONS";
         corre = "$p${Random().nextInt(9000) + 1000}";
      }

      String fechaFormato = DateFormat('dd-MM-yy').format(_fechaServicio);
      String nombreClienteArchivo = nombreCliente.toLowerCase().contains("duoc") ? "" : nombreCliente;
      String nombreArchivo = "Informe $nombreClienteArchivo $corre.pdf"; // Nombre simplificado para evitar errores de ruta

      // FIRMA
      setState(() => _textoCarga = "Procesando firma...");
      await Future.delayed(const Duration(milliseconds: 50));
      Uint8List? signatureBytes;
      if (_signatureController.isNotEmpty) signatureBytes = await _signatureController.toPngBytes();
      else if (_firmaExistenteBytes != null) signatureBytes = _firmaExistenteBytes;
      String? firmaBase64 = signatureBytes != null ? base64Encode(signatureBytes) : null;

      // CREAR OBJETO INFORME
      InformeBase informe = ReportLogic.generarInformeModelo(
        tipoServicio: servicioSeleccionado!,
        idExistente: esModoEdicion ? widget.informeParaEditar!.id : null,
        cliente: nombreCliente,
        sede: nombreSede,
        tecnicoId: tecnicoSeleccionado ?? "",
        fechaCreacion: esModoEdicion ? widget.informeParaEditar!.fechaCreacion : ahora,
        fechaServicio: _fechaServicio,
        fechaFinRecu: _fechaFinRecu,
        correlativo: corre,
        firmaBase64: firmaBase64,
        guia: _guiaCtrl.text,
        certificado: _certCtrl.text,
        obsGeneral: _obsCtrl.text,
        obsMantencion: _obsMantencionCtrl.text,
        nombreInsp: _nombreInspeccionaCtrl.text,
        rutInsp: _rutInspeccionaCtrl.text,
        descConstancia: _descConstanciaCtrl.text,
        equipos: _detallesBombas,
        correlativoFosaInt: esModoEdicion && widget.informeParaEditar is InformeFosa ? (widget.informeParaEditar as InformeFosa).correlativo : 1,
      );

      // 3. GUARDADO INTELIGENTE (OFFLINE/ONLINE)
      setState(() => _textoCarga = hayInternet ? "Sincronizando nube..." : "Guardando en dispositivo...");
      
      if (hayInternet) {
        // ONLINE: Esperamos confirmación completa
        if (esModoEdicion) await _firebaseService.actualizarInforme(informe);
        else await _firebaseService.guardarInforme(informe);
      } else {
        // OFFLINE: "Dispara y olvida". Firebase guarda local y sincroniza después.
        if (esModoEdicion) _firebaseService.actualizarInforme(informe).catchError((e) => print("Pendiente sync: $e"));
        else _firebaseService.guardarInforme(informe).catchError((e) => print("Pendiente sync: $e"));
        // Pausa breve para asegurar escritura en disco
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // 4. GENERACIÓN DE PDF (SIEMPRE LOCAL)
      setState(() => _textoCarga = "Generando PDF...");
      final pdfGen = PdfGenerator();
      Uint8List? pdfBytes;

      if (informe is InformeFosa) pdfBytes = await pdfGen.generarPdfFosa(informe, _fotos);
      else if (informe is InformeSanitizacion) pdfBytes = await pdfGen.generarPdfSanitizacion(informe, _fotos, signatureBytes);
      else if (informe is InformeRecuperacion) pdfBytes = await pdfGen.generarPdfRecuperacion(informe, _fotos, signatureBytes);
      else if (informe is InformeConstancia) pdfBytes = await pdfGen.generarPdfConstancia(informe, _fotos, signatureBytes);
      else if (informe is InformeMantencion) pdfBytes = await pdfGen.generarPdfMantencion(informe, _fotos, signatureBytes);

      if (pdfBytes != null) {
        // 5. ENVÍO DE CORREO (SOLO SI HAY INTERNET)
        if (hayInternet) {
            if (kIsWeb) {
                print("WEB: Correo saltado por restricciones");
            } else {
              if (_emailsDestino.isNotEmpty && !esModoEdicion) {
                setState(() => _textoCarga = "Enviando correos...");
                try {
                  final output = await getTemporaryDirectory();
                  final file = File("${output.path}/$nombreArchivo");
                  await file.writeAsBytes(pdfBytes);
                  
                  await EmailService.enviarInforme(destinatarios: _emailsDestino, nombreSede: nombreSede, fecha: fechaFormato, rutaPdf: file.path);
                  
                  try { if (await file.exists()) await file.delete(); } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📧 Enviado a ${_emailsDestino.length} destinatarios'), backgroundColor: Colors.green));
                } catch (e) {
                  print("❌ Error SMTP: $e");
                }
              }
            }
        } else {
            // AVISO OFFLINE
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('📡 MODO OFFLINE: Informe guardado. El correo quedará pendiente.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ));
        }

        // FIN
        setState(() => _textoCarga = "¡Listo!");
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => PdfPreviewScreen(pdfBytes: pdfBytes!, fileName: nombreArchivo)));
        
        // Limpiar si no es edición
        if (!esModoEdicion) _limpiar();
      }

    } catch (e) {
      print("ERROR GENERAL: $e"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _estaCargando = false); }
  }

  void _limpiar() {
    _guiaCtrl.clear(); _certCtrl.clear(); _obsCtrl.clear(); _obsMantencionCtrl.clear();
    _nombreInspeccionaCtrl.clear(); _rutInspeccionaCtrl.clear(); _descConstanciaCtrl.clear();
    _signatureController.clear(); _fotos.clear(); _detallesBombas.clear();
    setState(() { servicioSeleccionado = null; _fechaServicio = DateTime.now(); _fechaFinRecu = DateTime.now(); _firmaExistenteBytes = null; _emailsDestino = []; });
  }
}

class RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^0-9K]'), '');
    if (text.length > 9) text = text.substring(0, 9);
    String formatted = '';
    if (text.length > 1) {
      int splitIndex = text.length - 1;
      formatted = '-${text.substring(splitIndex)}';
      text = text.substring(0, splitIndex);
    }
    int counter = 0;
    for (int i = text.length - 1; i >= 0; i--) {
      counter++;
      formatted = text[i] + formatted;
      if (counter == 3 && i > 0) { formatted = '.$formatted'; counter = 0; }
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}