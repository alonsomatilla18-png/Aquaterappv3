import 'package:cloud_firestore/cloud_firestore.dart';

abstract class InformeBase {
  String? id;
  String cliente;
  String sede;
  String tecnicoId;
  DateTime fechaCreacion;
  String tipoServicio;
  String? firmaUrl;
  String estado;
  String observaciones;
  String? codigoCorrelativo;

  InformeBase({
    this.id,
    required this.cliente,
    required this.sede,
    required this.tecnicoId,
    required this.fechaCreacion,
    required this.tipoServicio,
    this.firmaUrl,
    this.estado = 'pendiente',
    this.observaciones = '',
    this.codigoCorrelativo,
  });

  Map<String, dynamic> toMap();

  // MÉTODO NUEVO: Fábrica inteligente para convertir datos de Firebase a Objetos
  static InformeBase fromMap(Map<String, dynamic> map, String id) {
    final tipo = map['tipoServicio'];
    switch (tipo) {
      case 'fosa':
        return InformeFosa.fromMap(map, id);
      case 'man':
        return InformeMantencion.fromMap(map, id);
      case 'sani':
        return InformeSanitizacion.fromMap(map, id);
      case 'recu':
        return InformeRecuperacion.fromMap(map, id);
      case 'cons':
        return InformeConstancia.fromMap(map, id);
      default:
        // Si hay datos viejos o desconocidos, retornamos una constancia genérica para no romper la app
        return InformeConstancia.fromMap(map, id); 
    }
  }
}

class DetalleMantencionBomba {
  String tipoBomba;
  String nombreEquipo;
  String? ubicacion;
  double ampR, ampS, ampT;
  double voltRT, voltST, voltRS;
  Map<String, Map<String, String>> checklist;

  DetalleMantencionBomba({
    required this.tipoBomba,
    required this.nombreEquipo,
    this.ubicacion,
    this.ampR = 0, this.ampS = 0, this.ampT = 0,
    this.voltRT = 0, this.voltST = 0, this.voltRS = 0,
    required this.checklist,
  });

  Map<String, dynamic> toMap() => {
    'tipoBomba': tipoBomba, 'nombreEquipo': nombreEquipo, 'ubicacion': ubicacion,
    'ampR': ampR, 'ampS': ampS, 'ampT': ampT,
    'voltRT': voltRT, 'voltST': voltST, 'voltRS': voltRS,
    'checklist': checklist,
  };

  // NUEVO: Para leer el equipo desde Firebase
  factory DetalleMantencionBomba.fromMap(Map<String, dynamic> map) {
    // Conversión segura del checklist
    Map<String, Map<String, String>> checkMap = {};
    if (map['checklist'] != null) {
      (map['checklist'] as Map).forEach((k, v) {
        checkMap[k.toString()] = {
          'estado': v['estado']?.toString() ?? '',
          'obs': v['obs']?.toString() ?? ''
        };
      });
    }

    return DetalleMantencionBomba(
      tipoBomba: map['tipoBomba'] ?? 'bom',
      nombreEquipo: map['nombreEquipo'] ?? 'Equipo',
      ubicacion: map['ubicacion'],
      ampR: (map['ampR'] ?? 0).toDouble(),
      ampS: (map['ampS'] ?? 0).toDouble(),
      ampT: (map['ampT'] ?? 0).toDouble(),
      voltRT: (map['voltRT'] ?? 0).toDouble(),
      voltST: (map['voltST'] ?? 0).toDouble(),
      voltRS: (map['voltRS'] ?? 0).toDouble(),
      checklist: checkMap,
    );
  }
}

class InformeFosa extends InformeBase {
  String guia; String numCertificado; String personaResponsable; String? fotoUrl; int correlativo; DateTime fechaServicio;

  InformeFosa({super.id, required super.cliente, required super.sede, required super.tecnicoId, required super.fechaCreacion, super.firmaUrl, super.estado, required this.guia, required this.numCertificado, required this.personaResponsable, required this.correlativo, required this.fechaServicio, super.observaciones, super.codigoCorrelativo, this.fotoUrl}) : super(tipoServicio: 'fosa');

  @override Map<String, dynamic> toMap() => {'cliente': cliente, 'sede': sede, 'tecnicoId': tecnicoId, 'fechaCreacion': Timestamp.fromDate(fechaCreacion), 'tipoServicio': 'fosa', 'firmaUrl': firmaUrl, 'estado': estado, 'guia': guia, 'numCertificado': numCertificado, 'personaResponsable': personaResponsable, 'correlativo': correlativo, 'fechaServicio': Timestamp.fromDate(fechaServicio), 'observaciones': observaciones, 'codigoCorrelativo': codigoCorrelativo, 'fotoUrl': fotoUrl};

