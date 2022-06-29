import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/database.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:term_project/classes/classes.dart';
import 'package:term_project/classes/models.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Profile extends StatefulWidget {
  const Profile({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  User firebaseUser = FirebaseAuth.instance.currentUser;

  List<dynamic> postsRaw;
  Post post;
  List<Post> posts = [];

  String username = '', bio = '', profilePhoto = '', photoUrl = '';
  int postCount = 0, followersCount = 0, followingCount = 0;

  List<dynamic> userFollowersRaw = [], userFollowingRaw = [];
  List<String> userFollowers = [], userFollowing = [];


  bool isPostClicked = false;

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  Future<void> updatePage() async {
    await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get().then(
            (DocumentSnapshot documentSnapshot) {
          setState(() {
            username = documentSnapshot['username'];
            bio = documentSnapshot['bio'];
            postCount = documentSnapshot['postCount'];
            followersCount = documentSnapshot['followersCount'];
            followingCount = documentSnapshot['followingCount'];
            profilePhoto = documentSnapshot['profilePhoto'];
            userFollowersRaw = documentSnapshot['userFollowers'];
            userFollowingRaw = documentSnapshot['userFollowing'];
          });
        }
    );
    userFollowers.clear();
    for (var i in userFollowersRaw) {
      userFollowers.add(i);
    }
    userFollowing.clear();
    for (var i in userFollowingRaw) {
      userFollowing.add(i);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (userFollowers.contains(doc.id) && doc["isDeactivated"]) {
          userFollowers.remove(doc.id);
          followersCount--;
        }
      });
    });

    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (userFollowing.contains(doc.id) && doc["isDeactivated"]) {
          userFollowing.remove(doc.id);
          followingCount--;
        }
      });
    });


    setState(() {});
    //print(userFollowers);
    //print(userFollowing);
    //print(profilePhoto);
    if (profilePhoto != '') {
      firebase_storage.Reference firebaseStorageRef = firebase_storage
          .FirebaseStorage.instance.ref().child(profilePhoto);
      final photo = await firebaseStorageRef.getDownloadURL();
      photoUrl = photo.toString();
    } else {
      photoUrl = '';
    }
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
      posts.add(Post.fromMap(e));
    }
    setState((){});
  }

  @override
  void initState() {
    updatePage();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Profile', 'ProfileState');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Container(
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(),
                    SizedBox(),
                    SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(),
                        ClipOval(
                          child: Material(
                            color: Colors.green,
                            child: InkWell(
                              child: CircleAvatar(
                                backgroundImage: (photoUrl == '' ? NetworkImage("https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png") : NetworkImage(photoUrl)),
                                backgroundColor: Colors.green,
                                radius: 50,
                              ),
                              onTap: () { Navigator.pushNamed(context, '/zoomedphoto', arguments: {"imageUrl": photoUrl, "username": username}); },
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  username,
                                  style: mainTitleTextStyle,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () { Navigator.pushNamed(context, '/profilesettings'); },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(AppColors.primary),
                                      elevation: MaterialStateProperty.all(10),
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                                    ),
                                    child: Text(
                                      'Profile Settings',
                                      style: bodySmallTextStyle,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () { Navigator.pushNamed(context, '/settingsall'); },
                                    splashRadius: 20,
                                    icon: Icon(
                                      IconData(0xe9c6, fontFamily: 'MaterialIcons'),
                                      color: AppColors.text
                                    ),
                                    iconSize: 30,
                                  ),
                                ]
                              ),
                            ],
                          ),
                        ),
                        SizedBox(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                postCount.toString(),
                                style: bodyNormalTextStyle,
                              ),
                              Text(
                                'Posts',
                                style: bodyNormalTextStyle,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () { Navigator.pushNamed(context, '/followers', arguments: {"followers": userFollowers, "username": username}); },
                          child: Container(
                            width: 100,
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  followersCount.toString(),
                                  style: bodyNormalTextStyle,
                                ),
                                Text(
                                  'Followers',
                                  style: bodyNormalTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () { Navigator.pushNamed(context, '/following', arguments: {"following": userFollowing, "username": username}); },
                          child: Container(
                            width: 100,
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  followingCount.toString(),
                                  style: bodyNormalTextStyle,
                                ),
                                Text(
                                  'Following',
                                  style: bodyNormalTextStyle,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: 350,
                      height: 75,
                      child: Text(
                        'Bio:\n$bio',
                        style: bodyNormalTextStyle,
                      )
                    ),
                    Container(
                      width: 350,
                      height: 390,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 350,
                            height: 390,
                            child: ListView(
                              padding: EdgeInsets.all(0.0),
                              children:
                                posts.map(
                                (post) => PostsOwnSection(
                                  post: post,
                                  like: () {},
                                  dislike: () {},
                                  makeComment: () {},
                                  delete: () {},
                                )
                              ).toList(),
                            ),
                          ),
                        ],
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
            );

      }
    );
  }
}