import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../screens/login_screen.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Importante para el Rastreador

// ==========================================
// 1. SYSTEM DESIGN & CONFIG (AQUATER ENTERPRISE - VISUAL UPGRADE)
// ==========================================

class AppColors {
  static const Color primary = Color(0xFF005696);    // Azul Corporativo Profundo
  static const Color accent = Color(0xFF00A8E8);     // Cyan Tecnológico Vibrante
  static const Color dark = Color(0xFF0F172A);       // Gris Carbón (Slate 900)
  static const Color surface = Color(0xFFF8FAFC);    // Fondo Suave (Slate 50)
  static const Color white = Colors.white;
  static const Color success = Color(0xFF10B981);    // Verde Esmeralda
  static const Color danger = Color(0xFFEF4444);     // Rojo Alerta
  static const Color techBg = Color(0xFF1E293B);     // Fondo Software (Slate 800)
}

class AppTextStyles {
  // Mejora: Sombra sutil en H1 para contraste sobre imágenes
  static TextStyle h1(bool isMobile) => GoogleFonts.montserrat(
    fontSize: isMobile ? 36 : 56, 
    fontWeight: FontWeight.w900, 
    color: AppColors.white, 
    height: 1.1, 
    letterSpacing: -1.5,
    shadows: [
      const Shadow(offset: Offset(0, 4), blurRadius: 10, color: Colors.black45)
    ]
  );
  
  static TextStyle h2 = GoogleFonts.montserrat(
    fontSize: 28, 
    fontWeight: FontWeight.w800, // Más peso para jerarquía
    color: AppColors.primary, 
    letterSpacing: -0.5
  );
  
  static TextStyle h3 = GoogleFonts.montserrat(
    fontSize: 20, 
    fontWeight: FontWeight.w700, 
    color: AppColors.dark,
    letterSpacing: -0.5
  );
  
  static TextStyle body = GoogleFonts.lato(
    fontSize: 16, 
    height: 1.7, // Mejor lectura
    color: const Color(0xFF475569) // Gris Slate 600 (más suave que negro puro)
  );
  
  static TextStyle nav = GoogleFonts.montserrat(
    fontSize: 14, 
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5
  );
}

// Helper visual para contenedores con sombra moderna
BoxDecoration modernDecoration({Color color = Colors.white, double radius = 16}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.dark.withOpacity(0.06),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: -4
      )
    ],
    border: Border.all(color: Colors.white, width: 1.5) // Borde sutil "Highlight"
  );
}

Widget safeNetworkImage(String url, {double? height, BoxFit fit = BoxFit.cover}) {
  return Image.network(
    url,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        height: height,
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, color: Colors.grey, size: 30),
            SizedBox(height: 5),
            Text("Imagen no disponible", style: TextStyle(fontSize: 12, color: Colors.grey))
          ],
        ),
      );
    },
  );
}

