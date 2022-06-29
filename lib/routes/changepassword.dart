import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  String password;

  User firebaseUser = FirebaseAuth.instance.currentUser;

  void changePassword()
  {
    firebaseUser.updatePassword(password);
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'ChangePassword', 'ChangePasswordState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
          children: [
          SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 175.0,
                child: Text(
                  'New Password: ',
                  style: bodyNormalTextStyle,
                ),
              ),
              Container(
                width: 175,
                height: 30,
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '********',
                    hintStyle: TextStyle(
                      color: AppColors.text,
                    )
                  ),
                  validator: (value) {
                    if(value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if(value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    password = value;
                  },
                ),
              ),
            ],
          ),
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 200),
                Container(
                height: 40,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () { Navigator.of(context).pop(); changePassword(); },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppColors.primary),
                      elevation: MaterialStateProperty.all(10),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                    ),
                    child: Text(
                      'Change Password',
                      style: bodyNormalTextStyle,
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
