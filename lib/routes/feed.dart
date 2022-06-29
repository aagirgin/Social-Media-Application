
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:term_project/classes/classes.dart';
import 'package:term_project/classes/models.dart';

class Feed extends StatefulWidget {
  const Feed({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  User firebaseUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  List<dynamic> userFollowingRaw = [];
  List<String> userFollowing = [];
  Future<void> loadFeed() async {
    await userCollection.doc(firebaseUser.uid).get().then(
            (DocumentSnapshot documentSnapshot) {
          setState(() {
            userFollowingRaw = documentSnapshot['userFollowing'];
          });
        }
    );
    for (var i in userFollowingRaw) {
      userFollowing.add(i.toString());
      //print(userFollowingRaw);
    }
    posts.clear();
    for (var i in userFollowing) {
      //print(i);
      FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isEqualTo: i)
          .where('isDeactivated', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          for (var j in doc["usersPosts"]) {
            setState(() {
              posts.add(Post.fromMap(j));
            });
          }
        });
      });
    }
    setState(() {
      posts.shuffle(Random());
    });
  }



  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  List<Post> posts = [];

  bool isEnteredApp = false;

  loadEnteredAppStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnteredApp = prefs.getBool('enteredApp'); }
    );
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Feed', 'FeedState');
    loadEnteredAppStatus();
    loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(!isEnteredApp);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 65,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () { Navigator.pushNamed(context, '/search'); },
                splashRadius: 30,
                icon: Icon(
                    IconData(59828, fontFamily: 'MaterialIcons'),
                    color: AppColors.text
                ),
                iconSize: 45,
              ),
              Text(
                'FooBar App',
                style: mainTitleTextStyle,
              ),
              IconButton(
                onPressed: () { Navigator.pushNamed(context, '/profile'); },
                splashRadius: 30,
                icon: Icon(
                    IconData(59648, fontFamily: 'MaterialIcons'),
                    color: AppColors.text
                ),
                iconSize: 45,
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 0.0,
        ),
        body: Container(
          color: AppColors.background,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
              padding: EdgeInsets.all(0.0),
              children: posts.map(
                    (post) => PostsOthersSection(
                    post: post,
                    like: () {},
                    dislike: () {},
                    makeComment: () {},
                    bookmark: () {},
                  )
              ).toList(),
            ),
        ),
        floatingActionButton:FloatingActionButton(backgroundColor: AppColors.primary,
          splashColor: AppColors.background,
          onPressed: () { Navigator.pushNamed(context, '/addpost'); },
          child: Icon(Icons.add),//add post
        ),
        bottomNavigationBar: BottomAppBar(
          color: AppColors.primary,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {},
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
              /*
              IconButton(
                onPressed: () { Navigator.pushNamed(context, '/messagesall'); },
                splashRadius: 30,
                icon: Icon(
                    IconData(61858, fontFamily: 'MaterialIcons'),
                    color: AppColors.text
                ),
                iconSize: 45,
              ),

               */
            ],
          ),
        ),
      ),
    );
  }
}