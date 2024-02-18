import 'package:flutter/material.dart';

class ShapeRotationPage extends StatefulWidget {
  const ShapeRotationPage({super.key});

  @override
  State<ShapeRotationPage> createState() => ShapeRotationPageState();
}

class ShapeRotationPageState extends State<ShapeRotationPage> {
  
  bool _showEmoji = false;
  
  @override
  Widget build(BuildContext context) {
    _showEmojiAfterDelay();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
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
            SizedBox(height: 20),
            Icon(Icons.shape_line, size: 100, color: Colors.deepPurple),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Welcome to the Shape Rotation Game!',
                style: TextStyle(fontSize: 22),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Color.fromARGB(147, 156, 82, 230), // Faded purple color
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
              child: Text(
                'Exercise 2: Rotate the Pentagon twice.',
                style: TextStyle(fontSize: 20, color: Colors.white), // Text style
              ),
            ),
            SizedBox(height: 20),
            if (_showEmoji)
              Text(
                'Great job! 👍',
                style: TextStyle(
                  fontSize: 35.0, // adjust the size as needed
                ),
              ),
          ],
        )
      )
    );
  }

  // Method to show the emoji after a delay
  void _showEmojiAfterDelay() {
    // Set a delay of 5 seconds before showing the emoji
    Future.delayed(Duration(seconds: 15), () {
      setState(() {
        _showEmoji = true;
      });
    });
  }
}