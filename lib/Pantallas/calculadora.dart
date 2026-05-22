import 'package:flutter/material.dart';

class calculadora extends StatefulWidget {
  const calculadora({super.key, required this.titulo});

  final String titulo;

  @override
  State<calculadora> createState() => _calculadoraState();
}

class _calculadoraState extends State<calculadora> {
  final TextEditingController _pantallaCalculadora = TextEditingController(
    text: "0",
  );
  final TextEditingController _pantallaAnterior = TextEditingController(
    text: "",
  );
  String _operacion = "";
  double _valorActual = 0;
  double _valorAnterior = 0;
  bool _usandoDecimal = false;
  int _decimales = 0;

  List<dynamic> simbolosBotones = [
    [7, 8, 9, "+"],
    [4, 5, 6, "-"],
    [1, 2, 3, "*"],
    ["=", 0, ".", "/"],
  ];

  double opera(String operador) {
    switch (operador) {
      case "+":
        return _valorAnterior + _valorActual;
      case "-":
        return _valorAnterior - _valorActual;
      case "*":
        return _valorAnterior * _valorActual;
      case "/":
        if (_valorActual == 0) return 0;
        return _valorAnterior / _valorActual;
      default:
        return _valorActual;
    }
  }

  String _formatearResultado(double valor) {
    if (valor == valor.truncateToDouble()) {
      return valor.toInt().toString();
    }
    return valor.toString();
  }

  void _presionarBotonCalculadora(dynamic n) {
    if (n is num) {
      setState(() {
        if (_usandoDecimal) {
          _decimales++;
          _valorActual = _valorActual + n / (10 * _decimales * 10 * (_decimales - 1 > 0 ? _decimales - 1 : 1));
          // forma más simple y correcta:
          String actual = _pantallaCalculadora.text;
          _pantallaCalculadora.text = actual + n.toString();
          _valorActual = double.parse(_pantallaCalculadora.text);
        } else {
          _valorActual = _valorActual * 10 + n;
          _pantallaCalculadora.text = _formatearResultado(_valorActual);
        }
      });
      return;
    }

    switch (n) {
      case ".":
        if (!_usandoDecimal) {
          setState(() {
            _usandoDecimal = true;
            _decimales = 0;
            _pantallaCalculadora.text = _pantallaCalculadora.text + ".";
          });
        }
        break;

      case "+":
      case "-":
      case "*":
      case "/":
        setState(() {
          if (_operacion == "") {
            _valorAnterior = _valorActual;
          } else {
            _valorAnterior = opera(_operacion);
          }
          _operacion = n;
          _valorActual = 0;
          _usandoDecimal = false;
          _decimales = 0;
          _pantallaAnterior.text = "${_formatearResultado(_valorAnterior)} $_operacion";
          _pantallaCalculadora.text = "0";
        });
        break;

      case "=":
        if (_operacion != "") {
          double resultado = opera(_operacion);
          setState(() {
            _pantallaCalculadora.text = _formatearResultado(resultado);
            _pantallaAnterior.text = "";
          });
          _valorActual = resultado;
          _valorAnterior = 0;
          _operacion = "";
          _usandoDecimal = false;
          _decimales = 0;
        }
        break;
    }
  }

  Widget _construyeTeclado() {
    List<Widget> filas = [];

    // BUG CORREGIDO: antes los índices i y j estaban al revés
    for (int i = 0; i < simbolosBotones.length; i++) {
      List<Widget> columna = [];
      for (int j = 0; j < simbolosBotones[i].length; j++) {
        dynamic digito = simbolosBotones[i][j];
        columna.add(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  _presionarBotonCalculadora(digito);
                },
                color: Colors.black,
                child: Text("$digito", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 5),
            ],
          ),
        );
      }
      filas.add(
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: columna,
        ),
      );
    }

    return Column(children: filas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.titulo),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              Container(
                height: 40,
                width: 350,
                color: Colors.grey,
                child: TextField(
                  controller: _pantallaAnterior,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 20),
                  readOnly: true,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 40,
                width: 350,
                color: Colors.grey,
                child: TextField(
                  controller: _pantallaCalculadora,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 20),
                  readOnly: true,
                ),
              ),
              SizedBox(height: 10),
              _construyeTeclado(),
            ],
          ),
        ),
      ),
    );
  }
}
