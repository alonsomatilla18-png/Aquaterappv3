import 'package:flutter/material.dart';
import '../../models/informe_model.dart';

class BombasForm extends StatefulWidget {
  final List<DetalleMantencionBomba> detallesBombas;
  // Callback para avisar al padre que algo cambió
  final VoidCallback onUpdate; 

  const BombasForm({
    super.key,
    required this.detallesBombas,
    required this.onUpdate,
  });

  @override
  State<BombasForm> createState() => _BombasFormState();
}

class _BombasFormState extends State<BombasForm> {
  // Mapa para controlar qué tarjeta está abierta
  final Map<int, bool> _expansionStates = {};

  @override
  Widget build(BuildContext context) {
    if (widget.detallesBombas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text("Selecciona una Sede para cargar equipos.", 
          style: TextStyle(color: Colors.grey, fontSize: 16))
        ),
      );
    }

    return Column(
      children: widget.detallesBombas.asMap().entries.map((entry) {
        int idx = entry.key;
        DetalleMantencionBomba b = entry.value;
        bool esTablero = b.tipoBomba.startsWith('ta');
        bool isExpanded = _expansionStates[idx] ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: esTablero ? Colors.indigo.shade100 : Colors.blue.shade100, 
              width: 1
            ),
            borderRadius: BorderRadius.circular(16)
          ),
          child: ExpansionTile(
            key: ObjectKey(b), // Mantiene la identidad del objeto
            initiallyExpanded: isExpanded,
            onExpansionChanged: (v) => setState(() => _expansionStates[idx] = v),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: esTablero ? Colors.indigo[50] : Colors.white,
            title: Text(b.nombreEquipo, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, 
              color: esTablero ? Colors.indigo[800] : Colors.blue[800])),
            subtitle: Text(b.ubicacion ?? "Ubicación General", 
              style: TextStyle(color: Colors.grey[700])),
            leading: CircleAvatar(
              backgroundColor: esTablero ? Colors.indigo[100] : Colors.blue[100],
              child: Icon(esTablero ? Icons.electrical_services : Icons.water_drop, 
                color: esTablero ? Colors.indigo : Colors.blue)
            ),
            childrenPadding: const EdgeInsets.all(20),
            children: [
              _buildFormularioInterno(b),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text("LISTO / CERRAR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    setState(() => _expansionStates[idx] = false);
                    widget.onUpdate(); 
                  }
                )
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  // Lógica interna del formulario de bombas
  Widget _buildFormularioInterno(DetalleMantencionBomba b) {
    if(b.tipoBomba=='bom') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('CHEQUEO MECÁNICO'),
          _chk(b, 'mec_1', '1. Inspección visual, fugas sello mecánico', siNo: true), 
          _chk(b, 'mec_2', '2. Temperatura cuerpo bomba (ºC)', input: true),
          _chk(b, 'mec_3', '3. Ruidos, vibraciones, pintura', prob: true),
          _chk(b, 'mec_4', '4. Llaves, válvulas y sensores', prob: true),
          _chk(b, 'mec_5', '5. Sistema de llenado estanques', prob: true),
          const SizedBox(height: 20), _sectionTitle('DATOS ELÉCTRICOS'), _elec(b)
      ]);
    }
    
    // TABLEROS (Simplificado para cubrir todos los tipos de tableros)
    if(b.tipoBomba.startsWith('ta')) {
       return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('CHEQUEO ELÉCTRICO'),
          _chk(b, 'elec_1', '1. Circuitos eléctricos fuerza/control'), 
          _chk(b, 'elec_2', '2. Limpieza y ajuste de comandos'),
          _chk(b, 'elec_3', '3. Contactores, presostatos, variadores'), 
          _chk(b, 'elec_4', '4. Estado conexiones y cableado'),
          _chk(b, 'elec_5', '5. Alarmas y sistemas de bloqueo'), 
          if(b.tipoBomba=='tabom') ...[
             _chk(b, 'elec_6', '6. Presión aire estanques hidroneumáticos'),
             _chk(b, 'elec_7', '7. Flexibles y juntas elásticas')
          ],
          if(b.tipoBomba=='taser') _chk(b, 'elec_6', '6. Revisión visual fosa (nivel/suciedad)'),
       ]);
    }

    // GENERIÁ (Cualquier otro equipo)
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('DATOS GENERALES'),
        _chk(b,'mec_1','1. Inspección operativa general (ruidos, estado)'),
        const SizedBox(height: 20),
        _sectionTitle('DATOS ELÉCTRICOS'), _elec(b)
    ]);
  }

  Widget _sectionTitle(String title) => Container(
    margin: const EdgeInsets.only(bottom: 15), 
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), 
    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), 
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))
  );

  Widget _elec(DetalleMantencionBomba b) { 
    return Column(children: [
      const Text("AMPERAJE (A)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      Row(children: [Expanded(child:_num("R",(v)=>b.ampR=d(v), b.ampR)), const SizedBox(width:5), Expanded(child:_num("S",(v)=>b.ampS=d(v), b.ampS)), const SizedBox(width:5), Expanded(child:_num("T",(v)=>b.ampT=d(v), b.ampT))]),
      const SizedBox(height: 10),
      const Text("VOLTAJE (V)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      Row(children: [Expanded(child:_num("R-T",(v)=>b.voltRT=d(v), b.voltRT)), const SizedBox(width:5), Expanded(child:_num("S-T",(v)=>b.voltST=d(v), b.voltST)), const SizedBox(width:5), Expanded(child:_num("R-S",(v)=>b.voltRS=d(v), b.voltRS))])
    ]); 
  }
  
  // CORRECCIÓN IMPORTANTE: Reemplazar comas por puntos para que funcionen los decimales
  double d(String v) {
    String limpio = v.replaceAll(',', '.');
    return double.tryParse(limpio) ?? 0;
  }
  
  Widget _num(String l, Function(String) f, double i) => TextFormField(
    initialValue: i==0 ? "" : i.toString().replaceAll('.', ','), // Muestra comas al usuario si hay valor
    keyboardType: const TextInputType.numberWithOptions(decimal: true), 
    decoration: InputDecoration(labelText: l, isDense: true), 
    onChanged: (val) {
      f(val); // Guarda el valor en el objeto
      // No hacemos setState aquí para no redibujar a cada tecla y perder el foco,
      // pero el objeto 'b' ya quedó actualizado por referencia.
    }
  );

  Widget _chk(DetalleMantencionBomba b, String k, String l, {bool input=false, bool siNo=false, bool prob=false}) {
     if (!b.checklist.containsKey(k)) b.checklist[k] = {'estado': '', 'obs': ''};
     
     String? val = b.checklist[k]!['estado']; 
     if (val == '') val = null;

     // Listas de opciones
     List<String> opciones = ["OK", "Malo", "N/A"];
     if(siNo) opciones = ["Si", "No", "N/A"];
     if(prob) opciones = ["Sin problemas", "Con problemas", "N/A"];

     return Padding(padding: const EdgeInsets.only(bottom: 10.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Text(l, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
       const SizedBox(height: 5),
       Row(children: [
         Expanded(
           flex: 3, 
           child: input 
           ? TextFormField(
               initialValue: b.checklist[k]!['estado'], 
               decoration: const InputDecoration(labelText: 'Valor', isDense: true), 
               onChanged:(v) => b.checklist[k]!['estado'] = v
             ) 
           : DropdownButtonFormField<String>(
               initialValue: val, 
               isExpanded: true, 
               decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
               hint: const Text("Select..."),
               items: opciones.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12)))).toList(), 
               onChanged:(v) {
                 setState(() {
                   b.checklist[k]!['estado'] = v ?? "";
                 });
               }
             )
         ),
         const SizedBox(width:10),
         Expanded(
           flex: 4, 
           child: TextFormField(
             initialValue: b.checklist[k]!['obs'], 
             decoration: const InputDecoration(labelText: 'Obs', isDense: true), 
             onChanged:(v) => b.checklist[k]!['obs'] = v
           )
         )
       ])
     ])); 
  }
}