import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final miUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rankings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .orderBy('puntos_mes', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {

          // =============================================
          // PASO 4 - MANEJO DE ERROR DE FIREBASE
          // =============================================

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: Colors.white54,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No se pudo cargar el ranking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Comprueba tu conexión e intenta nuevamente.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF534AB7),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Sin jugadores aún',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;

              final uid = docs[index].id;

              final alias =
                  data['alias'] ?? '???';

              final puntosMes =
                  data['puntos_mes'] ?? 0;

              final plan =
                  data['plan'] ?? 'free';

              final esMio =
                  uid == miUid;

              final posicion =
                  index + 1;

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: esMio
                      ? const Color(0xFF26215C)
                      : const Color(0xFF0D0D0D),
                  border: Border.all(
                    color: esMio
                        ? const Color(0xFF534AB7)
                        : Colors.white12,
                    width: esMio ? 2 : 1,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        posicion <= 3
                            ? [
                                '🥇',
                                '🥈',
                                '🥉'
                              ][posicion - 1]
                            : '#$posicion',
                        style: TextStyle(
                          color: posicion <= 3
                              ? Colors.white
                              : Colors.white54,
                          fontSize:
                              posicion <= 3
                                  ? 22
                                  : 14,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF534AB7),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          alias.isNotEmpty
                              ? alias[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            alias,
                            style: TextStyle(
                              color: esMio
                                  ? const Color(
                                      0xFFEEEDFE,
                                    )
                                  : Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            plan.toUpperCase(),
                            style: const TextStyle(
                              color:
                                  Colors.white38,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '$puntosMes pts',
                      style: const TextStyle(
                        color:
                            Color(0xFF534AB7),
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}