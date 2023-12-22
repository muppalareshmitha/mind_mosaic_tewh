import 'package:flutter/material.dart';

class NoteMatchingPage extends StatefulWidget {
  const NoteMatchingPage({super.key});

  @override
  State<NoteMatchingPage> createState() => NoteMatchingPageState();
}

class NoteMatchingPageState extends State<NoteMatchingPage> {
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
            SizedBox(height: 20), // Adjust spacing as needed
            Icon(Icons.music_note, size: 50, color: Colors.blue), // Music note icon
            SizedBox(height: 10), // Adjust spacing as needed
            Center(
              child: Text(
                'Note Matching Page',
                style: TextStyle(fontSize: 18),
              ),
          ),
          ],
        )
      )
    );
  }
}