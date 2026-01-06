import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_animate/flutter_animate.dart';



class DashboardScreen extends StatelessWidget {

  const DashboardScreen({super.key});



  Future<void> _cerrarSesion(BuildContext context) async {

    await FirebaseAuth.instance.signOut();

    if (context.mounted) {

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Panel de Control"),

        backgroundColor: const Color(0xFF0D47A1),

        centerTitle: true,

        actions: [

          IconButton(

            icon: const Icon(Icons.exit_to_app),

            tooltip: "Cerrar Sesión",

            onPressed: () => _cerrarSesion(context),

          ),

        ],

      ),

      backgroundColor: const Color(0xFFF5F5F5),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // --- SECCIÓN 1: BIENVENIDA ---

            Text(

              "Hola, ${_getNombreUsuario()}",

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),

            ).animate().fade(duration: 500.ms).slideX(begin: -0.2),

           

            const SizedBox(height: 5),

           

            Text(

              "Bienvenido al sistema de gestión.",

              style: TextStyle(fontSize: 14, color: Colors.grey[600]),

            ).animate().fade(delay: 200.ms, duration: 500.ms),



            const SizedBox(height: 30),



            const Text(

              "Menú Principal",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),

            ).animate().fade(delay: 300.ms),

           

            const SizedBox(height: 15),



            // --- SECCIÓN 2: BOTONES ---

            Expanded(

              child: GridView.count(

                crossAxisCount: 2,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,

                childAspectRatio: 1.3,

                children: [

                  _buildMenuCard(

                    context,

                    icon: Icons.add_circle_outline,

                    title: "Nuevo Informe",

                    subtitle: "Crear",

                    color: Colors.blue[800]!,

                    onTap: () => Navigator.pushNamed(context, '/home'),

                    delay: 100,

                  ),

                  _buildMenuCard(

                    context,

                    icon: Icons.history,

                    title: "Registro",

                    subtitle: "Historial y Estadísticas",

                    color: Colors.teal[700]!,

                    onTap: () => Navigator.pushNamed(context, '/historial'),

                    delay: 200,

                  ),

                  _buildMenuCard(

                    context,

                    icon: Icons.edit_note,

                    title: "Edición",

                    subtitle: "Modificar",

                    color: Colors.orange[800]!,

                    onTap: () => Navigator.pushNamed(context, '/edicion'),

                    delay: 300,

                  ),

                  _buildMenuCard(

                    context,

                    icon: Icons.settings,

                    title: "Cuenta",

                    subtitle: "Ajustes",

                    color: Colors.grey[700]!,

                    onTap: () {

                      ScaffoldMessenger.of(context).showSnackBar(

                        const SnackBar(content: Text("⚙️ Configuración próximamente..."))

                      );

                    },

                    delay: 400,

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }



  String _getNombreUsuario() {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {

      return user.email!.split('@')[0];

    }

    return "Técnico";

  }



  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap, int delay = 0}) {

    return Card(

      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      color: Colors.white,

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Padding(

          padding: const EdgeInsets.all(12.0), // <--- AQUÍ ESTABA EL ERROR DEL EMOJI

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Container(

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: color.withOpacity(0.1),

                  shape: BoxShape.circle,

                ),

                child: Icon(icon, size: 32, color: color),

              ),

              const SizedBox(height: 10),

              Text(

                title,

                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),

                textAlign: TextAlign.center,

              ),

              Text(

                subtitle,

                style: TextStyle(fontSize: 12, color: Colors.grey[600]),

                textAlign: TextAlign.center,

              ),

            ],

          ),

        ),

      ),

    ).animate().fade(delay: delay.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad);

  }

}