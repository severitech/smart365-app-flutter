// lib/main.dart

import 'dart:io';

import 'package:app_tienda/data/auth_provider.dart';
import 'package:app_tienda/data/carrito_provider.dart';
import 'package:app_tienda/screens/carrito_screen.dart';
import 'package:app_tienda/screens/mis_pedidos_screen.dart';
import 'package:app_tienda/screens/perfil_screen.dart';
import 'package:app_tienda/views/tienda_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'widgets/navbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } on FileSystemException catch (e) {
    debugPrint('Archivo .env no disponible: $e');
  } on Exception catch (e) {
    debugPrint('Error cargando .env: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<CarritoProvider>(create: (_) => CarritoProvider()),
      ],
      child: MaterialApp(
        title: 'Tienda App',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: Navbar(),
          body: TiendaScreen(),
        ),
        routes: {
          '/carrito': (context) => CarritoScreen(),
          '/mis-pedidos': (context) => MisPedidosScreen(),
          '/perfil': (context) => PerfilScreen(),
          '/login': (context) => LoginScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}