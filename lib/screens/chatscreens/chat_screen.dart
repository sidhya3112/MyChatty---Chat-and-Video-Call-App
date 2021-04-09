import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chatty/enum/view_state.dart';
import 'package:my_chatty/models/message.dart';
import 'package:my_chatty/models/user.dart';
import 'package:my_chatty/provider/image_upload_provider.dart';
import 'package:my_chatty/resources/firebase_repository.dart';
import 'package:my_chatty/screens/callscreens/pickup/pickup_layout.dart';
import 'package:my_chatty/screens/chatscreens/widgets/cached_image.dart';
import 'package:my_chatty/utils/call_utilities.dart';
import 'package:my_chatty/utils/permissions.dart';
import 'package:my_chatty/utils/universal_variables.dart';
import 'package:my_chatty/utils/utilities.dart';
import 'package:my_chatty/widgets/appbar.dart';
import 'package:my_chatty/widgets/custom_tile.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();
  ImageUploadProvider _imageUploadProvider;

  User sender;
  String _currentUserId;

  FocusNode textFieldFocus = FocusNode();

  bool isWriting = false;

  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      _currentUserId = user.uid;
      setState(() {
        sender = User(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoUrl,
        );
      });
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(context),
        body: Column(
          children: <Widget>[
            Flexible(
              child: messageList(),
            ),
            _imageUploadProvider.getViewState == ViewState.LOADING
                ? Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 15),
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            chatControls(),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: Colors.white,
      indicatorColor: Colors.grey[600],
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("messages")
          .document(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(15);
    return Container(
      margin: EdgeInsets.only(top: 20),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != 'image'
        ? Text(
            message.message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        : message.photoUrl != null
            ? CachedImage(
                message.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              )
            : Text("Url was null");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 20),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          topLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _repository.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  sendMessage() {
    var text = textFieldController.text;
    Message _message = Message(
      receiverId: widget.receiver.uid,
      senderId: sender.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
    );
    setState(() {
      isWriting = false;
    });
    textFieldController.text = "";
    _repository.addMessageToDb(_message, sender, widget.receiver);
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 10,
          backgroundColor: Colors.white,
          builder: (context) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.32,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: ListView(
                      children: <Widget>[
                        ModalTile(
                          title: "Media",
                          subtitle: "Share Photos and Video",
                          icon: Icons.image,
                          onTap: () => pickImage(source: ImageSource.gallery),
                        ),
                        ModalTile(
                            title: "File",
                            subtitle: "Share files",
                            icon: Icons.insert_drive_file),
                        ModalTile(
                            title: "Contact",
                            subtitle: "Share contacts",
                            icon: Icons.contact_phone),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(children: [
              TextFormField(
                maxLines: null,
                focusNode: textFieldFocus,
                controller: textFieldController,
                onTap: () => hideEmojiContainer(),
                style: TextStyle(
                  color: Colors.black,
                ),
                onChanged: (val) {
                  (val.length > 0 && val.trim() != "")
                      ? setWritingTo(true)
                      : setWritingTo(false);
                },
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(50.0),
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  filled: true,
                  fillColor: Colors.white38,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 185),
                child: IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(
                    Icons.face,
                    color: Colors.grey[600],
                  ),
                ),
              )
            ]),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.mic,
                    color: Colors.grey[600],
                  ),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(source: ImageSource.camera),
                  child: Icon(Icons.camera_alt, color: Colors.grey[600])),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 15,
                      color: Colors.white,
                    ),
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        widget.receiver.username,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.video_call,
          ),
          onPressed: () async {
            await Permissions.cameraAndMicrophonePermissionsGranted()
                ? CallUtils.dial(
                    from: sender, to: widget.receiver, context: context)
                : { };
          },
        ),
        IconButton(
          icon: Icon(
            Icons.phone,
          ),
          onPressed: () {},
        )
      ],
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.grey[600],
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
