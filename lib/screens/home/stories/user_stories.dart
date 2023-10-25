import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/stories/user_stories_child.dart';
import 'package:video_player/video_player.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class UserStories extends StatefulWidget {
  final String uid;
  final int index;
  final void Function({String returnValue}) onClose;
  UserStories({this.uid, this.index, this.onClose});
  @override
  _UserStoriesState createState() => _UserStoriesState();
}

class _UserStoriesState extends State<UserStories> {
  PageController _ctrl = PageController();
  PageController _controller;
  int currentPage;
  double vp;
  List<String> storiesCheckArray = [];
  List<String> storiesPreCheckArray = [];
  bool userHasStories = true;

  checkIfFriendHasStories() async {
    final user = Provider.of<CustomUser>(this.context, listen: false);
    print('good till now');
    await FirebaseFirestore.instance
        .collection('usernames')
        .doc(user.uid)
        .collection('addedUsers')
        .get()
        .then((snapshot) async {
      print('saposalsa toro');
      if (snapshot.docs.length > 0) {
        storiesPreCheckArray.clear();
        for (int i = 0; i < snapshot.docs.length; i++) {
          print('there is check uid is  ${snapshot.docs[i].data()['addedUserUid']}');
          setState(() {
            storiesPreCheckArray.add(snapshot.docs[i].data()['addedUserUid']);
            storiesPreCheckArray.insert(0, user.uid);
          });
          print('the pre check array uid is  ${storiesPreCheckArray}');
          /**/
        }
      } else {
        storiesPreCheckArray.add(user.uid);
      }
    });
    for (int i = 0; i < storiesPreCheckArray.length; i++) {
      print('stories pre check fro loop is working yey ${storiesPreCheckArray.length}');
      print('stories pre check uid is ${storiesPreCheckArray[i]}');
      await FirebaseFirestore.instance
          .collection('stories')
          .where('uid', isEqualTo: storiesPreCheckArray[i])
          .get()
          .then((snap) {
        for (int j = 0; j < snap.docs.length; j++) {
          print('the storie uid is  ${snap.docs[j].data()['uid']}');
          setState(() {
            List<Map<String, dynamic>> friendsArray = [];
            for (int s = 0; s < snap.docs.length; s++) {
              Map<String, dynamic> friendsMap = {
                //'friendUid': snapshot.data.docs[i].data()['uid'],
                //'storie': snapshot.data.docs[i].data()['theFile'],
                'uid': snap.docs[s].data()['uid'],
                //'id': snapshot.data.docs[i].data()['id'],
              };
              friendsArray.add(friendsMap);
            }
            friendsArray.forEach((i) {
              if (storiesCheckArray.contains(i["uid"])) {
                print('there is a duplicate ${i['uid']}');
                //friendsArray.remove(i['uid']);
              } else {
                storiesCheckArray.add(i["uid"]);
              }
            });
            if (storiesCheckArray.length > 0) {
              //setState(() {
              userHasStories = true;
              //});
            } else {
              //setState(() {
              userHasStories = false;
              //});
            }
          });
          print('checkray is now $storiesCheckArray');
        }
        print('the check array is ${storiesCheckArray}');
        print('the check array length is ${storiesCheckArray.length}');
        print('stories map is being called ');
      });
    }
  }

  @override
  void initState() {
    checkIfFriendHasStories();
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

  void dispose() {
    _ctrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: userHasStories
            ? PageView.builder(
                controller: _controller,
                itemCount: storiesCheckArray.length,
                itemBuilder: (context, index) {
                  bool active = index == currentPage;
                  final double blur = active ? 0 : 50;
                  final Color opacity = active ? Colors.transparent : Colors.black45;
                  final double height = active ? 0.0 : MediaQuery.of(context).size.height * 0.150;
                  print('the user uid is ${storiesCheckArray[index]}');
                  return FractionallySizedBox(
                      widthFactor: 1 / _controller.viewportFraction,
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeIn,
                          height: height,
                          decoration: BoxDecoration(color: opacity, boxShadow: [BoxShadow(blurRadius: blur)]),
                          margin: EdgeInsets.symmetric(vertical: height),
                          child: StreamBuilder<DocumentSnapshot>(
                              stream: DatabaseService(uid: storiesCheckArray[index]).getUserProfile(),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  Map<String, dynamic> userDocs = snapshot.data.data();
                                  print('the future user uid is ${userDocs['uid']}');
                                  return Stack(children: [
                                    Positioned.fill(
                                        child: Container(
                                            child: FutureBuilder(
                                                future:
                                                    DatabaseService(uid: userDocs['uid']).getStories(userDocs['uid']),
                                                builder: (context, snap) {
                                                  if (snap.hasData) {
                                                    print('the current user storie length is ${snap.data.docs.length}');
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
                                                                      id: storiesArray[theIndex]['id'],
                                                                      theUid: storiesArray[theIndex]['uid'],
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
                })
            : Container());
  }
}
