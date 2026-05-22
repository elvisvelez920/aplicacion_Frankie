import 'package:flutter/material.dart';
import 'package:frankie_aplication/Navegador/navegador.dart';

class Frankie extends StatelessWidget {
  const Frankie({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Navegador(),
    );
  }
}
