import 'package:app_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';

class AsistenciaDetallesPage extends StatefulWidget {
  final int eventId;
  final String eventName;

  const AsistenciaDetallesPage({super.key, required this.eventId, required this.eventName});

  @override
  _AsistenciaDetallesPageState createState() => _AsistenciaDetallesPageState();
}

class _AsistenciaDetallesPageState extends State<AsistenciaDetallesPage> with TickerProviderStateMixin {
  late final AnimationController _controller;

  List<dynamic> _attendances = [];
  Dio dio = Dio();
  bool _loading = true;
  bool _noData = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 2), // Define la duración de la animación
    );

    // Establecer un temporizador de 5 segundos para verificar si hay datos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _attendances.isEmpty) {
        setState(() {
          _loading = false;
          _noData = true;
        });
      }
    });
  }

  // Función para obtener la asistencia del evento desde la API
  Future<void> _fetchAttendance() async {
    try {
      Response response =
          await dio.get('$apiUrl/asistencia/eventos/${widget.eventId}');
      if (response.statusCode == 200) {
        setState(() {
          _attendances = response.data; // Asignamos los datos recibidos
          _loading = false; // Detenemos el indicador de carga
          _noData = _attendances.isEmpty; // Si no hay datos, mostrar mensaje
        });
      } else {
        throw Exception('Error al cargar asistencias');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _noData
              ? const Center(
                  child: Text(
                    'No hay registro de asistencia para este evento',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    Text('Total Asistentes de ${widget.eventName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: size.width * 0.99,
                      height: size.height * 0.8,
                      child: ListView.builder(
                        itemCount: _attendances.length,
                        itemBuilder: (context, index) {
                          final attendance = _attendances[index];
                          return Card(
                            elevation: 5,
                            child: ListTile(
                              trailing: Lottie.asset(
                              'assets/animations/check.json',
                              width: 35,
                              height:35,
                              controller: _controller,
                              onLoaded: (c) {
                                _controller.duration = c.duration;
                                _controller.forward(); // Inicia la animación cuando se carga
                              },
                            ),
                              title: Text(
                                '${attendance['asistente_name']}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              //   subtitle: Text('Evento: ${attendance['evento_name']}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
