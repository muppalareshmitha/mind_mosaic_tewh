import 'package:flutter/material.dart';

class PianoKeysPage extends StatefulWidget {
  const PianoKeysPage({super.key});

  @override
  State<PianoKeysPage> createState() => PianoKeysPageState();
}

class PianoKeysPageState extends State<PianoKeysPage> {
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
            Text('Piano Keys Page.'),
          ],
        )
      )
    );
  }
}