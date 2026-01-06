import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // NECESARIO PARA LOS FORMATTERS



class CustomInput extends StatelessWidget {

  final String label;

  final IconData icon;

  final TextEditingController? controller;

  final TextInputType keyboardType;

  final int maxLines;

  final Function(String)? onChanged;

  final String? initialValue;

  final bool isReadOnly;

 

  // NUEVO: Permite pasar reglas de formato (ej: solo números, formato RUT, etc.)

  final List<TextInputFormatter>? inputFormatters;



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

    this.inputFormatters, // Recibimos el parámetro

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

        // NUEVO: Asignamos los formatters al campo de texto

        inputFormatters: inputFormatters,

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