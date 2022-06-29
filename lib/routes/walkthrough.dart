import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:term_project/utils/styles.dart';

class WalkthroughPage {
  String text1;
  String text2;
  String url;
  int currPage;
  WalkthroughPage({this.text1, this.text2, this.url, this.currPage});
}

class Walkthrough extends StatefulWidget {
  const Walkthrough({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _WalkthroughState createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  List<WalkthroughPage> walkthroughPagesList = [
    WalkthroughPage(text1: 'Welcome to FooBar App!', text2: 'New generation of social media', url: 'https://static.wixstatic.com/media/8b5fea_f34ebf88d43e43c28520e627446e1dd8~mv2.png/v1/fill/w_458,h_446,al_c,q_85,usm_0.66_1.00_0.01/Social-Media%20(1).webp', currPage: 1),
    WalkthroughPage(text1: 'Welcome to FooBar App!', text2: 'Post your contents easily', url: 'https://image.flaticon.com/icons/png/512/2198/2198963.png', currPage: 2),
    WalkthroughPage(text1: 'Welcome to FooBar App!', text2: 'Meet with new people', url: 'https://mantrahq.com/wp-content/uploads/2020/01/social-Media-Management.png', currPage: 3),
  ];
  String text1, text2, url;
  int currPage, p = 0;

  bool isFirstPage() {
    if (p == 0)
    {
      return true;
    }
    return false;
  }

  bool isLastPage() {
    if (p == 2)
    {
      return true;
    }
    return false;
  }

  void goNextPage()
  {
    setState(() {
      p += 1;
    });
  }
  void goPrevPage()
  {
    setState(() {
        p -= 1;
    });
  }

  bool isPassed = false;

  setPassWalkthroughStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('status', true);
  }

  loadPassWalkthroughStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isPassed = prefs.getBool('status'); }
    );
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Walkthrough', 'WalkthroughState');
    loadPassWalkthroughStatus();
  }

  @override
  Widget build(BuildContext context) {
    text1 = walkthroughPagesList[p].text1;
    text2 = walkthroughPagesList[p].text2;
    url = walkthroughPagesList[p].url;
    currPage = walkthroughPagesList[p].currPage;
    return Scaffold(
      body: Container(
        color: AppColors.background,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(),
            Center(
              child: Text(
                '$text1',
                style: mainTitleTextStyle,
              ),
            ),
            SizedBox(),
            Image(
              color: Colors.white,
              height: 250,
              width: 250,
              //color: AppColors.secondary,
              image: NetworkImage(
                  '$url'
              )
            ),
            Center(
              child: Text(
                '$text2',
                style: bodyLargeTextStyle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Offstage(
                  offstage: isFirstPage(),
                  child: Container(
                    width: 100,
                    height: 50,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      label: Text(
                        'Previous',
                        style: bodySmallTextStyle,
                      ),
                      onPressed: () {
                        goPrevPage();
                      },
                    ),
                  ),
                ),
                Offstage(
                  offstage: !isFirstPage(),
                  child: Container(
                    width: 100,
                    height: 50,
                  ),
                ),
                SizedBox(width: 25),
                Container(
                  width: 75,
                  height: 50,
                  child: Center(
                    child: Text(
                      '$currPage/3',
                      style: bodySmallTextStyle,
                    ),
                  ),
                ),
                SizedBox(width: 25),
                Offstage(
                  offstage: isLastPage(),
                  child: Container(
                    width: 100,
                    height: 50,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      label: Text(
                        'Next',
                        style: bodySmallTextStyle,
                      ),
                      onPressed: () { goNextPage(); },
                    ),
                  ),
                ),
                Offstage(
                  offstage: !isLastPage(),
                  child: Container(
                    width: 100,
                    height: 50,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      label: Text(
                        'Finish',
                        style: bodySmallTextStyle,
                      ),
                      onPressed: () {
                        setPassWalkthroughStatus();
                        Navigator.pushNamed(context, '/welcome');
                      }, //navigator
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}