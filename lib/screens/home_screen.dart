
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_chatty/enum/user_state.dart';
import 'package:my_chatty/provider/user_provider.dart';
import 'package:my_chatty/resources/firebase_methods.dart';
import 'package:my_chatty/screens/pageviews/chat_list_screen.dart';
import 'package:my_chatty/utils/universal_variables.dart';
import 'package:provider/provider.dart';

import 'callscreens/pickup/pickup_layout.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  PageController pageController;
  int _page = 0;

  UserProvider userProvider;
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUser();

      _firebaseMethods.setUserState(
        userId: userProvider.getUser?.uid,
        userState: UserState.Online,
      );
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
    (userProvider != null && userProvider.getUser != null)
        ? userProvider.getUser.uid
        : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    double _labelFontSize = 11;

    return  PickupLayout(
      scaffold: Scaffold(
          backgroundColor: Colors.white,
          body: PageView(
            children: <Widget>[
              Container(child: ChatListScreen(),),
              Center(child: Text("Call Logs", style: TextStyle(color: Colors.black),)),
              Center(child: Text("Contact Screen", style: TextStyle(color: Colors.black),)),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
          ),
          bottomNavigationBar: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: CupertinoTabBar(
                backgroundColor: Colors.white,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat,
                        color: (_page == 0)
                            ? UniversalVariables.lightBlueColor
                            : UniversalVariables.greyColor),
                    title: Text(
                      "Chats",
                      style: TextStyle(
                          fontSize: _labelFontSize,
                          color: (_page == 0)
                              ? UniversalVariables.lightBlueColor
                              : Colors.grey),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.call,
                        color: (_page == 1)
                            ? UniversalVariables.lightBlueColor
                            : UniversalVariables.greyColor),
                    title: Text(
                      "Calls",
                      style: TextStyle(
                          fontSize: _labelFontSize,
                          color: (_page == 1)
                              ? UniversalVariables.lightBlueColor
                              : Colors.grey),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.contact_phone,
                        color: (_page == 2)
                            ? UniversalVariables.lightBlueColor
                            : UniversalVariables.greyColor),
                    title: Text(
                      "Contacts",
                      style: TextStyle(
                          fontSize: _labelFontSize,
                          color: (_page == 2)
                              ? UniversalVariables.lightBlueColor
                              : Colors.grey),
                    ),
                  ),
                ],
                onTap: navigationTapped,
                currentIndex: _page,
              ),
            ),
          ),
      ),
    );
  }
}