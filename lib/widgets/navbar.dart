import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      title: Text(
        'Tienda',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/carrito');
          },
        ),
        IconButton(
          icon: Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/perfil');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}