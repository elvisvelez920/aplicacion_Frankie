import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Principal extends StatefulWidget {
  const Principal({super.key, required this.titulo});

  final String titulo;

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  int _counter = 0;

  void _leerDatoNube() async {
    DocumentSnapshot elDoc =
    await db.collection("prueba").doc("miPagina").get();

    if (elDoc.exists) {
      setState(() {
        _counter = elDoc.get("elContador") ?? 0;
      });
    }
  }

  void _escribirDatoNube() async {
    await db
        .collection("prueba")
        .doc("miPagina")
        .set({"elContador": _counter});
  }

  void _incrementCounter() {
    setState(() {
      _counter += 2;
    });

    _escribirDatoNube();
  }

  void _decrementCounter() {
    setState(() {
      if (_counter >= 2) {
        _counter -= 2;
      }
    });

    _escribirDatoNube();
  }

  @override
  void initState() {
    super.initState();
    _leerDatoNube();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Has presionado el botón $_counter veces',
              style: TextStyle(fontSize: 20 + _counter.toDouble()),
            ),

            const SizedBox(height: 20),

            MaterialButton(
              onPressed: () {},
              color: Colors.amber,
              child: Text(
                "YAA VA A TERMINAR EL SEMESTRE",
                style: TextStyle(
                  fontSize: 20 + _counter.toDouble(),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            child: const Icon(Icons.add),
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            onPressed: _decrementCounter,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}