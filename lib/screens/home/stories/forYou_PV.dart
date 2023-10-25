import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/camera/add_friends.dart';
import 'package:snapchatClone/screens/home/camera/preview_screen.dart';
import 'package:snapchatClone/screens/home/profile/profile.dart';
import 'package:snapchatClone/screens/home/stories/user_stories_child.dart';
import 'package:video_player/video_player.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ForYouPV extends StatefulWidget {
  final String uid;
  final int index;
  final void Function({String returnValue}) onClose;
  ForYouPV({this.uid, this.index, this.onClose});
  @override
  _ForYouPVState createState() => _ForYouPVState();
}

class _ForYouPVState extends State<ForYouPV> {
  PageController _ctrl = PageController();
  PageController _controller;
  int currentPage;
  double vp;
  //double vpToHeight;
  //double vpToWidth;

  @override
  void initState() {
    _controller = PageController(initialPage: widget.index, viewportFraction: 1.45);
    currentPage = widget.index;
    _controller.addListener(() {
      int next = _controller.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
            future: DatabaseService().getAllStories(),
            builder: (context, snaps) {
              if (snaps.hasData) {
                List<Map<String, dynamic>> friendsArray = [];
                for (int i = 0; i < snaps.data.docs.length; i++) {
                  Map<String, dynamic> friendsMap = {
                    'uid': snaps.data.docs[i].data()['uid'],
                  };
                  friendsArray.add(friendsMap);
                }
                List<String> checkArray = [];
                friendsArray.forEach((i) {
                  print('salsa choque');
                  if (checkArray.contains(i["uid"])) {
                    print('there is a duplicate ${i['uid']}');
                  } else {
                    checkArray.add(i["uid"]);
                  }
                });
                print('the f 2 array is ${checkArray}');
                return PageView.builder(
                    controller: _controller,
                    itemCount: checkArray.length,
                    itemBuilder: (context, index) {
                      bool active = index == currentPage;
                      final double blur = active ? 0 : 50;
                      final Color opacity = active ? Colors.transparent : Colors.black45;
                      final double height = active ? 0.0 : MediaQuery.of(context).size.height * 0.150;
                      print('the f 2 array is ${checkArray}');
                      return FractionallySizedBox(
                          widthFactor: 1 / _controller.viewportFraction,
                          child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeIn,
                              height: height,
                              decoration: BoxDecoration(color: opacity, boxShadow: [BoxShadow(blurRadius: blur)]),
                              margin: EdgeInsets.symmetric(vertical: height),
                              child: StreamBuilder<DocumentSnapshot>(
                                  stream: DatabaseService(uid: checkArray[index]).getUserProfile(),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      Map<String, dynamic> userDocs = snapshot.data.data();
                                      print('the future user uid is ${userDocs['uid']}');
                                      return Stack(children: [
                                        Positioned.fill(
                                            child: Container(
                                                child: FutureBuilder(
                                                    future: DatabaseService(uid: userDocs['uid'])
                                                        .getStories(userDocs['uid']),
                                                    builder: (context, snap) {
                                                      if (snap.hasData) {
                                                        print(
                                                            'the current user storie length is ${snap.data.docs.length}');
                                                        return FutureBuilder(
                                                            future: DatabaseService(uid: userDocs['uid'])
                                                                .getStoriesTime(DateTime.now()),
                                                            builder: (context, snapTime) {
                                                              if (snapTime.hasData) {
                                                                print(
                                                                    'the current user storie time  length is ${snapTime.data.docs.length}');
                                                                List<Map<String, dynamic>> storiesArray = [];
                                                                for (int i = 0; i < snap.data.docs.length; i++) {
                                                                  Map<String, dynamic> storiesMap = {
                                                                    'story': snap.data.docs[i].data()['theFile'],
                                                                    'uid': snap.data.docs[i].data()['uid'],
                                                                    'id': snap.data.docs[i].data()['id'],
                                                                    'created': snap.data.docs[i].data()['created'],
                                                                  };
                                                                  storiesArray.add(storiesMap);
                                                                }
                                                                return PageView.builder(
                                                                    physics: new NeverScrollableScrollPhysics(),
                                                                    controller: _ctrl,
                                                                    scrollDirection: Axis.horizontal,
                                                                    itemCount: storiesArray.length,
                                                                    itemBuilder: (context, theIndex) {
                                                                      //if (_ctrl.position.haveDimensions) {
                                                                      final createdTimeAgo = timeAgo.format(
                                                                          storiesArray[theIndex]['created'].toDate(),
                                                                          locale: 'en_short');
                                                                      final timeElapsed =
                                                                          createdTimeAgo.replaceAll(' ', '');
                                                                      return UserStoriesChild(
                                                                          theFile: storiesArray[theIndex]['story'],
                                                                          name: userDocs['name'],
                                                                          timeAgo: timeElapsed,
                                                                          ctrl: _ctrl,
                                                                          onClose: widget.onClose);
                                                                    });
                                                              } else {
                                                                return Container();
                                                              }
                                                            });
                                                      } else {
                                                        return Container();
                                                      }
                                                    }))),
                                      ]);
                                    } else {
                                      return Container();
                                    }
                                  })));
                    });
              } else {
                return Container();
              }
            }));
  }
}
