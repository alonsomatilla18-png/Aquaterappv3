import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // ---------------- CONFIGURACIÓN ----------------
  static const String _remitente = 'informes.aquater@gmail.com'; 
  static const String _password = 'vvlp tspg dvfd sphh'; 
  // -----------------------------------------------

  static Future<void> enviarInforme({
    required String destinatarioEmail,
    required String nombreSede,
    required String fecha,
    required String rutaPdf,
  }) async {
    // 1. Configurar el servidor SMTP de Gmail
    final smtpServer = gmail(_remitente, _password);

    // 2. Crear el mensaje
    final message = Message()
      ..from = const Address(_remitente, 'Sistema Aquater')
      ..recipients.add(destinatarioEmail)
      ..subject = 'Informe Técnico Aquater - $nombreSede - $fecha'
      ..text = 'Estimado/a,\n\nSe adjunta el informe técnico realizado en $nombreSede con fecha $fecha.\n\nAtte,\nEquipo Técnico Aquater.'
      ..attachments.add(FileAttachment(File(rutaPdf)));

    try {
      // 3. Intentar enviar
      final sendReport = await send(message, smtpServer);
      print('✅ Correo enviado con éxito: ${sendReport.toString()}');
    } catch (e) {
      print('❌ Error enviando correo: $e');
      rethrow; // Reenviamos el error para manejarlo en la pantalla principal si es necesario
    }
  }
}