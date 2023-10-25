import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/stories/for_you_child.dart';
import 'package:snapchatClone/screens/home/stories/stories_child.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class Stories extends StatefulWidget {
  final double statusBar;
  Stories({this.statusBar});
  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  List<String> storiesCheckArray = [];
  List<String> storiesPreCheckArray = [];
  bool userHasStories;
  bool isLoading = true;

  _saveDeviceToken(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    String fcmToken = await _fcm.getToken();
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('usernames').doc(user.uid).collection('tokens').doc();
    if (fcmToken != null) {
      Map<String, dynamic> tokenMap = {
        'token': fcmToken,
        'createdAt': '${FieldValue.serverTimestamp()}',
        'platform': Platform.operatingSystem,
        'id': docRef.id
      };
      DatabaseService(uid: user.uid).saveUserTokens(tokenMap, fcmToken);
    }
  }

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
      print('the length saposalsa is ${snapshot.docs.length}');
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
        //userHasStories = false;
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
              isLoading = false;
              userHasStories = true;
              //});
            } else {
              //setState(() {
              isLoading = false;
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
    super.initState();
    checkIfFriendHasStories();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: true,
      leading: null,
      titleSpacing: 0.0,
      backgroundColor: Colors.transparent,
      title: Container(
          color: Colors.transparent,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text('Stories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
      centerTitle: true,
    );
    return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Stack(children: [
          Positioned.fill(
              child: Container(
            color: Colors.grey[100],
          )),
          Positioned(top: 0.0, left: 0.0, right: 0.0, child: appBar),
          Positioned(
              top: appBar.preferredSize.height + widget.statusBar,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                  //color: Colors.red,
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    /*height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,*/
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: Column(children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text('Friends',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 17.2, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                      Container(
                          //color: Colors.red,
                          height: MediaQuery.of(context).size.height * 0.17,
                          width: MediaQuery.of(context).size.width,
                          //margin: EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Container(
                              color: Colors.transparent,
                              child: userHasStories == true
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: storiesCheckArray.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        //children: snapshot.data.docs.map<Widget>((DocumentSnapshot doc) {
                                        return Container(
                                            margin: EdgeInsets.symmetric(horizontal: 6),
                                            child: StreamBuilder<DocumentSnapshot>(
                                                stream: DatabaseService(uid: storiesCheckArray[index]).getUserProfile(),
                                                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                                  if (userSnapshot.hasData) {
                                                    Map<String, dynamic> userDocs = userSnapshot.data.data();

                                                    return FutureBuilder(
                                                        future: DatabaseService(uid: userDocs['uid'])
                                                            .getStories(userDocs['uid']),
                                                        builder: (context, snap) {
                                                          //print('the first image from the doc is ${snap.data.docs[0].data()['uid']}');
                                                          print('second future builder works');
                                                          if (snap.connectionState == ConnectionState.done &&
                                                              snap.data.docs.length > 0) {
                                                            List<Map<String, dynamic>> storiesArray = [];
                                                            for (int j = 0; j < snap.data.docs.length; j++) {
                                                              Map<String, dynamic> storiesMap = {
                                                                'storie': snap.data.docs[j].data()['theFile'],
                                                                'uid': snap.data.docs[j].data()['uid'],
                                                                'id': snap.data.docs[j].data()['id'],
                                                              };
                                                              storiesArray.add(storiesMap);
                                                            }
                                                            return Container(
                                                                //aspectRatio: 1,
                                                                child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                  Container(
                                                                      height: MediaQuery.of(context).size.height * 0.1,
                                                                      width: MediaQuery.of(context).size.height * 0.1,
                                                                      decoration: BoxDecoration(
                                                                        //color: Colors.red,
                                                                        border: Border.all(
                                                                            width: 3, color: Colors.purple[400]),
                                                                        borderRadius: BorderRadius.circular(100 / 2),
                                                                      ),
                                                                      child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(100 / 2),
                                                                          child: Container(
                                                                            alignment: Alignment.center,
                                                                            padding: EdgeInsets.all(2),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.transparent,
                                                                              borderRadius:
                                                                                  BorderRadius.circular(100 / 2),
                                                                            ),
                                                                            child: StoriesChild(
                                                                              index: index,
                                                                              theFilePrev:
                                                                                  storiesArray[storiesArray.length - 1]
                                                                                      ['storie'],
                                                                              theUid:
                                                                                  storiesArray[storiesArray.length - 1]
                                                                                      ['uid'],
                                                                            ),
                                                                          ))),
                                                                  Container(
                                                                      margin: EdgeInsets.only(top: 6),
                                                                      child: Text(userDocs['name'],
                                                                          textAlign: TextAlign.center,
                                                                          style: TextStyle(
                                                                              color: Colors.grey[900],
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w600)))
                                                                ]));
                                                          } else if (snap.connectionState == ConnectionState.waiting) {
                                                            return Container();
                                                          } else if (!snap.hasData) {
                                                            return Container();
                                                          } else if (snap.data.docs.length <= 0 ||
                                                              storiesCheckArray.length <= 0) {
                                                            return Container(
                                                                width: MediaQuery.of(context).size.width,
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    Container(
                                                                        child: Text(
                                                                            'Stories from your friends will appear here.',
                                                                            textAlign: TextAlign.center,
                                                                            style: TextStyle(
                                                                              color: Colors.grey[500],
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w600,
                                                                              letterSpacing: 0.5,
                                                                            ))),
                                                                    Container(
                                                                        //margin: EdgeInsets.only(top: 8),
                                                                        padding: EdgeInsets.symmetric(
                                                                            vertical: 10, horizontal: 20),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.purple[400],
                                                                          borderRadius: BorderRadius.circular(100 / 2),
                                                                        ),
                                                                        child: Text('Add Friends',
                                                                            textAlign: TextAlign.center,
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 16.8,
                                                                              fontWeight: FontWeight.bold,
                                                                              letterSpacing: 0.4,
                                                                            )))
                                                                  ],
                                                                ));
                                                          } else {
                                                            return Container();
                                                          }
                                                        });
                                                  } else if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                    return Container();
                                                  } else if (!userSnapshot.hasData) {
                                                    return Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                                child:
                                                                    Text('Stories from your friends will appear here.',
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(
                                                                          color: Colors.grey[500],
                                                                          fontSize: 15,
                                                                          fontWeight: FontWeight.w600,
                                                                          letterSpacing: 0.5,
                                                                        ))),
                                                            Container(
                                                                //margin: EdgeInsets.only(top: 8),
                                                                padding:
                                                                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.purple[400],
                                                                  borderRadius: BorderRadius.circular(100 / 2),
                                                                ),
                                                                child: Text('Add Friends',
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 16.8,
                                                                      fontWeight: FontWeight.bold,
                                                                      letterSpacing: 0.4,
                                                                    )))
                                                          ],
                                                        ));
                                                  } else {
                                                    return Container();
                                                  }
                                                }));
                                      })
                                  : isLoading
                                      ? Container()
                                      : Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                  child: Text('Stories from your friends will appear here.',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 0.5,
                                                      ))),
                                              Container(
                                                  //margin: EdgeInsets.only(top: 8),
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.purple[400],
                                                    borderRadius: BorderRadius.circular(100 / 2),
                                                  ),
                                                  child: Text('Add Friends',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.8,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 0.4,
                                                      )))
                                            ],
                                          ))))
                    ])),
                Expanded(
                    child: Container(
                        //height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        //color: Colors.red,
                        child: FutureBuilder(
                            future: DatabaseService().getAllStories(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<Map<String, dynamic>> friendsArray = [];
                                for (int i = 0; i < snapshot.data.docs.length; i++) {
                                  Map<String, dynamic> friendsMap = {
                                    //'friendUid': snapshot.data.docs[i].data()['uid'],
                                    //'storie': snapshot.data.docs[i].data()['theFile'],
                                    'uid': snapshot.data.docs[i].data()['uid'],
                                    //'id': snapshot.data.docs[i].data()['id'],
                                  };
                                  friendsArray.add(friendsMap);
                                }
                                List<String> checkArray = [];
                                friendsArray.forEach((i) {
                                  print('salsa choque');
                                  if (checkArray.contains(i["uid"])) {
                                    //print('there is a duplicate ${i['uid']}');
                                    //friendsArray.remove(i['uid']);
                                  } else {
                                    checkArray.add(i["uid"]);
                                  }

                                  /*else
                                    friendsArray.add(i["uid"]);*/
                                });
                                var nonRepeatedFriendsArray = [
                                  // to remove all eual data in array
                                  ...{...friendsArray}
                                ];
                                print('the f array is ${checkArray}');
                                return checkArray.isNotEmpty
                                    ? Container(
                                        child: Column(children: [
                                        Container(
                                            //color: Colors.blue,
                                            width: MediaQuery.of(context).size.width,
                                            child: Text('For you',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 17.2,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[800]))),
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                                //color: Colors.yellow,
                                                child: SizedBox(
                                                    child: GridView.count(
                                                        crossAxisCount: 2,
                                                        shrinkWrap: true,
                                                        primary: true,
                                                        childAspectRatio: (9 / 14),
                                                        padding: EdgeInsets.zero,
                                                        children: List.generate(checkArray.length, (int theIndex) {
                                                          return Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                                              child: StreamBuilder<DocumentSnapshot>(
                                                                  stream: DatabaseService(uid: checkArray[theIndex])
                                                                      .getUserProfile(),
                                                                  builder: (context,
                                                                      AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                                                    if (userSnapshot.hasData) {
                                                                      Map<String, dynamic> userDocs =
                                                                          userSnapshot.data.data();
                                                                      return FutureBuilder(
                                                                          future: DatabaseService()
                                                                              .getStories(userDocs['uid']),
                                                                          builder: (context, snap1) {
                                                                            //print('the first image from the doc is ${snap.data.docs[0].data()['uid']}');
                                                                            print('second future builder works');
                                                                            if (snap1.connectionState ==
                                                                                    ConnectionState.done &&
                                                                                snap1.data.docs.length > 0) {
                                                                              List<Map<String, dynamic>> theStoryArray =
                                                                                  [];
                                                                              for (int j = 0;
                                                                                  j < snap1.data.docs.length;
                                                                                  j++) {
                                                                                Map<String, dynamic> storiesMap = {
                                                                                  'storie': snap1.data.docs[j]
                                                                                      .data()['theFile'],
                                                                                  'uid':
                                                                                      snap1.data.docs[j].data()['uid'],
                                                                                  'id': snap1.data.docs[j].data()['id'],
                                                                                };
                                                                                theStoryArray.add(storiesMap);
                                                                              }
                                                                              print(
                                                                                  'theStoryArray length is ${theStoryArray.length}');
                                                                              print('check array ${checkArray}');
                                                                              return ClipRRect(
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(14),
                                                                                  child: Container(
                                                                                      //color: Colors.green,
                                                                                      child: ForYouChild(
                                                                                    index: theIndex,
                                                                                    theFilePrev: theStoryArray[
                                                                                            snap1.data.docs.length - 1]
                                                                                        ['storie'],
                                                                                    theUid: checkArray[
                                                                                        checkArray.length - 1],
                                                                                  )));
                                                                            } else {
                                                                              return Container();
                                                                            }
                                                                          });
                                                                    } else {
                                                                      return Container(
                                                                          //color: Colors.green,
                                                                          );
                                                                    }
                                                                  }));
                                                        })))))
                                      ]))
                                    : Container();
                              } else {
                                return Container();
                              }
                            }))
                    /*FutureBuilder(
                        future: DatabaseService().getAllStories(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Map<String, dynamic>> storiesArray = [];
                            for (int j = 0; j < snapshot.data.docs.length; j++) {
                              Map<String, dynamic> storiesMap = {
                                'storie': snapshot.data.docs[j].data()['theFile'],
                                'uid': snapshot.data.docs[j].data()['uid'],
                                'id': snapshot.data.docs[j].data()['id'],
                              };
                              storiesArray.add(storiesMap);
                            }
                            return Container(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                child: Column(children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text('For you',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 17.2, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                      child: GridView.count(
                                          crossAxisCount: 2,
                                          childAspectRatio: (9 / 16),
                                          children: List.generate(storiesArray.length, (int index) {
                                            return Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                                child: Container(
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                                    child: ForYouChild(
                                                      index: index,
                                                      theFilePrev: storiesArray[storiesArray.length]['storie'],
                                                      theUid: storiesArray[storiesArray.length]['uid'],
                                                    )));
                                          })))
                                ]));
                          } else {
                            return Container();
                          }
                        }))*/
                    )
              ]))),
        ]));
  }
}
