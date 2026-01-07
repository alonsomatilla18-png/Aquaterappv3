import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- IMPORTANTE: Librería de seguridad

import 'config/app_theme.dart'; // Tu tema centralizado

// PANTALLAS
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/edicion_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. CARGA DE VARIABLES DE ENTORNO (.env)
  // Esto lee el archivo oculto con tus claves antes de iniciar la app
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("⚠️ Advertencia: No se encontró el archivo .env. Las funciones de correo podrían fallar.");
  }

  // 2. INICIALIZACIÓN ROBUSTA DE FIREBASE
  try {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAU4KF0ho3TGJIYLypUSVWTUepGQqD_QZY",
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
    print("⚠️ Firebase error: $e");
  }

  // 3. CONFIGURACIÓN DE PERSISTENCIA (Solo móvil)
  if (!kIsWeb) {
    try {
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    } catch (_) {}
  }

  runApp(const AquaterApp());
}

class AquaterApp extends StatelessWidget {
  const AquaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Aquater',
      debugShowCheckedModeBanner: false,
      
      // TEMA CENTRALIZADO
      theme: AppTheme.lightTheme,

      home: _getPantallaInicial(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/home': (context) => const HomeScreen(),
        '/historial': (context) => const HistorialScreen(),
        '/edicion': (context) => const EdicionListScreen(),
      },
    );
  }

  Widget _getPantallaInicial() {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}