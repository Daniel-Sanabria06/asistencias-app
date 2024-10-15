import 'dart:ffi';

import 'package:app_flutter/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AttendeesPage extends StatefulWidget {
  final int eventId;

  const AttendeesPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _AttendeesPageState createState() => _AttendeesPageState();
}

class _AttendeesPageState extends State<AttendeesPage>
    with TickerProviderStateMixin {
  List<dynamic> _attendees = [];
  List<dynamic> _filteredAttendees = [];
  Dio dio = Dio();
  TextEditingController _searchController = TextEditingController();
  String _filterOption = 'all';
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _fetchAttendees();
    _searchController.addListener(_filterAttendees);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendees() async {
    try {
      Response attendeesResponse = await dio.get('$apiUrl/asistentes');
      List<dynamic> attendees = attendeesResponse.data;

      Response attendanceResponse =
          await dio.get('$apiUrl/asistencia/eventos/${widget.eventId}');
      List<String> attendedNames = (attendanceResponse.data as List)
          .map((att) => att['asistente_name'] as String?)
          .where((name) => name != null)
          .map((name) => name!)
          .toList();

      // Combinar los asistentes y los estados de asistencia
      setState(() {
        _attendees = attendees.map((attendee) {
          bool isAttended = attendedNames.contains(attendee['name']);
          return {
            'id': attendee['id'],
            'name': attendee['name'],
            'isAttended': isAttended,
          };
        }).toList();

        _filteredAttendees = _attendees; // Asignar la lista filtrada
        _filterAttendees(); // Aplicar filtro por defecto
      });
    } catch (e) {}
  }

  void _filterAttendees() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAttendees = _attendees.where((attendee) {
        String name = attendee['name'].toLowerCase();
        bool matchesFilter = true;

        if (_filterOption == 'registered') {
          matchesFilter = attendee['isAttended'] == true;
        } else if (_filterOption == 'notRegistered') {
          matchesFilter = attendee['isAttended'] == false;
        }

        return name.contains(query) && matchesFilter;
      }).toList();
    });
  }

  Future<void> _toggleAttendance(int attendeeId, bool isAttended) async {
    if (isAttended) {
      // Desmarcar asistencia
      bool confirm = await _showConfirmationDialog();
      if (!confirm) return;
      await _eliminarAsistencia(attendeeId);
    } else {
      await _marcarAsistencia(attendeeId, isAttended);
    }
    _fetchAttendees();
  }

  Future<void> _marcarAsistencia(int asistenteId, bool isAttended) async {
    try {
      if (isAttended) {
        bool? confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Quitar Asistencia'),
              content: const Text('¿Seguro que desea quitar la asistencia?'),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Quitar'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          Response response = await dio
              .delete('$apiUrl/asistencia/${widget.eventId}/$asistenteId');
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Asistencia quitada correctamente.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        // Si el asistente no está registrado, marcar la asistencia
        Response response =
            await dio.post('$apiUrl/asistencia/${widget.eventId}/$asistenteId');
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Asistencia marcada correctamente.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al marcar/desmarcar asistencia.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _eliminarAsistencia(int attendeeId) async {
    try {
      Response response =
          await dio.delete('$apiUrl/asistencia/${widget.eventId}/$attendeeId');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asistencia eliminada correctamente.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Error al eliminar asistencia');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar asistencia.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar'),
              content: const Text(
                  '¿Estás seguro de que quieres quitar la asistencia?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _changeFilter(String option) {
    setState(() {
      _filterOption = option;
      _filterAttendees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcar Asistencia'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            onSelected: _changeFilter,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Mostrar Todos'),
                ),
                const PopupMenuItem(
                  value: 'registered',
                  child: Text('Mostrar Registrados'),
                ),
                const PopupMenuItem(
                  value: 'notRegistered',
                  child: Text('Mostrar No Registrados'),
                ),
              ];
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Cerrar el teclado al hacer clic fuera del TextField
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar asistente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Expanded(
              child: _filteredAttendees.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: _filteredAttendees.map((attendee) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text('${attendee['name']}'),
                                trailing: IconButton(
                                  icon: attendee['isAttended']
                                      ? Lottie.asset(
                                          'assets/animations/check.json',
                                          width: 35,
                                          height: 35,
                                          controller: _controller,
                                          onLoaded: (c) {
                                            _controller.duration = c.duration;
                                            _controller
                                                .forward();
                                          },
                                        )
                                      : const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.grey,
                                        ),
                                  onPressed: () {
                                    _toggleAttendance(
                                        attendee['id'], attendee['isAttended']);
                                  },
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus(); // Cerrar el teclado
    _filterAttendees(); // Aplicar el filtro nuevamente
  }
}
