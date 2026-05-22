import 'package:flutter/material.dart';
import 'package:frankie_aplication/Pantallas/calendario.dart';
import 'package:frankie_aplication/Pantallas/correo.dart';
import 'package:frankie_aplication/Pantallas/principal.dart';
import 'package:frankie_aplication/Pantallas/ubicacion.dart';
import 'package:frankie_aplication/pantallas/calculadora.dart';

class Navegador extends StatefulWidget {
  const Navegador({super.key});

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador> {
  Widget _cuerpo = const Correo(titulo: "Pantalla Principal");
  final List<Widget> _pantallas = [];
  int _indicePantalla = 0;

  void _cambiaPantalla(int value) {
    setState(() {
      _indicePantalla = value;
      _cuerpo = _pantallas[_indicePantalla];
    });
  }

  @override
  void initState() {
    _pantallas.add(const Principal(titulo: "pantalla principal"));
    _pantallas.add(const Correo(titulo: "correo"));
    _pantallas.add(const calculadora(titulo: "tercera pantalla"));
    _pantallas.add(calendar(titulo: "calendario"));
    _pantallas.add(Ubicacion(titulo: "ubicacion",));
    _cuerpo = _pantallas[_indicePantalla];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cuerpo,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _indicePantalla,
        onTap: _cambiaPantalla,

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "principal",backgroundColor: Colors.orange
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Correo", backgroundColor: Colors.teal),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "calculadora", backgroundColor: Colors.lightGreen
          ),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "calendario",backgroundColor: Colors.pinkAccent),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "calendario",backgroundColor: Colors.pinkAccent)
        ],
      ),
    );
  }
}
