import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => GameHistoryPageState();
}

class GameHistoryPageState extends State<GameHistoryPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int correct = 0;
  int incorrect = 0;

  @override
  void initState() {
    super.initState();
    //_fetchUserGameData();
  }

  Future<void> _fetchUserGameData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      correct = userData.get('notematch_correct') ?? 1;
      incorrect = userData.get('notematch_incorrect') ?? 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game History'),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text(
      //         'Note Matching Game Correct: ${correct}',
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       SizedBox(),
      //       Text(
      //         'Note Matching Game Incorrect: ${incorrect}',
      //         style: TextStyle(fontSize: 18),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}