import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/login_screen.dart';
import 'widgets/firebase_options.dart'; // Import Firebase configuration
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebase initialization
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Routine System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Set your initial screen here
    );
  }
}
