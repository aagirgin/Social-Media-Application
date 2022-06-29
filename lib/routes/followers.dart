import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:term_project/classes/classes.dart';
import 'package:term_project/classes/models.dart';

class Followers extends StatefulWidget {
  const Followers({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {

  List<AppUser> users = [];
  String username = '';

  Future<void> updateList() async {
    users.clear();
      await FirebaseFirestore.instance.collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          if (followersString.contains(doc.id)) {
            users.add(AppUser.fromMap(doc.data()));
          }
          });
        });
    setState(() {});
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  //List<AppUser> followersUsers = [];
  Map<String, dynamic> elements;
  List<String> followersString;
  String currUsername = "";

  @override
  void initState() {
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Followers', 'FollowersState');
    super.initState();
    updateList();
  }

    @override
  Widget build(BuildContext context) {
    elements = ModalRoute.of(context).settings.arguments;
    followersString = elements["followers"];
    currUsername = elements["username"];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          currUsername,
          style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0.0,
      ),
      body: Container(
        color: AppColors.background,
        width: 500,
        height: 1000,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(),
            Text(
              'Followers',
              style: bodyLargeTextStyle,
            ),
            Container(
              width: 350,
              height: 450,
              child: ListView(
                padding: EdgeInsets.all(0.0),
                children: users.map(
                        (user) => UsersSection(
                        user: user
                    )
                ).toList(),
              ),
            ),
            SizedBox(),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}