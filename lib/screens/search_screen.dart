import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chatty/models/user.dart';
import 'package:my_chatty/provider/user_provider.dart';
import 'package:my_chatty/utils/universal_variables.dart';
import 'package:my_chatty/resources/firebase_repository.dart';
import 'package:provider/provider.dart';
import 'callscreens/pickup/pickup_layout.dart';
import 'chatscreens/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";

  TextEditingController searchController = TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                  UniversalVariables.gradientColorStart,
                  UniversalVariables.gradientColorEnd
                ])),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 5,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 15),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => searchController.clear());
                        },
                      ),
                      hintText: 'Search Username...',
                      border: InputBorder.none),
                  onChanged: (val) {
                    setState(() {
                      query = val;
                    });
                  },
                  cursorColor: Colors.black,
                  autofocus: true,
                ),
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: (query != "" && query != null)
                ? Firestore.instance
                    .collection('users')
                    .where("username",
                        isGreaterThanOrEqualTo: query.toLowerCase())
                    .snapshots()
                : Firestore.instance.collection("users").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("We got an error ${snapshot.error}");
              } else {
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot data =
                              snapshot.data.documents[index];
                          User searchedUser;

                          searchedUser = User(
                              uid: data['uid'],
                              name: data['name'],
                              profilePhoto: data['profile_photo'],
                              username: data['username']);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChatScreen(receiver: searchedUser)));
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: 60,
                                    height: 60,
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          searchedUser.profilePhoto),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 75, top: 16, bottom: 18),
                                    child: Text(
                                      searchedUser.username ==
                                              userProvider.getUser.username
                                          ? "Me"
                                          : searchedUser.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 75, top: 38),
                                    child: Text(
                                      searchedUser.name,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              }
            }),
      ),
    );
  }
}
