import 'package:flutter/material.dart';

class ShapePlacementPage extends StatefulWidget {
  const ShapePlacementPage({super.key});

  @override
  State<ShapePlacementPage> createState() => ShapePlacementPageState();
}

class ShapePlacementPageState extends State<ShapePlacementPage> {
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
            Text('Shape Placement Page.'),
          ],
        )
      )
    );
  }
}