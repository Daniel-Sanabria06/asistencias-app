import 'package:app_flutter/components/asistenciaDetallesPage.dart';
import 'package:app_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AsistenciaPage extends StatefulWidget {
  const AsistenciaPage({super.key});

  @override
  _AsistenciaPageState createState() => _AsistenciaPageState();
}

class _AsistenciaPageState extends State<AsistenciaPage> {
  List<dynamic> _events = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // Función para obtener los eventos desde la API
  Future<void> _fetchEvents() async {
    try {
      Response response = await dio.get('$apiUrl/eventos');
      if (response.statusCode == 200) {
        setState(() {
          _events = response.data; 
        });
      } else {
        throw Exception('Error al cargar eventos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asistencias por evento',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: _events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Column(
                        children: [
                          Card(
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                '${event['name']}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AsistenciaDetallesPage(
                                            eventId: event['id'],
                                            eventName: event['name']),
                                  ),
                                );
                              },
                            ),
                          ),
                          // const Divider()
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
