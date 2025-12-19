import 'package:cloud_firestore/cloud_firestore.dart';

class CargaDatosMasivos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ESTA ES LA DATA QUE ME PASASTE, YA ESTRUCTURADA
  final Map<String, Map<String, dynamic>> datosDuoc = {
    'ALAM': {
      'nombre': 'Duoc UC Alameda',
      'equipos': {'bom': 3, 'bomsen': 1, 'bomser': 2}
    },
    'AOV1': {
      'nombre': 'Duoc UC Alonso de Ovalle 1',
      'equipos': {'bom': 4, 'bomsen': 2, 'bomser': 2, 'grasa': 2}
    },
    'AOV2': {
      'nombre': 'Duoc UC Alonso de Ovalle 2',
      'equipos': {'bom': 3, 'bomsen': 2}
    },
    'AOV34': {
      'nombre': 'Duoc UC Alonso de Ovalle 3-4',
      'equipos': {'bom': 4, 'bomsen': 1, 'bomser': 2}
    },
    'AOV5': {
      'nombre': 'Duoc UC Alonso de Ovalle 5',
      'equipos': {'bom': 3, 'bomsen': 1, 'bomser': 2}
    },
    'AVAR': {
      'nombre': 'Duoc UC Antonio Varas',
      'equipos': {'bom': 5, 'bomsen': 2, 'bomser': 4, 'bomllu': 1} // Sumé los bomser
    },
    'VBR1': {
      'nombre': 'Duoc UC Valparaíso Brasil 1',
      'equipos': {'bom': 2, 'bomser': 8, 'grasa': 2, 'bomllu': 1} // Sumé los bomser
    },
    'VBR2': {
      'nombre': 'Duoc UC Valparaíso Brasil 2',
      'equipos': {'bom': 3, 'bomsen': 2, 'bomser': 2}
    },
    'VCOU': {
      'nombre': 'Duoc UC Valparaíso Cousiño',
      'equipos': {'bom': 4, 'bomser': 8, 'grasa': 2}
    },
    'VINA': {
      'nombre': 'Duoc UC Viña del Mar',
      'equipos': {'bom': 7, 'bomsen': 2} // Sumé las bombas
    },
    'EDCN': {
      'nombre': 'Duoc UC Educación Continua',
      'equipos': {'bomser': 2}
    },
    'MAIP': {
      'nombre': 'Duoc UC Maipú',
      'equipos': {'bom': 6, 'bomsen': 2, 'bomser': 4, 'bomllu': 4}
    },
    'MELI': {
      'nombre': 'Duoc UC Melipilla',
      'equipos': {'bom': 4, 'bomsen': 2, 'bomllu': 2, 'bomser': 2}
    },
    'PIRQ': {
      'nombre': 'Duoc UC Pirque',
      'equipos': {'bom': 4, 'bomsen': 2, 'bomser': 2}
    },
    'PLN': {
      'nombre': 'Duoc UC Plaza Norte',
      'equipos': {'bom': 3, 'bomsen': 2, 'bomser': 2}
    },
    'PLO': {
      'nombre': 'Duoc UC Plaza Oeste',
      'equipos': {'bom': 3, 'bomsen': 2}
    },
    'PUEN': {
      'nombre': 'Duoc UC Puente Alto',
      'equipos': {'bom': 6, 'bomsen': 2, 'bomser': 9}
    },
    'SBER': {
      'nombre': 'Duoc UC San Bernardo',
      'equipos': {'bom': 4, 'bomsen': 2, 'bomser': 6}
    },
    'SCA1': {
      'nombre': 'Duoc UC San Carlos de Apoquindo 1',
      'equipos': {'bom': 3, 'bomllu': 1}
    },
    'SCA2': {
      'nombre': 'Duoc UC San Carlos de Apoquindo 2',
      'equipos': {'bom': 3, 'bomsen': 2, 'bomser': 6}
    },
    'ARAU': {
      'nombre': 'Duoc UC Arauco',
      'equipos': {'bom': 3, 'bomsen': 2, 'bomser': 4}
    },
    'CONC': {
      'nombre': 'Duoc UC Concepción',
      'equipos': {'bom': 9, 'bomsen': 2}
    },
    'SJOA': {
      'nombre': 'Duoc UC San Joaquín',
      'equipos': {'bom': 5, 'bomsen': 2, 'bomllu': 2, 'grasa': 2}
    },
    'VESP': {
      'nombre': 'Duoc UC Vespucio',
      'equipos': {} // Solo servicios específicos según tu doc
    },
    'QUIL': {
      'nombre': 'Duoc UC Quillota',
      'equipos': {'bomser': 2, 'sopla': 1}
    }
  };

  final Map<String, Map<String, dynamic>> datosISS = {
    'BANDERA': {
      'nombre': 'Scotiabank Bandera',
      'equipos': {'bom': 2} // Genérico, se puede editar
    },
    'TITANIUM': {
      'nombre': 'Scotiabank Torre Titanium',
      'equipos': {'bom': 2}
    }
  };

  Future<void> subirTodo() async {
    print("⏳ Iniciando carga masiva...");
    
    // 1. Subir Duoc UC
    await _crearCliente('Duoc_UC', 'Duoc UC', datosDuoc);
    
    // 2. Subir ISS
    await _crearCliente('ISS', 'ISS Chile', datosISS);

    // 3. Subir Viña Ventisquero (Genérico)
    await _crearCliente('Ventisquero', 'Viña Ventisquero', {});

    print("✅ ¡CARGA COMPLETA! Ya puedes usar la App.");
  }

  Future<void> _crearCliente(String id, String nombre, Map<String, dynamic> sedes) async {
    // Referencia al cliente
    DocumentReference refCliente = _db.collection('clientes').doc(id);
    
    // Crear el documento del cliente
    await refCliente.set({'nombre_visible': nombre});

    // Crear las sedes como sub-colección
    for (String idSede in sedes.keys) {
      await refCliente.collection('sedes').doc(idSede).set(sedes[idSede]);
    }
  }
}