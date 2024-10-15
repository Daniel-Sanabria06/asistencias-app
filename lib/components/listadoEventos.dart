import 'package:animate_do/animate_do.dart';
import 'package:app_flutter/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/components/attendeesPage.dart';

class ListaEventos extends StatefulWidget {
  const ListaEventos({super.key});

  @override
  ListaEventosState createState() => ListaEventosState();
}

class ListaEventosState extends State<ListaEventos>
    with SingleTickerProviderStateMixin {
  List<dynamic> _events = [];
  Dio dio = Dio();
  bool _isAsc = true;
  bool _isLoading = false;
  late AnimationController _controller;
  bool _isButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fetchEvents();
  }

  // Función para obtener los eventos desde la API
  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para crear un evento
  Future<void> _crearEvento() async {
    String newEventName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController eventNameController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Crear nuevo evento'),
          content: TextField(
            controller: eventNameController,
            decoration: const InputDecoration(labelText: 'Nombre del evento'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cerrar el diálogo
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                newEventName = toTitleCase(eventNameController.text);

                if (newEventName.isNotEmpty) {
                  setState(() {
                    _isLoading = true; 
                  });

                  Response response =
                      await dio.post('$apiUrl/eventos/$newEventName');

                  setState(() {
                    _isLoading = false; 
                  });

                  Navigator.of(context).pop(); 

                  if (response.statusCode == 201) {
                    await _fetchEvents(); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evento creado correctamente.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    throw Exception('Error al crear el evento');
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar un evento
  Future<void> _eliminarEvento(int id) async {
    try {
      Response response = await dio.delete('$apiUrl/eventos/$id');

      if (response.statusCode == 200) {
        setState(() {
          _events.removeWhere((evento) =>
              evento['id'] == id); 
        });
      } else {
        throw Exception('Error al eliminar el evento');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Función para editar un evento
  Future<void> _editarEvento(int id) async {
    String newEventName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController eventNameController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Editar Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration:
                    const InputDecoration(labelText: 'Nuevo nombre del evento'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _fetchEvents(); 
                Navigator.of(context).pop(); 
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                newEventName = toTitleCase(eventNameController.text);
                if (newEventName.isNotEmpty) {
                  await _actualizarEvento(
                      id, newEventName); 
                }
                Navigator.of(context).pop(); 
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Función para actualizar un evento en la API
  Future<void> _actualizarEvento(int id, String newEventName) async {
    try {
      Response response = await dio.put('$apiUrl/eventos/$id/$newEventName');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento actualizado correctamente.'),
            duration: Duration(seconds: 2),
          ),
        );
        await _fetchEvents(); 
      } else {
        throw Exception('Error al editar el evento');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el evento.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Función para invertir el orden de los eventos
  void _invertirOrdenEventos() {
    setState(() {
      _events = _events.reversed.toList();
      _isAsc = !_isAsc; 
    });
  }

  String toTitleCase(String input) {
    if (input.trim().isEmpty) return ''; // Verificar si el input está vacío

    List<String> words = input.trim().split(' ');
    String titleCase = '';

    for (String word in words) {
      if (word.isNotEmpty) {
        titleCase +=
            word[0].toUpperCase() + word.substring(1).toLowerCase() + ' ';
      }
    }

    return titleCase.trim(); // Eliminar el espacio extra al final
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(
            icon: Icon(_isAsc ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _invertirOrdenEventos,
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: _isButtonVisible,
        child: SizedBox(
          width: 65,
          height: 65,
          child: FadeInRight(
            from: 50,
            child: FloatingActionButton(
                elevation: 6,
                shape: const CircleBorder(),
                onPressed: _crearEvento,
                backgroundColor: Colors.blue.shade600,
                child: FadeIn(
                  child: ShakeY(
                     from: 2,
                     delay: const Duration(seconds: 1),
                     duration: const Duration(seconds: 2),
                     infinite: true,
                      child: const Icon(
                    Icons.add_circle_outlined,
                    size: 45,
                    color: Colors.white,
                  )),
                )),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No hay eventos disponibles.'))
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Dismissible(
                            key: Key(event['id'].toString()),
                            background: Container(
                              color: Colors.blue,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(
                                Icons.edit,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                await _editarEvento(event['id']);
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                await _eliminarEvento(event['id']);
                              }
                              return false;
                            },
                            child: Card(
                              elevation: 5,
                              child: ListTile(
                                title: Text(
                                  event['name'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttendeesPage(eventId: event['id']),
                                    ),
                                  );
                                },
                              ),
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