// ==========================================
// 2. PÁGINA PRINCIPAL (LANDING PAGE)
// ==========================================

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollBtn = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 800 && !_showScrollBtn) {
        setState(() => _showScrollBtn = true);
      }
      if (_scrollController.offset <= 800 && _showScrollBtn) {
        setState(() => _showScrollBtn = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: 800.ms, curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const WebNavBar(activePage: "Inicio"),
      drawer: isMobile ? const MobileDrawer() : null,
      body: SelectionArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _TopInfoBar(isMobile: isMobile), 
              _HeroSection(isMobile: isMobile),
              _IntroductionText(isMobile: isMobile),
              
              // ✅ AHORA CONECTADO A FIREBASE
              _ServiceTracker(isMobile: isMobile),

              _ValueTrilogy(isMobile: isMobile).animate().fadeIn(delay: 200.ms).moveY(begin: 30, end: 0),
              _StatsBar(isMobile: isMobile),
              _AquaterSoftwareSection(isMobile: isMobile),
              _CalculatorSection(isMobile: isMobile), 
              _WorkflowSection(isMobile: isMobile),
              _ComparisonSection(isMobile: isMobile),
              _ServicesDetailedPreview(isMobile: isMobile),
              
              _DiagnosticWizard(isMobile: isMobile),

              _ProjectsCarouselSection(isMobile: isMobile),
              _BrochureSection(isMobile: isMobile), 
              _TestimonialsSection(isMobile: isMobile),
              _BrandsSection(isMobile: isMobile),
              _CertificationsBar(isMobile: isMobile),
              _BlogSection(isMobile: isMobile),
              _FaqSection(isMobile: isMobile),
              
              _InteractiveMapSection(isMobile: isMobile), 
              
              _QuickContactFormSection(isMobile: isMobile), 
              
              const WebFooter(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SosButton(), 
            
            if (_showScrollBtn)
              FloatingActionButton(
                onPressed: _scrollToTop,
                mini: true,
                backgroundColor: AppColors.dark,
                elevation: 10, 
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
              ).animate().scale(curve: Curves.elasticOut),

            const WhatsAppButton(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. PÁGINAS SECUNDARIAS
// ==========================================

class GlossaryPage extends StatelessWidget {
  const GlossaryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final terms = [
      {"t": "Golpe de Ariete", "d": "Fenómeno hidráulico causado por la variación repentina de velocidad en el fluido, generando ondas de presión que pueden romper tuberías. Se mitiga con estanques hidroneumáticos bien calibrados."},
      {"t": "Cavitación", "d": "Formación y explosión de burbujas de vapor dentro de la bomba debido a baja presión. Causa erosión grave en los impulsores y ruido excesivo ('piedras' en la bomba)."},
      {"t": "VDF (Variador de Frecuencia)", "d": "Dispositivo electrónico que controla la velocidad de rotación de los motores eléctricos, permitiendo un ahorro energético significativo y una presión constante en la red."},
      {"t": "Presóstato", "d": "Interruptor electromecánico que abre o cierra un circuito eléctrico en función de la presión del fluido. Es el cerebro básico de los sistemas de bombeo tradicionales."},
      {"t": "NPSH", "d": "Altura Neta Positiva de Aspiración. Presión mínima necesaria en la entrada de la bomba para evitar la cavitación. Es un cálculo crítico en el diseño de ingeniería."},
      {"t": "D.S. 735", "d": "Decreto Supremo del Minsal que aprueba el reglamento de los servicios de agua destinados al consumo humano. Establece las normas de limpieza de estanques."},
      {"t": "Caudal (Q)", "d": "Volumen de agua que pasa por una sección de la tubería en una unidad de tiempo (ej: litros por minuto o m3/hora). Es fundamental para dimensionar la bomba."},
      {"t": "Altura Manométrica (H)", "d": "Energía por unidad de peso que la bomba debe entregar al fluido para elevarlo desde el nivel de succión hasta el punto de descarga, venciendo la fricción."},
      {"t": "Válvula de Retención (Check)", "d": "Válvula que permite el flujo de agua en una sola dirección, impidiendo que el agua regrese a la bomba cuando esta se detiene (evita vaciado de la columna)."},
      {"t": "Arranque Suave (Soft Starter)", "d": "Dispositivo que limita la corriente inicial durante el arranque del motor, reduciendo el estrés mecánico y los picos de consumo eléctrico."},
      {"t": "Tablero de Fuerza y Control", "d": "Gabinete eléctrico que contiene las protecciones (automáticos, térmicos) y la lógica de control (PLC, relés) para operar las bombas de manera segura."},
      {"t": "Sello Mecánico", "d": "Dispositivo que une la parte estática de la bomba con la parte rotatoria (eje), impidiendo que el agua se filtre hacia el motor eléctrico."},
      {"t": "Estanque Hidroneumático", "d": "Recipiente que contiene agua y aire a presión, separado generalmente por una membrana. Sirve para mantener la presión en la red cuando las bombas están detenidas."},
      {"t": "Aguas Grises", "d": "Aguas provenientes de bañeras, duchas, lavabos y lavadoras. Pueden ser tratadas y reutilizadas para riego o descarga de inodoros según la nueva normativa."},
      {"t": "Aguas Negras", "d": "Aguas residuales provenientes de inodoros y urinarios. Requieren tratamiento biológico complejo o conexión directa al alcantarillado público."},
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const WebNavBar(activePage: "Glosario"),
      drawer: isMobile ? const MobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PageHeader(title: "GLOSARIO TÉCNICO", subtitle: "Diccionario de términos hidráulicos fundamentales."),
            Container(
              padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 100),
              child: Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: terms.map((term) => Container(
                  width: isMobile ? double.infinity : 400,
                  padding: const EdgeInsets.all(35),
                  decoration: modernDecoration(color: AppColors.surface), // Estilo unificado
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(term['t']!, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 15),
                    Text(term['d']!, style: AppTextStyles.body),
                  ]),
                )).toList(),
              ),
            ),
            const WebFooter(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [SosButton(), WhatsAppButton()],
        ),
      ),
    );
  }
}

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    
    final fullServices = [
      {
        "title": "MANTENCIÓN DE SALAS DE BOMBAS",
        "description": "El corazón de su edificio merece atención experta. Ofrecemos un servicio completo de mantención preventiva y correctiva para salas de bombas, ajustado a las necesidades específicas de cada comunidad o industria. Nuestro objetivo es maximizar la vida útil de los equipos y evitar cortes de suministro imprevistos.",
        "checklist": ["Revisión completa de circuitos eléctricos y reapriete de bornes.", "Inspección y verificación de presión en estanques hidroneumáticos (carga de aire).", "Revisión y ajuste de controles y comandos eléctricos (automáticos, contactores).", "Ajuste y calibración de presóstatos y temporizadores.", "Revisión, control y ajuste de válvulas de flotación y válvulas check.", "Detección y revisión de posibles filtraciones en sellos mecánicos.", "Entrega de Hoja de Mantención en formato digital o impreso.", "Atención de emergencias 24/7 para clientes con contrato."],
        "image": Icons.settings_suggest
      },
      {
        "title": "LAVADO Y SANITIZACIÓN DE ESTANQUES",
        "description": "El agua potable es salud. Realizamos el lavado y sanitizado de estanques de agua potable (AP) cumpliendo estrictamente con el Decreto Supremo 735. Utilizamos equipos de trasvasije para no botar el agua, recuperándola y filtrándola si es posible, o disponiéndola responsablemente.",
        "checklist": ["Vaciado controlado mediante bombas de achique.", "Hidrolavado a alta presión de paredes y piso para eliminar biofilm.", "Aplicación de solución clorada certificada para desinfección total.", "Enjuague y neutralización de residuos químicos.", "Revisión de la estructura del estanque (grietas, fierro expuesto).", "Entrega de Certificado de Limpieza válido para la Seremi de Salud.", "Análisis bacteriológico (opcional según requerimiento)."],
        "image": Icons.water_drop
      },
      {
        "title": "MODERNIZACIÓN Y VDF",
        "description": "La tecnología avanza, y su edificio no debe quedarse atrás. Optimizamos el rendimiento y la eficiencia de su sistema a través de la instalación de Variadores de Frecuencia (VDF) y controladores PLC. Esto permite mantener una presión constante en los departamentos, eliminar los molestos golpes de ariete y reducir significativamente el consumo eléctrico.",
        "checklist": ["Evaluación de factibilidad técnica y ahorro energético.", "Desmontaje de tableros antiguos (partida directa/estrella-triángulo).", "Instalación de gabinetes IP55/IP65 con ventilación forzada.", "Programación de curvas de aceleración y desaceleración suave.", "Integración con sensores de presión 4-20mA.", "Capacitación al personal de conserjería sobre el uso del nuevo sistema."],
        "image": Icons.speed
      },
      {
        "title": "RETIRO DE SÓLIDOS Y RILES",
        "description": "Manejo efectivo y responsable de residuos líquidos industriales (RILES) y aguas servidas. Contamos con camiones combinados certificados y personal profesional para asegurar la limpieza profunda de cámaras desgrasadoras, fosas sépticas y plantas de tratamiento.",
        "checklist": ["Succión de lodos y grasas con camión de alto vacío.", "Lavado de paredes de las cámaras con hidrojet.", "Desobstrucción de las líneas de entrada y salida.", "Transporte seguro de los residuos.", "Disposición final en plantas de tratamiento autorizadas (Aguas Andinas/Otras).", "Entrega de certificado de disposición final (trazabilidad ambiental)."],
        "image": Icons.cleaning_services
      },
      {
        "title": "DESTAPE HIDROCINÉTICO (HYDROJET)",
        "description": "Solución rápida y efectiva para obstrucciones difíciles. La tecnología Hydrojet utiliza agua a altísima presión para cortar raíces, disolver grasas solidificadas y arrastrar escombros, dejando la tubería limpia y con su diámetro original recuperado, sin dañar la estructura como ocurre con las varillas metálicas.",
        "checklist": ["Diagnóstico de la obstrucción.", "Aplicación de manguera de alta presión con puntera rotatoria.", "Limpieza de shaft de alcantarillado vertical y horizontal.", "Prueba de flujo post-servicio.", "Video inspección (opcional) para verificar estado interior."],
        "image": Icons.plumbing
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const WebNavBar(activePage: "Servicios"),
      drawer: isMobile ? const MobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PageHeader(title: "CATÁLOGO TÉCNICO DE SERVICIOS", subtitle: "Soluciones de ingeniería para la infraestructura crítica de su edificio."),
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: isMobile ? 20 : 100),
              child: Column(
                children: fullServices.map((service) => _ServiceDetailSection(service, isMobile)).toList(),
              ),
            ),
            _ProjectsSection(isMobile: isMobile),
            const WebFooter(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [SosButton(), WhatsAppButton()],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const WebNavBar(activePage: "Nosotros"),
      drawer: isMobile ? const MobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PageHeader(title: "SOBRE AQUATER", subtitle: "Compromiso con la excelencia desde 2011."),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NUESTRA HISTORIA", style: AppTextStyles.h2),
                  const SizedBox(height: 20),
                  Text(
                    "Aquater Ltda. nace como respuesta a la necesidad urgente de profesionalizar el rubro del mantenimiento hidráulico en Chile. Durante años, detectamos que muchas comunidades y empresas dependían de servicios informales ('maestros chasquilla') que, aunque voluntariosos, carecían del conocimiento técnico para manejar sistemas complejos, poniendo en riesgo la seguridad del suministro de agua y la integridad de los equipos.\n\nHoy, combinamos más de 40 años de experiencia colectiva entre nuestros ingenieros, técnicos electromecánicos y químicos. No solo reparamos fallas; gestionamos activos críticos. Utilizamos tecnología de monitoreo y herramientas de precisión para asegurar que cada litro de agua sea impulsado de la manera más eficiente posible.",
                    style: AppTextStyles.body.copyWith(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 50),
                  
                  Text("MISIÓN", style: AppTextStyles.h2),
                  const SizedBox(height: 20),
                  Text(
                    "Proveer seguridad hídrica y tranquilidad a nuestros clientes mediante soluciones de ingeniería confiables, sustentables y tecnológicamente avanzadas. Nos esforzamos por transformar el mantenimiento preventivo en una inversión rentable, minimizando costos de energía y reparaciones mayores.",
                    style: AppTextStyles.body.copyWith(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 50),

                  Text("VISIÓN", style: AppTextStyles.h2),
                  const SizedBox(height: 20),
                  Text(
                    "Ser reconocidos como el referente nacional en gestión de infraestructura sanitaria inteligente, liderando la transición hacia edificios más eficientes y ecológicos mediante la adopción de tecnologías de telemetría y automatización.",
                    style: AppTextStyles.body.copyWith(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 80),
                  
                  Center(child: Text("NUESTROS VALORES", style: AppTextStyles.h2)),
                  const SizedBox(height: 40),
                  const Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                        _ValueCard(Icons.security_rounded, "Seguridad", "Cumplimiento estricto de normas eléctricas e hidráulicas para proteger a las personas."),
                        _ValueCard(Icons.electric_bolt_rounded, "Eficiencia", "Enfoque en la reducción del consumo energético mediante tecnología VDF."),
                        _ValueCard(Icons.eco_rounded, "Sustentabilidad", "Procesos de limpieza que minimizan la pérdida de agua potable."),
                        _ValueCard(Icons.handshake_rounded, "Transparencia", "Informes claros y honestidad en cada diagnóstico técnico."),
                    ],
                  ),
                  const SizedBox(height: 80),
                  _TeamSection(isMobile: isMobile)
                ],
              ),
            ),
            const WebFooter(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [SosButton(), WhatsAppButton()],
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const WebNavBar(activePage: "Contacto"),
      drawer: isMobile ? const MobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PageHeader(title: "CONTACTO COMERCIAL", subtitle: "Estamos listos para optimizar su sistema."),
            Container(
              padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 100),
              child: Column(
                children: [
                  Wrap(
                    spacing: 30,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _ContactTile(Icons.phone_rounded, "+56 9 9322 1797", () => launchUrl(Uri.parse("tel:+56993221797"))),
                      _ContactTile(Icons.email_rounded, "alonso.matilla@aquater.cl", () => launchUrl(Uri.parse("mailto:alonso.matilla@aquater.cl"))),
                      _ContactTile(Icons.location_on_rounded, "Eliodoro Yañez 1568, Providencia", () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=Eliodoro+Yañez+1568,+Providencia"))),
                    ],
                  ),
                  const SizedBox(height: 80),
                  _QuickContactFormSection(isMobile: isMobile, isDark: false),
                ],
              ),
            ),
            const WebFooter(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [SosButton(), WhatsAppButton()],
        ),
      ),
    );
  }
}

