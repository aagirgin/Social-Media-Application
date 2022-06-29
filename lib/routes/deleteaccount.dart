import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/classes/classes.dart';
import 'package:term_project/services/auth.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _DeleteAccount createState() => _DeleteAccount();
}

class _DeleteAccount extends State<DeleteAccount> {

  User firebaseUser = FirebaseAuth.instance.currentUser;
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  final Auth _auth = Auth();

  List<dynamic> postsRaw;
  List<Post> posts = [];

  String photo, profilePhoto = 'gs://cs310-term-project.appspot.com';

  Future<void> deleteUser () async {

    await FirebaseFirestore
        .instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then(
            (DocumentSnapshot documentSnapshot) {
          postsRaw = documentSnapshot["usersPosts"];
          profilePhoto = profilePhoto + documentSnapshot["profilePhoto"];
        });
    for (var e in postsRaw) {
      posts.add(Post.fromMap(e));
    }
    for (var i in posts) {
      photo = 'gs://cs310-term-project.appspot.com' + i.imagePath;
      print(photo);
      await firebase_storage.FirebaseStorage.instance.refFromURL(photo).delete();
    }

    if (profilePhoto != 'gs://cs310-term-project.appspot.com') {
      print(profilePhoto);
      await firebase_storage.FirebaseStorage.instance.refFromURL(profilePhoto).delete();
    }


    DocumentReference documentReference = FirebaseFirestore
        .instance
        .collection("users")
        .doc(firebaseUser.uid);

    documentReference.delete();
    await firebaseUser.delete();
  }

  Future<void> signOut() async {
    await deleteUser();
    Navigator.popUntil(context, ModalRoute.withName('/welcome'));
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'DeleteAccount', 'DeleteAccountState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Column(

        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Warning',
                style: TextStyle(
                  color: Color(0xFF280505),
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'It is an irreversible process!',
                style: bodyNormalTextStyle
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Delete account",),
                          content: Text("Are you sure to delete your account?"),
                          actions: [
                            FlatButton(onPressed: (){ Navigator.of(context).pop(); }, child: Text('No')),
                            FlatButton(onPressed: (){ Navigator.of(context).pop(); signOut(); }, child: Text('Yes')), //go to welcome page
                          ],
                        );
                      }
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppColors.primary),
                    elevation: MaterialStateProperty.all(10),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                  ),
                  child: Text(
                    'Delete',
                    style: bodyNormalTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
