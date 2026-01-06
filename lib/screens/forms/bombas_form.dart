import 'package:flutter/material.dart';
import '../../models/informe_model.dart';
import '../../widgets/custom_input.dart';

class BombasForm extends StatefulWidget {
  final List<DetalleMantencionBomba> detallesBombas;
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
  @override
  Widget build(BuildContext context) {
    if (widget.detallesBombas.isEmpty) {
      return const Center(child: Text("No hay equipos configurados para esta sede.", style: TextStyle(fontStyle: FontStyle.italic)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detalle de Equipos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 10),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), 
          itemCount: widget.detallesBombas.length,
          itemBuilder: (context, index) {
            final equipo = widget.detallesBombas[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                title: Text(equipo.nombreEquipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(equipo.ubicacion ?? "Sin ubicación", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                leading: Icon(_getIcono(equipo.tipoBomba), color: Colors.blue[800]),
                childrenPadding: const EdgeInsets.all(15),
                children: [
                  _buildFormularioEquipo(equipo),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIcono(String tipo) {
    if (tipo.contains('tab')) return Icons.electric_bolt;
    if (tipo == 'grasa') return Icons.water_drop_outlined;
    return Icons.settings_applications;
  }

  Widget _buildFormularioEquipo(DetalleMantencionBomba equipo) {
    // Si es tablero
    if (equipo.tipoBomba.startsWith('ta')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chequeo Eléctrico y Control", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const Divider(),
          _chk(equipo, 'elec_1', '1. Circuitos de fuerza y control'),
          _chk(equipo, 'elec_2', '2. Limpieza/Ajuste comandos'),
          _chk(equipo, 'elec_3', '3. Contactores/Presóstatos/Variadores'),
          _chk(equipo, 'elec_4', '4. Estado conexiones y cableado'),
          _chk(equipo, 'elec_5', '5. Alarmas y bloqueos'),
          if(equipo.tipoBomba == 'tabom') ...[
            _chk(equipo, 'elec_6', '6. Presión aire estanque hidroneum.'),
            _chk(equipo, 'elec_7', '7. Flexibles y juntas elásticas'),
          ],
          if(equipo.tipoBomba == 'taser') _chk(equipo, 'elec_6', '6. Nivel y suciedad de fosa'),
        ],
      );
    }

    // Si es bomba o genérico
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Inspección Mecánica e Hidráulica", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const Divider(),
        _chk(equipo, 'mec_1', '1. Inspección visual / fugas sello'),
        _chk(equipo, 'mec_2', '2. Temperatura cuerpo bomba'),
        _chk(equipo, 'mec_3', '3. Ruidos / Vibraciones / Pintura'),
        _chk(equipo, 'mec_4', '4. Llaves de paso / Válvulas'),
        _chk(equipo, 'mec_5', '5. Sistema llenado estanques'),
        
        const SizedBox(height: 15),
        const Text("Mediciones Eléctricas", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const Divider(),
        Row(
          children: [
            Expanded(child: CustomInput(label: 'Amp R', icon: Icons.bolt, keyboardType: TextInputType.number, initialValue: equipo.ampR == 0 ? '' : equipo.ampR.toString(), onChanged: (v) => equipo.ampR = double.tryParse(v) ?? 0)),
            const SizedBox(width: 5),
            Expanded(child: CustomInput(label: 'Amp S', icon: Icons.bolt, keyboardType: TextInputType.number, initialValue: equipo.ampS == 0 ? '' : equipo.ampS.toString(), onChanged: (v) => equipo.ampS = double.tryParse(v) ?? 0)),
            const SizedBox(width: 5),
            Expanded(child: CustomInput(label: 'Amp T', icon: Icons.bolt, keyboardType: TextInputType.number, initialValue: equipo.ampT == 0 ? '' : equipo.ampT.toString(), onChanged: (v) => equipo.ampT = double.tryParse(v) ?? 0)),
          ],
        ),
        Row(
          children: [
            Expanded(child: CustomInput(label: 'Volt R-T', icon: Icons.electrical_services, keyboardType: TextInputType.number, initialValue: equipo.voltRT == 0 ? '' : equipo.voltRT.toString(), onChanged: (v) => equipo.voltRT = double.tryParse(v) ?? 0)),
            const SizedBox(width: 5),
            Expanded(child: CustomInput(label: 'Volt S-T', icon: Icons.electrical_services, keyboardType: TextInputType.number, initialValue: equipo.voltST == 0 ? '' : equipo.voltST.toString(), onChanged: (v) => equipo.voltST = double.tryParse(v) ?? 0)),
            const SizedBox(width: 5),
            Expanded(child: CustomInput(label: 'Volt R-S', icon: Icons.electrical_services, keyboardType: TextInputType.number, initialValue: equipo.voltRS == 0 ? '' : equipo.voltRS.toString(), onChanged: (v) => equipo.voltRS = double.tryParse(v) ?? 0)),
          ],
        ),
      ],
    );
  }

  Widget _chk(DetalleMantencionBomba b, String k, String l, {bool input=false, bool siNo=false, bool prob=false}) {
      if (!b.checklist.containsKey(k)) b.checklist[k] = {'estado': '', 'obs': ''};
      
      List<String> opciones = ["OK", "Malo", "N/A"];
      if(siNo) opciones = ["Si", "No", "N/A"];
      if(prob) opciones = ["Sin problemas", "Con problemas", "N/A"];

      String? val = b.checklist[k]!['estado']; 
      if (val == '') val = null;

      // ✅ PROTECCIÓN: Si el valor de la BD no está en las opciones permitidas, reiniciar a null
      if (val != null && !input && !opciones.contains(val)) {
        val = null; 
      }

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
                hint: const Text("Seleccionar..."),
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