// ==========================================
// 4. LOGIC WIDGETS (INTERACTIVOS)
// ==========================================

class _ServiceTracker extends StatefulWidget {
  final bool isMobile;
  const _ServiceTracker({required this.isMobile});
  @override
  State<_ServiceTracker> createState() => _ServiceTrackerState();
}
class _ServiceTrackerState extends State<_ServiceTracker> {
  final TextEditingController _controller = TextEditingController();
  String? _status;
  bool _hasError = false;

  // ✅ LOGICA REAL CONECTADA A FIREBASE
// En _ServiceTrackerState dentro de landing_page.dart

  void _checkStatus() async {
    FocusScope.of(context).unfocus(); 
    
    String inputRaw = _controller.text.trim().toUpperCase(); // <-- LA CLAVE: MAYÚSCULAS

    if (inputRaw.isEmpty) {
      setState(() {
        _hasError = true;
        _status = null;
      });
      return;
    }

    setState(() {
      _hasError = false;
      _status = "🔍 Buscando orden $inputRaw...";
    });

    try {
      print("Buscando en Firebase: $inputRaw"); // Debug para ver en consola del navegador

      final query = await FirebaseFirestore.instance
          .collection('informes')
          .where('codigoCorrelativo', isEqualTo: inputRaw) // Usamos el input normalizado
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        // Usamos valores por defecto por si el campo no existe
        final String tecnico = data['tecnicoId'] ?? "Técnico Asignado";
        final String sede = data['sede'] ?? "Instalación del Cliente";
        final String tipo = (data['tipoServicio'] ?? "Servicio").toString().toUpperCase();
        
        // Formato de fecha seguro
        String fecha = "Fecha no registrada";
        if (data['fechaCreacion'] != null) {
          final Timestamp ts = data['fechaCreacion'];
          final dt = ts.toDate();
          fecha = "${dt.day}/${dt.month}/${dt.year} a las ${dt.hour}:${dt.minute}";
        }

        setState(() {
          _status = "✅ ORDEN ENCONTRADA\n\n"
                    "📄 Tipo: $tipo\n"
                    "🏢 Sede: $sede\n"
                    "👷 Técnico: $tecnico\n"
                    "📅 Fecha: $fecha\n"
                    "🚀 Estado: Informe Generado y Sincronizado.";
        });
      } else {
        setState(() {
          _status = "❌ No encontramos la orden '$inputRaw'.\nVerifique que el código sea exacto (Ej: MAN1234).";
        });
      }
    } catch (e) {
      print("Error Tracker: $e");
      setState(() {
        _status = "⚠️ Error de conexión: $e";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.dark,
        image: DecorationImage(image: NetworkImage("https://www.transparenttextures.com/patterns/carbon-fibre.png"), opacity: 0.1, repeat: ImageRepeat.repeat), // Textura sutil
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: widget.isMobile ? 20 : 100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text("CLIENTES CONTRATO", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 15),
          Text("Rastree el estado de su visita técnica en tiempo real", style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 24), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Flex(
              direction: widget.isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: widget.isMobile ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          hintText: "Ingrese N° de Orden (ej: MAN1234)",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          errorText: _hasError ? "Debe ingresar un número" : null,
                          errorStyle: const TextStyle(color: AppColors.danger),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
                          prefixIcon: const Icon(Icons.confirmation_number_outlined, color: Colors.white54)
                        ),
                      ),
                    ],
                  ),
                ),
                if(widget.isMobile) const SizedBox(height: 15) else const SizedBox(width: 15),
                SizedBox(
                  width: widget.isMobile ? double.infinity : null,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _checkStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("RASTREAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                )
              ],
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(50), border: Border.all(color: AppColors.success)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_shipping_rounded, color: AppColors.success),
                  const SizedBox(width: 15),
                  Flexible(child: Text(_status!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ).animate().fadeIn().scale(),
            )
          ]
        ],
      ),
    );
  }
}

class _DiagnosticWizard extends StatefulWidget {
  final bool isMobile;
  const _DiagnosticWizard({required this.isMobile});

  @override
  State<_DiagnosticWizard> createState() => _DiagnosticWizardState();
}
class _DiagnosticWizardState extends State<_DiagnosticWizard> {
  int _step = 0;
  String _result = "";

  final List<Map<String, dynamic>> _questions = [
    {
      "q": "¿Qué síntoma presenta su equipo?",
      "options": [
        {"text": "Ruido fuerte / Vibración", "next": 1},
        {"text": "Poca presión de agua", "next": 2},
        {"text": "Aumento cuenta de luz", "next": 3},
      ]
    },
    { 
      "q": "¿Cómo describiría el ruido?",
      "options": [
        {"text": "Como piedras golpeando (Crak-Crak)", "result": "PELIGRO: Posible Cavitación. Requiere atención urgente para evitar destrucción de impulsores."},
        {"text": "Zumbido eléctrico constante", "result": "POSIBLE FALLA: Rodamientos desgastados o problema de fase eléctrica."},
      ]
    },
    { 
      "q": "¿La falta de presión es constante?",
      "options": [
        {"text": "Sí, todo el día", "result": "DIAGNÓSTICO: Posible falla en válvulas de retención o bombas mal dimensionadas."},
        {"text": "Solo en horas punta", "result": "RECOMENDACIÓN: Su sistema requiere tecnología VDF para compensar la alta demanda."},
      ]
    },
    { 
      "q": "¿Tiene sistema de variación de frecuencia?",
      "options": [
        {"text": "No / No sé", "result": "OPORTUNIDAD: Instalar VDF puede reducir su consumo hasta un 40% inmediatamente."},
        {"text": "Sí, ya tengo", "result": "MANTENCIÓN: Un sistema VDF mal calibrado puede gastar más energía. Requerimos revisar parámetros."},
      ]
    }
  ];

