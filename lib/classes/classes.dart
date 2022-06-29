class AppUser {
  String username;
  String mail;
  String gsm;
  String password;
  int postCount;
  int followersCount;
  int followingCount;
  String bio;
  List<Post> usersPosts;
  List<Notifi> userFollowers;
  List<String> userNotifications;
  List<String> userFollowing;
  List<Chat> usersChats;
  bool isPrivate;
  bool isDeactivated;
  String profilePhoto;
  String profilePhotoUrl;
  AppUser({ this.username, this.mail, this.gsm, this.password, this.postCount, this.followersCount, this.followingCount, this.bio, this.isPrivate, this.isDeactivated, this.profilePhoto, this.profilePhotoUrl });
  AppUser.fromMap(Map map){
    username = map['username'];
    mail = map['mail'];
    gsm = map['gsm'];
    password = map['password'];
    postCount = map['postCount'];
    followersCount = map['followersCount'];
    followingCount = map['followingCount'];
    bio = map['bio'];
    usersPosts = [];
    userNotifications = [];
    userFollowers = [];
    userFollowing = [];
    usersChats = [];
    isPrivate = map['isPrivate'];
    isDeactivated = map['isDeactivated'];
    profilePhoto = map['profilePhoto'];
    profilePhotoUrl = map['profilePhotoUrl'];
  }
}

class Post {
  String imagePath;
  String imageUrl;
  String userPhotoUrl;
  String description;
  int likes;
  int dislikes;
  int reports;
  List<String> comments;
  List<String> likeUsersID;
  List<String> dislikeUsersID;
  List<String> reportUsersID;
  List<String> commentUsersID;
  Post({ this.imagePath, this.description, this.likes, this.dislikes, this.reports, this.userPhotoUrl, this.imageUrl});

  Post.fromMap(Map map){
    imageUrl = map['imageUrl'];
    userPhotoUrl = map['userPhotoUrl'];
    imagePath = map['imagePath'];
    description = map['description'];
    likes = map['likes'];
    dislikes = map['dislikes'];
    reports = map['reports'];
    commentUsersID = [];
    for (var i in map['commentUsersID']) {
      commentUsersID.add(i.toString());
    }
    comments = [];
    for (var i in map['comments']) {
      comments.add(i.toString());
    }
    likeUsersID = [];
    for (var i in map['likeUsersID']) {
      likeUsersID.add(i.toString());
    }
    dislikeUsersID = [];
    for (var i in map['dislikeUsersID']) {
      dislikeUsersID.add(i.toString());
    }
    reportUsersID = [];
    for (var i in map['reportUserID']) {
      reportUsersID.add(i.toString());
    }
  }
}

class Notifi {
  String userID;
  String message;
  Notifi({ this.userID, this.message });
  Notifi.fromMap(Map map){
    userID = map['userID'];
    message = map['message'];
  }
}

class ChatType {
  String msg;
  String type;
  ChatType({ this.msg, this.type });
}

class Chat {
  AppUser user;
  List<ChatType> chatbox;
  Chat({ this.user, this.chatbox });
}