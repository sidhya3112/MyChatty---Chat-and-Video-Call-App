
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_chatty/enum/user_state.dart';
import 'package:my_chatty/models/user.dart';
import 'package:my_chatty/resources/firebase_methods.dart';
import 'package:my_chatty/utils/universal_variables.dart';
import 'package:my_chatty/utils/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final FirebaseMethods _firebaseMethods = FirebaseMethods();

  OnlineDotIndicator({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return UniversalVariables.onlineDotColor;
        default:
          return Colors.orange;
      }
    }

    getBorder(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Border.all(color: Colors.red[700], width: 2);
        case UserState.Online:
          return Border.all(color: Colors.green[700], width: 2);
        default:
          return Border.all(color: Colors.orange[700], width: 2);
      }
    }

    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseMethods.getUserStream(
          uid: uid,
        ),
        builder: (context, snapshot) {
          User user;

          if (snapshot.hasData && snapshot.data.data != null) {
            user = User.fromMap(snapshot.data.data);
          }

          return Container(
            height: 10,
            width: 10,
            margin: EdgeInsets.only(right: 5, top: 5),
            decoration: BoxDecoration(
              border: getBorder(user?.state),
              shape: BoxShape.circle,
              color: getColor(user?.state),
            ),
          );
        },
      ),
    );
  }
}