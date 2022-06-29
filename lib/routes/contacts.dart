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

class Contacts extends StatefulWidget {
  const Contacts({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  List<AppUser> users = [
    AppUser(username: 'username #1', mail: '', gsm: '', password: '', postCount: 0, followersCount: 0, followingCount: 0, bio: 'desc #1', isPrivate: true, profilePhoto: ''),
    AppUser(username: 'username #2', mail: '', gsm: '', password: '', postCount: 0, followersCount: 0, followingCount: 0, bio: 'desc #2', isPrivate: true, profilePhoto: ''),
  ];

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Contacts', 'ContactsState');
  }

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
        width: 450,
        height: 650,
        child: Column(
            children: <Widget>[
              SizedBox(height: 15),
              Container(
                child: Text(
                  'All Contacts',
                  style: bodyLargeTextStyle,
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 350,
                height: 500,
                child: ListView(
                  padding: EdgeInsets.all(0.0),
                  children: users.map(
                          (user) => UsersMessagesSection(
                          user: user
                      )
                  ).toList(),
                ),
              ),
            ]
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