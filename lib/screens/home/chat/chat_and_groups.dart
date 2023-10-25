import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/camera/add_friends.dart';
import 'package:snapchatClone/screens/home/camera/memories.dart';
import 'package:snapchatClone/screens/home/camera/preview_screen.dart';
import 'package:snapchatClone/screens/home/camera/preview_video_screen.dart';
import 'package:snapchatClone/screens/home/chat/in_chat.dart';
import 'package:snapchatClone/screens/home/profile/profile.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapchatClone/services/database.dart';

class ChatAndGroups extends StatefulWidget {
  final double statusBar;
  ChatAndGroups({this.statusBar});
  @override
  _ChatAndGroupsState createState() => _ChatAndGroupsState();
}

class _ChatAndGroupsState extends State<ChatAndGroups> {
  TextEditingController searchController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot searchSnapshot;
  List<String> selectedUsers = [];
  bool isSelected = false;
  String singleChatType;

  initializeSearch() async {
    if (searchController.text.isNotEmpty) {
      await databaseService.getUserByUsername(searchController.text).then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          //SearchSnapshot.searchSnapshot = searchSnapshot;
        });
      });
    }
  }

  createChatroomAndStartConversation(
      String userName, String myName, String myUid, String userUid, String singleChatType, BuildContext context) {
    List<String> users = [userUid, myUid];
    print(users);
    String chatRoomId = getChatRoomId(userUid, myUid);
    print('constant name below');
    print(myName);
    Map<String, dynamic> chatRoomMap = {
      'users': users,
      'user1': userUid,
      'user2': myUid,
      'type': 'normal',
      'chatroomId': chatRoomId,
    };
    DatabaseService().createChatRoom(chatRoomId, chatRoomMap);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationScreen(
                chatRoomId: chatRoomId, myName: myName, userName: userName, chatType: singleChatType == 'group')));
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  startGroupChat(String myUid, BuildContext context) {
    String chatRoomId = 'group${groupNameController.text}By${myUid}';
    selectedUsers.add(myUid);
    Map<String, dynamic> chatGrupMap = {
      'users': selectedUsers,
      'host': myUid,
      'type': 'group',
      'chatroomId': chatRoomId,
      'groupName': groupNameController.text,
    };
    DatabaseService().createChatRoom(chatRoomId, chatGrupMap);
  }

  searchList(BuildContext context, String userUid) {
    final user = Provider.of<CustomUser>(context, listen: false);
    print(searchSnapshot);
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return FutureBuilder(
                  future: DatabaseService(uid: userUid).queryFriends(searchSnapshot.docs[index].data()['uid']),
                  builder: (context, friendSnap) {
                    if (friendSnap.hasData && friendSnap.data.docs.length > 0) {
                      print('working till future builder the length is ${friendSnap.data.docs.length}');
                      List<Map<String, dynamic>> friendArray = [];
                      for (int i = 0; i < friendSnap.data.docs.length; i++) {
                        Map<String, dynamic> friendMap = {'friendUid': friendSnap.data.docs[i].data()['addedUserUid']};
                        friendArray.add(friendMap);
                      }
                      return ListView.builder(
                          itemCount: friendArray.length,
                          primary: true,
                          shrinkWrap: true,
                          itemBuilder: (context, theIndex) {
                            return StreamBuilder<DocumentSnapshot>(
                                stream: DatabaseService(uid: friendArray[theIndex]['friendUid']).getUserProfile(),
                                builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                  if (snap.hasData) {
                                    print('the array data is $selectedUsers');
                                    Map<String, dynamic> userData = snap.data.data();
                                    return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9.0),
                                        ),
                                        color: Colors.grey[50],
                                        child: GestureDetector(
                                            onTap: () {
                                              if (selectedUsers.contains(userData['uid'])) {
                                                setState(() {
                                                  selectedUsers.remove(userData['uid']);
                                                });
                                              } else {
                                                setState(() {
                                                  selectedUsers.add(userData['uid']);
                                                });
                                              }
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(color: Colors.grey[400], width: 0.6))),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                        child: Row(children: [
                                                      Container(
                                                          child: Text(userData['name'],
                                                              style: TextStyle(
                                                                  color: selectedUsers.contains(userData['uid'])
                                                                      ? Colors.blue[300]
                                                                      : Colors.grey[900],
                                                                  fontSize: 17,
                                                                  fontWeight: selectedUsers.contains(userData['uid'])
                                                                      ? FontWeight.w700
                                                                      : FontWeight.w600)))
                                                    ])),
                                                    selectedUsers.contains(userData['uid'])
                                                        ? Container(
                                                            height: 22,
                                                            width: 22,
                                                            decoration: BoxDecoration(
                                                              color: Colors.blue[400],
                                                              border: Border.all(width: 1.6, color: Colors.blue[400]),
                                                              borderRadius: BorderRadius.circular(100 / 2),
                                                            ),
                                                            padding: EdgeInsets.zero,
                                                            child: Icon(
                                                              Icons.check_rounded,
                                                              color: Colors.grey[50],
                                                              size: 19,
                                                            ))
                                                        : Container(
                                                            height: 22,
                                                            width: 22,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(width: 1.6, color: Colors.grey[500]),
                                                              borderRadius: BorderRadius.circular(100 / 2),
                                                            ))
                                                  ],
                                                ))));
                                  } else {
                                    return Container();
                                  }
                                });
                          });
                    } else {
                      return Container();
                    }
                  });
            })
        : Container();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey[100],
    ));
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      leading: null,
      actions: [
        IconButton(
            //padding: EdgeInsets.only(top: widget.statusBar),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[800],
              size: 37,
            ),
            onPressed: () => Navigator.of(context).pop())
      ],
      title: Container(
          child: selectedUsers.length > 1
              ? Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.55,
                  ),
                  child: TextField(
                      controller: groupNameController,
                      autofocus: false,
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      cursorColor: Colors.blue[400],
                      cursorHeight: 24,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Name Group',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ))))
              : Text('New Chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
      centerTitle: true,
      titleSpacing: 0.0,
      backgroundColor: Colors.transparent,
    );
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBar.preferredSize.height + widget.statusBar),
            child: Container(padding: EdgeInsets.only(top: widget.statusBar), child: appBar)),
        body: Stack(children: [
          Container(
              child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 12),
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
                              style: TextStyle(
                                fontSize: 19,
                              ),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[350],
                                  //hintText: 'Find Friends',
                                  border: InputBorder.none,
                                  prefixIcon: Padding(
                                      padding: EdgeInsets.only(left: 15, top: 9),
                                      child: Text('To:',
                                          style: TextStyle(
                                              color: Colors.grey[600], fontSize: 17, fontWeight: FontWeight.w900))),
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
                  ? Column(children: [
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                          margin: EdgeInsets.only(left: 10, right: 10, bottom: 12, top: 16),
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    child: Icon(Icons.group_add_rounded, color: Colors.black, size: 26),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 12),
                                      child: Text(
                                        'New Group',
                                        style:
                                            TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w700),
                                      ))
                                ],
                              ))),
                      Container(
                          margin: EdgeInsets.only(left: 10, right: 10, bottom: 12, top: 8),
                          child: Column(children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(vertical: 4),
                                child: Text('Recents',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ))),
                            Container(
                                child: StreamBuilder(
                                    stream: databaseService.getChatRooms(user.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        print('the added user length is ${snapshot.data.docs.length}');
                                        List<Map<String, dynamic>> chatsArray = [];
                                        for (int i = 0; i < snapshot.data.docs.length; i++) {
                                          Map<String, dynamic> chatsMap = {
                                            'friendUid': snapshot.data.docs[i].data()['type'] == 'group'
                                                ? snapshot.data.docs[i].data()['groupName']
                                                : snapshot.data.docs[i].data()['user1'] == user.uid
                                                    ? snapshot.data.docs[i].data()['user2']
                                                    : snapshot.data.docs[i].data()['user1'],
                                          };
                                          chatsArray.add(chatsMap);
                                        }
                                        return Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            color: Colors.grey[50],
                                            child: ListView.builder(
                                                itemCount: chatsArray.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  return snapshot.data.docs[index].data()['type'] == 'group'
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ConversationScreen(
                                                                          chatRoomId: snapshot.data.docs[index]
                                                                              .data()['chatroomId'],
                                                                          chatType: snapshot.data.docs[index]
                                                                                  .data()['type'] ==
                                                                              'group',
                                                                          userName: chatsArray[index]['friendUid'],
                                                                        )));
                                                          },
                                                          child: Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                                              decoration: BoxDecoration(
                                                                  border: Border(
                                                                      bottom: BorderSide(
                                                                          color: Colors.grey[300], width: 0.6))),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Container(
                                                                      child: Row(children: [
                                                                    Container(
                                                                        child: Text(chatsArray[index]['friendUid'],
                                                                            style: TextStyle(
                                                                                color: Colors.grey[900],
                                                                                fontSize: 17,
                                                                                fontWeight: FontWeight.w700))),
                                                                  ])),
                                                                ],
                                                              )))
                                                      : StreamBuilder<DocumentSnapshot>(
                                                          stream: DatabaseService(uid: chatsArray[index]['friendUid'])
                                                              .getUserProfile(),
                                                          builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                                            if (snap.hasData) {
                                                              Map<String, dynamic> userData = snap.data.data();
                                                              print('the array data is $selectedUsers');
                                                              return GestureDetector(
                                                                  onTap: () {
                                                                    if (selectedUsers.contains(userData['uid'])) {
                                                                      setState(() {
                                                                        selectedUsers.remove(userData['uid']);
                                                                        singleChatType = '';
                                                                      });
                                                                    } else {
                                                                      setState(() {
                                                                        selectedUsers.add(userData['uid']);
                                                                        singleChatType =
                                                                            '${snapshot.data.docs[index].data()['type']}';
                                                                      });
                                                                      print(
                                                                          'the first index in the array is ${selectedUsers.first}');
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: 12, vertical: 16),
                                                                      decoration: BoxDecoration(
                                                                          border: Border(
                                                                              bottom: BorderSide(
                                                                                  color: Colors.grey[300],
                                                                                  width: 0.6))),
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                              child: Row(children: [
                                                                            Container(
                                                                                child: Text(userData['name'],
                                                                                    style: TextStyle(
                                                                                        color: selectedUsers.contains(
                                                                                                userData['uid'])
                                                                                            ? Colors.blue[400]
                                                                                            : Colors.grey[900],
                                                                                        fontSize: 17,
                                                                                        fontWeight:
                                                                                            selectedUsers.contains(
                                                                                                    userData['uid'])
                                                                                                ? FontWeight.w700
                                                                                                : FontWeight.w600))),
                                                                          ])),
                                                                          selectedUsers.contains(userData['uid'])
                                                                              ? Container(
                                                                                  height: 22,
                                                                                  width: 22,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.blue[400],
                                                                                    border: Border.all(
                                                                                        width: 1.6,
                                                                                        color: Colors.blue[400]),
                                                                                    borderRadius:
                                                                                        BorderRadius.circular(100 / 2),
                                                                                  ),
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: Icon(
                                                                                    Icons.check_rounded,
                                                                                    color: Colors.grey[50],
                                                                                    size: 19,
                                                                                  ))
                                                                              : Container(
                                                                                  height: 22,
                                                                                  width: 22,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(
                                                                                        width: 1.6,
                                                                                        color: Colors.grey[500]),
                                                                                    borderRadius:
                                                                                        BorderRadius.circular(100 / 2),
                                                                                  ))
                                                                        ],
                                                                      )));
                                                            } else {
                                                              return Container();
                                                            }
                                                          });
                                                }));
                                      } else {
                                        return Container();
                                      }
                                    }))
                          ]))
                    ])
                  : Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 12, top: 16),
                      //height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Friends',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ))),
                          Container(child: searchList(context, user.uid))
                        ],
                      ))
            ],
          )),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: selectedUsers.length > 0
                      ? selectedUsers.length > 1
                          ? GestureDetector(
                              onTap: () {
                                startGroupChat(user.uid, context);
                              },
                              child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  height: MediaQuery.of(context).size.height * 0.062,
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  decoration: BoxDecoration(
                                      color: selectedUsers.length > 0 ? Colors.blue[500] : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(35)),
                                  child: Center(
                                      child: selectedUsers.length > 1
                                          ? Text('Chat with Group',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.4,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2,
                                              ))
                                          : Text('Chat',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.4,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.12,
                                              )))))
                          : StreamBuilder<DocumentSnapshot>(
                              stream: DatabaseService(uid: selectedUsers.first).getUserProfile(),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                if (snap.hasData) {
                                  Map<String, dynamic> userData = snap.data.data();
                                  return StreamBuilder<DocumentSnapshot>(
                                      stream: DatabaseService(uid: user.uid).getUserProfile(),
                                      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnap) {
                                        if (userSnap.hasData) {
                                          Map<String, dynamic> currentUserData = userSnap.data.data();
                                          print('my uid is ${currentUserData['uid']}');
                                          print('the other uid is ${userData['uid']}');
                                          return GestureDetector(
                                              onTap: () {
                                                createChatroomAndStartConversation(
                                                    userData['name'],
                                                    currentUserData['name'],
                                                    currentUserData['uid'],
                                                    userData['uid'],
                                                    singleChatType,
                                                    context);
                                              },
                                              child: Container(
                                                  margin: EdgeInsets.only(bottom: 30),
                                                  height: MediaQuery.of(context).size.height * 0.062,
                                                  width: MediaQuery.of(context).size.width * 0.6,
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue[500], borderRadius: BorderRadius.circular(35)),
                                                  child: Center(
                                                      child: Text('Chat',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 17.4,
                                                            fontWeight: FontWeight.w700,
                                                            letterSpacing: 1.12,
                                                          )))));
                                        } else {
                                          return Container();
                                        }
                                      });
                                } else {
                                  return Container();
                                }
                              })
                      : Container(
                          margin: EdgeInsets.only(bottom: 30),
                          height: MediaQuery.of(context).size.height * 0.062,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(35)),
                          child: Center(
                              child: Text('Chat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.4,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.12,
                                  ))))))
        ]));
  }
}
