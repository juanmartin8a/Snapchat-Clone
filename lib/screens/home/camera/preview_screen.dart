import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/services/database.dart';

class PreviewScreen extends StatefulWidget {
  final String imgPath;

  PreviewScreen({this.imgPath});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> with SingleTickerProviderStateMixin {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://snapchatclone-28e90.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;

  _startUpload(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (widget.imgPath != null) {
      String filePath = 'stories/${DateTime.now()}.png';
      _uploadTask = _storage.ref().child(filePath).putFile(File(widget.imgPath));
      _taskSnapshot = await _uploadTask.onComplete;
      final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
      DocumentReference docRef = FirebaseFirestore.instance.collection('stories').doc();
      //DocumentReference docRef = FirebaseFirestore.instance.collection('usernames').doc(user.uid).collection('stories').doc();
      Map<String, dynamic> storyMap = {
        'theFile': downloadUrl,
        'uid': user.uid,
        'created': DateTime.now(),
        'deleted': DateTime.now().add(Duration(days: 1)),
        'id': docRef.id,
      };
      DatabaseService().addStory(storyMap, docRef);
    }
  }

  _saveSnap(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    String filePath = 'memories/${DateTime.now()}.png';
    _uploadTask = _storage.ref().child(filePath).putFile(File(widget.imgPath));
    _taskSnapshot = await _uploadTask.onComplete;
    final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('usernames').doc(user.uid).collection('memories').doc();
    String year = DateTime.now().year.toString();
    String month = DateTime.now().month.toString();
    DateTime now = DateTime.now();
    String day = DateTime.now().day.toString();
    String formatedMonth = DateFormat('MMMM').format(now);
    List<String> splitListYear = year.split(" ");
    List<String> splitListMonth = month.split(" ");
    List<String> splitListDay = day.split(" ");
    List<String> splitListFMonth = formatedMonth.split(" ");
    List<String> indexList = [];
    for (int i = 0; i < splitListYear.length; i++) {
      for (int y = 1; y < splitListYear[i].length + 1; y++) {
        indexList.add(splitListYear[i].substring(0, y).toLowerCase());
      }
    }
    for (int i = 0; i < splitListMonth.length; i++) {
      for (int y = 1; y < splitListMonth[i].length + 1; y++) {
        indexList.add(splitListMonth[i].substring(0, y).toLowerCase());
      }
    }
    for (int i = 0; i < splitListDay.length; i++) {
      for (int y = 1; y < splitListDay[i].length + 1; y++) {
        indexList.add(splitListDay[i].substring(0, y).toLowerCase());
      }
    }
    for (int i = 0; i < splitListFMonth.length; i++) {
      for (int y = 1; y < splitListFMonth[i].length + 1; y++) {
        indexList.add(splitListFMonth[i].substring(0, y).toLowerCase());
      }
    }
    Map<String, dynamic> snapMap = {
      'snap': downloadUrl,
      'id': docRef.id,
      'userUid': user.uid,
      'createdArray': indexList,
      'created': DateTime.now(),
    };
    DatabaseService().saveSnap(snapMap, docRef);
  }

  AnimationController _controller1;
  Animation<double> _size1Animation;
  bool hasSaved = false;
  bool toStory = false;
  Animation _curve1;

  @override
  void initState() {
    _controller1 = AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _curve1 = CurvedAnimation(parent: _controller1, curve: Curves.bounceInOut);
    _size1Animation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 30, end: 40), weight: 40),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 40, end: 30), weight: 40)
    ]).animate(_curve1);
    _controller1.addListener(() {});
    _controller1.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        setState(() {
          hasSaved = true;
        });

      if (status == AnimationStatus.dismissed)
        setState(() {
          hasSaved = false;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(child: Container(child: Image.file(File(widget.imgPath), fit: BoxFit.fill))),
      Positioned.fill(
          child: Container(
              color: Colors.transparent,
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.96,
                      //height: MediaQuery.of(context).size.height * 0.07,
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      if (hasSaved == true) {
                                        null;
                                      } else {
                                        _saveSnap(context);
                                        _controller1.forward();
                                      }
                                    },
                                    child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                                child: AnimatedCrossFade(
                                              firstChild: Icon(Icons.check_rounded,
                                                  color: Colors.white, size: _size1Animation.value),
                                              secondChild: Icon(Icons.save_alt_rounded,
                                                  color: Colors.white, size: _size1Animation.value),
                                              crossFadeState:
                                                  hasSaved ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                              duration: Duration(milliseconds: 400),
                                            )),
                                            Container(
                                                child: Text('Save',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 0.4)))
                                          ],
                                        ))),
                                GestureDetector(
                                    onTap: () {
                                      if (toStory == true) {
                                        null;
                                      } else {
                                        _startUpload(context);
                                        setState(() {
                                          toStory = true;
                                        });
                                      }
                                    },
                                    child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                                child: AnimatedCrossFade(
                                              firstChild: Icon(Icons.check_rounded, color: Colors.white, size: 30),
                                              secondChild:
                                                  Icon(Icons.my_library_add_outlined, color: Colors.white, size: 30),
                                              crossFadeState:
                                                  toStory ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                              duration: Duration(milliseconds: 400),
                                            )),
                                            Container(
                                                child: Text('Story',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 0.4)))
                                          ],
                                        )))
                              ]),
                          //Container
                        ],
                      ))))),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
      )
    ]));
  }
}
