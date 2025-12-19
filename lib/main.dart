import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

// --- IMPORTACIONES DE TUS PANTALLAS ---
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';      // <--- Faltaba o es crucial
import 'screens/home_screen.dart';           // Formulario de creación
import 'screens/historial_screen.dart';      // Historial
import 'screens/edicion_list_screen.dart';   // <--- Nueva pantalla de edición

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. INICIALIZACIÓN ROBUSTA DE FIREBASE
  try {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAU4KF0ho3TGJIYLypUSVWTUepGQqD_QZY", // Tu API Key
            appId: "1:332388584766:web:626bfcd360de668533f06f",
            messagingSenderId: "332388584766",
            projectId: "software-aquater-ltda",
            storageBucket: "software-aquater-ltda.firebasestorage.app",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print("⚠️ Firebase ya estaba inicializado o hubo un error: $e");
  }

  // 2. CONFIGURACIÓN DE PERSISTENCIA (OFFLINE)
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  runApp(const AquaterApp());
}

class AquaterApp extends StatelessWidget {
  const AquaterApp({super.key});

  // Color Corporativo
  static const Color primaryBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    // 3. LÓGICA DE SESIÓN
    // Si hay usuario, vamos al Dashboard. Si no, al Login.
    final usuario = FirebaseAuth.instance.currentUser;
    final String rutaInicial = usuario != null ? '/dashboard' : '/login';

    return MaterialApp(
      title: 'Aquater Software',
      debugShowCheckedModeBanner: false,
      
      // 4. TEMA VISUAL GLOBAL
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: Colors.blueAccent,
          surface: Colors.grey[50]!,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2.5),
          ),
          border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.w500),
        ),
      ),

      // 5. RUTAS DE NAVEGACIÓN
      initialRoute: rutaInicial, 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),      // Menú Principal
        '/home': (context) => const HomeScreen(),                // Formulario (Crear/Editar)
        '/historial': (context) => const HistorialScreen(),      // Ver Historial
        '/edicion': (context) => const EdicionListScreen(),      // Lista para Editar
      },
    );
  }
}