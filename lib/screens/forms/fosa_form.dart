import 'package:flutter/material.dart';
import '../../widgets/custom_input.dart';

class FosaForm extends StatelessWidget {
  final TextEditingController guiaController;
  final TextEditingController certificadoController;
  final TextEditingController obsController;

  const FosaForm({
    super.key,
    required this.guiaController,
    required this.certificadoController,
    required this.obsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInput(label: 'Nº Guía', icon: Icons.receipt, controller: guiaController),
        CustomInput(label: 'Nº Certificado', icon: Icons.verified, controller: certificadoController),
        // AHORA CON 5 LÍNEAS PARA ESCRIBIR CÓMODO
        CustomInput(label: 'Observaciones Fosa', icon: Icons.comment, controller: obsController, maxLines: 5),
      ],
    );
  }
}