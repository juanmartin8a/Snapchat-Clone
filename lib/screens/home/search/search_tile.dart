import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';

class SearchTile extends StatefulWidget {
  final String name;
  final String userName;
  final String userEmail;
  final String userUID;
  final bool privacy;
  final String currentUserUID;
  final int arrayLength;
  SearchTile(
      {this.userName, this.userEmail, this.userUID, this.currentUserUID, this.name, this.privacy, this.arrayLength});
  @override
  _SearchTileState createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {
  bool userIsAdded = false;

  getAddedState(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    await DatabaseService(uid: widget.userUID).getUserFriendsBool(user.uid).then((value) {
      print(value);
      setState(() {
        userIsAdded = value;
      });
    });
  }

  @override
  void initState() {
    //getNotificationState(this.context);
    getAddedState(this.context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
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
                                        style: TextStyle(fontSize: 15, color: Colors.black, letterSpacing: 0.38),
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
                              child: FutureBuilder(
                                  future: DatabaseService(uid: user.uid).queryFriends(userDocs['uid']),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data.docs.length > 0) {
                                      return userIsAdded
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
                                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                                child: Icon(Icons.person_add,
                                                                    color: Colors.grey[900], size: 17)),
                                                            Container(
                                                                child: Text('add',
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors.grey[900],
                                                                      fontWeight: FontWeight.bold,
                                                                    )))
                                                          ])))
                                            ]);
                                    } else {
                                      return userIsAdded
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
                                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                                                    } else {
                                                      print('privacy is not false');
                                                    }
                                                  },
                                                  child: Container(
                                                      width: MediaQuery.of(context).size.width * 0.21,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey[200],
                                                          borderRadius: BorderRadius.circular(20)),
                                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                                child: Icon(Icons.person_add,
                                                                    color: Colors.grey[900], size: 17)),
                                                            Container(
                                                                child: Text('add',
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors.grey[900],
                                                                      fontWeight: FontWeight.bold,
                                                                    )))
                                                          ])))
                                            ]);
                                    }
                                  }))
                        ]))));
          } else {
            return Container();
          }
        });
  }
}
