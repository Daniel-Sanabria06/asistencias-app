import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Asistencias'),
      ),
      body: SizedBox(
        height: screenHeight * 1,
        width: screenWidth * 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                leading: const Icon(Icons.event_available, size: 35),
                title: const Text('Eventos', style: TextStyle(fontSize: 25)),
                onTap: () => context.push('/eventos')),
            const Divider(),
            ListTile(
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                leading: const Icon(Icons.groups, size: 35),
                title: const Text('Asistentes', style: TextStyle(fontSize: 25)),
                onTap: () => context.push('/asistentes')),
            const Divider(),
            ListTile(
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                leading: const Icon(Icons.how_to_reg, size: 35),
                title: const Text('Registro Asistencias', style: TextStyle(fontSize: 25)),
                onTap: () => context.push('/asistencias')),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
