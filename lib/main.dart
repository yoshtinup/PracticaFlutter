import 'package:flutter/material.dart';
import 'Pages/Home.dart';
import 'Pages/Pagechatbot.dart'; // Asumiendo que crearás esta página

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Home(),
        '/chat': (context) => const Pagechatbot(), // Ruta para la página de chat
      },
    );
  }
}