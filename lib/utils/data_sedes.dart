class EquipoConfig {
  final String tipo; 
  final String nombre; 
  final int cantidad;
  final String? ubicacion;

  EquipoConfig({
    required this.tipo,
    required this.nombre,
    required this.cantidad,
    this.ubicacion,
  });
}

final Map<String, List<EquipoConfig>> configuracionBombas = {
  'ALAM': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 1),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2),
  ],
  'AOV1': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 4),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2),
    EquipoConfig(tipo: 'grasa', nombre: 'Cámara de Grasas', cantidad: 2),
  ],
  'AOV2': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
  ],
  'AOV34': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 4),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 1),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2),
  ],
  'AOV5': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 1),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2),
  ],
  'AVAR': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 5),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Estacionamiento -2'),
    EquipoConfig(tipo: 'bomllu', nombre: 'Bomba Aguas Lluvias', cantidad: 1, ubicacion: 'Estacionamientos'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Baño mujeres'),
  ],
  'VBR1': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Cámara patio central'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Cámara 1, nivel patio'),
    EquipoConfig(tipo: 'grasa', nombre: 'Cámara de Grasas', cantidad: 2, ubicacion: 'Cámara sala de basura'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Cámara baños cocina casino'),
    EquipoConfig(tipo: 'bomllu', nombre: 'Bomba Aguas Lluvias', cantidad: 1, ubicacion: 'Cámara aguas lluvias'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Salida calle Blanco'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Sala de construcción'),
  ],
  'VBR2': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Estacionamiento -1'),
  ],
  'VCOU': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 4),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Baño mujeres'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Baño hombres'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Camarines auxiliares'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Pasillo actores'),
    EquipoConfig(tipo: 'grasa', nombre: 'Cámara de Grasas', cantidad: 2, ubicacion: 'Sala de basura'),
  ],
  'VINA': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 2, ubicacion: 'Álvarez'),
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 2, ubicacion: 'Cerro'),
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3, ubicacion: 'CTI'),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
  ],
  'EDCN': [
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Patio'),
  ],
  'MAIP': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 6),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Casino'),
    EquipoConfig(tipo: 'bomllu', nombre: 'Bomba Aguas Lluvias', cantidad: 1, ubicacion: 'Casino'),
    EquipoConfig(tipo: 'bomllu', nombre: 'Bomba Aguas Lluvias', cantidad: 3, ubicacion: 'Taller Electrónica'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Peñol'),
  ],
  'MELI': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 4),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomllu', nombre: 'Bomba Aguas Lluvias', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2),
  ],
  'PIRQ': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 4),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'PEAS'),
  ],
  'PLN': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Bodega -1'),
  ],
  'PLO': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
  ],
  'PUEN': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 6),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Baños alumnos'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Taller autos'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 3, ubicacion: '-1 Zócalo'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: '-2'),
  ],
  'SBER': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 4),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Al lado sala agua potable'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'General'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Fosa grande'),
  ],
  'SCA1': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomllu', nombre: 'Bomba Aguas Lluvias', cantidad: 1),
  ],
  'SCA2': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Patio inglés'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Auditorio'),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2, ubicacion: 'Estacionamiento'),
  ],
  'ARAU': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 4),
  ],
  'CONC': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 6, ubicacion: 'Sala H'),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2, ubicacion: 'Sala H'),
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 3, ubicacion: 'Sala E'),
  ],
  'SJOA': [
    EquipoConfig(tipo: 'bom', nombre: 'Bomba Agua Potable', cantidad: 5),
    EquipoConfig(tipo: 'bomsen', nombre: 'Bomba Sentina', cantidad: 2),
    EquipoConfig(tipo: 'bomllu', nombre: 'Bomba Aguas Lluvias', cantidad: 2, ubicacion: 'Norte Mecánica'),
    EquipoConfig(tipo: 'grasa', nombre: 'Cámara de Grasas', cantidad: 2, ubicacion: 'Sur mecánica'),
  ],
  'QUIL': [
    EquipoConfig(tipo: 'bomser', nombre: 'Bomba Aguas Servidas', cantidad: 2),
    EquipoConfig(tipo: 'sopla', nombre: 'Soplador', cantidad: 1),
  ],
};