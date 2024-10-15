import 'package:animate_do/animate_do.dart';
import 'package:app_flutter/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AsistenteLista extends StatefulWidget {
  const AsistenteLista({super.key});

  @override
  AsistenteListaState createState() => AsistenteListaState();
}

class AsistenteListaState extends State<AsistenteLista> {
  List<dynamic> _attendees = [];
  Dio dio = Dio(); // Inicializamos Dio
  bool _isAsc = true; // Para rastrear si el orden es ascendente o descendente

  @override
  void initState() {
    super.initState();
    _fetchAttendees(); // Cargar los asistentes cuando se inicia
  }

  // Función para obtener los asistentes desde la API
  Future<void> _fetchAttendees() async {
    try {
      Response response = await dio.get('$apiUrl/asistentes');

      if (response.statusCode == 200) {
        setState(() {
          _attendees =
              response.data; // Asignamos los datos recibidos a la lista
        });
      } else {
        throw Exception('Error al cargar asistentes');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Función para crear un asistente
  Future<void> _crearAsistente() async {
    String newAttendeeName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController attendeeNameController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Crear nuevo asistente'),
          content: TextField(
            controller: attendeeNameController,
            decoration:
                const InputDecoration(labelText: 'Nombre del asistente'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop(), // Cerrar el diálogo sin hacer nada
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                newAttendeeName = toTitleCase(attendeeNameController.text);

                if (newAttendeeName.isNotEmpty) {
                  try {
                    // Mostrar CircularProgressIndicator mientras se realiza la petición
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    // Petición para crear el asistente
                    Response response =
                        await dio.post('$apiUrl/asistentes/$newAttendeeName');

                    Navigator.of(context)
                        .pop(); // Cerramos el CircularProgressIndicator

                    if (response.statusCode == 201) {
                      await _fetchAttendees(); // Volver a cargar los asistentes

                      // Si el asistente se creó correctamente
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Asistente creado correctamente.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      throw Exception('Error al crear el asistente');
                    }
                  } catch (e) {
                    Navigator.of(context)
                        .pop(); // Cerramos el CircularProgressIndicator en caso de error
                    print('Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al crear el asistente.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
                Navigator.of(context)
                    .pop(); // Cerrar el diálogo después de crear el asistente
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar un asistente
  Future<void> _eliminarAsistente(int id) async {
    try {
      Response response = await dio.delete('$apiUrl/asistentes/$id');

      if (response.statusCode == 200) {
        setState(() async {
          _attendees.removeWhere((attendee) =>
              attendee['id'] == id); // Eliminamos el asistente de la lista
          await _fetchAttendees(); // Volver a cargar los asistentes
        });
      } else {
        throw Exception('Error al eliminar el asistente');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Función para editar un asistente
  Future<void> _editarAsistente(int id) async {
    String newAttendeeName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController attendeeNameController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Editar Asistente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: attendeeNameController,
                decoration: const InputDecoration(
                    labelText: 'Nuevo nombre del asistente'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _fetchAttendees(); // Volver a cargar los asistentes

                Navigator.of(context).pop(); // Cerrar el dialog
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                newAttendeeName = toTitleCase(attendeeNameController.text);

                if (newAttendeeName.isNotEmpty) {
                  await _actualizarAsistente(
                      id, newAttendeeName); // Actualizamos el asistente
                }
                Navigator.of(context).pop(); // Cerrar el dialog
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Función para actualizar un asistente en la API
  Future<void> _actualizarAsistente(int id, String newAttendeeName) async {
    try {
      Response response =
          await dio.put('$apiUrl/asistentes/$id/$newAttendeeName');

      if (response.statusCode == 200) {
        // Mostrar SnackBar con éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asistente actualizado correctamente.'),
            duration: Duration(seconds: 2),
          ),
        );
        await _fetchAttendees(); // Volver a cargar los asistentes
      } else {
        throw Exception('Error al editar el asistente');
      }
    } catch (e) {
      print('Error: $e');
      // Mostrar SnackBar con error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el asistente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Función para invertir el orden de los asistentes
  void _invertirOrdenAsistentes() {
    setState(() {
      _attendees =
          _attendees.reversed.toList(); // Invertimos el orden de la lista
      _isAsc = !_isAsc; // Alternamos entre ascendente y descendente
    });
  }

  String toTitleCase(String input) {
    if (input.trim().isEmpty)
      return ''; // Verificar si el input está vacío o solo contiene espacios

    List<String> words = input
        .trim()
        .split(' '); // Eliminar espacios adicionales al inicio o final
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Asistentes'),
        actions: [
          IconButton(
            icon: Icon(_isAsc ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed:
                _invertirOrdenAsistentes, // Llama a la función para invertir el orden
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FadeInRight(
          from: 50,
          child: FloatingActionButton(
              elevation: 6,
              shape: const CircleBorder(),
              onPressed: _crearAsistente,
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
      body: SizedBox(
        width: size.width * 0.99,
        height: size.height * 0.80,
        child: _attendees.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  const Divider(),
                  SizedBox(
                    width: size.width * 0.99,
                    height: size.height * 0.70,
                    child: ListView.builder(
                      itemCount: _attendees.length,
                      itemBuilder: (context, index) {
                        final attendee = _attendees[index];
                        return Dismissible(
                          key: Key(attendee['id'].toString()),
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              _editarAsistente(attendee['id']);
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              _eliminarAsistente(
                                  attendee['id']);
                            }
                            setState(() {
                              _attendees.removeWhere((attendee) =>
                                  attendee['id'] == attendee['id']);
                            });
                          },
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: const Text(
                                        '¿Seguro que quieres eliminar este Asistente?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            return true;
                          },
                          child: Card(
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                '${attendee['name']}',
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
