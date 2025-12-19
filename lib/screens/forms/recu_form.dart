import 'package:flutter/material.dart';
import '../../widgets/custom_input.dart';
class RecuForm extends StatelessWidget {
  final TextEditingController obsController;
  const RecuForm({super.key, required this.obsController});
  @override Widget build(BuildContext context) => CustomInput(label: 'Observaciones Recuperación', icon: Icons.build, controller: obsController, maxLines: 5);
}