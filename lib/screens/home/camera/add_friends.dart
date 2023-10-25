import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/added/added_me.dart';
import 'package:snapchatClone/screens/home/search/search_tile.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class AddFriends extends StatefulWidget {
  final double statusBar;
  AddFriends({this.statusBar});
  @override
  _AddFriendsState createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  TextEditingController searchController = TextEditingController();
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot searchSnapshot;
  bool notificationExists = true;

  initializeSearch() async {
    if (searchController.text.isNotEmpty) {
      await databaseService.getUserByUsername(searchController.text).then((snapshot) {
        if (mounted) {
          setState(() {
            searchSnapshot = snapshot;
            //SearchSnapshot.searchSnapshot = searchSnapshot;
          });
        }
      });
    }
  }

  notificationState(String currentUserUid, String theId) async {
    await DatabaseService(uid: currentUserUid, docId: theId).isNotificationDeleted().then((snapshot) {
      if (mounted) {
        setState(() {
          notificationExists = snapshot;
          //SearchSnapshot.searchSnapshot = searchSnapshot;
        });
      }
    });
  }

  searchList(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print(searchSnapshot);
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                arrayLength: searchSnapshot.docs.length,
                name: searchSnapshot.docs[index].data()['name'],
                userName: searchSnapshot.docs[index].data()['username'],
                privacy: searchSnapshot.docs[index].data()['privacy'],
                userEmail: searchSnapshot.docs[index].data()['email'],
                userUID: searchSnapshot.docs[index].data()['uid'],
                currentUserUID: user.uid,
              );
            },
          )
        : Container();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey[100],
    ));
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      leading: IconButton(
          //padding: EdgeInsets.only(top: widget.statusBar),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[800],
            size: 37,
          ),
          onPressed: () => Navigator.of(context).pop()),
      title: Container(
          //color: Colors.green,
          //height: MediaQuery.of(context).size.height,
          //margin: EdgeInsets.only(top: widget.statusBar),
          child:
              Text('Add Friends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
      centerTitle: true,
      //titleSpacing: 0.0,
      backgroundColor: Colors.transparent,
    );
    return Scaffold(
        primary: true,
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBar.preferredSize.height + widget.statusBar),
            child: Container(padding: EdgeInsets.only(top: widget.statusBar), child: appBar)),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Container(
                child: Column(children: [
              Container(
                  margin: EdgeInsets.only(left: 8, right: 8, bottom: 12),
                  child: SizedBox(
                      height: 38,
                      child: Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: Colors.black,
                          ),
                          child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  initializeSearch();
                                });
                              },
                              minLines: 1,
                              maxLines: 1,
                              controller: searchController,
                              autofocus: false,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[350],
                                  hintText: 'Find Friends',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search, color: Colors.black, size: 30),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(0.0)))))),
              searchController.text.isEmpty || searchController.text == null || searchController.text == ''
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.93,
                      //margin: EdgeInsets.only(top: 2),
                      child: Column(children: [
                        FutureBuilder(
                            future: DatabaseService(uid: user.uid).getNotifications(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data.docs.length != 0) {
                                print('first snapshot is ${snapshot.data.docs.length}');
                                List<Map<String, dynamic>> addedMeArray = [];
                                for (int i = 0; i < snapshot.data.docs.length; i++) {
                                  Map<String, dynamic> addedMeMap = {
                                    'userAddedMe': snapshot.data.docs[i].data()['sendBy'],
                                    'id': snapshot.data.docs[i].data()['id']
                                  };
                                  addedMeArray.add(addedMeMap);
                                }
                                print('the array length is ${addedMeArray.length}');
                                return Column(
                                  children: [
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.93,
                                        margin: EdgeInsets.symmetric(vertical: 4),
                                        child: Text('Added Me',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                                    Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9.0),
                                        ),
                                        child: ListView.builder(
                                          itemCount: addedMeArray.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            print('made it till List View ${addedMeArray.length}');
                                            bool addedMe = true;
                                            notificationState(user.uid, addedMeArray[index]['id']);
                                            return notificationExists
                                                ? AddedMe(
                                                    arrayLength: addedMeArray.length,
                                                    userUID: addedMeArray[index]['userAddedMe'],
                                                    theId: addedMeArray[index]['id'],
                                                    //deleteNot: deleteNotifications(user.uid, addedMeArray[index]['id']),
                                                    addedMe: addedMe)
                                                : Container();
                                          },
                                        ))
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            }),
                        FutureBuilder(
                            future: DatabaseService().getUsers(),
                            builder: (context, snapshot) {
                              //print('the snapshots length is ${snapshot.data.docs.length}');
                              if (snapshot.hasData) {
                                List<Map<String, dynamic>> usersArray = [];
                                for (int i = 0; i < snapshot.data.docs.length; i++) {
                                  Map<String, dynamic> usersMap = {
                                    'user': snapshot.data.docs[i].data()['uid'],
                                  };
                                  usersArray.add(usersMap);
                                }
                                return Column(
                                  children: [
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.93,
                                        margin: EdgeInsets.symmetric(vertical: 4),
                                        child: Text('Quick Add',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                                    Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9.0),
                                        ),
                                        child: ListView.builder(
                                          itemCount: usersArray.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            //print('made it till List View ${usersArray.length}');
                                            if (usersArray[index]['user'] != user.uid) {
                                              //bool addedMe = false;
                                              return FutureBuilder(
                                                  future: DatabaseService(uid: user.uid)
                                                      .getQueriedFriends(usersArray[index]['user']),
                                                  builder: (context, snap) {
                                                    if (snap.hasData && snap.data.docs.length > 0) {
                                                      return Container();
                                                    } else {
                                                      bool addedMe = false;
                                                      return AddedMe(
                                                          arrayLength: usersArray.length,
                                                          userUID: usersArray[index]['user'],
                                                          addedMe: addedMe);
                                                    }
                                                  });
                                            } else {
                                              return Container();
                                            }
                                          },
                                        ))
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            })
                      ]))
                  : Container(
                      width: MediaQuery.of(context).size.width * 0.93,
                      //margin: EdgeInsets.only(top: 2),
                      child: Column(children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.93,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: Text('Add Friends',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                        Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: searchList(context))
                      ]))
            ]))));
  }
}
