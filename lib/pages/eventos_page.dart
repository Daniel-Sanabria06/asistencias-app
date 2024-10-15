import 'package:app_flutter/components/listadoEventos.dart';
import 'package:flutter/material.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final GlobalKey<ListaEventosState> _listaEventosKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListaEventos(
          key: _listaEventosKey),  );
  }
}
