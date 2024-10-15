import 'package:app_flutter/components/listaAsistentes.dart';
import 'package:app_flutter/components/listadoEventos.dart';
import 'package:flutter/material.dart';

class AsistentesPage extends StatefulWidget {
  const AsistentesPage({super.key});

  @override
  _AsistentesPageState createState() => _AsistentesPageState();
}

class _AsistentesPageState extends State<AsistentesPage> {
  final GlobalKey<AsistenteListaState> _listaAsistentesKey = GlobalKey(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      AsistenteLista(key: _listaAsistentesKey)
    );
  }
}
