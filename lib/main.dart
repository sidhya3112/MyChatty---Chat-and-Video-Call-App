import 'package:my_chatty/provider/image_upload_provider.dart';
import 'package:my_chatty/provider/user_provider.dart';
import 'package:my_chatty/resources/firebase_repository.dart';
import 'package:my_chatty/screens/home_screen.dart';
import 'package:my_chatty/screens/login_screen.dart';
import 'package:my_chatty/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FirebaseRepository _repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {


    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: "MyChatty",
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          '/search_screen': (context) => SearchScreen(),
        },
        home: FutureBuilder(
        future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot){
          if(snapshot.hasData) {
            return HomeScreen();
          }
          else{
            return LoginScreen();
          }
          },
        ),
      ),
    );
  }
}
