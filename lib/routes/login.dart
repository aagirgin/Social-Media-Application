import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/services/auth.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';

class Login extends StatefulWidget {
  const Login({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final Auth _auth = Auth();
  String _message = '';
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  bool isEnteredApp = false;
  String mail;
  String password;
  final _formKey = GlobalKey<FormState>();

  setEnteredAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enteredApp', true);
  }

  loadEnteredAppStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnteredApp = prefs.getBool('enteredApp'); }
    );
  }

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  User firebaseUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> loginUser() async {

    dynamic result = await _auth.signInWithEmailAndPassword(mail, password);
    if (result == null) {
      setmessage('User login failed.');
    } else {
      firebaseUser = FirebaseAuth.instance.currentUser;
      await users.doc(firebaseUser.uid).update({'isDeactivated': false});


      setEnteredAppStatus();
      Navigator.pushNamed(context, '/feed');
    }
  }
  /*
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      setEnteredAppStatus();
      Navigator.pushNamed(context, '/feed');
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      print("Failed to sign-in.");
    }
  }
  */

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Login', 'LoginState');
    loadEnteredAppStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'FooBar App',
          style: mainTitleTextStyle
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              child: Text(
                'Log In',
                style: fancyTextStyle
              )
            ),
            SizedBox(
              height: 15,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField(
                      style: TextStyle(
                          color: AppColors.text
                      ),
                      decoration: InputDecoration(
                        counterText: ' ',
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF9885B1))),
                        labelText: 'E-mail',
                        labelStyle: bodySmallTextStyle,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if(value.isEmpty) {
                          return 'Please enter your e-mail';
                        }
                        if(!EmailValidator.validate(value)) {
                          return 'The e-mail address is not valid';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        mail = value;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField(
                      style: TextStyle(
                          color: AppColors.text
                      ),
                      decoration: InputDecoration(
                        counterText: ' ',
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF9885B1))),
                        labelText: 'Password',
                        labelStyle: bodySmallTextStyle,
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
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
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              width: 250, height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    setmessage('');
                    _formKey.currentState.save();
                    loginUser();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.primary),
                  elevation: MaterialStateProperty.all(10),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                ),
                child: Text(
                  'Log In',
                  style: bodyNormalTextStyle,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '$_message',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.red[900],
              )
            ),
            FlatButton(
              onPressed: () {},
              textColor: AppColors.primary,
              child: Text(
                'Forgot Password?',
                style: bodySmallTextStyle,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Do not have an account?',
                    style: bodySmallTextStyle
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: (){ Navigator.pushNamed(context, '/signup'); },
                    child: Text(
                      '<Sign Up>',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
            ),
            /*
            Container(
              width: 225,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.background),
                  elevation: MaterialStateProperty.all(0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Login with Google',
                      style: bodySmallTextStyle,
                    ),
                    SizedBox(width: 12),
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png',
                       height: 35.0,
                    ),
                  ],
                ),
                onPressed: () {
                  signInWithGoogle();
                },
              ),
            ),
            */
          ],
        )
      )
    );
  }
}