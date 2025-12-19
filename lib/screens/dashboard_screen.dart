import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  final String nombreTecnico;

  const DashboardScreen({
    super.key, 
    this.nombreTecnico = "Técnico Aquater"
  });

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
        backgroundColor: const Color(0xFF0D47A1), // Azul Aquater
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenido,",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              nombreTecnico,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF0D47A1)
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Menú Principal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                // Hace los botones más rectangulares y pequeños
                childAspectRatio: 1.5, 
                children: [
                  // 1. NUEVO INFORME
                  _buildMenuCard(
                    context,
                    icon: Icons.add_circle_outline,
                    title: "Nuevo Informe",
                    subtitle: "Crear",
                    color: Colors.blue[800]!,
                    onTap: () => Navigator.pushNamed(context, '/home'),
                  ),

                  // 2. REGISTRO (HISTORIAL)
                  _buildMenuCard(
                    context,
                    icon: Icons.history,
                    title: "Registro",
                    subtitle: "Historial",
                    color: Colors.teal[700]!,
                    onTap: () => Navigator.pushNamed(context, '/historial'),
                  ),

                  // 3. EDICIÓN (AHORA CONECTADO)
                  _buildMenuCard(
                    context,
                    icon: Icons.edit_note,
                    title: "Edición",
                    subtitle: "Modificar",
                    color: Colors.orange[800]!,
                    onTap: () {
                      // Navega a la nueva pantalla de lista de edición
                      Navigator.pushNamed(context, '/edicion');
                    },
                  ),

                  // 4. CUENTA (FUTURO)
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}