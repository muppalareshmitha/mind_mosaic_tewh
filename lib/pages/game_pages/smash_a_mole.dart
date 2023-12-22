import 'package:flutter/material.dart';

class SmashAMolePage extends StatefulWidget {
  const SmashAMolePage({super.key});

  @override
  State<SmashAMolePage> createState() => SmashAMolePageState();
}

class SmashAMolePageState extends State<SmashAMolePage> {
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
            Text('Smash-A-Mole Page.'), 
          ],
        )
      )
    );
  }
}