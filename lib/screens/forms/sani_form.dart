import 'package:flutter/material.dart';

import '../../widgets/custom_input.dart';

class SaniForm extends StatelessWidget {

  final TextEditingController obsController;

  const SaniForm({super.key, required this.obsController});

  @override Widget build(BuildContext context) => CustomInput(label: 'Observaciones Sanitización', icon: Icons.cleaning_services, controller: obsController, maxLines: 5);

}