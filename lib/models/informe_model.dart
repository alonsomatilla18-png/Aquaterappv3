
// --- CLASE BASE ---
abstract class InformeBase {
  String? id;
  String cliente;
  String sede;
  String tecnicoId;
  DateTime fechaCreacion;
  String tipoServicio;
  String? codigoCorrelativo;
  String? firmaUrl; 
  String? fotoUrl; 
  String estado;

  InformeBase({
    this.id,
    required this.cliente,
    required this.sede,
    required this.tecnicoId,
    required this.fechaCreacion,
    required this.tipoServicio,
    this.codigoCorrelativo,
    this.firmaUrl,
    this.fotoUrl,
    this.estado = 'borrador',
  });

  Map<String, dynamic> toMap();

  static InformeBase fromMap(Map<String, dynamic> map, String id) {
    String tipo = map['tipoServicio'] ?? '';
    switch (tipo) {
      case 'fosa': return InformeFosa.fromMap(map, id);
      case 'man': return InformeMantencion.fromMap(map, id);
      case 'sani': return InformeSanitizacion.fromMap(map, id);
      case 'recu': return InformeRecuperacion.fromMap(map, id);
      case 'cons': return InformeConstancia.fromMap(map, id);
      default: return InformeGenerico.fromMap(map, id);
    }
  }
}

// --- 1. INFORME FOSA ---
class InformeFosa extends InformeBase {
  String guia;
  String numCertificado;
  String personaResponsable;
  DateTime fechaServicio;
  int correlativo;
  String observaciones;

  InformeFosa({
    super.id,
    required super.cliente,
    required super.sede,
    required super.tecnicoId,
    required super.fechaCreacion,
    required this.guia,
    required this.numCertificado,
    required this.personaResponsable,
    required this.fechaServicio,
    required this.correlativo,
    required this.observaciones,
    super.codigoCorrelativo,
    super.fotoUrl,
    super.firmaUrl,
    super.estado,
  }) : super(tipoServicio: 'fosa');

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'sede': sede,
      'tecnicoId': tecnicoId,
      'fechaCreacion': fechaCreacion,
      'tipoServicio': 'fosa',
      'guia': guia,
      'numCertificado': numCertificado,
      'personaResponsable': personaResponsable,
      'fechaServicio': fechaServicio,
      'correlativo': correlativo,
      'observaciones': observaciones,
      'codigoCorrelativo': codigoCorrelativo,
      'fotoUrl': fotoUrl,
      'firmaUrl': firmaUrl,
      'estado': estado,
    };
  }

  factory InformeFosa.fromMap(Map<String, dynamic> map, String id) {
    return InformeFosa(
      id: id,
      cliente: map['cliente'] ?? '',
      sede: map['sede'] ?? '',
      tecnicoId: map['tecnicoId'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as dynamic).toDate(),
      guia: map['guia'] ?? '',
      numCertificado: map['numCertificado'] ?? '',
      personaResponsable: map['personaResponsable'] ?? '',
      fechaServicio: (map['fechaServicio'] as dynamic).toDate(),
      correlativo: map['correlativo'] is int ? map['correlativo'] : 0,
      observaciones: map['observaciones'] ?? '',
      codigoCorrelativo: map['codigoCorrelativo'],
      fotoUrl: map['fotoUrl'],
      firmaUrl: map['firmaUrl'],
      estado: map['estado'] ?? 'borrador',
    );
  }
}

// --- 2. INFORME MANTENCIÓN BOMBAS ---
class InformeMantencion extends InformeBase {
  String personaResponsable;
  DateTime fechaServicio;
  String observaciones;
  List<DetalleMantencionBomba> equipos;
  
  String? nombreInspecciona;
  String? rutInspecciona;

  InformeMantencion({
    super.id,
    required super.cliente,
    required super.sede,
    required super.tecnicoId,
    required super.fechaCreacion,
    required this.personaResponsable,
    required this.fechaServicio,
    required this.observaciones,
    required this.equipos,
    this.nombreInspecciona,
    this.rutInspecciona,
    super.codigoCorrelativo,
    super.firmaUrl,
    super.estado,
  }) : super(tipoServicio: 'man');

  @override
  Map<String, dynamic> toMap() {
    return {
      'cliente': cliente,
      'sede': sede,
      'tecnicoId': tecnicoId,
      'fechaCreacion': fechaCreacion,
      'tipoServicio': 'man',
      'personaResponsable': personaResponsable,
      'fechaServicio': fechaServicio,
      'observaciones': observaciones,
      'equipos': equipos.map((e) => e.toMap()).toList(),
      'nombreInspecciona': nombreInspecciona,
      'rutInspecciona': rutInspecciona,
      'codigoCorrelativo': codigoCorrelativo,
      'firmaUrl': firmaUrl,
      'estado': estado,
    };
  }

