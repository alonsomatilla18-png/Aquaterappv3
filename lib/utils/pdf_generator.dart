import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/informe_model.dart';

class PdfGenerator {
  // COLORES CORPORATIVOS
  static const PdfColor _aquaterBlue = PdfColor.fromInt(0xFF0D47A1);
  static const PdfColor _aquaterLightBlue = PdfColor.fromInt(0xFFBBDEFB);
  static const PdfColor _greyHeader = PdfColor.fromInt(0xFFE0E0E0);
  
  // ESTILOS DE TEXTO
  final pw.TextStyle _headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _aquaterBlue);
  final pw.TextStyle _subHeaderStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _aquaterBlue);
  final pw.TextStyle _tableHeaderStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
  final pw.TextStyle _tableCellStyle = const pw.TextStyle(fontSize: 9);
  final pw.TextStyle _equipmentTitleStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white);

  // OPTIMIZACIÓN: Mapas estáticos
  static const Map<String, String> mapaFirmas = {
    "Jorge Raúl Cornejo Sotomayor": "assets/images/firma_jorge.png",
    "Marco Antonio Matilla Bustos": "assets/images/firma_marco.png",
    "Maximiliano Nicolas Vásquez Canto": "assets/images/firma_maximiliano.png",
    "Gustavo David Cornejo Sotomayor": "assets/images/firma_gustavo.png",
  };
  
  static const Map<String, String> mapaRutsTecnicos = {
    "Jorge Raúl Cornejo Sotomayor": "13.248.393-0",
    "Marco Antonio Matilla Bustos": "6.220.340-4",
    "Maximiliano Nicolas Vásquez Canto": "13.914.943-2",
    "Gustavo David Cornejo Sotomayor": "13.248.394-9",
  };

  Future<pw.ImageProvider> _getLogoCliente(String cliente) async {
    String assetPath = 'assets/images/logo_duoc.png';
    String c = cliente.toLowerCase();
    if (c.contains('iss')) {
      assetPath = 'assets/images/logo_iss.png';
    } else if (c.contains('ventisquero') || c.contains('viña')) assetPath = 'assets/images/logo_ventisquero.png';
    try { return await imageFromAssetBundle(assetPath); } catch (_) { return await imageFromAssetBundle('assets/images/logo_duoc.png'); }
  }

  double _getLogoHeight(String cliente) {
    String c = cliente.toLowerCase();
    if (c.contains('ventisquero') || c.contains('viña')) return 120;
    return 50;
  }

  // REPORTE 1: MANTENCIÓN
  Future<Uint8List> generarPdfMantencion(InformeMantencion informe, List<XFile>? fotosLocales, Uint8List? firmaInspeccionaBytes) async {
    final pdf = pw.Document();
    pw.ImageProvider? logoAquater; try { logoAquater = await imageFromAssetBundle('assets/images/logo_aquater.png'); } catch (_) {}
    pw.ImageProvider logoCliente = await _getLogoCliente(informe.cliente); double logoH = _getLogoHeight(informe.cliente);
    
    pw.ImageProvider? firmaTecnicoAquater; String rutTecnico = mapaRutsTecnicos[informe.tecnicoId] ?? "";
    if (mapaFirmas.containsKey(informe.tecnicoId)) { try { firmaTecnicoAquater = await imageFromAssetBundle(mapaFirmas[informe.tecnicoId]!); } catch (_) {} }
    
    List<Uint8List> fotosProcesadas = await _procesarFotosBytes(fotosLocales);
    final fechaTexto = "${informe.fechaServicio.day.toString().padLeft(2,'0')}/${informe.fechaServicio.month.toString().padLeft(2,'0')}/${informe.fechaServicio.year}";

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 30),
      footer: (context) => _buildFooter(context),
      build: (context) {
        List<pw.Widget> contenido = [
          _buildHeader(logoCliente, logoAquater, logoH, informe.codigoCorrelativo),
          pw.Center(child: pw.Text("INFORME TÉCNICO DE MANTENCIÓN", style: _headerStyle)),
          pw.SizedBox(height: 20),
          pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _aquaterBlue, width: 1)),
            child: pw.Table(
              border: pw.TableBorder.symmetric(inside: const pw.BorderSide(color: _aquaterBlue, width: 0.5)),
              columnWidths: {0: const pw.FlexColumnWidth(1.5), 1: const pw.FlexColumnWidth(3)},
              children: [
                _filaTablaEstilizada("FECHA SERVICIO", fechaTexto, true),
                _filaTablaEstilizada("CLIENTE", informe.cliente, false),
                _filaTablaEstilizada("INSTALACIÓN / SEDE", informe.sede, true),
                _filaTablaEstilizada("TÉCNICO RESPONSABLE", informe.tecnicoId, false)
              ]
            )
          ),
          pw.SizedBox(height: 25),
          pw.Text("DETALLE DE EQUIPOS INSPECCIONADOS", style: _subHeaderStyle),
          pw.SizedBox(height: 10),
        ];

        for (var equipo in informe.equipos) {
          if (equipo.tipoBomba == 'bom') {
            contenido.add(_templateBomUnified(equipo));
          } else if (equipo.tipoBomba.startsWith('ta')) contenido.add(_templateTableroUnified(equipo));
          else contenido.add(_templateGenericoUnified(equipo));
          contenido.add(pw.SizedBox(height: 20));
        }

        contenido.add(_buildObservaciones(informe.observaciones));
        contenido.add(pw.SizedBox(height: 30));
        contenido.add(_buildFirmasDoble(firmaTecnicoAquater, firmaInspeccionaBytes, informe.nombreInspecciona, informe.rutInspecciona, rutTecnico));
        
        if (fotosProcesadas.isNotEmpty) {
          contenido.add(pw.NewPage());
          contenido.add(pw.Center(child: pw.Text("REGISTRO FOTOGRÁFICO", style: _headerStyle)));
          contenido.add(pw.Divider(color: _aquaterBlue));
          contenido.add(pw.SizedBox(height: 20));
          contenido.addAll(_buildPhotoGrid(fotosProcesadas));
        }
        return contenido;
      }
    ));
    return pdf.save();
  }

  // --- TEMPLATES UNIFICADOS ---
  pw.Widget _templateBomUnified(DetalleMantencionBomba e) {
    return pw.Table(
      border: pw.TableBorder.all(color: _aquaterBlue, width: 1.5),
      columnWidths: {0: const pw.FlexColumnWidth()},
      children: [
        _rowTitle(e.nombreEquipo, e.ubicacion),
        _rowSubtitle("Inspección Mecánica e Hidráulica"),
        _rowChecklistHeader(),
        ..._buildChecklistRows([
          "1. Inspección visual de la bomba, detección de fugas en el sello mecánico del eje.", 
          "2. Medida de la temperatura del cuerpo de la bomba (en funcionamiento si es posible).", 
          "3. Inspección general: Revisión de ruidos anormales, vibraciones excesivas, estado de pintura y limpieza.", 
          "4. Inspección operativa de llaves de paso, válvulas de retención y sensores asociados.", 
          "5. Revisión completa del sistema de llenado de los estanques de acumulación de agua potable."
        ], e.checklist, "mec"),
        _rowSubtitle("Mediciones Eléctricas"),
        pw.TableRow(children: [pw.Padding(padding: const pw.EdgeInsets.all(5), child: _tableMedicionesVisual(e))])
      ]
    );
  }

  pw.Widget _templateTableroUnified(DetalleMantencionBomba e) {
    List<String> items = [
      "1. Revisión general de circuitos eléctricos de fuerza y control.", 
      "2. Revisión, limpieza y ajuste de apriete de controles de comandos eléctricos.", 
      "3. Revisión, limpieza y ajuste de contactores, presóstatos, temporizadores y variadores de frecuencia.", 
      "4. Inspección visual del correcto estado de todas las conexiones eléctricas y cableado.", 
      "5. Pruebas de funcionamiento de alarmas sonoras/lumínicas y sistemas de bloqueo de seguridad."
    ];
    if(e.tipoBomba=='tabom') items.addAll(["6. Control y verificación de presión de aire en estanques hidroneumáticos.", "7. Inspección visual de estado de flexibles y juntas elásticas antivibratorias."]);
    if(e.tipoBomba=='taser') items.add("6. Revisión visual del estado de la cámara/fosa (nivel, suciedad).");

    return pw.Table(
      border: pw.TableBorder.all(color: _aquaterBlue, width: 1.5),
      columnWidths: {0: const pw.FlexColumnWidth()},
      children: [
        _rowTitle(e.nombreEquipo, "Tablero de Control"),
        _rowSubtitle("Chequeo Eléctrico y de Control"),
        _rowChecklistHeader(),
        ..._buildChecklistRows(items, e.checklist, "elec"),
      ]
    );
  }

  pw.Widget _templateGenericoUnified(DetalleMantencionBomba e) {
    List<pw.TableRow> rows = [
      _rowTitle(e.nombreEquipo, ""),
      _rowSubtitle("Inspección General"),
      _rowChecklistHeader(),
      ..._buildChecklistRows(["1. Inspección operativa general (ruidos, vibraciones, estado físico)."], e.checklist, "mec"),
    ];
    if(e.ampR > 0 || e.voltRT > 0) {
      rows.add(_rowSubtitle("Mediciones Eléctricas (Si aplica)"));
      rows.add(pw.TableRow(children: [pw.Padding(padding: const pw.EdgeInsets.all(5), child: _tableMedicionesVisual(e))]));
    }
    return pw.Table(border: pw.TableBorder.all(color: _aquaterBlue, width: 1.5), columnWidths: {0: const pw.FlexColumnWidth()}, children: rows);
  }

  // REPORTE 2: FOSA
  Future<Uint8List> generarPdfFosa(InformeFosa informe, [List<XFile>? fotosLocales]) async { 
    final pdf = pw.Document(); 
    pw.ImageProvider? logoAquater; try { logoAquater = await imageFromAssetBundle('assets/images/logo_aquater.png'); } catch (_) {} 
    pw.ImageProvider logoCliente = await _getLogoCliente(informe.cliente); double logoH = _getLogoHeight(informe.cliente); 
    
    pw.ImageProvider? firmaTecnico; if (mapaFirmas.containsKey(informe.personaResponsable)) { try { firmaTecnico = await imageFromAssetBundle(mapaFirmas[informe.personaResponsable]!); } catch (_) {} } 
    List<Uint8List> fotosProcesadas = await _procesarFotosBytes(fotosLocales); 
    pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 30), footer: (context) => _buildFooter(context), 
    build: (context) => [
      _buildHeader(logoCliente, logoAquater, logoH, informe.codigoCorrelativo), 
      pw.Table(border: pw.TableBorder.all(color: PdfColors.black, width: 0.5), columnWidths: {0: const pw.FlexColumnWidth(1.5), 1: const pw.FlexColumnWidth(3)}, children: [_filaTabla("CLIENTE", informe.cliente), _filaTabla("SERVICIO", "Limpieza de Fosa"), _filaTabla("INSTALACIÓN", informe.sede), _filaTabla("GUÍA Nº", informe.guia), _filaTabla("CERTIFICADO Nº", informe.numCertificado)]), 
      pw.SizedBox(height: 25), 
      pw.Center(child: pw.Text("CERTIFICADO ${informe.fechaServicio.year} / ${informe.numCertificado}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))), 
      pw.SizedBox(height: 15), 
      pw.Text("Servicios de Análisis Químico Aquater Ltda., rut 76.153.908-6, Eliodoro Yañez 1568 Providencia, Santiago, certifica la limpieza de cámara receptora de aguas servidas y grasas, ubicada en las instalaciones de ${informe.sede} (Guía Nº ${informe.guia}).", textAlign: pw.TextAlign.justify, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)), 
      pw.SizedBox(height: 15), 
      _buildObservaciones(informe.observaciones), 
      pw.SizedBox(height: 15), 
      pw.Text("Fecha: ${informe.fechaServicio.day}/${informe.fechaServicio.month}/${informe.fechaServicio.year}", style: const pw.TextStyle(fontSize: 11)), 
      pw.SizedBox(height: 10), 
      pw.Text("Empresa encargada: Aquater Ltda.", style: const pw.TextStyle(fontSize: 11)), 
      pw.SizedBox(height: 10), 
      pw.Text("Persona Responsable: ${informe.personaResponsable}", style: const pw.TextStyle(fontSize: 11)), 
      pw.SizedBox(height: 30), 
      _buildFirmaBlock(firmaTecnico, "Firma Responsable"), 
      if(fotosProcesadas.isNotEmpty) ...[pw.NewPage(), pw.Center(child: pw.Text("REGISTRO FOTOGRÁFICO", style: _headerStyle)), pw.Divider(color: _aquaterBlue), pw.SizedBox(height: 20), ..._buildPhotoGrid(fotosProcesadas)]
    ])); 
    return pdf.save(); 
  }

  // REPORTE 3: SANITIZACION
  Future<Uint8List> generarPdfSanitizacion(InformeSanitizacion informe, List<XFile>? fotosLocales, Uint8List? firmaInspeccionaBytes) async { 
    final pdf = pw.Document(); 
    pw.ImageProvider? logoAquater; try { logoAquater = await imageFromAssetBundle('assets/images/logo_aquater.png'); } catch (_) {} 
    pw.ImageProvider logoCliente = await _getLogoCliente(informe.cliente); double logoH = _getLogoHeight(informe.cliente); 
    
    pw.ImageProvider? firmaTecnicoAquater; String rutTecnico = mapaRutsTecnicos[informe.tecnicoId] ?? ""; 
    if (mapaFirmas.containsKey(informe.tecnicoId)) { try { firmaTecnicoAquater = await imageFromAssetBundle(mapaFirmas[informe.tecnicoId]!); } catch (_) {} } 
    List<Uint8List> fotosProcesadas = await _procesarFotosBytes(fotosLocales); 
    final fechaTexto = "${informe.fechaServicio.day.toString().padLeft(2,'0')}/${informe.fechaServicio.month.toString().padLeft(2,'0')}/${informe.fechaServicio.year}"; 
    pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 30), footer: (context) => _buildFooter(context), 
    build: (context) => [
      _buildHeader(logoCliente, logoAquater, logoH, informe.codigoCorrelativo), 
      pw.Center(child: pw.Text("INFORME DE SANITIZACIÓN Y LIMPIEZA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))), 
      pw.SizedBox(height: 20), 
      pw.Table(border: pw.TableBorder.all(color: PdfColors.black, width: 0.5), columnWidths: {0: const pw.FlexColumnWidth(1.5), 1: const pw.FlexColumnWidth(3)}, children: [_filaTabla("CLIENTE", informe.cliente), _filaTabla("SERVICIO", "Sanitización y Limpieza"), _filaTabla("INSTALACIÓN", informe.sede), _filaTabla("PERSONA RESPONSABLE", informe.tecnicoId)]), 
      pw.SizedBox(height: 25), 
      pw.Container(width: double.infinity, child: pw.Text("Se realiza limpieza y sanitización de estanques acumuladores de agua potable con fecha $fechaTexto, en las instalaciones de ${informe.sede}.", style: const pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.justify)), 
      pw.SizedBox(height: 15), 
      _buildObservaciones(informe.observaciones), 
      pw.SizedBox(height: 40), 
      _buildFirmasDoble(firmaTecnicoAquater, firmaInspeccionaBytes, informe.nombreInspecciona, informe.rutInspecciona, rutTecnico), 
      if (fotosProcesadas.isNotEmpty) ...[pw.NewPage(), pw.Center(child: pw.Text("REGISTRO FOTOGRÁFICO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))), pw.SizedBox(height: 20), ..._buildPhotoGrid(fotosProcesadas)]
    ])); 
    return pdf.save(); 
  }

  // REPORTE 4: RECUPERACION
  Future<Uint8List> generarPdfRecuperacion(InformeRecuperacion informe, List<XFile>? fotosLocales, Uint8List? firmaInspeccionaBytes) async { 
    final pdf = pw.Document(); 
    pw.ImageProvider? logoAquater; try { logoAquater = await imageFromAssetBundle('assets/images/logo_aquater.png'); } catch (_) {} 
    pw.ImageProvider logoCliente = await _getLogoCliente(informe.cliente); double logoH = _getLogoHeight(informe.cliente); 
    
    pw.ImageProvider? firmaTecnicoAquater; String rutTecnico = mapaRutsTecnicos[informe.tecnicoId] ?? ""; 
    if (mapaFirmas.containsKey(informe.tecnicoId)) { try { firmaTecnicoAquater = await imageFromAssetBundle(mapaFirmas[informe.tecnicoId]!); } catch (_) {} } 
    List<Uint8List> fotosProcesadas = await _procesarFotosBytes(fotosLocales); 
    final inicio = "${informe.fechaInicio.day}/${informe.fechaInicio.month}/${informe.fechaInicio.year}"; 
    final fin = "${informe.fechaFin.day}/${informe.fechaFin.month}/${informe.fechaFin.year}"; 
    pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 30), footer: (context) => _buildFooter(context), 
    build: (context) => [
      _buildHeader(logoCliente, logoAquater, logoH, informe.codigoCorrelativo), 
      pw.Table(border: pw.TableBorder.all(color: PdfColors.black, width: 0.5), columnWidths: {0: const pw.FlexColumnWidth(1.5), 1: const pw.FlexColumnWidth(3)}, children: [_filaTabla("FECHA", inicio), _filaTabla("CLIENTE", informe.cliente), _filaTabla("SERVICIO", "Recuperación de Diámetro"), _filaTabla("PERSONA RESPONSABLE", informe.tecnicoId)]), 
      pw.SizedBox(height: 25), 
      pw.Center(child: pw.Text("DESCRIPCIÓN DEL TRABAJO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))), 
      pw.SizedBox(height: 10), 
      pw.Bullet(text: "Recuperación de Diámetro."), pw.SizedBox(height: 5), pw.Bullet(text: "Aplicación de solución desincrustante."), 
      pw.SizedBox(height: 20), 
      pw.Text("Los trabajos fueron realizados en las siguientes fechas:", style: const pw.TextStyle(fontSize: 11)), pw.SizedBox(height: 5), pw.Text("Inicio $inicio"), pw.Text("Fin $fin"), 
      pw.SizedBox(height: 10), 
      pw.Text("Estos labores fueron realizados por ${informe.tecnicoId}.", style: const pw.TextStyle(fontSize: 11)), 
      pw.SizedBox(height: 15), 
      _buildObservaciones(informe.observaciones), 
      pw.SizedBox(height: 30), 
      _buildFirmasDoble(firmaTecnicoAquater, firmaInspeccionaBytes, informe.nombreInspecciona, informe.rutInspecciona, rutTecnico), 
      if (fotosProcesadas.isNotEmpty) ...[pw.NewPage(), pw.Center(child: pw.Text("REGISTRO FOTOGRÁFICO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))), pw.SizedBox(height: 20), ..._buildPhotoGrid(fotosProcesadas)]
    ])); 
    return pdf.save(); 
  }

  // REPORTE 5: CONSTANCIA
  Future<Uint8List> generarPdfConstancia(InformeConstancia informe, List<XFile>? fotosLocales, Uint8List? firmaInspeccionaBytes) async { 
    final pdf = pw.Document(); 
    pw.ImageProvider? logoAquater; try { logoAquater = await imageFromAssetBundle('assets/images/logo_aquater.png'); } catch (_) {} 
    pw.ImageProvider logoCliente = await _getLogoCliente(informe.cliente); double logoH = _getLogoHeight(informe.cliente); 
    
    pw.ImageProvider? firmaTecnicoAquater; String rutTecnico = mapaRutsTecnicos[informe.tecnicoId] ?? ""; 
    if (mapaFirmas.containsKey(informe.tecnicoId)) { try { firmaTecnicoAquater = await imageFromAssetBundle(mapaFirmas[informe.tecnicoId]!); } catch (_) {} } 
    List<Uint8List> fotosProcesadas = await _procesarFotosBytes(fotosLocales); 
    final fechaTexto = "${informe.fechaServicio.day}/${informe.fechaServicio.month}/${informe.fechaServicio.year}"; 
    pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 30), footer: (context) => _buildFooter(context), 
    build: (context) => [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.center, children: [pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [logoAquater != null ? pw.Container(height: 50, child: pw.Image(logoAquater, fit: pw.BoxFit.contain)) : pw.Container(height: 50), if (informe.codigoCorrelativo != null) pw.Text("Nº ${informe.codigoCorrelativo}", style: pw.TextStyle(fontSize: 10, color: PdfColors.red, fontWeight: pw.FontWeight.bold))]), pw.Container(height: logoH, alignment: pw.Alignment.topRight, child: pw.Image(logoCliente, fit: pw.BoxFit.contain))]), 
      pw.SizedBox(height: 10), pw.Divider(thickness: 1), pw.SizedBox(height: 20), 
      pw.Center(child: pw.Text("INFORME DE CONSTANCIA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))), 
      pw.SizedBox(height: 20), 
      pw.Table(border: pw.TableBorder.all(color: PdfColors.black, width: 0.5), columnWidths: {0: const pw.FlexColumnWidth(1.5), 1: const pw.FlexColumnWidth(3)}, children: [_filaTabla("FECHA", fechaTexto), _filaTabla("CLIENTE", informe.cliente), _filaTabla("PROYECTO", informe.sede), _filaTabla("PERSONA RESPONSABLE", informe.tecnicoId)]), 
      pw.SizedBox(height: 20), 
      pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(10), decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5)), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text("DESCRIPCIÓN DEL TRABAJO REALIZADO:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)), pw.SizedBox(height: 5), pw.Text(informe.descripcionTrabajo, style: const pw.TextStyle(fontSize: 10))])), 
      pw.SizedBox(height: 15), 
      _buildObservaciones(informe.observaciones), 
      pw.SizedBox(height: 40), 
      _buildFirmasDoble(firmaTecnicoAquater, firmaInspeccionaBytes, informe.nombreInspecciona, informe.rutInspecciona, rutTecnico), 
      if (fotosProcesadas.isNotEmpty) ...[pw.NewPage(), pw.Center(child: pw.Text("REGISTRO FOTOGRÁFICO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))), pw.SizedBox(height: 20), ..._buildPhotoGrid(fotosProcesadas)]
    ])); 
    return pdf.save(); 
  }

  // --- HELPERS Y UTILS ---

  // ✅ CAMBIO 1: Aumentar tamaño de firma sola (ej: Fosa)
  pw.Widget _buildFirmaBlock(pw.ImageProvider? firma, String titulo) { 
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start, 
      children: [
        if (firma != null) 
          // Antes: height: 60, width: 120. AHORA: height: 120, width: 250
          pw.Container(height: 120, width: 250, alignment: pw.Alignment.centerLeft, child: pw.Image(firma, fit: pw.BoxFit.contain)) 
        else 
          pw.SizedBox(height: 120), 
        
        // Antes: width: 200. AHORA: width: 250
        pw.Container(width: 250, height: 1, color: PdfColors.black), 
        pw.Text(titulo, style: const pw.TextStyle(fontSize: 9))
      ]
    ); 
  }

  // ✅ CAMBIO 2: Aumentar tamaño de firmas dobles (ej: Mantención)
  pw.Widget _buildFirmasDoble(pw.ImageProvider? firmaIzq, Uint8List? firmaDerBytes, String? nombreDer, String? rutDer, String rutTecnico) { 
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, 
      crossAxisAlignment: pw.CrossAxisAlignment.end, 
      children: [
        // Firma Izquierda
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center, 
          children: [
            if (firmaIzq != null) 
              // Antes: height: 60, width: 120. AHORA: height: 100, width: 180
              pw.Container(height: 100, width: 180, child: pw.Image(firmaIzq, fit: pw.BoxFit.contain)) 
            else 
              pw.SizedBox(height: 100), 
            // Antes: width: 150. AHORA: width: 180
            pw.Container(width: 180, height: 1, color: PdfColors.black), 
            pw.SizedBox(height: 2), 
            pw.Text("Firma Responsable Aquater", style: const pw.TextStyle(fontSize: 9)), 
            if (rutTecnico.isNotEmpty) pw.Text("RUT: $rutTecnico", style: const pw.TextStyle(fontSize: 8)), 
            pw.Text("(Aquater Ltda.)", style: const pw.TextStyle(fontSize: 8))
          ]
        ), 
        // Firma Derecha
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center, 
          children: [
            if (firmaDerBytes != null) 
              // Antes: height: 60, width: 120. AHORA: height: 100, width: 180
              pw.Container(height: 100, width: 180, child: pw.Image(pw.MemoryImage(firmaDerBytes), fit: pw.BoxFit.contain)) 
            else 
              pw.SizedBox(height: 100), 
            // Antes: width: 150. AHORA: width: 180
            pw.Container(width: 180, height: 1, color: PdfColors.black), 
            pw.SizedBox(height: 2), 
            pw.Text(nombreDer ?? "", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)), 
            if (rutDer != null && rutDer.isNotEmpty) pw.Text("RUT: $rutDer", style: const pw.TextStyle(fontSize: 9)), 
            pw.Text("Nombre, Rut y Firma Encargado", style: const pw.TextStyle(fontSize: 9))
          ]
        )
      ]
    ); 
  }

  Future<List<Uint8List>> _procesarFotosBytes(List<XFile>? fotos) async {
    List<Uint8List> listaBytes = [];
    if (fotos != null && fotos.isNotEmpty) {
      for (var file in fotos) {
        try {
          final Uint8List originalBytes = await file.readAsBytes();
          final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
            originalBytes,
            minHeight: 800, 
            minWidth: 800,
            quality: 70,
          );
          listaBytes.add(compressedBytes);
        } catch (e) {
          print("Error procesando foto: $e");
        }
      }
    }
    return listaBytes;
  }

  List<pw.Widget> _buildPhotoGrid(List<Uint8List> images) {
    List<pw.Widget> rows = [];
    for (int i = 0; i < images.length; i += 2) {
      // Altura aumentada para fotos grandes
      double altura = 350; 
      
      pw.Widget leftPhoto = pw.Expanded(child: pw.Container(height: altura, decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)), child: pw.Image(pw.MemoryImage(images[i]), fit: pw.BoxFit.contain)));
      pw.Widget rightPhoto;
      if (i + 1 < images.length) { rightPhoto = pw.Expanded(child: pw.Container(height: altura, margin: const pw.EdgeInsets.only(left: 10), decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)), child: pw.Image(pw.MemoryImage(images[i + 1]), fit: pw.BoxFit.contain))); } 
      else { rightPhoto = pw.Expanded(child: pw.Container()); }
      rows.add(pw.Padding(padding: const pw.EdgeInsets.only(bottom: 15), child: pw.Row(children: [leftPhoto, rightPhoto])));
    }
    return rows;
  }
  
  pw.Widget _buildHeader(pw.ImageProvider? logo1, pw.ImageProvider? logo2, double logoH, String? corre) { return pw.Column(children: [pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [logo1 != null ? pw.Container(height: logoH, child: pw.Image(logo1, fit: pw.BoxFit.contain)) : pw.Container(height: logoH), pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [logo2 != null ? pw.Container(height: 50, child: pw.Image(logo2, fit: pw.BoxFit.contain)) : pw.Container(height: 50), if (corre != null) pw.Text("Nº $corre", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))])]), pw.SizedBox(height: 10), pw.Divider(thickness: 1, color: _aquaterBlue), pw.SizedBox(height: 20)]); }
  
  pw.Widget _buildFooter(pw.Context? context) { 
    return pw.Column(
      children: [
        pw.Divider(color: _aquaterBlue),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
             pw.Text("Web: www.aquater.cl | Mail: contacto@aquater.cl", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
             if (context != null)
               pw.Text("Página ${context.pageNumber} de ${context.pagesCount}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800))
          ]
        ),
      ]
    );
  }

  pw.TableRow _filaTabla(String titulo, String valor) { return pw.TableRow(children: [pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8), child: pw.Text(titulo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))), pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8), child: pw.Text(valor, style: const pw.TextStyle(fontSize: 10)))]); }
  
  // Helpers Tabla Bombas
  pw.TableRow _rowTitle(String title, String? sub) { return pw.TableRow(decoration: const pw.BoxDecoration(color: _aquaterBlue), children: [pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(title.toUpperCase(), style: _equipmentTitleStyle), if(sub != null && sub.isNotEmpty) pw.Text(sub, style: _equipmentTitleStyle.copyWith(fontSize: 10))]))]); }
  pw.TableRow _rowSubtitle(String title) { return pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10), child: pw.Row(children: [pw.PdfLogo(color: _aquaterBlue), pw.SizedBox(width: 8), pw.Text(title, style: _subHeaderStyle)]))]); }
  pw.TableRow _rowChecklistHeader() { return pw.TableRow(decoration: const pw.BoxDecoration(color: _aquaterBlue), children: [pw.Row(children: [_expandedCell("Punto de Inspección", 5, true), _expandedCell("Estado", 2, true), _expandedCell("Observaciones", 3, true)])]); }
  
  List<pw.TableRow> _buildChecklistRows(List<String> items, Map<String, dynamic> check, String prefix) {
    List<pw.TableRow> rows = [];
    for(int i=0; i<items.length; i++) {
      String key = "${prefix}_${i + 1}";
      String estado = check[key]?['estado'] ?? "---";
      String obs = check[key]?['obs'] ?? "";
      bool isEven = i % 2 == 0;
      PdfColor estadoColor = PdfColors.black; 
      if(estado == 'No' || estado == 'Malo' || estado.contains('Con problemas')) estadoColor = PdfColors.red900; 
      if(estado == 'OK' || estado == 'Si' || estado.contains('Sin problemas')) estadoColor = PdfColors.green900;
      rows.add(pw.TableRow(decoration: pw.BoxDecoration(color: isEven ? PdfColors.white : _greyHeader.shade(0.9)), children: [pw.Row(children: [_expandedCell(items[i], 5, false, alignLeft: true), _expandedCell(estado, 2, false, color: estadoColor, isBold: true), _expandedCell(obs, 3, false, isItalic: true)])]));
    }
    return rows;
  }

  pw.Widget _expandedCell(String text, int flex, bool isHeader, {bool alignLeft = false, PdfColor? color, bool isBold = false, bool isItalic = false}) { return pw.Expanded(flex: flex, child: pw.Container(padding: const pw.EdgeInsets.all(6), decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: _greyHeader, width: 0.5))), alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center, child: pw.Text(text, style: isHeader ? _tableHeaderStyle : _tableCellStyle.copyWith(color: color, fontWeight: isBold ? pw.FontWeight.bold : null, fontStyle: isItalic ? pw.FontStyle.italic : null), textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center))); }
  pw.TableRow _filaTablaEstilizada(String titulo, String valor, bool esGris) => pw.TableRow(decoration: pw.BoxDecoration(color: esGris ? _greyHeader : PdfColors.white), children: [pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(titulo, style: _tableCellStyle.copyWith(fontWeight: pw.FontWeight.bold))), pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(valor, style: _tableCellStyle))]);
  pw.Widget _tableMedicionesVisual(DetalleMantencionBomba e) { return pw.Table(border: pw.TableBorder.all(color: _greyHeader, width: 1), children: [pw.TableRow(decoration: const pw.BoxDecoration(color: _aquaterLightBlue), children: [pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("CONSUMO (Amperes)", style: _subHeaderStyle.copyWith(fontSize: 10)))), pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("VOLTAJE (Volts)", style: _subHeaderStyle.copyWith(fontSize: 10))))]), pw.TableRow(children: [_celdaMedicionGrupo(["R: ${e.ampR}", "S: ${e.ampS}", "T: ${e.ampT}"]), _celdaMedicionGrupo(["R-T: ${e.voltRT}", "S-T: ${e.voltST}", "R-S: ${e.voltRS}"])])]); }
  pw.Widget _celdaMedicionGrupo(List<String> valores) => pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: valores.map((v) => pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: pw.BoxDecoration(border: pw.Border.all(color: _greyHeader), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))), child: pw.Text(v, style: _tableCellStyle.copyWith(fontWeight: pw.FontWeight.bold)))).toList()));
  
  pw.Widget _buildObservaciones(String obs) {
    if (obs.isEmpty) return pw.Container();
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text("OBSERVACIONES:", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)), pw.SizedBox(height: 5), pw.Text(obs, style: const pw.TextStyle(fontSize: 10)), pw.SizedBox(height: 20)]);
  }
}