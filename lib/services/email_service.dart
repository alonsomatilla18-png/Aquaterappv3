import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- IMPORTANTE

class EmailService {
  
  static Future<void> enviarInforme({
    required List<String> destinatarios,
    required String nombreSede,
    required String fecha,
    required String rutaPdf,
  }) async {
    
    // 1. LEER CREDENCIALES DEL ARCHIVO .env
    final String usuario = dotenv.env['GMAIL_USER'] ?? '';
    final String password = dotenv.env['GMAIL_PASS'] ?? '';

    // Validación de seguridad: Si no hay claves, no intentamos enviar
    if (usuario.isEmpty || password.isEmpty) {
      print("⚠️ ERROR CRÍTICO: Faltan las credenciales en el archivo .env");
      print("Asegúrate de crear el archivo .env en la raíz con GMAIL_USER y GMAIL_PASS");
      return;
    }

    if (destinatarios.isEmpty) {
      print("⚠️ Cancelando envío: No hay destinatarios.");
      return;
    }

    // 2. CONFIGURAR SERVIDOR SMTP
    // Usamos las variables cargadas, no texto fijo
    final smtpServer = gmail(usuario, password);

    // 3. CREAR EL MENSAJE
    final message = Message()
      ..from = Address(usuario, 'Sistema Aquater')
      ..subject = 'Informe Técnico Aquater - $nombreSede - $fecha'
      ..text = 'Estimado Cliente,\n\nAdjunto encontrará el informe técnico correspondiente a los trabajos realizados en $nombreSede con fecha $fecha.\n\nEste es un mensaje automático del Sistema de Gestión Aquater.\n\nAtte,\nEquipo Técnico Aquater Ltda.'
      ..attachments.add(FileAttachment(File(rutaPdf)));

    // Agregar destinatarios de forma segura
    for (String email in destinatarios) {
      if (email.contains('@')) {
        message.recipients.add(email.trim());
      }
    }

    try {
      // 4. ENVIAR
      final sendReport = await send(message, smtpServer);
      print('✅ Correo enviado con éxito a: $destinatarios');
      print('Detalle: ${sendReport.toString()}');
    } catch (e) {
      print('❌ Error enviando correo: $e');
      print('Verifica que la contraseña de aplicación sea correcta en el archivo .env');
    }
  }
}