  factory InformeMantencion.fromMap(Map<String, dynamic> map, String id) {
    var list = map['equipos'] as List? ?? [];
    List<DetalleMantencionBomba> equiposList = list.map((i) => DetalleMantencionBomba.fromMap(i)).toList();

    return InformeMantencion(
      id: id,
      cliente: map['cliente'] ?? '',
      sede: map['sede'] ?? '',
      tecnicoId: map['tecnicoId'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as dynamic).toDate(),
      personaResponsable: map['personaResponsable'] ?? '',
      fechaServicio: (map['fechaServicio'] as dynamic).toDate(),
      observaciones: map['observaciones'] ?? '',
      equipos: equiposList,
      nombreInspecciona: map['nombreInspecciona'],
      rutInspecciona: map['rutInspecciona'],
      codigoCorrelativo: map['codigoCorrelativo'],
      firmaUrl: map['firmaUrl'],
      estado: map['estado'] ?? 'borrador',
    );
  }
}

// SUB-CLASE PARA BOMBAS (Aquí está la protección técnica)
class DetalleMantencionBomba {
  String tipoBomba; 
  String nombreEquipo;
  String? ubicacion;
  
  double ampR; double ampS; double ampT;
  double voltRT; double voltST; double voltRS;

  Map<String, Map<String, String>> checklist;

  DetalleMantencionBomba({
    required this.tipoBomba,
    required this.nombreEquipo,
    this.ubicacion,
    this.ampR = 0, this.ampS = 0, this.ampT = 0,
    this.voltRT = 0, this.voltST = 0, this.voltRS = 0,
    required this.checklist,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipoBomba': tipoBomba,
      'nombreEquipo': nombreEquipo,
      'ubicacion': ubicacion,
      'ampR': ampR, 'ampS': ampS, 'ampT': ampT,
      'voltRT': voltRT, 'voltST': voltST, 'voltRS': voltRS,
      'checklist': checklist,
    };
  }

  // ✅ PROTECCIÓN CONTRA ERRORES DE TIPO DE DATO
  factory DetalleMantencionBomba.fromMap(Map<String, dynamic> map) {
    Map<String, Map<String, String>> checkMap = {};
    if (map['checklist'] != null) {
      (map['checklist'] as Map).forEach((k, v) {
        checkMap[k.toString()] = {
          'estado': v['estado']?.toString() ?? '',
          'obs': v['obs']?.toString() ?? ''
        };
      });
    }

    // Helper técnico: convierte texto a número sin romper la app
    double toDoubleSafe(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return DetalleMantencionBomba(
      tipoBomba: map['tipoBomba'] ?? 'bom',
      nombreEquipo: map['nombreEquipo'] ?? 'Equipo',
      ubicacion: map['ubicacion'],
      ampR: toDoubleSafe(map['ampR']),
      ampS: toDoubleSafe(map['ampS']),
      ampT: toDoubleSafe(map['ampT']),
      voltRT: toDoubleSafe(map['voltRT']),
      voltST: toDoubleSafe(map['voltST']),
      voltRS: toDoubleSafe(map['voltRS']),
      checklist: checkMap,
    );
  }
}

// --- 3. INFORME SANITIZACIÓN ---
class InformeSanitizacion extends InformeBase {
  DateTime fechaServicio;
  String descripcion;
  String observaciones;
  String? nombreInspecciona;
  String? rutInspecciona;

  InformeSanitizacion({
    super.id,
    required super.cliente,
    required super.sede,
    required super.tecnicoId,
    required super.fechaCreacion,
    required this.fechaServicio,
    required this.descripcion,
    required this.observaciones,
    this.nombreInspecciona,
    this.rutInspecciona,
    super.codigoCorrelativo,
    super.fotoUrl,
    super.firmaUrl,
    super.estado,
  }) : super(tipoServicio: 'sani');

  @override
  Map<String, dynamic> toMap() => {
    'cliente': cliente,
    'sede': sede,
    'tecnicoId': tecnicoId,
    'fechaCreacion': fechaCreacion,
    'tipoServicio': 'sani',
    'fechaServicio': fechaServicio,
    'descripcion': descripcion,
    'observaciones': observaciones,
    'nombreInspecciona': nombreInspecciona,
    'rutInspecciona': rutInspecciona,
    'codigoCorrelativo': codigoCorrelativo,
    'fotoUrl': fotoUrl,
    'firmaUrl': firmaUrl,
    'estado': estado,
  };

  factory InformeSanitizacion.fromMap(Map<String, dynamic> map, String id) => InformeSanitizacion(
    id: id,
    cliente: map['cliente'] ?? '',
    sede: map['sede'] ?? '',
    tecnicoId: map['tecnicoId'] ?? '',
    fechaCreacion: (map['fechaCreacion'] as dynamic).toDate(),
    fechaServicio: (map['fechaServicio'] as dynamic).toDate(),
    descripcion: map['descripcion'] ?? '',
    observaciones: map['observaciones'] ?? '',
    nombreInspecciona: map['nombreInspecciona'],
    rutInspecciona: map['rutInspecciona'],
    codigoCorrelativo: map['codigoCorrelativo'],
    fotoUrl: map['fotoUrl'],
    firmaUrl: map['firmaUrl'],
    estado: map['estado'] ?? 'borrador',
  );
}

// --- 4. INFORME RECUPERACIÓN ---
class InformeRecuperacion extends InformeBase {
  DateTime fechaInicio;
  DateTime fechaFin;
  String observaciones;
  String? nombreInspecciona;
  String? rutInspecciona;

