import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  Widget customButton(String text, String routeName) {
    return SizedBox(
      width: 170, // Set a fixed width for all buttons
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image.jpg'), // Adjust the path to your image
            fit: BoxFit.cover,
          ),
        ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as ' + user.email!),
            SizedBox(height: 20),
            customButton('Tutorial', '/tutorial'),
            SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton('Note Matching', '/note_matching'),
                    SizedBox(width: 20),
                    customButton('Finger Tapping', '/finger_tapping')
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 170, // Set a fixed width for all buttons
                      child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/piano_keys');
                      },
                      child: Text('Piano Keys'),
                    )),
                    SizedBox(width: 20),
                    customButton('Reaction Time', '/reaction_time')
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     customButton('Piano Keys', '/piano_keys'),
                //     SizedBox(width:20),
                //     SizedBox(
                //       width: 170, // Set a fixed width for all buttons
                //       child: ElevatedButton(
                //       onPressed: () {
                //         //Navigator.pushNamed(context, '/reaction_time');
                //         final user = <String, dynamic>{
                //           // "uid" : FirebaseAuth.instance.currentUser?.uid ?? "",
                //           "clicks": 0
                //         };
                //         FirebaseFirestore db = FirebaseFirestore.instance;
                //         db.collection('users').add(user).then((DocumentReference doc) => print("thx"));
                //       },
                //       child: Text('Reaction Time'),
                //     )),
                //   ],
                // ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 170, // Set a fixed width for all buttons
                      child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/shape_placement');
                      },
                      child: Text('Shape Placement'),
                    )),
                    SizedBox(width: 20),
                    customButton('Shape Rotation', '/shape_rotation')
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton('Simon Memory', '/simon_memory'),
                    SizedBox(width: 20),
                    customButton('Smash A Mole', '/smash_a_mole')
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            customButton('Game History', '/game_history'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                // Additional logic after signing out if needed
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    ));
  }
}
