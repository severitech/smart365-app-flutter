import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            ),
            child: Text(
              'Iniciar Sesión',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}