import 'package:flutter/material.dart';

class Correo extends StatefulWidget {
  const Correo({super.key, required this.titulo});

  final String titulo;

  @override
  State<Correo> createState() => _CorreoState();
}

class _CorreoState extends State<Correo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.titulo),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("soy la pantalla de correo"),
            MaterialButton(
              onPressed: () {
                print("se presiono");
              },
              child: Text("Presionar"),
            ),
          ],
        ),
      ),
    );
  }
}
