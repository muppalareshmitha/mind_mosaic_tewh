import 'package:flutter/material.dart';

class SimonMemoryPage extends StatefulWidget {
  const SimonMemoryPage({super.key});

  @override
  State<SimonMemoryPage> createState() => SimonMemoryPageState();
}

class SimonMemoryPageState extends State<SimonMemoryPage> {
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
            Text('Simon Memory Page.'),
          ],
        )
      )
    );
  }
}