  void _reset() => setState(() { _step = 0; _result = ""; });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: widget.isMobile ? 20 : 100),
      color: Colors.blueGrey[50], // Fondo sutil
      child: Column(
        children: [
          Text("AUTODIAGNÓSTICO EN LÍNEA", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text("Identifique posibles fallas antes de solicitar la visita.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 50),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey<int>(_step + (_result.isEmpty ? 0 : 99)),
              width: 700,
              padding: const EdgeInsets.all(50),
              decoration: modernDecoration(), // Uso de decoración moderna
              child: _result.isNotEmpty
                ? Column(
                    children: [
                      const Icon(Icons.build_circle_outlined, size: 80, color: AppColors.danger),
                      const SizedBox(height: 30),
                      Text(_result, style: AppTextStyles.h3.copyWith(height: 1.5), textAlign: TextAlign.center),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, _createRoute(const ContactPage())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, 
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5
                        ),
                        child: const Text("AGENDAR VISITA TÉCNICA AHORA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      TextButton(onPressed: _reset, child: const Text("Reiniciar diagnóstico"))
                    ],
                  )
                : Column(
                    children: [
                      Text(_questions[_step]['q'], style: AppTextStyles.h3.copyWith(fontSize: 24), textAlign: TextAlign.center),
                      const SizedBox(height: 40),
                      ...(_questions[_step]['options'] as List).map((opt) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              if (opt.containsKey('result')) {
                                setState(() => _result = opt['result']);
                              } else {
                                setState(() => _step = opt['next']);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: AppColors.primary
                            ),
                            child: Text(opt['text'], style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                        ),
                      )),
                      if(_step > 0) TextButton.icon(icon: const Icon(Icons.arrow_back, size: 16), onPressed: _reset, label: const Text("Volver al inicio"))
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickContactFormSection extends StatefulWidget {
  final bool isMobile;
  final bool isDark; 
  const _QuickContactFormSection({required this.isMobile, this.isDark = true});
  @override
  State<_QuickContactFormSection> createState() => _QuickContactFormSectionState();
}

class _QuickContactFormSectionState extends State<_QuickContactFormSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud enviada. Un experto lo contactará en breve."), backgroundColor: AppColors.success)
      );
      _nameCtrl.clear();
      _phoneCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? AppColors.dark : AppColors.surface;
    final titleColor = widget.isDark ? Colors.white : AppColors.dark;
    final textColor = widget.isDark ? Colors.white70 : Colors.grey[700];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: widget.isMobile ? 20 : 100),
      color: bgColor,
      child: Flex(
        direction: widget.isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: widget.isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: widget.isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: widget.isDark ? Colors.white10 : Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("SOPORTE COMERCIAL", style: TextStyle(color: widget.isDark ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 20),
                Text("¿NECESITA ASESORÍA INMEDIATA?", style: AppTextStyles.h2.copyWith(color: titleColor, fontSize: widget.isMobile ? 28 : 36)),
                const SizedBox(height: 20),
                Text(
                  "Déjenos sus datos y un ingeniero especialista lo contactará en menos de 30 minutos para evaluar su requerimiento sin costo.",
                  style: AppTextStyles.body.copyWith(color: textColor, fontSize: 18),
                  textAlign: widget.isMobile ? TextAlign.center : TextAlign.start,
                ),
                const SizedBox(height: 40),
                if(!widget.isMobile) Row(
                  children: [
                      _BenefitChip("Evaluación Gratuita", titleColor),
                      const SizedBox(width: 20),
                      _BenefitChip("Respuesta Rápida", titleColor),
                  ],
                )
              ],
            ),
          ),
          if(widget.isMobile) const SizedBox(height: 50),
          if(!widget.isMobile) const SizedBox(width: 80),
          Container(
            width: widget.isMobile ? double.infinity : 450,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, 10))]
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Solicitar Llamado", style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (v) => v == null || v.isEmpty ? "Ingrese su nombre" : null,
                    decoration: const InputDecoration(labelText: "Su Nombre", prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8FAFC)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneCtrl,
                    validator: (v) => v == null || v.length < 8 ? "Ingrese un teléfono válido" : null,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Teléfono de Contacto", prefixIcon: Icon(Icons.phone_android), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8FAFC)),
                  ),
                  const SizedBox(height: 20),
                  const TextField(decoration: InputDecoration(labelText: "Correo Electrónico", prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8FAFC))),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, 
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5
                      ),
                      child: const Text("ENVIAR SOLICITUD AHORA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(child: Text("Al enviar, acepta ser contactado por Aquater Ltda.", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _BenefitChip(String text, Color color) {
  return Row(
    children: [
      const Icon(Icons.check_circle_rounded, color: AppColors.success), 
      const SizedBox(width: 8), 
      Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold))
    ],
  );
}

class _CalculatorSection extends StatefulWidget {
  final bool isMobile;
  const _CalculatorSection({required this.isMobile});
  @override
  State<_CalculatorSection> createState() => _CalculatorSectionState();
}
class _CalculatorSectionState extends State<_CalculatorSection> {
  double _hp = 5.0; 
  double _hours = 12.0; 
  final double _kwhPrice = 150.0; 
  @override
  Widget build(BuildContext context) {
    double kw = _hp * 0.746;
    double monthlyCost = kw * _hours * 30 * _kwhPrice;
    double savings = monthlyCost * 0.35; 
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: widget.isMobile ? 20 : 100),
      color: AppColors.surface,
      width: double.infinity,
      child: Column(
        children: [
          Text("CALCULADORA DE AHORRO ENERGÉTICO", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 15),
          Text("Estime cuánto dinero podría ahorrar mensualmente en su edificio instalando tecnología VDF.", style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: modernDecoration(),
            child: widget.isMobile ? Column(children: _buildContent(savings)) : Row(children: _buildContent(savings)),
          )
        ],
      ),
    );
  }
  List<Widget> _buildContent(double savings) {
    String formatMoney(double value) => "\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    return [
      Expanded(
        flex: widget.isMobile ? 0 : 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("POTENCIA DE BOMBAS", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 5),
            Text("${_hp.round()} HP", style: AppTextStyles.h3.copyWith(fontSize: 24)),
            Slider(value: _hp, min: 1, max: 50, divisions: 49, activeColor: AppColors.primary, thumbColor: AppColors.primary, onChanged: (v) => setState(() => _hp = v)),
            const SizedBox(height: 30),
            Text("USO DIARIO", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 5),
            Text("${_hours.round()} Horas", style: AppTextStyles.h3.copyWith(fontSize: 24)),
            Slider(value: _hours, min: 1, max: 24, divisions: 23, activeColor: AppColors.primary, thumbColor: AppColors.primary, onChanged: (v) => setState(() => _hours = v)),
          ],
        ),
      ),
      if(!widget.isMobile) const SizedBox(width: 60),
      if(widget.isMobile) const SizedBox(height: 40),
      Expanded(
        flex: widget.isMobile ? 0 : 1,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF003D6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
          ),
          child: Column(
            children: [
              const Icon(Icons.savings_outlined, color: Colors.white, size: 50),
              const SizedBox(height: 15),
              const Text("AHORRO ESTIMADO", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 5),
              Text(formatMoney(savings), style: GoogleFonts.montserrat(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.white)),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.push(context, _createRoute(const ContactPage())),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.white, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("COTIZAR MODERNIZACIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      )
    ];
  }
}

// ==========================================
// 5. SECCIONES Y WIDGETS DE CONTENIDO
// ==========================================

