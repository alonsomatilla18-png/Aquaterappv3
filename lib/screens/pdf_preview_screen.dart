import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:printing/printing.dart';



class PdfPreviewScreen extends StatelessWidget {

  final Uint8List pdfBytes;

  final String fileName;



  const PdfPreviewScreen({

    super.key,

    required this.pdfBytes,

    required this.fileName,

  });



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(fileName, style: const TextStyle(fontSize: 14)),

        backgroundColor: const Color(0xFF0D47A1), // Tu azul corporativo

        foregroundColor: Colors.white,

      ),

      body: PdfPreview(

        build: (format) => pdfBytes,

        pdfFileName: fileName,

        canChangeOrientation: false,

        canChangePageFormat: false,

      ),

    );

  }

}