  InformeRecuperacion({
    super.id,
    required super.cliente,
    required super.sede,
    required super.tecnicoId,
    required super.fechaCreacion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.observaciones,
    this.nombreInspecciona,
    this.rutInspecciona,
    super.codigoCorrelativo,
    super.fotoUrl,
    super.firmaUrl,
    super.estado,
  }) : super(tipoServicio: 'recu');

  @override
  Map<String, dynamic> toMap() => {
    'cliente': cliente,
    'sede': sede,
    'tecnicoId': tecnicoId,
    'fechaCreacion': fechaCreacion,
    'tipoServicio': 'recu',
    'fechaInicio': fechaInicio,
    'fechaFin': fechaFin,
    'observaciones': observaciones,
    'nombreInspecciona': nombreInspecciona,
    'rutInspecciona': rutInspecciona,
    'codigoCorrelativo': codigoCorrelativo,
    'fotoUrl': fotoUrl,
    'firmaUrl': firmaUrl,
    'estado': estado,
  };

  factory InformeRecuperacion.fromMap(Map<String, dynamic> map, String id) => InformeRecuperacion(
    id: id,
    cliente: map['cliente'] ?? '',
    sede: map['sede'] ?? '',
    tecnicoId: map['tecnicoId'] ?? '',
    fechaCreacion: (map['fechaCreacion'] as dynamic).toDate(),
    fechaInicio: (map['fechaInicio'] as dynamic).toDate(),
    fechaFin: (map['fechaFin'] as dynamic).toDate(),
    observaciones: map['observaciones'] ?? '',
    nombreInspecciona: map['nombreInspecciona'],
    rutInspecciona: map['rutInspecciona'],
    codigoCorrelativo: map['codigoCorrelativo'],
    fotoUrl: map['fotoUrl'],
    firmaUrl: map['firmaUrl'],
    estado: map['estado'] ?? 'borrador',
  );
}

// --- 5. INFORME CONSTANCIA ---
class InformeConstancia extends InformeBase {
  DateTime fechaServicio;
  String numeroConstancia;
  String descripcionTrabajo;
  String observaciones;
  String? nombreInspecciona;
  String? rutInspecciona;

  InformeConstancia({
    super.id,
    required super.cliente,
    required super.sede,
    required super.tecnicoId,
    required super.fechaCreacion,
    required this.fechaServicio,
    required this.numeroConstancia,
    required this.descripcionTrabajo,
    required this.observaciones,
    this.nombreInspecciona,
    this.rutInspecciona,
    super.codigoCorrelativo,
    super.fotoUrl,
    super.firmaUrl,
    super.estado,
  }) : super(tipoServicio: 'cons');

  @override
  Map<String, dynamic> toMap() => {
    'cliente': cliente,
    'sede': sede,
    'tecnicoId': tecnicoId,
    'fechaCreacion': fechaCreacion,
    'tipoServicio': 'cons',
    'fechaServicio': fechaServicio,
    'numeroConstancia': numeroConstancia,
    'descripcionTrabajo': descripcionTrabajo,
    'observaciones': observaciones,
    'nombreInspecciona': nombreInspecciona,
    'rutInspecciona': rutInspecciona,
    'codigoCorrelativo': codigoCorrelativo,
    'fotoUrl': fotoUrl,
    'firmaUrl': firmaUrl,
    'estado': estado,
  };

  factory InformeConstancia.fromMap(Map<String, dynamic> map, String id) => InformeConstancia(
    id: id,
    cliente: map['cliente'] ?? '',
    sede: map['sede'] ?? '',
    tecnicoId: map['tecnicoId'] ?? '',
    fechaCreacion: (map['fechaCreacion'] as dynamic).toDate(),
    fechaServicio: (map['fechaServicio'] as dynamic).toDate(),
    numeroConstancia: map['numeroConstancia'] ?? '',
    descripcionTrabajo: map['descripcionTrabajo'] ?? '',
    observaciones: map['observaciones'] ?? '',
    nombreInspecciona: map['nombreInspecciona'],
    rutInspecciona: map['rutInspecciona'],
    codigoCorrelativo: map['codigoCorrelativo'],
    fotoUrl: map['fotoUrl'],
    firmaUrl: map['firmaUrl'],
    estado: map['estado'] ?? 'borrador',
  );
}

class InformeGenerico extends InformeBase {
  InformeGenerico({required super.cliente, required super.sede, required super.tecnicoId, required super.fechaCreacion, required super.tipoServicio, super.id});
  @override Map<String, dynamic> toMap() => {};
  factory InformeGenerico.fromMap(Map<String, dynamic> map, String id) => InformeGenerico(cliente: '', sede: '', tecnicoId: '', fechaCreacion: DateTime.now(), tipoServicio: 'unknown', id: id);
}