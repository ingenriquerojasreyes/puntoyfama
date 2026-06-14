import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final String nivel;
  final String modo;

  const GameScreen({
    super.key,
    required this.nivel,
    required this.modo,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int _cifras;
  late int _maxIntentos;
  late List<List<String>> _grid;
  late List<List<String>> _colores;
  int _intentoActual = 0;
  String _inputActual = '';
  late String _secreto;
  bool _juegoTerminado = false;

  @override
  void initState() {
    super.initState();
    _cifras = widget.nivel == 'Básico' ? 3 : widget.nivel == 'Medio' ? 4 : 5;
    _maxIntentos = widget.nivel == 'Básico' ? 7 : widget.nivel == 'Medio' ? 10 : 15;
    _grid = List.generate(_maxIntentos, (_) => List.filled(_cifras, ''));
    _colores = List.generate(_maxIntentos, (_) => List.filled(_cifras, 'vacio'));
    _secreto = _generarSecreto();
    debugPrint('Secreto: $_secreto');
  }

  String _generarSecreto() {
    final digitos = ['0','1','2','3','4','5','6','7','8','9'];
    digitos.shuffle();
    if (digitos[0] == '0') {
      final idx = digitos.indexWhere((d) => d != '0');
      final tmp = digitos[0];
      digitos[0] = digitos[idx];
      digitos[idx] = tmp;
    }
    return digitos.sublist(0, _cifras).join();
  }

  bool _tieneRepetidos(String intento) {
    return intento.length != intento.split('').toSet().length;
  }

  Map<int, String> _evaluar(String secreto, String intento) {
    final resultado = <int, String>{};
    for (int i = 0; i < _cifras; i++) {
      if (intento[i] == secreto[i]) {
        resultado[i] = 'fama';
      } else if (secreto.contains(intento[i])) {
        resultado[i] = 'punto';
      } else {
        resultado[i] = 'nope';
      }
    }
    return resultado;
  }

  void _onTecla(String valor) {
    if (_juegoTerminado) return;

    if (valor == 'DEL') {
      if (_inputActual.isNotEmpty) {
        setState(() => _inputActual = _inputActual.substring(0, _inputActual.length - 1));
      }
      return;
    }

    if (valor == 'OK') {
      if (_inputActual.length == _cifras) {
        if (_tieneRepetidos(_inputActual)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sin dígitos repetidos'),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFF854F0B),
            ),
          );
          return;
        }
        _enviarIntento();
      }
      return;
    }

    if (_inputActual.length < _cifras) {
      setState(() => _inputActual += valor);
    }
  }

  void _enviarIntento() {
    final resultado = _evaluar(_secreto, _inputActual);
    setState(() {
      for (int i = 0; i < _cifras; i++) {
        _grid[_intentoActual][i] = _inputActual[i];
        _colores[_intentoActual][i] = resultado[i]!;
      }
      _intentoActual++;
      _inputActual = '';
    });

    final gano = resultado.values.every((c) => c == 'fama');
    final perdio = _intentoActual >= _maxIntentos;

    if (gano || perdio) {
      _juegoTerminado = true;
      Future.delayed(const Duration(milliseconds: 400), () {
        _mostrarResultado(gano: gano);
      });
    }
  }

  void _mostrarResultado({required bool gano}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF26215C),
        title: Text(
          gano ? '¡Ganaste!' : 'Perdiste',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          gano
              ? '+${widget.modo == 'Normal' ? 50 : 100} puntos'
              : 'El número era $_secreto',
          style: const TextStyle(color: Color(0xFFEEEDFE), fontSize: 20),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Volver',
              style: TextStyle(color: Color(0xFF534AB7), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFondo(String estado) {
    switch (estado) {
      case 'fama': return const Color(0xFF3B6D11);
      case 'punto': return const Color(0xFF854F0B);
      case 'nope': return const Color(0xFF5F5E5A);
      case 'hardcore': return const Color(0xFF26215C);
      default: return Colors.transparent;
    }
  }

  Color _colorTexto(String estado) {
    switch (estado) {
      case 'fama': return const Color(0xFFEAF3DE);
      case 'punto': return const Color(0xFFFAEEDA);
      case 'nope': return const Color(0xFFF1EFE8);
      case 'hardcore': return const Color(0xFFEEEDFE);
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${widget.nivel} · ${widget.modo}',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _maxIntentos,
              itemBuilder: (_, fila) {
                final esFila = fila == _intentoActual && !_juegoTerminado;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_cifras, (col) {
                      final texto = esFila && col < _inputActual.length
                          ? _inputActual[col]
                          : _grid[fila][col];
                      final estado = _colores[fila][col];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _colorFondo(estado),
                          border: Border.all(
                            color: esFila
                                ? const Color(0xFF534AB7)
                                : estado == 'vacio'
                                    ? Colors.white24
                                    : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            texto,
                            style: TextStyle(
                              color: estado == 'vacio' ? Colors.white : _colorTexto(estado),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          _buildTeclado(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTeclado() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['1','2','3','4','5'].map((d) => _Tecla(d, _onTecla)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['6','7','8','9','0'].map((d) => _Tecla(d, _onTecla)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Tecla('DEL', _onTecla, ancho: 80),
              const SizedBox(width: 8),
              _Tecla('OK', _onTecla, ancho: 80),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tecla extends StatelessWidget {
  final String label;
  final void Function(String) onTap;
  final double ancho;

  const _Tecla(this.label, this.onTap, {this.ancho = 56});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: ancho,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF26215C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}