import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:term_project/utils/analytics.dart';
import 'package:term_project/utils/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:term_project/utils/colors.dart';
import 'package:term_project/utils/styles.dart';
import 'package:term_project/classes/classes.dart';
import 'package:term_project/classes/models.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key key, this.analytics, this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _AddPostState createState() => _AddPostState();
}
class _AddPostState extends State<AddPost> {

  bool _checkBoxState = false;
  File _image;
  final picker = ImagePicker();
  String pickedFileString;
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


  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'AddPost', 'AddPostState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(),
            Text(
              'Add New Post',
              style: mainTitleTextStyle,
            ),
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/addpost2', arguments: {"image": _image, "filename": pickedFileString}); },
              splashRadius: 30,
              icon: Icon(
                IconData(59087, fontFamily: 'MaterialIcons'),
                color: _checkBoxState ? Colors.deepOrange: Colors.grey,
              ),
              iconSize: 45,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0.0,
      ),

      body: Center(
        child: _image == null
            ? Text('No image selected.')
            : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}