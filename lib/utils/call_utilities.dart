import 'dart:math';

import 'package:my_chatty/models/call.dart';
import 'package:my_chatty/models/user.dart';
import 'package:my_chatty/resources/call_methods.dart';
import 'package:my_chatty/screens/callscreens/call_screen.dart';
import 'package:flutter/material.dart';


class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({User from, User to, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}