import 'dart:io';

import 'package:mailer/mailer.dart';

import 'package:mailer/smtp_server.dart';



class EmailService {

  // ---------------- CONFIGURACIÓN ----------------

  static const String _remitente = 'informes.aquater@gmail.com';

 

  // ✅ CLAVE DE APLICACIÓN REAL (NO BORRAR)

  static const String _password = 'vvlp tspg dvfd sphh';

  // -----------------------------------------------



  static Future<void> enviarInforme({

    required List<String> destinatarios,

    required String nombreSede,

    required String fecha,

    required String rutaPdf,

  }) async {

   

    // Validación de seguridad

    if (destinatarios.isEmpty) {

      print("⚠️ Cancelando envío: No hay destinatarios.");

      return;

    }



    // 1. Configurar el servidor SMTP de Gmail

    final smtpServer = gmail(_remitente, _password);



    // 2. Crear el mensaje

    final message = Message()

      ..from = const Address(_remitente, 'Sistema Aquater')

      ..subject = 'Informe Técnico Aquater - $nombreSede - $fecha'

      ..text = 'Estimado Cliente,\n\nAdjunto encontrará el informe técnico correspondiente a los trabajos realizados en $nombreSede con fecha $fecha.\n\nEste es un mensaje automático del Sistema de Gestión Aquater.\n\nAtte,\nEquipo Técnico Aquater Ltda.'

      ..attachments.add(FileAttachment(File(rutaPdf)));



    // ✅ Agregamos todos los destinatarios de la lista de forma segura

    for (String email in destinatarios) {

      if (email.contains('@')) {

        message.recipients.add(email.trim());

      }

    }



    try {

      // 3. Intentar enviar

      final sendReport = await send(message, smtpServer);

      print('✅ Correo enviado con éxito a: $destinatarios');

      print('Detalle técnico: ${sendReport.toString()}');

    } catch (e) {

      print('❌ Error enviando correo: $e');

      // No lanzamos rethrow para que la app no se congele si falla el correo

    }

  }

}