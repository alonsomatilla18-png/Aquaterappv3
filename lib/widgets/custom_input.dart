import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final Function(String)? onChanged;
  final String? initialValue;
  final bool isReadOnly;
  final List<TextInputFormatter>? inputFormatters;
  
  // NUEVO: Función para validar (devuelve texto de error o null si está bien)
  final String? Function(String?)? validator; 

  const CustomInput({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.initialValue,
    this.isReadOnly = false,
    this.inputFormatters,
    this.validator, // Recibimos el validador
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        maxLines: maxLines,
        readOnly: isReadOnly,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        validator: validator, // Conectamos el validador al sistema de Flutter
        autovalidateMode: AutovalidateMode.onUserInteraction, // Valida apenas escribes
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          // El borde rojo y estilos vienen de tu app_theme.dart global
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: isReadOnly ? Colors.grey[100] : Colors.white,
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
          isDense: true,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}