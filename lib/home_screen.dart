import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_screen.dart';
import 'perfil_screen.dart';
import 'ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nivel = 'Básico';
  String _modo = 'Normal';

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Cómo jugar?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Adivina el número secreto sin dígitos repetidos.',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 16),
              // Colores
              const Text('COLORES', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 8),
              _FilaAyuda(color: const Color(0xFF3B6D11), etiqueta: 'FAMA', descripcion: 'Dígito correcto en posición correcta'),
              const SizedBox(height: 6),
              _FilaAyuda(color: const Color(0xFF854F0B), etiqueta: 'PUNTO', descripcion: 'Dígito existe pero en otra posición'),
              const SizedBox(height: 6),
              _FilaAyuda(color: const Color(0xFF5F5E5A), etiqueta: 'NOPE', descripcion: 'Dígito no está en el número'),
              const SizedBox(height: 16),
              // Niveles
              const Text('NIVELES', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 8),
              _FilaNivel(nivel: 'Básico', cifras: '3 cifras', intentos: '7 intentos'),
              const SizedBox(height: 4),
              _FilaNivel(nivel: 'Medio', cifras: '4 cifras', intentos: '10 intentos'),
              const SizedBox(height: 4),
              _FilaNivel(nivel: 'Difícil', cifras: '5 cifras', intentos: '15 intentos'),
              const SizedBox(height: 16),
              // Modos
              const Text('MODOS', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text('Normal — ves los colores de cada intento.',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Row(children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF26215C), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Expanded(child: Text('Hardcore — todas las celdas son moradas, solo ves XF YP por fila.',
                    style: TextStyle(color: Colors.white70, fontSize: 13))),
              ]),
              const SizedBox(height: 16),
              // Puntos
              const Text('PUNTOS', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 8),
              _TablaPuntos(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Entendido!', style: TextStyle(color: Color(0xFF534AB7), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _mostrarAyuda(context),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('NUMLE', style: TextStyle(color: Color(0xFF534AB7), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8)),
              const SizedBox(height: 8),
              const Text('Puntos del mes', style: TextStyle(color: Colors.white54, fontSize: 14)),
              if (uid == null)
                const Text('0', style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold))
              else
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
                  builder: (context, snapshot) {
                    final pts = snapshot.hasData && snapshot.data!.exists
                        ? (snapshot.data!.data() as Map<String, dynamic>)['puntos_mes'] ?? 0
                        : 0;
                    return Text('$pts', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold));
                  },
                ),
              const Spacer(),
              const Text('Nivel', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: ['Básico', 'Medio', 'Difícil'].map((nivel) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Pill(label: nivel, activo: _nivel == nivel, onTap: () => setState(() => _nivel = nivel)),
                )).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Modo', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: ['Normal', 'Hardcore'].map((modo) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Pill(label: modo, activo: _modo == modo, onTap: () => setState(() => _modo = modo)),
                )).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(nivel: _nivel, modo: _modo))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF534AB7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('JUGAR', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaAyuda extends StatelessWidget {
  final Color color;
  final String etiqueta;
  final String descripcion;
  const _FilaAyuda({required this.color, required this.etiqueta, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52, height: 28,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text(etiqueta, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(descripcion, style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }
}

class _FilaNivel extends StatelessWidget {
  final String nivel;
  final String cifras;
  final String intentos;
  const _FilaNivel({required this.nivel, required this.cifras, required this.intentos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(nivel, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
        Text('$cifras · $intentos', style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }
}

class _TablaPuntos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const filas = [
      ['', 'Normal', 'Hardcore'],
      ['Básico', '100', '200'],
      ['Medio', '300', '600'],
      ['Difícil', '500', '1000'],
    ];
    return Table(
      border: TableBorder.all(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
      children: filas.map((fila) => TableRow(
        decoration: BoxDecoration(color: fila[0] == '' ? const Color(0xFF26215C) : null),
        children: fila.map((celda) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Text(celda, style: TextStyle(
            color: fila[0] == '' ? const Color(0xFF534AB7) : Colors.white70,
            fontSize: 12,
            fontWeight: fila[0] == '' ? FontWeight.bold : FontWeight.normal,
          ), textAlign: celda == '' ? TextAlign.left : TextAlign.center),
        )).toList(),
      )).toList(),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF26215C) : Colors.transparent,
          border: Border.all(color: const Color(0xFF534AB7)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          color: activo ? const Color(0xFFEEEDFE) : Colors.white54,
          fontWeight: activo ? FontWeight.bold : FontWeight.normal,
        )),
      ),
    );
  }
}