import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:term_project/classes/classes.dart';
import 'package:term_project/classes/models.dart';

class DirectMessagesPrivate extends StatefulWidget {
  const DirectMessagesPrivate({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _DirectMessagesPrivateState createState() => _DirectMessagesPrivateState();
}

class _DirectMessagesPrivateState extends State<DirectMessagesPrivate> {


  AppUser dummyUser = AppUser(username: 'username #1', mail: '', gsm: '', password: '', postCount: 0, followersCount: 0, followingCount: 0, bio: 'desc #1', isPrivate: true, profilePhoto: '');
  List<ChatType> chatboxes = [
    ChatType(msg: "a1", type: "sender"),
    ChatType(msg: "b1", type: "receiver"),
    ChatType(msg: "a2", type: "sender"),
    ChatType(msg: "a3", type: "sender"),
    ChatType(msg: "b2", type: "receiver"),
  ];

  Chat dummyChat;
  String lastMsg;
  final textFieldFocusNode = FocusNode();
  var _controller = TextEditingController();

  setLastText(String msg){
    if (msg != null && msg != ""){
      lastMsg = msg;
    }
  }
  getLastText(){
    return lastMsg;
  }
  addNewChat(String msg){
    if (msg != null && msg != "") {
      chatboxes.add(ChatType(msg: "$msg", type: "sender"));
    }
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState(){
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'DirectMessagesPrivate', 'DirectMessagesPrivateState');
    dummyChat = Chat(user: dummyUser, chatbox: chatboxes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${dummyChat.user.username}',
          style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        color: AppColors.background,
        height: 750,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 525,
                child: ListView(
                  padding: EdgeInsets.all(0.0),
                  children: dummyChat.chatbox.map(
                    (chat) => Messages(
                      msg: chat.msg,
                      type: chat.type,
                    )
                  ).toList(),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: 350,
                child: TextField(
                  controller: _controller,
                  focusNode: textFieldFocusNode,
                  onChanged: (String value) => setLastText(value),
                  style: bodySmallTextStyle,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF9885B1))
                    ),
                    labelStyle: bodySmallTextStyle,
                    suffixIcon: IconButton(
                      onPressed: () { textFieldFocusNode.unfocus(); addNewChat(getLastText()); _controller.clear(); },
                      splashRadius: 55,
                      icon: Icon(
                          IconData(59834, fontFamily: 'MaterialIcons'),
                          color: AppColors.text
                      ),
                      iconSize: 35,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/feed'); },
              splashRadius: 30,
              icon: Icon(
                  IconData(0xe7ba, fontFamily: 'MaterialIcons'),
                  color: AppColors.text
              ),
              iconSize: 45,
            ),
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/notifications'); },
              splashRadius: 30,
              icon: Icon(
                  IconData(60966, fontFamily: 'MaterialIcons'),
                  color: AppColors.text
              ),
              iconSize: 45,
            ),
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/messagesall'); },
              splashRadius: 30,
              icon: Icon(
                  IconData(61858, fontFamily: 'MaterialIcons'),
                  color: AppColors.text
              ),
              iconSize: 45,
            ),
          ],
        ),
      ),
    );
  }
}