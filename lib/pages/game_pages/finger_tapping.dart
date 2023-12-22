import 'package:flutter/material.dart';

class FingerTappingPage extends StatefulWidget {
  const FingerTappingPage({super.key});

  @override
  State<FingerTappingPage> createState() => FingerTappingPageState();
}

class FingerTappingPageState extends State<FingerTappingPage> {
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
            Text('Finger Tapping Page.'),
          ],
        )
      )
    );
  }
}