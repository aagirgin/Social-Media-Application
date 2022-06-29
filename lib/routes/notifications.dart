import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:term_project/classes/classes.dart';
import 'package:term_project/classes/models.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  User firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Notifications', 'NotificationsState');
    updatePage();
  }

  List<dynamic> userNotifisRaw;
  List<Notifi> userNotifis = [];

  Future<void> updatePage() async {
    await FirebaseFirestore.instance.collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then(
            (DocumentSnapshot documentSnapshot) {
          setState(() {
            userNotifisRaw = documentSnapshot['userNotifications'];
          });
        }
    );
    for (var i in userNotifisRaw) {
      userNotifis.add(Notifi.fromMap(i));
    }
    setState(() {
      notifications = userNotifis;
    });
  }

  List<Notifi> notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/search'); },
              splashRadius: 30,
              icon: Icon(IconData(59828, fontFamily: 'MaterialIcons'),
                  color: AppColors.text),
              iconSize: 45,
            ),
            Text(
              'FooBar App',
              style: mainTitleTextStyle,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              splashRadius: 30,
              icon: Icon(IconData(59648, fontFamily: 'MaterialIcons'),
                  color: AppColors.text),
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
          children: notifications.map(
            (notification) => NotificationSection(
              currNotification: notification,
            )
          ).toList(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/feed');
              },
              splashRadius: 30,
              icon: Icon(IconData(0xe7ba, fontFamily: 'MaterialIcons'),
                  color: AppColors.text),
              iconSize: 45,
            ),
            IconButton(
              onPressed: () {},
              splashRadius: 30,
              icon: Icon(IconData(60966, fontFamily: 'MaterialIcons'),
                  color: AppColors.text),
              iconSize: 45,
            ),
            /*
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/messagesall'); },
              splashRadius: 30,
              icon: Icon(IconData(61858, fontFamily: 'MaterialIcons'),
                  color: AppColors.text),
              iconSize: 45,
            ),

             */
          ],
        ),
      ),
    );
  }
}