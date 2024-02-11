import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class NoteMatchingPage extends StatefulWidget {
  const NoteMatchingPage({Key? key}) : super(key: key);

  @override
  State<NoteMatchingPage> createState() => NoteMatchingPageState();
}

class NoteMatchingPageState extends State<NoteMatchingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late int randomNumber1;
  late int randomNumber2;
  int notematchCorrect = 0;
  int notematchIncorrect = 0;
  int guessesRemaining = 10;
  bool isPlayingNotes = false;

  void resetGame() {
    setState(() {
      guessesRemaining = 10;
      isPlayingNotes = false;
    });
  }

  Future<void> playRandomNotes() async {
    if (isPlayingNotes) return;

    setState(() {
    isPlayingNotes = true;
    });

    Random random = Random();
    randomNumber1 = random.nextInt(6) + 1;
    if (random.nextDouble() < 0.3) {
    randomNumber2 = randomNumber1;
  } else {
    randomNumber2 = random.nextInt(6) + 1;
  }

    final player = AudioPlayer();
    // ignore: prefer_interpolation_to_compose_strings
    String x = 'note' + randomNumber1.toString() + '.mp3';
    await player.play(AssetSource(x));

    await Future.delayed(Duration(seconds: 1));

    final player1 = AudioPlayer();
    String y = 'note' + randomNumber2.toString() + '.mp3';
    await player1.play(AssetSource(y));
    
  }

    void handleGuess(bool isMatch) {
    if ((randomNumber1 == randomNumber2 && isMatch) ||
        (randomNumber1 != randomNumber2 && !isMatch)) {
      // Correct guess
      setState(() {
        notematchCorrect++;
      });
    } else {
      // Incorrect guess
      setState(() {
        notematchIncorrect++;
      });
    }

    User? user = _auth.currentUser;
    // Update Firestore database

    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'notematch_correct': notematchCorrect,
        'notematch_incorrect': notematchIncorrect,
      });
    }

    setState(() {
    isPlayingNotes = false;
    guessesRemaining--; // Set to false after the user has made their guess
    });
  }

  void _handleButtonClick() async {
    // Get current user
    User? user = _auth.currentUser;
    if (user != null) {
      // Retrieve user document
      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      // Update clicks field
      userDoc.update({'clicks': FieldValue.increment(1)})
          .then((value) => print('Click count updated'))
          .catchError((error) => print('Failed to update click count: $error'));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.music_note, size: 100, color: Colors.deepPurple),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Welcome to the Note Matching Game!',
                style: TextStyle(fontSize: 22),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPlayingNotes ? null : playRandomNotes,
              child: Text('Play Note Matching Game'),
            ),
            SizedBox(height: 20),
            Text(
              'Did the notes match?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: guessesRemaining > 0 ? () => handleGuess(true) : null,
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: guessesRemaining > 0 ? () => handleGuess(false) : null,
                  child: Text('No'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Guess ${10 - guessesRemaining}/10',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            guessesRemaining <= 0
                ? Column(
                    children: [
                      Text('This Round Over'),
                      ElevatedButton(
                        onPressed: resetGame,
                        child: Text('New Game'),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}