class _TopInfoBar extends StatelessWidget {
  final bool isMobile;
  const _TopInfoBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) return const SizedBox.shrink(); 
    return Container(
      width: double.infinity,
      color: AppColors.dark,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.email_outlined, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text("alonso.matilla@aquater.cl", style: GoogleFonts.lato(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 25),
              const Icon(Icons.phone_outlined, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text("+56 9 9322 1797", style: GoogleFonts.lato(color: Colors.white70, fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 14),
                const SizedBox(width: 8),
                Text("Atención de Emergencias 24/7", style: GoogleFonts.lato(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isMobile;
  const _HeroSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 700 : 850,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1581094794329-c8112a89af12?q=80&w=1932&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.dark.withOpacity(0.92), AppColors.primary.withOpacity(0.6), Colors.transparent],
            stops: const [0.0, 0.6, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight
          )
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent, 
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                ),
                child: Text("INGENIERÍA HIDRÁULICA Y MANTENIMIENTO INDUSTRIAL", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.5)),
              ).animate().fadeIn().moveX(begin: -30, end: 0),
              
              const SizedBox(height: 35),
              
              Text("SOLUCIONES EFICIENTES,\nSEGURAS Y NORMATIVAS.", style: AppTextStyles.h1(isMobile))
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .moveX(begin: -30, end: 0),
              
              const SizedBox(height: 30),
              
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Text(
                  "Descubra los servicios especializados de AQUATER en mantenimiento industrial de alta complejidad: lavado y sanitización certificada de estanques de agua potable, modernización tecnológica de salas de bombas con sistemas VDF, gestión integral de residuos sólidos y desobstrucción hidrocinética.",
                  style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.95), fontSize: 18, height: 1.8),
                ),
              ).animate().fadeIn(delay: 400.ms).moveX(begin: -30, end: 0),
              
              const SizedBox(height: 50),
              
              _HoverButton(
                text: "SOLICITAR EVALUACIÓN TÉCNICA",
                onTap: () => Navigator.push(context, _createRoute(const ContactPage())),
              ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroductionText extends StatelessWidget {
  final bool isMobile;
  const _IntroductionText({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 150),
      color: AppColors.white,
      width: double.infinity,
      child: Column(
        children: [
          Text("MANTENIMIENTO EXPERTO DE SALAS DE BOMBAS", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Container(height: 4, width: 60, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 40),
          Text(
            "El mantenimiento regular es fundamental para asegurar el funcionamiento óptimo, seguro y continuo de cualquier sistema hidráulico. En AQUATER, nos especializamos en mantener su infraestructura en condiciones impecables mediante un servicio integral que no deja nada al azar. \n\nNuestra metodología abarca desde la revisión preventiva de tableros eléctricos y control de presiones, hasta la atención crítica de emergencias 24/7. Supervisamos trimestralmente cada instalación con ingenieros expertos para anticiparnos a las fallas antes de que ocurran, reduciendo costos operativos y extendiendo la vida útil de sus activos.",
            style: AppTextStyles.body.copyWith(fontSize: 18),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

class _ValueTrilogy extends StatelessWidget {
  final bool isMobile;
  const _ValueTrilogy({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 100),
      color: AppColors.surface, // Cambio sutil de fondo
      width: double.infinity,
      child: Wrap(
        spacing: 40,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _InteractiveCard(
            icon: Icons.verified_user_rounded, 
            title: "CALIDAD CERTIFICADA", 
            desc: "Nuestros procesos cumplen estrictamente con el D.S. 735 y la normativa RIDAA. Entregamos certificados de calidad.",
            onTap: () => Navigator.push(context, _createRoute(const ServicesPage())),
            isMobile: isMobile
          ),
          _InteractiveCard(
            icon: Icons.engineering_rounded, 
            title: "INGENIERÍA APLICADA", 
            desc: "Revisamos sus proyectos hidráulicos ofreciendo mejoras sustanciales en eficiencia energética.",
            onTap: () => Navigator.push(context, _createRoute(const ServicesPage())),
            isMobile: isMobile
          ),
          _InteractiveCard(
            icon: Icons.support_agent_rounded, 
            title: "SOPORTE 24/7", 
            desc: "Ofrecemos un servicio de emergencias real, disponible las 24 horas durante toda la semana.",
            onTap: () => Navigator.push(context, _createRoute(const ContactPage())),
            isMobile: isMobile
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final bool isMobile;
  const _StatsBar({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: const BoxDecoration(
        image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=2072&auto=format&fit=crop"), fit: BoxFit.cover, colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.multiply))
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const _AnimatedStatItem(endValue: 12, label: "Años de Experiencia", symbol: "+"),
          if(isMobile) const SizedBox(height: 40),
          const _AnimatedStatItem(endValue: 100, label: "Cumplimiento D.S. 735", symbol: "%"),
          if(isMobile) const SizedBox(height: 40),
          const _AnimatedStatItem(endValue: 365, label: "Días de Soporte al Año", symbol: ""),
        ],
      ),
    );
  }
}

class _AquaterSoftwareSection extends StatelessWidget {
  final bool isMobile;
  const _AquaterSoftwareSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.techBg,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 100),
      child: Column(
        children: [
          Text("TRANSPARENCIA TOTAL CON NUESTRA APP", style: AppTextStyles.h2.copyWith(color: AppColors.accent), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: 800,
            child: Text("Olvídese de las bitácoras en papel ilegibles. Con el software de Aquater, usted tiene control y trazabilidad digital de cada visita.", 
              style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 18), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 80),
          Wrap(
            spacing: 80,
            runSpacing: 50,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // MOCKUP DEL SOFTWARE (VISUAL OPTIMIZADA)
              Container(
                width: isMobile ? double.infinity : 500,
                height: 340,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 50, offset: const Offset(0, 10))]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // UI Header Mockup
                      Positioned(top: 0, left: 0, right: 0, height: 60, child: Container(color: AppColors.primary)),
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("EDIFICIO: LOS ALERCES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                  child: const Text("AL DÍA", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 30),
                            const _SoftwareRowItem("Última Visita Técnica", "12 Dic, 2025 - 10:30 AM", Icons.calendar_today),
                            const SizedBox(height: 20),
                            const _SoftwareRowItem("Técnico Responsable", "Juan Pérez (Cert. SEC)", Icons.person),
                            const SizedBox(height: 20),
                            const _SoftwareRowItem("Informe Digital", "Disponible para descarga (PDF)", Icons.picture_as_pdf),
                            
                            const Spacer(),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,4))]),
                              child: const Center(child: Text("VER BITÁCORA HISTÓRICA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // BENEFICIOS DEL SOFTWARE
              SizedBox(
                width: isMobile ? double.infinity : 400,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TechBenefit("Bitácora 100% Digital", "Acceda al historial de mantenciones desde su celular o computador."),
                    _TechBenefit("Evidencia Fotográfica", "Cada informe incluye fotos del 'Antes y Después' de los trabajos."),
                    _TechBenefit("Notificaciones en Vivo", "Sepa exactamente cuándo nuestros técnicos ingresan y salen de su edificio."),
                    _TechBenefit("Respaldo en la Nube", "Sus certificados y garantías siempre seguros y disponibles 24/7."),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _ProjectsCarouselSection extends StatefulWidget {
  final bool isMobile;
  const _ProjectsCarouselSection({required this.isMobile});
  @override
  State<_ProjectsCarouselSection> createState() => _ProjectsCarouselSectionState();
}
class _ProjectsCarouselSectionState extends State<_ProjectsCarouselSection> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _projects = [
    {
      "image": "https://images.unsplash.com/photo-1635845573931-79f43678739b?q=80&w=1932&auto=format&fit=crop",
      "title": "Modernización VDF - Edificio Las Condes",
      "desc": "Reemplazo de tablero estrella-triángulo por sistema VDF doble. Ahorro energético del 38% validado."
    },
    {
      "image": "https://images.unsplash.com/photo-1563311238-c77a27b670c7?q=80&w=2070&auto=format&fit=crop",
      "title": "Sanitización Compleja - Torre Santiago Centro",
      "desc": "Limpieza de estanque de 60.000 Litros con acceso restringido, cumpliendo protocolos de seguridad."
    },
    {
      "image": "https://plus.unsplash.com/premium_photo-1664304477470-c71922e6823a?q=80&w=2070&auto=format&fit=crop",
      "title": "Instalación de Banco de Bombas - Industrial",
      "desc": "Montaje de 4 bombas multietapa para proceso productivo crítico, con redundancia total."
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _projects.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubicEmphasized,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: widget.isMobile ? 0 : 100),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("GALERÍA DE PROYECTOS RECIENTES", style: AppTextStyles.h2, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("Evidencia visual de nuestra calidad de ejecución.", style: AppTextStyles.body, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: widget.isMobile ? 400 : 500,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                return _ProjectCarouselCard(
                  image: _projects[index]['image']!,
                  title: _projects[index]['title']!,
                  desc: _projects[index]['desc']!,
                  isMobile: widget.isMobile,
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_projects.length, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: 8,
              width: _currentPage == index ? 30 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4)
              ),
            )),
          )
        ],
      ),
    );
  }
}

class _WorkflowSection extends StatelessWidget {
  final bool isMobile;
  const _WorkflowSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 100),
      child: Column(
        children: [
          Text("METODOLOGÍA DE TRABAJO", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text("Nuestro proceso garantiza transparencia y resultados medibles desde el primer día.", style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 80),
          Wrap(
            spacing: 20,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              const _WorkflowStep("01", "Diagnóstico", "Visita técnica inicial para levantar el estado real de los equipos.", Icons.analytics_outlined),
              const _WorkflowStep("02", "Ingeniería", "Cálculo hidráulico y propuesta de mejoras enfocadas en ahorro.", Icons.computer_rounded),
              const _WorkflowStep("03", "Ejecución", "Implementación con técnicos certificados y supervisión de ingeniería.", Icons.construction_rounded),
              const _WorkflowStep("04", "Monitoreo", "Seguimiento post-venta y entrega de informes de rendimiento.", Icons.query_stats_rounded),
            ].animate(interval: 100.ms).fadeIn().moveY(begin: 20, end: 0),
          )
        ],
      ),
    );
  }
}

class _ServicesDetailedPreview extends StatelessWidget {
  final bool isMobile;
  const _ServicesDetailedPreview({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 100),
      color: AppColors.surface,
      width: double.infinity,
      child: Column(
        children: [
          Text("SERVICIOS ESPECIALIZADOS", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 15),
          Text("Soluciones integrales de ingeniería sanitaria para comunidades e industrias.", style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _InteractiveCard(
                icon: Icons.settings_suggest_rounded, 
                title: "Mantención Salas de Bombas", 
                desc: "Ofrecemos un servicio completo de mantención para salas de bombas, ajustado a las necesidades de cada cliente. Incluye revisión de tableros, ajuste de presóstatos y medición de consumo.", 
                onTap: () => Navigator.push(context, _createRoute(const ServicesPage())),
                isMobile: isMobile
              ),
              _InteractiveCard(
                icon: Icons.water_drop_rounded, 
                title: "Lavado de Estanques", 
                desc: "Lavamos y sanitizamos estanques de agua potable, sin botar el agua innecesariamente. Entregamos certificado de calidad y análisis de laboratorio según la necesidad del cliente.", 
                onTap: () => Navigator.push(context, _createRoute(const ServicesPage())),
                isMobile: isMobile
              ),
              _InteractiveCard(
                icon: Icons.speed_rounded, 
                title: "Modernización VDF", 
                desc: "Optimizamos el rendimiento y la eficiencia de tu sistema, a través de equipos y productos de primera calidad como Variadores de Frecuencia y controladores lógicos.", 
                onTap: () => Navigator.push(context, _createRoute(const ServicesPage())),
                isMobile: isMobile
              ),
              _InteractiveCard(
                icon: Icons.cleaning_services_rounded, 
                title: "Retiro de Sólidos", 
                desc: "Manejo efectivo de sólidos, camión certificado y personal profesional para asegurar la limpieza profunda de las cámaras y fosas sépticas.", 
                onTap: () => Navigator.push(context, _createRoute(const ServicesPage())),
                isMobile: isMobile
              ),
            ],
          ),
          const SizedBox(height: 60),
          OutlinedButton(
            onPressed: () => Navigator.push(context, _createRoute(const ServicesPage())),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 2), 
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text("VER TODOS LOS SERVICIOS Y DETALLES", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
          )
        ],
      ),
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  final bool isMobile;
  const _ComparisonSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 100),
      width: double.infinity,
      child: Column(
        children: [
          Text("¿POR QUÉ ELEGIR AQUATER?", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text("La diferencia entre un servicio informal y la ingeniería profesional.", style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 60),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))]
            ),
            child: Column(
              children: [
                _ComparisonHeader(isMobile),
                _ComparisonRow("Atención de Emergencias", "Garantía 24/7 Real", "Solo horario hábil", isMobile),
                _ComparisonRow("Personal Técnico", "Ingenieros Certificados SEC", "Sin certificación", isMobile),
                _ComparisonRow("Garantía de Trabajo", "Contrato y Póliza", "Solo de palabra", isMobile),
                _ComparisonRow("Tecnología", "Telemetría y VDF", "Herramientas básicas", isMobile),
                _ComparisonRow("Normativa", "Cumplimiento D.S. 735", "Desconocimiento legal", isMobile, isLast: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _ComparisonHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("CARACTERÍSTICA", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Center(child: Text("AQUATER", style: GoogleFonts.montserrat(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 18)))),
          Expanded(flex: 2, child: Center(child: Text("INFORMAL", style: GoogleFonts.montserrat(color: Colors.white30, fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 18)))),
        ],
      ),
    );
  }

  Widget _ComparisonRow(String feature, String aquater, String others, bool isMobile, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100))
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(feature, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 16, color: AppColors.dark))),
          Expanded(flex: 2, child: Column(children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            if(!isMobile) const SizedBox(height: 5),
            if(!isMobile) Text(aquater, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
          ])),
          Expanded(flex: 2, child: Column(children: [
            const Icon(Icons.cancel, color: Colors.grey),
            if(!isMobile) const SizedBox(height: 5),
            if(!isMobile) Text(others, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13))
          ])),
        ],
      ),
    );
  }
}

