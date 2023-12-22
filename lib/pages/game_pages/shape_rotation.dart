import 'package:flutter/material.dart';

class ShapeRotationPage extends StatefulWidget {
  const ShapeRotationPage({super.key});

  @override
  State<ShapeRotationPage> createState() => ShapeRotationPageState();
}

class ShapeRotationPageState extends State<ShapeRotationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            iconSize: 30,
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Shape Rotation Page.'),
          ],
        )
      )
    );
  }
}