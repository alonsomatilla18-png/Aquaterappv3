import 'dart:io';

import 'package:flutter/foundation.dart'; // Para kIsWeb

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';



class PhotoSelector extends StatelessWidget {

  final List<XFile> fotos;

  final VoidCallback onCameraTap;

  final VoidCallback onGalleryTap;

  final Function(int) onRemove; // Nuevo: Callback para borrar



  const PhotoSelector({

    super.key,

    required this.fotos,

    required this.onCameraTap,

    required this.onGalleryTap,

    required this.onRemove,

  });



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text("Fotografías del Servicio:", style: TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

       

        // BOTONES

        Row(

          children: [

            Expanded(

              child: ElevatedButton.icon(

                onPressed: onCameraTap,

                icon: const Icon(Icons.camera_alt),

                label: const Text("Cámara"),

                style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.blue[50], foregroundColor: Colors.blue[800]),

              ),

            ),

            const SizedBox(width: 10),

            Expanded(

              child: ElevatedButton.icon(

                onPressed: onGalleryTap,

                icon: const Icon(Icons.photo_library),

                label: const Text("Galería"),

                style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.blue[50], foregroundColor: Colors.blue[800]),

              ),

            ),

          ],

        ),



        const SizedBox(height: 15),



        // LISTA HORIZONTAL DE FOTOS (CARRUSEL)

        if (fotos.isNotEmpty)

          SizedBox(

            height: 120, // Altura del carrusel

            child: ListView.builder(

              scrollDirection: Axis.horizontal,

              itemCount: fotos.length,

              itemBuilder: (context, index) {

                final file = fotos[index];

                return Stack(

                  children: [

                    Container(

                      width: 100,

                      margin: const EdgeInsets.only(right: 10),

                      decoration: BoxDecoration(

                        border: Border.all(color: Colors.grey.shade300),

                        borderRadius: BorderRadius.circular(8),

                      ),

                      child: ClipRRect(

                        borderRadius: BorderRadius.circular(8),

                        child: kIsWeb

                            ? Image.network(file.path, fit: BoxFit.cover)

                            : Image.file(File(file.path), fit: BoxFit.cover),

                      ),

                    ),

                    // Botón de Borrar (X)

                    Positioned(

                      top: 2,

                      right: 12,

                      child: GestureDetector(

                        onTap: () => onRemove(index),

                        child: Container(

                          padding: const EdgeInsets.all(4),

                          decoration: const BoxDecoration(

                            color: Colors.red,

                            shape: BoxShape.circle,

                          ),

                          child: const Icon(Icons.close, size: 14, color: Colors.white),

                        ),

                      ),

                    ),

                  ],

                );

              },

            ),

          )

        else

          const Center(

            child: Padding(

              padding: EdgeInsets.all(10.0),

              child: Text(

                "No hay fotos adjuntas.",

                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),

              ),

            ),

          ),

      ],

    );

  }

}