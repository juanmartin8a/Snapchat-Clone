import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/services/database.dart';
import 'package:video_player/video_player.dart';

class MyStoryVideoPrev extends StatefulWidget {
  final String imgPath;
  MyStoryVideoPrev({this.imgPath});

  @override
  _MyStoryVideoPrevState createState() => _MyStoryVideoPrevState();
}

class _MyStoryVideoPrevState extends State<MyStoryVideoPrev> {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://snapchatclone-28e90.appspot.com');
  StorageUploadTask _uploadTask;
  StorageTaskSnapshot _taskSnapshot;
  VideoPlayerController _controller;
  Future hasInitialized;

  Future<void> initialize() async {
    //print(widget.index);
    final VideoPlayerController vController = VideoPlayerController.file(File(widget.imgPath));
    vController.addListener(videoPlayerListener);
    await vController.setLooping(true);
    hasInitialized = vController.initialize();
    final VideoPlayerController oldController = _controller;
    if (mounted) {
      print('HEY!!!!!');
      setState(() {
        _controller = vController;
      });
    }
    //print('current post is ${widget.postsList}');
    await vController.play();
    await oldController?.dispose();
    print('controller is $_controller');
  }

  get videoPlayerListener => () {
        if (_controller != null && _controller.value.size != null) {
          // Refreshing the state to update video player with the correct ratio.
          if (mounted) setState(() {});
          _controller.removeListener(videoPlayerListener);
        }
      };

  _startUpload(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (widget.imgPath != null) {
      String filePath = 'stories/${DateTime.now()}.mp4';
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
    String filePath = 'memories/${DateTime.now()}.mp4';
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

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: Container(
              child: FutureBuilder(
                  future: hasInitialized,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        child: VideoPlayer(_controller),
                      );
                    } else {
                      return Container(color: Colors.black);
                    }
                  }))),
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.15,
              color: Colors.transparent,
              child: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: () {
                        _saveSnap(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Icon(
                          Icons.move_to_inbox_rounded,
                          color: Colors.white,
                          size: 31,
                        ),
                      )),
                  GestureDetector(
                      onTap: () {
                        _startUpload(context);
                      },
                      child: Container(
                        height: 55,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        color: Colors.black38,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Container(),
                          Container(
                              child: Row(
                            children: [
                              Container(
                                  child: Text('My Story',
                                      style: TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                          fontSize: 17.7,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  margin: EdgeInsets.only(left: 12),
                                  child: Icon(Icons.send_rounded, color: Colors.white, size: 30))
                            ],
                          ))
                        ]),
                      ))
                ],
              )))),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: AppBar(
          elevation: 0.0,
          leading: IconButton(
              //padding: EdgeInsets.only(top: widget.statusBar),
              icon: Icon(
                Icons.clear_rounded,
                color: Colors.white,
                size: 34,
              ),
              onPressed: () => Navigator.of(context).pop()),
          backgroundColor: Colors.transparent,
        ),
      )
    ]));
  }
}
