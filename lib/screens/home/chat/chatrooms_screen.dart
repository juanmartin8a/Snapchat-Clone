import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/chat/in_chat.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';

class ChatRooms extends StatefulWidget {
  final double statusBar;
  ChatRooms({this.statusBar});
  @override
  _ChatRoomsState createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  Stream chatRoomStream;
  DatabaseService databaseService = DatabaseService();
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConversationScreen(
                  chatRoomId: chatRoomId,
                  myName: myName,
                  userName: userName,
                )));
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  /*getChatRooms(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    databaseService.getChatRooms(user.uid).then((snapshots) {
      setState(() {
        chatRoomStream = snapshots;
      });
    });
  }*/

  @override
  void initState() {
    //getChatRooms(this.context);
    super.initState();
  }

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
          //margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text('Chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
      centerTitle: true,
    );
    return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
                child: Container(
              color: Colors.grey[100],
            )),
            Positioned(
                top: appBar.preferredSize.height + widget.statusBar,
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Container(
                    child: StreamBuilder(
                        stream: databaseService.getChatRooms(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Map<String, dynamic>> friendsArray = [];
                            for (int i = 0; i < snapshot.data.docs.length; i++) {
                              Map<String, dynamic> friendsMap = {
                                'friendUid': snapshot.data.docs[i].data()['type'] == 'group'
                                    ? snapshot.data.docs[i].data()['groupName']
                                    : snapshot.data.docs[i].data()['user1'] == user.uid
                                        ? snapshot.data.docs[i].data()['user2']
                                        : snapshot.data.docs[i].data()['user1']
                              };
                              friendsArray.add(friendsMap);
                            }
                            return Container(
                                //color: Colors.yellow,
                                //padding: EdgeInsets.symmetric(vertical: 4),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                padding: EdgeInsets.zero,
                                child: ListView.builder(
                                    itemCount: friendsArray.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      return snapshot.data.docs[index].data()['type'] == 'group'
                                          ? GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                        transitionDuration: Duration(milliseconds: 500),
                                                        transitionsBuilder: (BuildContext context,
                                                            Animation<double> animation,
                                                            Animation<double> secondaryAnimation,
                                                            Widget child) {
                                                          animation = CurvedAnimation(
                                                              parent: animation, curve: Curves.easeInOut);
                                                          return SlideTransition(
                                                            position: Tween<Offset>(
                                                              begin: const Offset(-1.0, 0.0),
                                                              end: const Offset(0.0, 0.0),
                                                            ).animate(animation),
                                                            //).animate(CurvedAnimation(parent: animation, curve: Curves.elasticInOut)),
                                                            child: child,
                                                          );
                                                          /*return ScaleTransition(
                                                            alignment: Alignment.center,
                                                            scale: animation,
                                                            child: child,
                                                          );*/
                                                        },
                                                        pageBuilder: (context, Animation<double> animation,
                                                                Animation<double> secondaryAnimation) =>
                                                            ConversationScreen(
                                                              chatRoomId:
                                                                  snapshot.data.docs[index].data()['chatroomId'],
                                                              chatType:
                                                                  snapshot.data.docs[index].data()['type'] == 'group',
                                                              userName: friendsArray[index]['friendUid'],
                                                            )));
                                              },
                                              child: Container(
                                                  margin: EdgeInsets.zero,
                                                  width: MediaQuery.of(context).size.width,
                                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(color: Colors.grey[350], width: 0.5))),
                                                  child: Container(
                                                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                                    Expanded(
                                                        child: Column(
                                                            //mainAxisAl
                                                            children: [
                                                          Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Text(friendsArray[index]['friendUid'],
                                                                  textAlign: TextAlign.left,
                                                                  style: TextStyle(
                                                                      color: Colors.grey[900],
                                                                      fontSize: 16.4,
                                                                      letterSpacing: 0.4))),
                                                          Container(
                                                              child: Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                Container(
                                                                    child: Icon(Icons.mode_comment_outlined,
                                                                        color: Colors.grey[500], size: 14)),
                                                                Container(
                                                                    margin: EdgeInsets.only(left: 4),
                                                                    child: Text('Tap to chat',
                                                                        style: TextStyle(
                                                                            color: Colors.grey[700], fontSize: 13)))
                                                              ]))
                                                        ]))
                                                  ]))))
                                          : Container(
                                              //color: Colors.green,
                                              margin: EdgeInsets.zero,
                                              padding: EdgeInsets.zero,
                                              child: StreamBuilder<DocumentSnapshot>(
                                                  stream: DatabaseService(uid: friendsArray[index]['friendUid'])
                                                      .getUserProfile(),
                                                  builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                                    if (snap.hasData) {
                                                      Map<String, dynamic> userData = snap.data.data();
                                                      return StreamBuilder<DocumentSnapshot>(
                                                          stream: DatabaseService(uid: user.uid).getUserProfile(),
                                                          builder: (context, AsyncSnapshot<DocumentSnapshot> userSnap) {
                                                            if (userSnap.hasData) {
                                                              Map<String, dynamic> currentUserData =
                                                                  userSnap.data.data();
                                                              return GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        PageRouteBuilder(
                                                                            transitionDuration:
                                                                                Duration(milliseconds: 500),
                                                                            transitionsBuilder: (BuildContext context,
                                                                                Animation<double> animation,
                                                                                Animation<double> secondaryAnimation,
                                                                                Widget child) {
                                                                              animation = CurvedAnimation(
                                                                                  parent: animation,
                                                                                  curve: Curves.easeInOut);
                                                                              return SlideTransition(
                                                                                position: Tween<Offset>(
                                                                                  begin: const Offset(-1.0, 0.0),
                                                                                  end: const Offset(0.0, 0.0),
                                                                                ).animate(animation),
                                                                                //).animate(CurvedAnimation(parent: animation, curve: Curves.elasticInOut)),
                                                                                child: child,
                                                                              );
                                                                            },
                                                                            pageBuilder: (context,
                                                                                    Animation<double> animation,
                                                                                    Animation<double>
                                                                                        secondaryAnimation) =>
                                                                                ConversationScreen(
                                                                                    chatRoomId: snapshot
                                                                                        .data.docs[index]
                                                                                        .data()['chatroomId'],
                                                                                    myName: currentUserData['name'],
                                                                                    userName: userData['name'],
                                                                                    chatType: snapshot.data.docs[index]
                                                                                            .data()['type'] ==
                                                                                        'group')));
                                                                  },
                                                                  child: Container(
                                                                      margin: EdgeInsets.zero,
                                                                      width: MediaQuery.of(context).size.width,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical: 8, horizontal: 12),
                                                                      decoration: BoxDecoration(
                                                                          border: Border(
                                                                              bottom: BorderSide(
                                                                                  color: Colors.grey[350],
                                                                                  width: 0.5))),
                                                                      child: Container(
                                                                          child: Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.start,
                                                                              children: [
                                                                            Expanded(
                                                                                child: Column(
                                                                                    //mainAxisAl
                                                                                    children: [
                                                                                  Container(
                                                                                      width: MediaQuery.of(context)
                                                                                          .size
                                                                                          .width,
                                                                                      child: Text(userData['name'],
                                                                                          textAlign: TextAlign.left,
                                                                                          style: TextStyle(
                                                                                              color: Colors.grey[900],
                                                                                              fontSize: 16.4,
                                                                                              letterSpacing: 0.4))),
                                                                                  Container(
                                                                                      child: Row(
                                                                                          crossAxisAlignment:
                                                                                              CrossAxisAlignment.center,
                                                                                          children: [
                                                                                        Container(
                                                                                            child: Icon(
                                                                                                Icons
                                                                                                    .mode_comment_outlined,
                                                                                                color: Colors.grey[500],
                                                                                                size: 14)),
                                                                                        Container(
                                                                                            margin: EdgeInsets.only(
                                                                                                left: 4),
                                                                                            child: Text('Tap to chat',
                                                                                                style: TextStyle(
                                                                                                    color: Colors
                                                                                                        .grey[700],
                                                                                                    fontSize: 13)))
                                                                                      ]))
                                                                                ]))
                                                                          ]))));
                                                            } else {
                                                              return Container();
                                                            }
                                                          });
                                                    } else {
                                                      return Container();
                                                    }
                                                  }));
                                    }));
                          } else {
                            return Container();
                          }
                        }))),
            Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child:
                    /*Container(
                    decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 6.0, offset: Offset(0.0, 0.30))],
                        color: Colors.grey[100]),
                    child:*/
                    appBar),
          ],
        ));
  }
}
