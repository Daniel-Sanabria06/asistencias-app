import 'package:app_flutter/components/listaAsistentes.dart';
import 'package:app_flutter/components/listadoEventos.dart';
import 'package:flutter/material.dart';

class AsistentesPage extends StatefulWidget {
  const AsistentesPage({super.key});

  @override
  _AsistentesPageState createState() => _AsistentesPageState();
}

class _AsistentesPageState extends State<AsistentesPage> {
  //final GlobalKey<ListaEventosState> _listaEventosKey = GlobalKey(); // Key para ListaEventos
  final GlobalKey<AsistenteListaState> _listaAsistentesKey = GlobalKey(); // Key para ListaEventos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      AsistenteLista(key: _listaAsistentesKey)
      //ListaEventos( key: _listaEventosKey), // Referencia a la lista de eventos
    );
  }
}
