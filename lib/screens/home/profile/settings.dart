import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/profile/change_name.dart';
import 'package:snapchatClone/screens/home/profile/change_username.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final double statusBar;
  final Function logOut;
  final Function popProfile;
  SettingsScreen({this.statusBar, this.logOut, this.popProfile});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: Colors.teal[400],
            size: 37,
          ),
          onPressed: () => Navigator.of(context).pop()),
      title: Container(
          child:
              Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[400]))),
      centerTitle: true,
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[50],
      bottom: PreferredSize(
          child: Container(
            color: Colors.grey[600],
            height: 0.4,
          ),
          preferredSize: Size.fromHeight(0.4)),
    );
    return Scaffold(
        appBar:
            PreferredSize(preferredSize: Size.fromHeight(appBar.preferredSize.height), child: Container(child: appBar)),
        backgroundColor: Colors.grey[200],
        body: Container(
            child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(12),
                child: Text('MY ACCOUNT',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.teal[400], fontSize: 13.6, fontWeight: FontWeight.w600))),
            Container(
                color: Colors.grey[50],
                child: StreamBuilder<DocumentSnapshot>(
                    stream: DatabaseService(uid: user != null ? user.uid : null).getUserProfile(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> userDoc = snapshot.data.data();

                        return Container(
                            child: ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: [
                          GestureDetector(
                              onTap: () {
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
                                           );*/
                                        },
                                        pageBuilder: (context, Animation<double> animation,
                                                Animation<double> secondaryAnimation) =>
                                            ChangeName(name: userDoc['name'])));
                              },
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey[400]))),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Container(
                                        child: Text(
                                      'Name',
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                                    )),
                                    Container(
                                        child: Text(
                                      '${userDoc['name']}',
                                      style:
                                          TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600),
                                    ))
                                  ]))),
                          GestureDetector(
                              onTap: () {
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
                                        pageBuilder: (context, Animation<double> animation,
                                                Animation<double> secondaryAnimation) =>
                                            ChangeUsername(userName: userDoc['username'])));
                              },
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey[400]))),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Container(
                                        child: Text(
                                      'Username',
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                                    )),
                                    Container(
                                        child: Text(
                                      '${userDoc['username']}',
                                      style:
                                          TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600),
                                    ))
                                  ]))),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey[400]))),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Container(
                                    child: Text(
                                  'Email',
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                                )),
                                Container(
                                    child: Text(
                                  '${userDoc['email']}',
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600),
                                ))
                              ])),
                          GestureDetector(
                            onTap: () async {
                              await widget.logOut();
                              Navigator.of(context).pop();
                              widget.popProfile();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey[400]))),
                                child: Container(
                                    child: Text(
                                  'Log Out',
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                                ))),
                          )
                        ]));
                      } else {
                        return Container();
                      }
                    }))
          ],
        )));
  }
}
