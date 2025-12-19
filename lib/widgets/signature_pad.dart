import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePad extends StatelessWidget {
  final SignatureController controller;

  const SignaturePad({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Firma Inspecciona:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Signature(
            controller: controller,
            height: 150,
            backgroundColor: Colors.transparent,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: () => controller.clear(),
            label: const Text("Borrar Firma", style: TextStyle(color: Colors.red)),
          ),
        )
      ],
    );
  }
}