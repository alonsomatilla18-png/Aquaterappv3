import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final Function(String)? onChanged;
  final String? initialValue;
  final bool isReadOnly;

  const CustomInput({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1, // Si pones más de 1, se activa el modo párrafo
    this.onChanged,
    this.initialValue,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        // LÓGICA INTELIGENTE: Si maxLines > 1, forzamos teclado multilínea
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        maxLines: maxLines,
        readOnly: isReadOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          // Alineamos el icono arriba si es un campo grande
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
          isDense: true, 
          alignLabelWithHint: maxLines > 1, 
        ),
      ),
    );
  }
}