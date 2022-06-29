import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:path_provider/path_provider.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  bool _checkBoxState = false;
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    pickedFileString = pickedFile.path;
    pickedFileString = pickedFileString.split('/')[pickedFileString.split('/').length - 1];
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _checkBoxState=true;
      } else {
        print('No image selected.');
      }
    });
  }

  String username, bio, oldPhoto, pickedFileString;

  Future uploadImage(BuildContext context) async {

    firebase_storage.Reference firebaseStorageRef =
    firebase_storage.FirebaseStorage.instance.ref().child('photos').child(pickedFileString);
    firebase_storage.UploadTask uploadTask =
    firebaseStorageRef.putFile(_image);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Completed: $value"),
    );
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  User firebaseUser = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  bool exist;

  String photoUrl;
  Future<void> updateAllChanges() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc["username"] == username) {
          exist = true;
        }
      });
    });
    if (exist) {
      exist = false;
    } else {
      if (username != null) {
        users.doc(firebaseUser.uid).update({'username': username})
            .then((value) => print("User Updated"))
            .catchError((error) => print("Failed to update user: $error"));
      }
    }
    if (bio != null) {
      users.doc(firebaseUser.uid).update({'bio': bio});
    }
    if (currPrivStatusList[0] != currPrivStatus) {
      users.doc(firebaseUser.uid).update({'isPrivate': currPrivStatusList[0]});
    }
    //print('FILENAME: $pickedFileString');
    if (_checkBoxState) {
      if (oldPhoto != 'gs://cs310-term-project.appspot.com') {
        print(oldPhoto);
        await firebase_storage.FirebaseStorage.instance.refFromURL(oldPhoto).delete();
      }

      await uploadImage(context);
    }
    //print('FILENAME: $pickedFileString');
    if (pickedFileString != null) {
      users.doc(firebaseUser.uid).update({'profilePhoto': ('/photos/' + pickedFileString)});
      firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child('/photos/' + pickedFileString);
      final photo = await firebaseStorageRef.getDownloadURL();
      photoUrl = photo.toString();
      users.doc(firebaseUser.uid).update({'profilePhotoUrl': photoUrl});

      await FirebaseFirestore
          .instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .then(
              (DocumentSnapshot documentSnapshot) {
            postsRaw = documentSnapshot["usersPosts"];
          });
      for (var e in postsRaw) {
        e['userPhotoUrl'] = photoUrl;
      }
      users.doc(firebaseUser.uid).update({'usersPosts': postsRaw});
    }
  }

  List<dynamic> postsRaw;
  bool currPrivStatus = false;
  List<bool> currPrivStatusList = [false];

  Future<void> loadButton() async {
    await users.doc(firebaseUser.uid).get().then(
            (DocumentSnapshot documentSnapshot) {
          setState(() {
            currPrivStatus = documentSnapshot['isPrivate'];
          });
        }
    );
    currPrivStatusList[0] = currPrivStatus;
  }


  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'ProfileSettings', 'ProfileSettingsState');
    exist = false;
    users.doc(firebaseUser.uid).get().then(
            (DocumentSnapshot documentSnapshot) {
          setState(() {
            oldPhoto = 'gs://cs310-term-project.appspot.com' + documentSnapshot['profilePhoto'];
          });
        }
    );
    loadButton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage("https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")),
                  ),
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () async { await getImage(); },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Change Profile Photo',
              style: bodyNormalTextStyle,
            ),
            /*
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(),
                Container(
                  width: 100.0,
                  child: Text(
                    'Name: ',
                    style: bodyNormalTextStyle,
                  ),
                ),
                Container(
                  width: 225,
                  height: 30,
                  child: TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                      ),
                      style: bodySmallTextStyle
                  ),
                ),
                SizedBox(),
              ],
            ),

             */
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(),
                Container(
                  width: 100.0,
                  child: Text(
                    'Username: ',
                    style: bodyNormalTextStyle,
                  ),
                ),
                Container(
                  width: 225,
                  height: 30,
                  child: TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                      ),
                      onChanged: (String value3) {
                        username = value3;
                      },
                      style: bodySmallTextStyle
                  ),
                ),
                SizedBox(),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(),
                Container(
                  width: 100.0,
                  child: Text(
                    'Bio: ',
                    style: bodyNormalTextStyle,
                  ),
                ),
                Container(
                  width: 225,
                  height: 30,
                  child: TextFormField(
                    maxLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                    ),
                      onChanged: (String value2) {
                        bio = value2;
                      },
                    style: bodySmallTextStyle
                  ),
                ),
                SizedBox(),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 180),
                Container(
                  width: 150.0,
                  child: Text(
                    'Private Profile: ',
                    style: bodyNormalTextStyle,
                  ),
                ),
                Container(
                    child: ToggleButtons(
                      color: AppColors.text,
                      borderColor: AppColors.text,
                      selectedColor: Color(0xFF15AC0B),
                      selectedBorderColor: Color(0xFF15AC0B),
                      fillColor: Color(0xFF6200EE).withOpacity(0.08),
                      splashColor: Color(0xFF6200EE).withOpacity(0.12),
                      hoverColor: Color(0xFF6200EE).withOpacity(0.04),
                      borderRadius: BorderRadius.circular(4.0),
                      isSelected: currPrivStatusList,
                      onPressed: (index) {
                        // Respond to button selection
                        setState(() {
                          //print('1. $currPrivStatusList');
                          currPrivStatusList[index] = !currPrivStatusList[index];
                          //print('2. $currPrivStatusList');
                        });
                      },
                      children: [
                        Icon(Icons.check),
                      ],
                    )
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 200),
                Container(
                  child: ElevatedButton(
                    onPressed: () async { await updateAllChanges(); Navigator.pushNamed(context, '/profile');},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppColors.primary),
                      elevation: MaterialStateProperty.all(10),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                    ),
                    child: Text(
                      'Update Profile',
                      style: bodyNormalTextStyle,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
