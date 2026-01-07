import 'package:intl/intl.dart';
import '../models/informe_model.dart';
import '../utils/constants.dart';

class ReportLogic {
  
  /// Genera el objeto Informe manteniendo la lógica original intacta
  static InformeBase generarInformeModelo({
    required String tipoServicio,
    required String? idExistente,
    required String cliente,
    required String sede,
    required String tecnicoId,
    required DateTime fechaCreacion,
    required DateTime fechaServicio,
    required DateTime? fechaFinRecu,
    required String correlativo,
    required String? firmaBase64,
    // Datos de formularios específicos
    required String guia,
    required String certificado,
    required String obsGeneral,
    required String obsMantencion,
    required String nombreInsp,
    required String rutInsp,
    required String descConstancia,
    required List<DetalleMantencionBomba> equipos,
    required int correlativoFosaInt,
  }) {
    
    switch (tipoServicio) {
      case AppConstants.servFosa:
        return InformeFosa(
          id: idExistente,
          cliente: cliente,
          sede: sede,
          tecnicoId: tecnicoId,
          fechaCreacion: fechaCreacion,
          guia: guia,
          numCertificado: certificado,
          personaResponsable: tecnicoId,
          fechaServicio: fechaServicio,
          correlativo: correlativoFosaInt,
          observaciones: obsGeneral,
          codigoCorrelativo: correlativo,
          firmaUrl: firmaBase64,
        );

      case AppConstants.servBombas:
        return InformeMantencion(
          id: idExistente,
          cliente: cliente,
          sede: sede,
          tecnicoId: tecnicoId,
          fechaCreacion: fechaCreacion,
          personaResponsable: tecnicoId,
          fechaServicio: fechaServicio,
          observaciones: obsMantencion,
          nombreInspecciona: nombreInsp,
          rutInspecciona: rutInsp,
          codigoCorrelativo: correlativo,
          equipos: equipos,
          firmaUrl: firmaBase64,
        );

      case AppConstants.servSani:
        String f = DateFormat('dd/MM/yyyy').format(fechaServicio);
        return InformeSanitizacion(
          id: idExistente,
          cliente: cliente,
          sede: sede,
          tecnicoId: tecnicoId,
          fechaCreacion: fechaCreacion,
          fechaServicio: fechaServicio,
          descripcion: "Se realiza limpieza y sanitización de estanques acumuladores de agua potable con fecha $f, en las instalaciones de $sede.",
          observaciones: obsGeneral,
          nombreInspecciona: nombreInsp,
          rutInspecciona: rutInsp,
          codigoCorrelativo: correlativo,
          firmaUrl: firmaBase64,
        );

      case AppConstants.servRecu:
        return InformeRecuperacion(
          id: idExistente,
          cliente: cliente,
          sede: sede,
          tecnicoId: tecnicoId,
          fechaCreacion: fechaCreacion,
          fechaInicio: fechaServicio,
          fechaFin: fechaFinRecu ?? DateTime.now(),
          observaciones: obsGeneral,
          nombreInspecciona: nombreInsp,
          rutInspecciona: rutInsp,
          codigoCorrelativo: correlativo,
          firmaUrl: firmaBase64,
        );

      case AppConstants.servCons:
        return InformeConstancia(
          id: idExistente,
          cliente: cliente,
          sede: sede,
          tecnicoId: tecnicoId,
          fechaCreacion: fechaCreacion,
          fechaServicio: fechaServicio,
          numeroConstancia: correlativo,
          descripcionTrabajo: descConstancia,
          observaciones: obsGeneral,
          nombreInspecciona: nombreInsp,
          rutInspecciona: rutInsp,
          codigoCorrelativo: correlativo,
          firmaUrl: firmaBase64,
        );

      default:
        throw Exception("Tipo de servicio no soportado: $tipoServicio");
    }
  }
}