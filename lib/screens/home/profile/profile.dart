import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/camera/add_friends.dart';
import 'package:snapchatClone/screens/home/profile/add_to_my_story.dart';
import 'package:snapchatClone/screens/home/profile/settings.dart';
import 'package:snapchatClone/services/auth.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final double statusBar;
  Profile({this.statusBar});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();
  cameraBottomSheet(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          print('the status bar height is $statusBarHeight');
          return AddToMyStory(statusBar: widget.statusBar);
        });
  }

  friendsBottomSheet(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          /*return DraggableScrollableSheet(
              initialChildSize: 1, // half screen on load
              maxChildSize: 1, // full screen on scroll
              //minChildSize: 0.25,
              builder: (context, ScrollController scrollController) {*/
          return AddFriends(statusBar: widget.statusBar);
          //});
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.grey[800], size: 22),
          onPressed: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 500),
                    transitionsBuilder: (BuildContext context, Animation<double> animation,
                        Animation<double> secondaryAnimation, Widget child) {
                      animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
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
                    pageBuilder: (context, Animation<double> animation, Animation<double> secondaryAnimation) =>
                        SettingsScreen(
                            statusBar: widget.statusBar,
                            logOut: () async {
                              await _auth.signOut();
                            },
                            popProfile: () {
                              Navigator.of(context).pop();
                            })));
          },
        )
      ],
      leading: IconButton(
          //padding: EdgeInsets.only(top: widget.statusBar),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[800],
            size: 37,
          ),
          onPressed: () => Navigator.of(context).pop()),
      centerTitle: true,
      titleSpacing: 0.0,
      backgroundColor: Colors.transparent,
    );
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBar.preferredSize.height + widget.statusBar),
            child: Container(padding: EdgeInsets.only(top: widget.statusBar), child: appBar)),
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.26,
                      height: MediaQuery.of(context).size.width * 0.26,
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent[400],
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      )),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      width: MediaQuery.of(context).size.width,
                      //height: MediaQuery.of(context).size.width * 0.30,
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: DatabaseService(uid: user != null ? user.uid : null).getUserProfile(),
                          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> userDocs = snapshot.data.data();
                              return Container(
                                  child: Column(children: [
                                Container(
                                    child: Text('${userDocs['name']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 21,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8))),
                                Container(
                                    child: Text('${userDocs['username']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6))),
                              ]));
                            } else {
                              return Container();
                            }
                          })),
                ],
              )),
          Container(
              width: MediaQuery.of(context).size.width * 0.93,
              child: Column(children: [
                Container(
                    margin: EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    child: Text('Stories',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.grey[900], fontSize: 17, fontWeight: FontWeight.w700))),
                Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ]),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                          child: GestureDetector(
                              onTap: () {
                                cameraBottomSheet(context);
                              },
                              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                Container(
                                  child: Icon(Icons.camera_alt_outlined, color: Colors.lightBlueAccent[400], size: 28),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 8),
                                    child: Text('Add to My Story',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.grey[900], fontSize: 16, fontWeight: FontWeight.w600)))
                              ]))),
                      Container(child: Icon(Icons.more_vert, color: Colors.grey[500], size: 27))
                    ]))
              ])),
          Container(
              width: MediaQuery.of(context).size.width * 0.93,
              child: Column(children: [
                Container(
                    margin: EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    child: Text('Friends',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.grey[900], fontSize: 17, fontWeight: FontWeight.w700))),
                Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ]),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                          child: GestureDetector(
                              onTap: () {
                                friendsBottomSheet(context);
                              },
                              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                Container(
                                  child: Icon(Icons.person_add_alt, color: Colors.grey[400], size: 28),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 8),
                                    child: Text('Add Friends',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.grey[900], fontSize: 16, fontWeight: FontWeight.w600)))
                              ]))),
                      Container(child: Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey[350], size: 32))
                    ]))
              ]))
        ]));
  }
}
