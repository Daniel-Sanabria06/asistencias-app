import 'package:app_flutter/pages/asistencia_page.dart';
import 'package:app_flutter/pages/asistentes_page.dart';
import 'package:app_flutter/pages/eventos_page.dart';
import 'package:app_flutter/pages/home_page.dart';
import 'package:go_router/go_router.dart';

final  appRouter = GoRouter(
  initialLocation: '/',
  routes:[
    GoRoute(
      path: '/',
      builder: (context,state) => const HomePage(),
    ),
    GoRoute(
      path: '/eventos',
      builder: (context,state) => const EventosPage(),
    ),
    GoRoute(
      path: '/asistentes',
      builder: (context,state) => const AsistentesPage(),
    ),
    GoRoute(
      path: '/asistencias',
      builder: (context,state) => const AsistenciaPage(),
    ),
  ],
);