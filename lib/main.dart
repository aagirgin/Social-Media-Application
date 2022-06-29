import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:term_project/routes/addpost.dart';
import 'package:term_project/routes/addpost2.dart';
import 'package:term_project/routes/contacts.dart';
import 'package:term_project/routes/makecomment.dart';
import 'package:term_project/routes/walkthrough.dart';
import 'package:term_project/routes/welcome.dart';
import 'package:term_project/routes/login.dart';
import 'package:term_project/routes/signup.dart';
import 'package:term_project/routes/feed.dart';
import 'package:term_project/routes/search.dart';
import 'package:term_project/routes/messagesall.dart';
import 'package:term_project/routes/profile.dart';
import 'package:term_project/routes/zoomedphoto.dart';
import 'package:term_project/routes/notifications.dart';
import 'package:term_project/routes/changepassword.dart';
import 'package:term_project/routes/deactivateaccount.dart';
import 'package:term_project/routes/deleteaccount.dart';
import 'package:term_project/routes/settingsall.dart';
import 'package:term_project/routes/profilesettings.dart';
import 'package:term_project/routes/profileothers.dart';
import 'package:term_project/routes/followers.dart';
import 'package:term_project/routes/following.dart';
import 'package:term_project/routes/messagesprivate.dart';
import 'package:term_project/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        return StreamProvider<User>.value(
          value: Auth().user,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AppBase(),
          ),
        );
      }
    );
  }
}

class AppBase extends StatelessWidget {
  const AppBase({
    Key key,
  }) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  static FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[observer],
      home: Walkthrough(analytics: analytics, observer: observer),
      routes: {
        //'/walkthrough': (context) => Walkthrough(analytics: analytics, observer: observer),
        '/welcome': (context) => Welcome(analytics: analytics, observer: observer),
        '/login': (context) => Login(analytics: analytics, observer: observer),
        '/signup': (context) => SignUp(analytics: analytics, observer: observer),
        '/feed': (context) => Feed(analytics: analytics, observer: observer),
        '/search': (context) => Search(analytics: analytics, observer: observer),
        '/messagesall': (context) => DirectMessagesAll(analytics: analytics, observer: observer),
        '/profile': (context) => Profile(analytics: analytics, observer: observer),
        '/zoomedphoto': (context) => ZoomedPhoto(analytics: analytics, observer: observer),
        '/notifications': (context) => Notifications(analytics: analytics, observer: observer),
        '/changepassword': (context) => ChangePassword(analytics: analytics, observer: observer),
        '/deactivateaccount': (context) => DeactivateAccount(analytics: analytics, observer: observer),
        '/deleteaccount': (context) => DeleteAccount(analytics: analytics, observer: observer),
        '/settingsall': (context) => SettingsAll(analytics: analytics, observer: observer),
        '/profilesettings': (context) => ProfileSettings(analytics: analytics, observer: observer),
        '/profileothers': (context) => ProfileOthers(analytics: analytics, observer: observer),
        '/followers': (context) => Followers(analytics: analytics, observer: observer),
        '/following': (context) => Following(analytics: analytics, observer: observer),
        '/contacts': (context) => Contacts(analytics: analytics, observer: observer),
        '/messagesprivate': (context) => DirectMessagesPrivate(analytics: analytics, observer: observer),
        '/addpost': (context) => AddPost(analytics: analytics, observer: observer),
        '/addpost2': (context) => AddPost2(analytics: analytics, observer: observer),
        '/makecomment': (context) => CommentPage(analytics: analytics, observer: observer),
      },
    );
  }
}