  // NUEVO: Lectura
  factory InformeFosa.fromMap(Map<String, dynamic> map, String id) {
    return InformeFosa(
      id: id,
      cliente: map['cliente'] ?? '',
      sede: map['sede'] ?? '',
      tecnicoId: map['tecnicoId'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      firmaUrl: map['firmaUrl'],
      estado: map['estado'] ?? 'pendiente',
      guia: map['guia'] ?? '',
      numCertificado: map['numCertificado'] ?? '',
      personaResponsable: map['personaResponsable'] ?? '',
      correlativo: map['correlativo'] ?? 0,
      fechaServicio: (map['fechaServicio'] as Timestamp).toDate(),
      observaciones: map['observaciones'] ?? '',
      codigoCorrelativo: map['codigoCorrelativo'],
      fotoUrl: map['fotoUrl'],
    );
  }
}

class InformeMantencion extends InformeBase {
  String personaResponsable; DateTime fechaServicio; String? fotoUrl; String? nombreInspecciona; String? rutInspecciona;
  List<DetalleMantencionBomba> equipos;

  InformeMantencion({super.id, required super.cliente, required super.sede, required super.tecnicoId, required super.fechaCreacion, super.firmaUrl, super.estado, required this.personaResponsable, required this.fechaServicio, required this.equipos, super.observaciones, super.codigoCorrelativo, this.fotoUrl, this.nombreInspecciona, this.rutInspecciona}) : super(tipoServicio: 'man');

  @override Map<String, dynamic> toMap() => {'cliente': cliente, 'sede': sede, 'tecnicoId': tecnicoId, 'fechaCreacion': Timestamp.fromDate(fechaCreacion), 'tipoServicio': 'man', 'firmaUrl': firmaUrl, 'estado': estado, 'personaResponsable': personaResponsable, 'fechaServicio': Timestamp.fromDate(fechaServicio), 'observaciones': observaciones, 'codigoCorrelativo': codigoCorrelativo, 'fotoUrl': fotoUrl, 'nombreInspecciona': nombreInspecciona, 'rutInspecciona': rutInspecciona, 'equipos': equipos.map((e) => e.toMap()).toList()};

  // NUEVO: Lectura
  factory InformeMantencion.fromMap(Map<String, dynamic> map, String id) {
    return InformeMantencion(
      id: id,
      cliente: map['cliente'] ?? '',
      sede: map['sede'] ?? '',
      tecnicoId: map['tecnicoId'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      firmaUrl: map['firmaUrl'],
      estado: map['estado'] ?? 'pendiente',
      personaResponsable: map['personaResponsable'] ?? '',
      fechaServicio: (map['fechaServicio'] as Timestamp).toDate(),
      observaciones: map['observaciones'] ?? '',
      codigoCorrelativo: map['codigoCorrelativo'],
      fotoUrl: map['fotoUrl'],
      nombreInspecciona: map['nombreInspecciona'],
      rutInspecciona: map['rutInspecciona'],
      equipos: (map['equipos'] as List<dynamic>? ?? []).map((e) => DetalleMantencionBomba.fromMap(e)).toList(),
    );
  }
}

class InformeSanitizacion extends InformeBase {
  DateTime fechaServicio; String descripcion; String? fotoUrl; String? nombreInspecciona; String? rutInspecciona;

  InformeSanitizacion({super.id, required super.cliente, required super.sede, required super.tecnicoId, required super.fechaCreacion, super.firmaUrl, super.estado, required this.fechaServicio, required this.descripcion, super.observaciones, super.codigoCorrelativo, this.fotoUrl, this.nombreInspecciona, this.rutInspecciona}) : super(tipoServicio: 'sani');

  @override Map<String, dynamic> toMap() => {'cliente': cliente, 'sede': sede, 'tecnicoId': tecnicoId, 'fechaCreacion': Timestamp.fromDate(fechaCreacion), 'tipoServicio': 'sani', 'firmaUrl': firmaUrl, 'estado': estado, 'fechaServicio': Timestamp.fromDate(fechaServicio), 'descripcion': descripcion, 'observaciones': observaciones, 'codigoCorrelativo': codigoCorrelativo, 'fotoUrl': fotoUrl, 'nombreInspecciona': nombreInspecciona, 'rutInspecciona': rutInspecciona};

