import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}): super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as ' + user.email!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/tutorial');
              },
              child: Text('Tutorial'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/note_matching');
              },
              child: Text('Note Matching'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/finger_tapping');
              },
              child: Text('Finger Tapping'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/piano_keys');
              },
              child: Text('Piano Keys'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //Navigator.pushNamed(context, '/reaction_time');
                final user = <String, dynamic>{
                // "uid" : FirebaseAuth.instance.currentUser?.uid ?? "",
                "clicks" : 0
              };
              FirebaseFirestore db = FirebaseFirestore.instance;
              db.collection('users').add(user).then((DocumentReference doc) => print("thx"));
            },
              child: Text('Reaction Time'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shape_placement');
              },
              child: Text('Shape Placement'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shape_rotation');
              },
              child: Text('Shape Rotation'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/simon_memory');
              },
              child: Text('Simon Memory'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/smash_a_mole');
              },
              child: Text('Smash A Mole'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game_history');
              },
              child: Text('Game History'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                // Additional logic after signing out if needed
              },
              child: Text('Sign Out'),
            ),
          ],
        )),
    );
  }
}
