import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart'; // Necesario para 'kIsWeb'



// --- TUS PANTALLAS DEL SOFTWARE ---

import 'screens/login_screen.dart';

import 'screens/dashboard_screen.dart';

import 'screens/home_screen.dart';

import 'screens/historial_screen.dart';

import 'screens/edicion_list_screen.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();



  // 1. INICIALIZACIÓN ROBUSTA DE FIREBASE

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



  // 2. CONFIGURACIÓN DE PERSISTENCIA

  if (!kIsWeb) {

    try {

      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

    } catch (_) {}

  }



  runApp(const AquaterApp());

}



class AquaterApp extends StatelessWidget {

  const AquaterApp({super.key});



  static const Color primaryBlue = Color(0xFF0D47A1);



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Sistema Aquater',

      debugShowCheckedModeBanner: false,

     

      // TEMA VISUAL

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

        // Estilo de inputs global

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

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        ),

      ),



      home: _getPantallaInicial(),



      // Definimos las rutas del software

      // NOTA: Eliminamos 'const' en Dashboard y Edicion para evitar conflictos con animaciones

      routes: {

        '/login': (context) => const LoginScreen(),

        '/dashboard': (context) => const DashboardScreen(), // <--- Sin 'const' si da problemas, pero aquí probamos con const si la clase lo permite. Si falla, quita 'const'.

        '/home': (context) => const HomeScreen(),

        '/historial': (context) => const HistorialScreen(),

        '/edicion': (context) => const EdicionListScreen(), // <--- Sin 'const' si da problemas

      },

    );

  }



  Widget _getPantallaInicial() {

    final usuario = FirebaseAuth.instance.currentUser;

   

    if (usuario != null) {

      // Quitamos 'const' por seguridad con las animaciones nuevas

      return const DashboardScreen();

    } else {

      return const LoginScreen();

    }

  }

}