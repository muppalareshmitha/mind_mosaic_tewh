import 'package:flutter/material.dart';

class ReactionTimePage extends StatefulWidget {
  const ReactionTimePage({super.key});

  @override
  State<ReactionTimePage> createState() => ReactionTimePageState();
}

class ReactionTimePageState extends State<ReactionTimePage> {
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
            Text('Reaction Time Page.'),
          ],
        )
      )
    );
  }
}