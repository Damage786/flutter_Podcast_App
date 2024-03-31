import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:podcast/authmanagment/authmanagment.dart';
import 'package:podcast/firebase_options.dart';
import 'package:podcast/screens/Home_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:podcast/screens/buttonnav.dart';
import 'package:podcast/screens/forgotpassword.dart';
import 'package:podcast/screens/frontpgae.dart';
import 'package:podcast/screens/loginpage.dart';
import 'package:podcast/screens/registrationPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Podcast App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  Auth(),
      routes: {
        '/home': (context) => buttomPage(),
        '/registration': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        'forgotPassword': (context) => ForgotPasswordPage(),
      },
    );
  }
}


