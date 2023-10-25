import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/camera/camera_state.dart';
import 'package:snapchatClone/screens/home/chat/in_chat.dart';
import 'package:snapchatClone/screens/home/search/search.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:provider/provider.dart';

class AddedMe extends StatefulWidget {
  final String userUID;
  final int arrayLength;
  final bool addedMe;
  final String theId;
  final dynamic deleteNot;
  AddedMe({this.userUID, this.arrayLength, this.addedMe, this.theId, this.deleteNot});
  @override
  _AddedMeState createState() => _AddedMeState();
}

class _AddedMeState extends State<AddedMe> {
  bool userIsAdded = false;
  bool notificationExists;

  getAddedState(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: widget.userUID).getUserFriendsBool(user.uid).then((value) {
      print(value);
      if (mounted) {
        setState(() {
          userIsAdded = value;
        });
      }
    });
  }

  deleteNotification(BuildContext context) {
    final user = Provider.of<CustomUser>(context, listen: false);
    DatabaseService(uid: user.uid, docId: widget.theId).deleteNotification();
  }

  createChatroomAndStartConversation(
      String userName, String myName, String myUid, String userUid, BuildContext context) {
    List<String> users = [userUid, myUid];
    print(users);
    String chatRoomId = getChatRoomId(userUid, myUid);
    print('constant name below');
    print(myName);
    Map<String, dynamic> chatRoomMap = {
      'users': users,
      'user1': userUid,
      'user2': myUid,
      'chatroomId': chatRoomId,
      'type': 'normal'
    };
    DatabaseService().createChatRoom(chatRoomId, chatRoomMap);
    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationScreen(
                  chatRoomId: chatRoomId,
                  myName: myName,
                  userName: userName,
                )));*/
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    if (mounted) {
      getAddedState(this.context);
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(uid: user.uid).getUserProfile(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> currentUsersnap) {
          if (currentUsersnap.hasData) {
            Map<String, dynamic> currentUserDocs = currentUsersnap.data.data();
            return StreamBuilder<DocumentSnapshot>(
                stream: DatabaseService(uid: widget.userUID).getUserProfile(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> userDocs = snapshot.data.data();
                    return Container(
                        child: GestureDetector(
                            onTap: () {},
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                    border: widget.arrayLength <= 1
                                        ? Border(top: BorderSide(width: 0.6, color: Colors.grey[300]))
                                        : null),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Expanded(
                                      flex: 8,
                                      child: Row(children: [
                                        /*Container(
                                        child: CircleAvatar(
                                      radius: 23,
                                      backgroundImage:
                                          NetworkImage(userDocs['profileImg']),
                                      backgroundColor: Colors.grey,
                                    )),*/
                                        Container(
                                          margin: EdgeInsets.only(left: 8),
                                          //flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userDocs['name'],
                                                style:
                                                    TextStyle(fontSize: 15, color: Colors.black, letterSpacing: 0.38),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 3),
                                                child: Text(
                                                  userDocs['username'],
                                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ])),
                                  Expanded(
                                      flex: 4,
                                      child: widget.addedMe
                                          ? FutureBuilder(
                                              future: DatabaseService(uid: user.uid).queryFriends(widget.userUID),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData && snapshot.data.docs.length > 0) {
                                                  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          /*DatabaseService(uid: user.uid, docId: widget.theId)
                                                              .deleteNotification();*/
                                                          DatabaseService(uid: widget.userUID, docId: user.uid)
                                                              .deleteAddedMe();
                                                          DatabaseService(uid: user.uid, docId: widget.userUID)
                                                              .deleteAddedUsers();
                                                          DatabaseService(uid: widget.userUID, docId: user.uid)
                                                              .deleteFriend();
                                                          DatabaseService(uid: user.uid, docId: widget.userUID)
                                                              .deleteFriend();
                                                          setState(() {
                                                            getAddedState(context);
                                                          });
                                                          //getAddedState(context);
                                                        },
                                                        child: Container(
                                                            width: MediaQuery.of(context).size.width * 0.21,
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[200],
                                                                borderRadius: BorderRadius.circular(20)),
                                                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                                                            child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                      child: Icon(Icons.person_add,
                                                                          color: Colors.blue[500], size: 17)),
                                                                  Container(
                                                                      child: Text('Added',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Colors.blue[500],
                                                                            fontWeight: FontWeight.bold,
                                                                          )))
                                                                ]))),
                                                    GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            deleteNotification(context);
                                                          });
                                                        },
                                                        child: Container(
                                                            margin: EdgeInsets.only(left: 10),
                                                            child: Center(
                                                                child: Icon(Icons.close_rounded,
                                                                    size: 18, color: Colors.grey[900]))))
                                                  ]);
                                                } else {
                                                  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          if (userDocs['privacy'] == false) {
                                                            print('privacy is false');
                                                            Map<String, dynamic> addUserMap = {
                                                              'addedUserUid': widget.userUID,
                                                              'notificationId': 'added${user.uid}',
                                                              'addedUserName': userDocs['name'],
                                                              'addedBy': user.uid,
                                                              'time': DateTime.now().millisecondsSinceEpoch
                                                            };
                                                            DatabaseService(uid: user.uid)
                                                                .addUser(addUserMap, widget.userUID);
                                                            Map<String, dynamic> addedMeMap = {
                                                              'hasAddedMe': user.uid,
                                                              'me': widget.userUID
                                                            };
                                                            createChatroomAndStartConversation(
                                                                userDocs['name'],
                                                                currentUserDocs['name'],
                                                                currentUserDocs['uid'],
                                                                userDocs['uid'],
                                                                context);
                                                            setState(() {
                                                              getAddedState(context);
                                                            });
                                                            DatabaseService(uid: widget.userUID)
                                                                .usersThatAddedMe(addedMeMap, user.uid);
                                                          } else {
                                                            print('privacy is not false');
                                                          }
                                                        },
                                                        child: Container(
                                                            width: MediaQuery.of(context).size.width * 0.21,
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[200],
                                                                borderRadius: BorderRadius.circular(20)),
                                                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                                                            child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                      child: Icon(Icons.person_add,
                                                                          color: Colors.blue[500], size: 17)),
                                                                  Container(
                                                                      child: Text('Accept',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Colors.blue[500],
                                                                            fontWeight: FontWeight.bold,
                                                                          )))
                                                                ]))),
                                                    GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            deleteNotification(context);
                                                            //notificationExists = false;
                                                          });
                                                        },
                                                        child: Container(
                                                            margin: EdgeInsets.only(left: 10),
                                                            child: Center(
                                                                child: Icon(Icons.close_rounded,
                                                                    size: 18, color: Colors.grey[900]))))
                                                  ]);
                                                }
                                              })
                                          /*}
                                      })*/
                                          : Container(
                                              width: MediaQuery.of(context).size.width * 0.21,
                                              child: userIsAdded
                                                  ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                      GestureDetector(
                                                          onTap: () {
                                                            DatabaseService(uid: widget.userUID, docId: user.uid)
                                                                .deleteAddedMe();
                                                            DatabaseService(uid: user.uid, docId: widget.userUID)
                                                                .deleteAddedUsers();
                                                            DatabaseService(uid: widget.userUID, docId: user.uid)
                                                                .deleteFriend();
                                                            DatabaseService(uid: user.uid, docId: widget.userUID)
                                                                .deleteFriend();
                                                            setState(() {
                                                              getAddedState(context);
                                                            });
                                                          },
                                                          child: Container(
                                                              width: MediaQuery.of(context).size.width * 0.21,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.grey[200],
                                                                  borderRadius: BorderRadius.circular(20)),
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                                                              child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Container(
                                                                        child: Icon(Icons.person_add,
                                                                            color: Colors.blue[500], size: 17)),
                                                                    Container(
                                                                        child: Text('Added',
                                                                            style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.blue[500],
                                                                              fontWeight: FontWeight.bold,
                                                                            )))
                                                                  ])))
                                                    ])
                                                  : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                      GestureDetector(
                                                          onTap: () {
                                                            if (userDocs['privacy'] == false) {
                                                              print('privacy is false');
                                                              Map<String, dynamic> addUserMap = {
                                                                'addedUserUid': widget.userUID,
                                                                'notificationId': 'added${user.uid}',
                                                                'addedUserName': userDocs['name'],
                                                                'addedBy': user.uid,
                                                                'time': DateTime.now().millisecondsSinceEpoch
                                                              };
                                                              DatabaseService(uid: user.uid)
                                                                  .addUser(addUserMap, widget.userUID);
                                                              Map<String, dynamic> addedMeMap = {
                                                                'hasAddedMe': user.uid,
                                                                'me': widget.userUID
                                                              };
                                                              DatabaseService(uid: widget.userUID)
                                                                  .usersThatAddedMe(addedMeMap, user.uid);
                                                              setState(() {
                                                                getAddedState(context);
                                                              });
                                                              createChatroomAndStartConversation(
                                                                  userDocs['name'],
                                                                  currentUserDocs['name'],
                                                                  currentUserDocs['uid'],
                                                                  userDocs['uid'],
                                                                  context);
                                                            } else {
                                                              print('privacy is not false');
                                                            }
                                                          },
                                                          child: Container(
                                                              width: MediaQuery.of(context).size.width * 0.21,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.grey[200],
                                                                  borderRadius: BorderRadius.circular(20)),
                                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                                                              child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Container(
                                                                        child: Icon(Icons.person_add,
                                                                            color: Colors.grey[900], size: 17)),
                                                                    Container(
                                                                        child: Text('Add',
                                                                            style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.grey[900],
                                                                              fontWeight: FontWeight.bold,
                                                                            )))
                                                                  ])))
                                                    ])))
                                ]))));
                  } else {
                    return Container();
                  }
                });
          } else {
            return Container();
          }
        });
  }
}