class _InteractiveMapSection extends StatelessWidget {
  final bool isMobile;
  const _InteractiveMapSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const center = LatLng(-33.4324455, -70.6151703);

    return Container(
      height: 550,
      width: double.infinity,
      color: Colors.grey[200],
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: center, 
              initialZoom: 16.0,
              maxZoom: 18.0,
              minZoom: 5.0,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aquater.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.danger, size: 50),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)]),
                          child: const Text("AQUATER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 30,
            left: isMobile ? 20 : 50,
            right: isMobile ? 20 : null,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: modernDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NUESTRA OFICINA", style: AppTextStyles.h3.copyWith(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Eliodoro Yañez 1568,\nProvidencia, RM", style: AppTextStyles.body.copyWith(fontSize: 14)),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=-33.4324455,-70.6151703")),
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text("Cómo llegar"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _BrochureSection extends StatelessWidget {
  final bool isMobile;
  const _BrochureSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 100),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200))
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.file_download_outlined, size: 50, color: AppColors.primary),
          ),
          if(!isMobile) const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text("DESCARGUE NUESTRA PRESENTACIÓN", style: AppTextStyles.h2.copyWith(fontSize: 24)),
                const SizedBox(height: 10),
                Text("Obtenga el PDF institucional para presentarlo a su comité de administración o gerencia.", style: AppTextStyles.body, textAlign: isMobile ? TextAlign.center : TextAlign.start),
              ],
            ),
          ),
          if(isMobile) const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {}, 
            icon: const Icon(Icons.cloud_download_rounded),
            label: const Text("DESCARGAR PDF (3MB)"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
          )
        ],
      ),
    );
  }
}

class _BrandsSection extends StatelessWidget {
  final bool isMobile;
  const _BrandsSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 100),
      width: double.infinity,
      child: Column(
        children: [
          Text("TRABAJAMOS CON LAS MEJORES MARCAS", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 50),
          const Wrap(
            spacing: 60,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _BrandText("Pedrollo"),
              _BrandText("Vogt"),
              _BrandText("Reggio"),
              _BrandText("Siemens"),
              _BrandText("Schneider"),
              _BrandText("Bestflow"),
              _BrandText("Espa"),
              _BrandText("Wilo"),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertificationsBar extends StatelessWidget {
  final bool isMobile;
  const _CertificationsBar({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1F5F9), // Gris muy claro
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Wrap(
        spacing: 50,
        runSpacing: 25,
        alignment: WrapAlignment.center,
        children: [
          _CertBadge("SEC Certificado", Icons.bolt_rounded),
          _CertBadge("Cumplimiento SISS", Icons.water_damage_rounded),
          _CertBadge("ISO 9001 (Procesos)", Icons.verified_rounded),
          _CertBadge("Autorización Seremi", Icons.health_and_safety_rounded),
        ],
      ),
    );
  }
}

class _BlogSection extends StatelessWidget {
  final bool isMobile;
  const _BlogSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    final articles = [
      {
        "title": "Variadores de Frecuencia: ¿Gasto o Inversión?",
        "date": "15 Dic, 2025",
        "snippet": "Reduzca su factura eléctrica hasta un 40%.",
        "fullText": "Los Variadores de Frecuencia (VDF) permiten que las bombas operen a la velocidad exacta requerida por la demanda del edificio, en lugar de funcionar siempre al 100% de potencia. Esto no solo genera un ahorro energético inmediato de entre un 30% y 40%, sino que elimina los 'golpes de ariete' mecánicos, extendiendo la vida útil de tuberías y sellos en un 50%."
      },
      {
        "title": "Nueva Normativa de Aguas Grises",
        "date": "10 Dic, 2025",
        "snippet": "Análisis de la Ley 21.075 y su impacto.",
        "fullText": "La Ley 21.075 regula la recolección y reutilización de aguas grises (provenientes de duchas y lavamanos) para uso en riego y descarga de inodoros. Para los nuevos proyectos inmobiliarios, adaptar la infraestructura sanitaria para separar estas aguas no solo es una tendencia ecológica, sino una exigencia normativa creciente que valoriza la propiedad."
      },
      {
        "title": "Cavitación: El enemigo silencioso",
        "date": "05 Dic, 2025",
        "snippet": "Cómo detectar ruidos extraños a tiempo.",
        "fullText": "La cavitación ocurre cuando la presión del agua cae por debajo de su presión de vapor, formando burbujas que implosionan violentamente contra los impulsores de la bomba. Esto suena como si bombeara 'grava' o piedras. Si no se corrige ajustando la altura de aspiración (NPSH), la bomba puede destruirse internamente en cuestión de semanas."
      },
    ];
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 100),
      child: Column(
        children: [
          Text("NOTICIAS Y RECURSOS", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 60),
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: articles.map((a) => _BlogCard(title: a['title']!, date: a['date']!, snippet: a['snippet']!, fullText: a['fullText']!)).toList(),
          )
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final bool isMobile;
  const _FaqSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 150),
      child: Column(
        children: [
          Text("PREGUNTAS FRECUENTES", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 50),
          const _FaqItem("¿Cada cuánto tiempo se deben lavar los estanques?", "Según el D.S. 735, los estanques de agua potable deben lavarse y sanitizarse al menos dos veces al año (cada 6 meses)."),
          const _FaqItem("¿Atienden emergencias de noche o fines de semana?", "Sí. Nuestro equipo técnico está disponible 24/7 para emergencias críticas como inundaciones o cortes de agua."),
          const _FaqItem("¿Qué garantía tienen los trabajos de instalación?", "Todas nuestras instalaciones cuentan con garantía legal y ofrecemos planes de mantención extendida para asegurar la vida útil."),
          const _FaqItem("¿Entregan certificado para la Seremi?", "Absolutamente. Al finalizar la sanitización, entregamos un certificado válido para fiscalizaciones y auditorías."),
          const _FaqItem("¿Qué formas de pago aceptan?", "Aceptamos transferencias electrónicas, vale vista y facilidades de pago para comunidades (previa evaluación comercial)."),
          const _FaqItem("¿Realizan visitas a terreno fuera de Santiago?", "Sí, realizamos proyectos e instalaciones en todo Chile. Para servicios de mantención recurrente, nuestra cobertura principal es la Región Metropolitana."),
        ],
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  final bool isMobile;
  const _TestimonialsSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 100),
      child: Column(
        children: [
          Text("LO QUE DICEN NUESTROS CLIENTES", style: AppTextStyles.h2.copyWith(color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 60),
          const Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _TestimonialCard("Marco Antonio", "Administrador Edificio Ñuñoa", "Gracias a la modernización con VDF, bajamos la cuenta de luz en un 35%. Excelente asesoría técnica."),
              _TestimonialCard("Claudia Soto", "Gerente Operaciones Industrial", "La respuesta ante nuestra emergencia de inundación fue en menos de 2 horas. Servicio 100% recomendado."),
              _TestimonialCard("Jorge Pizarro", "Comité de Administración", "El informe mensual que envían es muy detallado. Por fin entendemos el estado real de nuestras bombas."),
            ],
          )
        ],
      ),
    );
  }
}

