import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:term_project/classes/classes.dart';

class Database {

  final String uid;
  Database({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> createUserData(String username, String phoneNumber) async {
    await userCollection.doc(uid).set({
      'username': username,
      'phoneNumber': phoneNumber,
      'postCount': 0,
      'followersCount': 0,
      'followingCount': 0,
      'bio': '',
      'usersPosts': [],
      'userFollowers': [],
      'userNotifications': [],
      'userFollowing': [],
      'usersChats': [],
      'isPrivate': false,
      'isDeactivated': false,
      'profilePhoto': '',
      'profilePhotoUrl': '',
    });
  }
}