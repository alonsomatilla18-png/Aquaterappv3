import 'package:flutter/material.dart';
import '../../widgets/custom_input.dart';
class ConsForm extends StatelessWidget {
  final TextEditingController descController;
  final TextEditingController obsController;
  const ConsForm({super.key, required this.descController, required this.obsController});
  @override Widget build(BuildContext context) => Column(children: [CustomInput(label: 'Descripción del Trabajo', icon: Icons.description, controller: descController, maxLines: 5), CustomInput(label: 'Observaciones', icon: Icons.comment, controller: obsController, maxLines: 5)]);
}