// ==========================================
// 6. COMPONENTES PEQUEÑOS Y HELPERS UI
// ==========================================

class _InteractiveCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;
  final bool isMobile;
  const _InteractiveCard({required this.icon, required this.title, required this.desc, required this.onTap, required this.isMobile});

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}
class _InteractiveCardState extends State<_InteractiveCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.isMobile ? double.infinity : 350,
          padding: const EdgeInsets.all(40),
          transform: Matrix4.translationValues(0, _isHovered ? -12 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHovered ? AppColors.accent : Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? AppColors.accent.withOpacity(0.15) : AppColors.dark.withOpacity(0.06),
                blurRadius: _isHovered ? 30 : 20,
                offset: const Offset(0, 10)
              )
            ]
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: (_isHovered ? AppColors.accent : AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle
                ),
                child: Icon(widget.icon, size: 40, color: _isHovered ? AppColors.accent : AppColors.primary),
              ),
              const SizedBox(height: 25),
              Text(widget.title, style: AppTextStyles.h3, textAlign: TextAlign.center),
              const SizedBox(height: 15),
              Text(widget.desc, style: AppTextStyles.body, textAlign: TextAlign.center),
              const SizedBox(height: 25),
              const Text("Leer más detalles →", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedStatItem extends StatelessWidget {
  final double endValue;
  final String label;
  final String symbol;
  const _AnimatedStatItem({required this.endValue, required this.label, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: endValue),
        duration: const Duration(seconds: 2),
        curve: Curves.easeOutExpo,
        builder: (context, value, child) {
          return Text(
            "${symbol.isEmpty ? '' : symbol}${value.toInt()}${symbol.isNotEmpty ? '' : symbol}",
            style: GoogleFonts.montserrat(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white)
          );
        },
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
    ]);
  }
}

class _SoftwareRowItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SoftwareRowItem(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        )
      ],
    );
  }
}

class _TechBenefit extends StatelessWidget {
  final String title;
  final String desc;
  const _TechBenefit(this.title, this.desc);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.check, color: AppColors.accent),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ProjectCarouselCard extends StatelessWidget {
  final String image;
  final String title;
  final String desc;
  final bool isMobile;
  const _ProjectCarouselCard({required this.image, required this.title, required this.desc, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            safeNetworkImage(image),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)]
                )
              )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3.copyWith(color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(desc, style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9))),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final String step;
  final String title;
  final String desc;
  final IconData icon;
  const _WorkflowStep(this.step, this.title, this.desc, this.icon);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200)
          ),
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 20),
        Text(step, style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.grey.shade200)),
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 10),
        Text(desc, textAlign: TextAlign.center, style: AppTextStyles.body),
      ]),
    );
  }
}

class _BrandText extends StatelessWidget {
  final String text;
  const _BrandText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.playfairDisplay(fontSize: 28, color: Colors.grey[400], fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
  }
}

class _CertBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CertBadge(this.label, this.icon);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.grey[500], size: 28),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 16))
    ]);
  }
}

class _BlogCard extends StatefulWidget {
  final String title;
  final String date;
  final String snippet;
  final String fullText;
  const _BlogCard({required this.title, required this.date, required this.snippet, required this.fullText});
  @override
  State<_BlogCard> createState() => _BlogCardState();
}
class _BlogCardState extends State<_BlogCard> {
  bool _hover = false;
  void _showArticle(BuildContext context) {
    showDialog(context: context, builder: (context) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), child: Container(width: 600, padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.date, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(widget.title, style: AppTextStyles.h2.copyWith(fontSize: 24)),
      const SizedBox(height: 20),
      const Divider(color: AppColors.accent),
      const SizedBox(height: 20),
      Flexible(child: SingleChildScrollView(child: Text(widget.fullText, style: AppTextStyles.body.copyWith(fontSize: 18)))),
      const SizedBox(height: 30),
      Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text("Cerrar", style: TextStyle(color: Colors.white))))
    ]))));
  }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: () => _showArticle(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 320,
          padding: const EdgeInsets.all(30),
          transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _hover ? AppColors.accent : Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: _hover ? 25 : 10, offset: const Offset(0,5))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.date, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(widget.title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 15),
            Text(widget.snippet, style: AppTextStyles.body.copyWith(fontSize: 14)),
            const SizedBox(height: 25),
            Text("Leer artículo completo →", style: TextStyle(color: _hover ? AppColors.accent : AppColors.primary, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.h3.copyWith(fontSize: 16)), 
        iconColor: AppColors.primary,
        childrenPadding: const EdgeInsets.all(25),
        children: [Text(answer, style: AppTextStyles.body)]
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String text;
  const _TestimonialCard(this.name, this.role, this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded, size: 40, color: AppColors.accent),
          const SizedBox(height: 20),
          Text(text, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 25),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 15),
          Text(name, style: AppTextStyles.h3.copyWith(fontSize: 16)),
          Text(role, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _HoverButton({required this.text, required this.onTap});
  @override
  State<_HoverButton> createState() => _HoverButtonState();
}
class _HoverButtonState extends State<_HoverButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 22),
          decoration: BoxDecoration(
            color: _hover ? AppColors.dark : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]
          ),
          child: Text(
            widget.text, 
            style: TextStyle(fontWeight: FontWeight.bold, color: _hover ? Colors.white : AppColors.primary, letterSpacing: 1)
          ),
        ),
      ),
    );
  }
}

