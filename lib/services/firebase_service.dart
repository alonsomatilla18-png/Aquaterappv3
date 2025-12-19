import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/informe_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String coleccionInformes = 'informes';

  // Guardar un informe nuevo
  Future<void> guardarInforme(InformeBase informe) async {
    try {
      DocumentReference ref = _db.collection(coleccionInformes).doc();
      informe.id = ref.id;
      informe.estado = 'enviado'; 
      await ref.set(informe.toMap());
      print("✅ Informe guardado: ${ref.id}");
    } catch (e) {
      print("❌ Error guardando: $e");
      rethrow;
    }
  }

  // --- NUEVO: Actualizar un informe existente ---
  Future<void> actualizarInforme(InformeBase informe) async {
    try {
      if (informe.id == null) throw Exception("El informe no tiene ID para editar");
      
      DocumentReference ref = _db.collection(coleccionInformes).doc(informe.id);
      
      // Actualizamos los datos manteniendo el ID original
      await ref.update(informe.toMap());
      print("🔄 Informe actualizado: ${informe.id}");
    } catch (e) {
      print("❌ Error actualizando: $e");
      rethrow;
    }
  }
}