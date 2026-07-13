import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _aliasController = TextEditingController();
  bool _cargando = false;
  String? _error;

  bool _esAliasValido(String alias) {
    final regex = RegExp(r'^[a-zA-Z0-9]{4,15}$');
    return regex.hasMatch(alias);
  }

  Future<void> _registrar() async {
    final alias = _aliasController.text.trim();

    if (!_esAliasValido(alias)) {
      setState(() => _error = 'Entre 4 y 15 caracteres, solo letras y números');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // 1. Verificar que el alias no exista
      final query = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('alias', isEqualTo: alias)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _error = 'Ese alias ya está en uso, elige otro';
          _cargando = false;
        });
        return;
      }

      // 2. Crear usuario anónimo en Firebase Auth
      final credential =
          await FirebaseAuth.instance.signInAnonymously();
      final uid = credential.user!.uid;

      // 3. Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set({
        'alias': alias,
        'puntos_mes': 0,
        'puntos_totales': 0,
        'partidas_jugadas': 0,
        'partidas_ganadas': 0,
        'plan': 'free',
        'created_at': FieldValue.serverTimestamp(),
      });

      // 4. Ir al Home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error al registrar. Intenta de nuevo.';
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'NUMLE',
                style: TextStyle(
                  color: Color(0xFF534AB7),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elige tu alias para comenzar',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _aliasController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                maxLength: 15,
                decoration: InputDecoration(
                  hintText: 'tu_alias',
                  hintStyle: const TextStyle(color: Colors.white24),
                  counterStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF534AB7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF534AB7), width: 2),
                  ),
                  errorText: _error,
                  errorStyle: const TextStyle(color: Color(0xFF854F0B)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '4 a 15 caracteres · solo letras y números',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF534AB7),
                    disabledBackgroundColor: const Color(0xFF26215C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'COMENZAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
              ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}