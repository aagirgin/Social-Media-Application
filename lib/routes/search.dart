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

class Search extends StatefulWidget {
  const Search({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  User firebaseUser = FirebaseAuth.instance.currentUser;

  List<AppUser> users = [], allusers = [];

  List<Post> allposts = [];

  List<Post> posts = [];

  bool isUserClicked = false;
  AppUser dummy;
  final textFieldFocusNode = FocusNode();
  String searchText = '';

  List<dynamic> postsRaw;
  List<dynamic> myFollowersRaw;
  List<String> myFollowers = [];


  Future<void> search() async {
    users.clear();
    allposts.clear();
    await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get().then(
      (DocumentSnapshot documentSnapshot) {
        setState(() {
          currUsername = documentSnapshot['username'];
          myFollowersRaw = documentSnapshot['userFollowers'];
        });
      }
    );
    for (var i in myFollowersRaw) {
      myFollowers.add(i.toString());

    }
    if (searchText == '') {
      /*
      FirebaseFirestore.instance
          .collection('users')
          .where('isDeactivated', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          if (doc["username"] != currUsername) {
            setState(() { users.add(AppUser.fromMap(doc.data())); });
          }
        });
      });
       */
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .where('isDeactivated', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          if (doc["username"] != currUsername && doc["username"].contains(searchText)) {
            setState(() { users.add(AppUser.fromMap(doc.data())); });
          }
        });
      });
    }
    await FirebaseFirestore.instance
        .collection('users')
        .where('isDeactivated', isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc["username"] != currUsername && (myFollowers.contains(doc.data()) || doc["isPrivate"] == false)) {
          postsRaw = doc["usersPosts"];
          for (var e in postsRaw) {
            allposts.add(Post.fromMap(e));
          }
        }
      });
    });

    //print("Posts: $posts");
    posts.clear();
    //print("AllPosts: $allposts");

    if (searchText != '') {
      for (var i in allposts) {
        if (i.description.contains(searchText)) {
          setState(() {
            posts.add(i);
          });
        }
      }
    } else {
      /*
      for (var i in allposts) {
        setState(() {posts.add(i);});
      }

       */
    }
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  String currUsername;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Search', 'SearchState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 65,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              onPressed: () {},
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 350,
                    child: TextField(
                      onChanged: (String value) {
                        searchText = value;
                      },
                      focusNode: textFieldFocusNode,
                      style: bodySmallTextStyle,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9885B1))
                        ),
                        labelText: 'Search',
                        labelStyle: bodySmallTextStyle,
                        suffixIcon: IconButton(
                          onPressed: () { textFieldFocusNode.unfocus(); search(); setState(() {});},
                          splashRadius: 55,
                          icon: Icon(
                              IconData(59828, fontFamily: 'MaterialIcons'),
                              color: AppColors.text
                          ),
                          iconSize: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 350,
              height: 450,
              child: PageView(
                controller: PageController(initialPage: 0),
                scrollDirection: Axis.horizontal,
                children: [
                  usersSection(users),
                  postsSection(posts),
                ],
              ),
            ),
          ],
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
}

Widget usersSection(List<AppUser> users) {
  return Container(
    width: 350,
    height: 450,
    child: ListView(
      padding: EdgeInsets.all(0.0),
      children: users.map(
              (each) => UsersSection(
              user: each
          )
      ).toList(),
    ),
  );
}

Widget postsSection(List<Post> posts) {
  return Container(
    width: 350,
    height: 450,
    child: ListView(
      padding: EdgeInsets.all(0.0),
      children: posts.map(
              (post) => PostsOthersSection(
            post: post,
            like: () {},
            dislike: () {},
            makeComment: () {},
            bookmark: () {},
          )
      ).toList(),
    ),
  );
}
