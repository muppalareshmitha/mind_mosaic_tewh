import 'package:mind_mosaic_proj/auth/main_page.dart';
import 'package:mind_mosaic_proj/pages/game_history.dart';
import 'package:mind_mosaic_proj/pages/game_pages/export_pages.dart';
import 'package:mind_mosaic_proj/pages/tutorial_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      routes: {
        '/tutorial': (context) => TutorialPage(),
        '/note_matching': (context) => NoteMatchingPage(),
        '/finger_tapping': (context) => FingerTappingPage(),
        '/piano_keys': (context) => PianoKeysPage(),
        '/reaction_time': (context) => ReactionTimePage(),
        '/shape_placement': (context) => ShapePlacementPage(),
        '/shape_rotation': (context) => ShapeRotationPage(),
        '/simon_memory': (context) => SimonMemoryPage(),
        '/smash_a_mole': (context) => SmashAMolePage(),
        '/game_history': (context) => GameHistoryPage(),
      },
    );
  }
}