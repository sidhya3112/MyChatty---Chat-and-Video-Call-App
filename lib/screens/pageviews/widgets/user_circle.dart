
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chatty/provider/user_provider.dart';
import 'package:my_chatty/utils/universal_variables.dart';
import 'package:my_chatty/utils/utilities.dart';
import 'package:provider/provider.dart';

class UserCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(0, 0, 80, 1),
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              Utils.getInitials(userProvider.getUser.name),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[100],
                fontSize: 18,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green[900], width: 2),
                  color: UniversalVariables.onlineDotColor),
            ),
          )
        ],
      ),
    );
  }
}