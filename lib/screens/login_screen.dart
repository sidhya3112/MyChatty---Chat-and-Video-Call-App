
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chatty/resources/firebase_repository.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseRepository _repository = FirebaseRepository();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 110, top: 70),
            child: Text(
              "Hello!",
              style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Image.asset(
            "images/login.png",
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 45,
          ),
          Stack(
            children: <Widget>[
              Center(child: loginButton()),
              isLoginPressed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(top: 30),
                        child: CircularProgressIndicator(backgroundColor: Colors.black,),
                      ),
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  Widget loginButton() {
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textColor: Colors.white,
      color: Colors.blue,
      padding: EdgeInsets.all(25),
      child: Text(
        "LOGIN",
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      onPressed: () => performLogin(),
    );
  }

  void performLogin() {
    print("trying too perform login");

    setState(() {
      isLoginPressed = true;
    });

    _repository.signIn().then((FirebaseUser user) {
      if (user != null) {
        authenticateUser(user);
      } else {
        print("There was an error");
      }
    });
  }

  void authenticateUser(FirebaseUser user) {
    _repository.authenticateUser(user).then((isNewUser) {

      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _repository.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