class _ServiceDetailSection extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isMobile;
  const _ServiceDetailSection(this.service, this.isMobile);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 60),
      padding: const EdgeInsets.all(50),
      decoration: modernDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(service['image'] as IconData, size: 40, color: AppColors.primary)),
              const SizedBox(width: 25),
              Expanded(child: Text(service['title'] as String, style: AppTextStyles.h2.copyWith(fontSize: 24))),
            ],
          ),
          const SizedBox(height: 30),
          Text(service['description'] as String, style: AppTextStyles.body.copyWith(fontSize: 18), textAlign: TextAlign.justify),
          const SizedBox(height: 40),
          const Text("DETALLE DE ACTIVIDADES:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 14, letterSpacing: 1)),
          const SizedBox(height: 20),
          ...(service['checklist'] as List<String>).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: AppTextStyles.body)),
              ],
            ),
          )),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, _createRoute(const ContactPage())),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("SOLICITAR ESTE SERVICIO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class _ProjectDetailCard extends StatelessWidget {
  final String title;
  final String desc;
  final bool isMobile;
  final BuildContext context;
  const _ProjectDetailCard(this.title, this.desc, this.isMobile, this.context);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(35),
      decoration: modernDecoration(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
          const SizedBox(height: 15),
          Text(desc, style: AppTextStyles.body),
          const SizedBox(height: 25),
          InkWell(
            onTap: () => Navigator.push(context, _createRoute(const ContactPage())),
            child: const Row(
              children: [
                Text("Cotizar Proyecto", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: AppColors.accent)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _ValueCard(this.icon, this.title, this.desc);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(25),
      decoration: modernDecoration(color: Colors.white),
      child: Column(
        children: [
          Icon(icon, size: 45, color: AppColors.primary),
          const SizedBox(height: 15),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 10),
          Text(desc, textAlign: TextAlign.center, style: AppTextStyles.body)
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  final bool isMobile;
  const _TeamSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 100),
      child: Column(
        children: [
          Text("NUESTRO EQUIPO EXPERTO", style: AppTextStyles.h2),
          const SizedBox(height: 60),
          const Wrap(
            spacing: 50,
            runSpacing: 50,
            alignment: WrapAlignment.center,
            children: [
              _TeamMemberCard("Alonso Matilla", "Gerente General", "Ingeniero Civil con 15 años liderando proyectos hidráulicos."),
              _TeamMemberCard("Jefe de Operaciones", "Ingeniería en Terreno", "Especialista en sistemas VDF y automatización industrial."),
              _TeamMemberCard("Equipo Técnico", "Certificados SEC", "Personal calificado para intervenciones de alto riesgo."),
            ],
          )
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String bio;
  const _TeamMemberCard(this.name, this.role, this.bio);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(30),
      decoration: modernDecoration(),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            child: Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(name, style: AppTextStyles.h3),
          const SizedBox(height: 5),
          Text(role, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(bio, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ContactTile extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _ContactTile(this.icon, this.text, this.onTap);
  @override
  State<_ContactTile> createState() => _ContactTileState();
}
class _ContactTileState extends State<_ContactTile> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 250,
          padding: const EdgeInsets.all(30),
          transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
          decoration: BoxDecoration(
            color: _hover ? AppColors.primary : Colors.white, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: _hover ? 20 : 0)]
          ),
          child: Column(children: [Icon(widget.icon, color: _hover ? Colors.white : AppColors.primary, size: 35), const SizedBox(height: 20), Text(widget.text, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: _hover ? Colors.white : null))]),
        ),
      ),
    );
  }
}

// ==========================================
// 7. NAVEGACIÓN GLOBAL Y FOOTER
// ==========================================

class WebNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String activePage;
  const WebNavBar({super.key, required this.activePage});
  @override
  Size get preferredSize => const Size.fromHeight(90); // Más altura para elegancia
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
      ),
      child: AppBar(
        backgroundColor: Colors.transparent, // Fondo transparente para ver el border
        elevation: 0,
        titleSpacing: isMobile ? 0 : 60,
        toolbarHeight: 90,
        title: InkWell(
          onTap: () => Navigator.pushReplacement(context, _createRoute(const LandingPage())),
          child: Image.asset('assets/images/logo_aquater.png', height: 50, errorBuilder: (c,e,s)=>const SizedBox()),
        ),
        actions: isMobile 
          ? [IconButton(icon: const Icon(Icons.menu_rounded, color: AppColors.dark, size: 30), onPressed: () => Scaffold.of(context).openDrawer())]
          : [
              _NavLink("Inicio", const LandingPage(), activePage == "Inicio", context),
              _NavLink("Servicios", const ServicesPage(), activePage == "Servicios", context),
              _NavLink("Glosario", const GlossaryPage(), activePage == "Glosario", context),
              _NavLink("Nosotros", const AboutPage(), activePage == "Nosotros", context),
              _NavLink("Contacto", const ContactPage(), activePage == "Contacto", context),
              const SizedBox(width: 30),
              ElevatedButton(
                onPressed: () => Navigator.push(context, _createRoute(const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  foregroundColor: Colors.white, 
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                child: const Text("ACCESO CLIENTES", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 60),
            ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String text;
  final Widget page;
  final bool isActive;
  final BuildContext context;
  const _NavLink(this.text, this.page, this.isActive, this.context);
  @override
  State<_NavLink> createState() => _NavLinkState();
}
class _NavLinkState extends State<_NavLink> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextButton(
          onPressed: () { if(!widget.isActive) Navigator.pushReplacement(widget.context, _createRoute(widget.page)); },
          style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.text, style: TextStyle(
                color: widget.isActive ? AppColors.primary : (_hover ? AppColors.accent : Colors.grey[600]), 
                fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 15)
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3, 
                width: (_hover || widget.isActive) ? 25 : 0, 
                color: AppColors.primary, 
                margin: const EdgeInsets.only(top: 6)
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context); 
    Navigator.pushReplacement(context, _createRoute(page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: ListView(padding: EdgeInsets.zero, children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: AppColors.primary),
        child: Center(child: Text("AQUATER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white, letterSpacing: 2)))
      ),
      ListTile(leading: const Icon(Icons.home_rounded), title: const Text("Inicio"), onTap: () => _navigate(context, const LandingPage())),
      ListTile(leading: const Icon(Icons.build_rounded), title: const Text("Servicios"), onTap: () => _navigate(context, const ServicesPage())),
      ListTile(leading: const Icon(Icons.menu_book_rounded), title: const Text("Glosario"), onTap: () => _navigate(context, const GlossaryPage())),
      ListTile(leading: const Icon(Icons.groups_rounded), title: const Text("Nosotros"), onTap: () => _navigate(context, const AboutPage())),
      ListTile(leading: const Icon(Icons.phone_rounded), title: const Text("Contacto"), onTap: () => _navigate(context, const ContactPage())),
    ]));
  }
}

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.dark,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/images/logo_aquater.png', height: 40, color: Colors.white, errorBuilder: (c,e,s)=>const SizedBox()),
          ]),
          const SizedBox(height: 30),
          const Text("Eliodoro Yañez 1568, Providencia, RM.", style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 15),
          const Text("+56 9 9322 1797  |  alonso.matilla@aquater.cl", style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 60),
          const Divider(color: Colors.white12),
          const SizedBox(height: 30),
          const Text("© 2025 Aquater Ltda. Todos los derechos reservados.", style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }
}

class WhatsAppButton extends StatelessWidget {
  const WhatsAppButton({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        if (!await launchUrl(Uri.parse('https://wa.me/56993221797'))) throw Exception('Error WhatsApp');
      },
      heroTag: "btnWhatsapp",
      backgroundColor: AppColors.success,
      elevation: 5,
      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
      label: const Text("WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class SosButton extends StatelessWidget {
  const SosButton({super.key});

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 30),
            SizedBox(width: 10),
            Text("Protocolo de Emergencia")
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Antes de llamar, por favor verifique:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Text("1. ¿Ha cortado el suministro eléctrico del tablero?"),
            Text("2. ¿Ha cerrado la llave de paso general?"),
            Text("3. ¿Hay riesgo inminente para las personas?"),
            SizedBox(height: 25),
            Text("Nuestros técnicos están listos para ayudarle.", style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              if (!await launchUrl(Uri.parse('tel:+56993221797'))) throw Exception('Error SOS');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white, elevation: 0),
            icon: const Icon(Icons.phone),
            label: const Text("LLAMAR AHORA"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showEmergencyDialog(context),
      heroTag: "btnSOS",
      backgroundColor: AppColors.danger,
      elevation: 5,
      icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
      label: const Text("EMERGENCIA 24/7", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2500.ms, color: Colors.white.withOpacity(0.4));
  }
}

Widget _PageHeader({required String title, required String subtitle}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))) // Borde sutil inferior
    ),
    child: Column(children: [
      Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
      const SizedBox(height: 15),
      Text(subtitle, style: AppTextStyles.body, textAlign: TextAlign.center),
    ]),
  );
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
// --- PEGAR ESTO AL FINAL DE lib/web/landing_page.dart ---

class _ProjectsSection extends StatelessWidget {
  final bool isMobile;
  const _ProjectsSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 100),
      child: Column(
        children: [
          Text("PROYECTOS DE INGENIERÍA", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          const Text(
            "Además de la mantención, diseñamos y ejecutamos obras nuevas.", 
            style: TextStyle(fontSize: 18, color: Colors.grey), 
            textAlign: TextAlign.center
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _ProjectDetailCard(
                "Equipos de Impulsión", 
                "Instalación en todo Chile. Automatización avanzada, tableros y motobombas de calidad. Revisamos sus proyectos para mejorar eficiencia.", 
                isMobile, 
                context
              ),
              _ProjectDetailCard(
                "Instalación Sanitaria", 
                "Sistemas completos de agua potable, alcantarillado, gas y redes de incendio. Cumplimiento estricto de normativa RIDAA.", 
                isMobile, 
                context
              ),
              _ProjectDetailCard(
                "Climatización e Hidráulica", 
                "Plantas de tratamiento y osmosis inversa. Trabajamos de la mano con constructoras y arquitectos.", 
                isMobile, 
                context
              ),
            ],
          )
        ],
      ),
    );
  }
}