  // NUEVO: Lectura
  factory InformeSanitizacion.fromMap(Map<String, dynamic> map, String id) {
    return InformeSanitizacion(
      id: id,
      cliente: map['cliente'] ?? '',
      sede: map['sede'] ?? '',
      tecnicoId: map['tecnicoId'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      firmaUrl: map['firmaUrl'],
      estado: map['estado'] ?? 'pendiente',
      fechaServicio: (map['fechaServicio'] as Timestamp).toDate(),
      descripcion: map['descripcion'] ?? '',
      observaciones: map['observaciones'] ?? '',
      codigoCorrelativo: map['codigoCorrelativo'],
      fotoUrl: map['fotoUrl'],
      nombreInspecciona: map['nombreInspecciona'],
      rutInspecciona: map['rutInspecciona'],
    );
  }
}

class InformeRecuperacion extends InformeBase {
  DateTime fechaInicio; DateTime fechaFin; String? fotoUrl; String? nombreInspecciona; String? rutInspecciona;

  InformeRecuperacion({super.id, required super.cliente, required super.sede, required super.tecnicoId, required super.fechaCreacion, super.firmaUrl, super.estado, required this.fechaInicio, required this.fechaFin, super.observaciones, super.codigoCorrelativo, this.fotoUrl, this.nombreInspecciona, this.rutInspecciona}) : super(tipoServicio: 'recu');

  @override Map<String, dynamic> toMap() => {'cliente': cliente, 'sede': sede, 'tecnicoId': tecnicoId, 'fechaCreacion': Timestamp.fromDate(fechaCreacion), 'tipoServicio': 'recu', 'firmaUrl': firmaUrl, 'estado': estado, 'fechaInicio': Timestamp.fromDate(fechaInicio), 'fechaFin': Timestamp.fromDate(fechaFin), 'observaciones': observaciones, 'codigoCorrelativo': codigoCorrelativo, 'fotoUrl': fotoUrl, 'nombreInspecciona': nombreInspecciona, 'rutInspecciona': rutInspecciona};

  // NUEVO: Lectura
  factory InformeRecuperacion.fromMap(Map<String, dynamic> map, String id) {
    return InformeRecuperacion(
      id: id,
      cliente: map['cliente'] ?? '',
      sede: map['sede'] ?? '',
      tecnicoId: map['tecnicoId'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      firmaUrl: map['firmaUrl'],
      estado: map['estado'] ?? 'pendiente',
      fechaInicio: (map['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (map['fechaFin'] as Timestamp).toDate(),
      observaciones: map['observaciones'] ?? '',
      codigoCorrelativo: map['codigoCorrelativo'],
      fotoUrl: map['fotoUrl'],
      nombreInspecciona: map['nombreInspecciona'],
      rutInspecciona: map['rutInspecciona'],
    );
  }
}

class InformeConstancia extends InformeBase {
  DateTime fechaServicio; String numeroConstancia; String descripcionTrabajo; String? nombreInspecciona; String? rutInspecciona; String? fotoUrl;

  InformeConstancia({super.id, required super.cliente, required super.sede, required super.tecnicoId, required super.fechaCreacion, super.firmaUrl, super.estado, required this.fechaServicio, required this.numeroConstancia, required this.descripcionTrabajo, super.observaciones, super.codigoCorrelativo, this.nombreInspecciona, this.rutInspecciona, this.fotoUrl}) : super(tipoServicio: 'cons');

  @override Map<String, dynamic> toMap() => {'cliente': cliente, 'sede': sede, 'tecnicoId': tecnicoId, 'fechaCreacion': Timestamp.fromDate(fechaCreacion), 'tipoServicio': 'cons', 'firmaUrl': firmaUrl, 'estado': estado, 'fechaServicio': Timestamp.fromDate(fechaServicio), 'numeroConstancia': numeroConstancia, 'descripcionTrabajo': descripcionTrabajo, 'observaciones': observaciones, 'codigoCorrelativo': codigoCorrelativo, 'nombreInspecciona': nombreInspecciona, 'rutInspecciona': rutInspecciona, 'fotoUrl': fotoUrl};

  // NUEVO: Lectura
  factory InformeConstancia.fromMap(Map<String, dynamic> map, String id) {
    return InformeConstancia(
      id: id,
      cliente: map['cliente'] ?? '',
      sede: map['sede'] ?? '',
      tecnicoId: map['tecnicoId'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      firmaUrl: map['firmaUrl'],
      estado: map['estado'] ?? 'pendiente',
      fechaServicio: (map['fechaServicio'] as Timestamp).toDate(),
      numeroConstancia: map['numeroConstancia'] ?? '',
      descripcionTrabajo: map['descripcionTrabajo'] ?? '',
      observaciones: map['observaciones'] ?? '',
      codigoCorrelativo: map['codigoCorrelativo'],
      nombreInspecciona: map['nombreInspecciona'],
      rutInspecciona: map['rutInspecciona'],
      fotoUrl: map['fotoUrl'],
    );
  }
}