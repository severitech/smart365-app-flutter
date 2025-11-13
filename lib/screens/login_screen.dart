import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 8.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bienvenido',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () {
                          // Lógica para iniciar sesión
                          Navigator.pop(context); // Regresar a la pantalla anterior
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}