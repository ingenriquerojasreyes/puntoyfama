import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Sin sesión', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF534AB7)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No se encontraron datos', style: TextStyle(color: Colors.white54)),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final alias = data['alias'] ?? 'jugador';
          final plan = data['plan'] ?? 'free';
          final puntosMes = data['puntos_mes'] ?? 0;
          final puntosTotales = data['puntos_totales'] ?? 0;
          final partidasJugadas = data['partidas_jugadas'] ?? 0;
          final partidasGanadas = data['partidas_ganadas'] ?? 0;
          final porcentajeExito = partidasJugadas == 0
              ? 0.0
              : (partidasGanadas / partidasJugadas) * 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26215C),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: const Color(0xFF534AB7), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            alias.isNotEmpty ? alias[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Color(0xFFEEEDFE),
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        alias,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26215C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plan.toUpperCase(),
                          style: const TextStyle(color: Color(0xFF534AB7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF26215C), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Puntos del mes', style: TextStyle(color: Colors.white54, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '$puntosMes',
                        style: const TextStyle(color: Color(0xFF534AB7), fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Puntos totales', valor: '$puntosTotales', icono: Icons.star)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: '% Éxito', valor: '${porcentajeExito.toStringAsFixed(0)}%', icono: Icons.emoji_events)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Jugadas', valor: '$partidasJugadas', icono: Icons.grid_on)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Ganadas', valor: '$partidasGanadas', icono: Icons.check_circle)),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF534AB7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Mejorar a PLUS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;

  const _StatCard({required this.label, required this.valor, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: const Color(0xFF534AB7), size: 20),
          const SizedBox(height: 8),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}