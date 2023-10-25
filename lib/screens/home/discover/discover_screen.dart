import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/added/added_me.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';

class Discover extends StatefulWidget {
  final double statusBar;
  Discover({this.statusBar});
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: true,
      leading: null,
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[50],
      title: Container(
          color: Colors.transparent,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text('Discover', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
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
            Positioned(top: 0.0, left: 0.0, right: 0.0, child: appBar),
            Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.93,
                    margin: EdgeInsets.only(top: appBar.preferredSize.height + widget.statusBar),
                    child: FutureBuilder(
                        future: DatabaseService(uid: user.uid).getUsers(),
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
                                Container(
                                    width: MediaQuery.of(context).size.width * 0.93,
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9.0),
                                        ),
                                        child: ListView.builder(
                                          itemCount: usersArray.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            print('made it till List View ${usersArray.length}');
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
                                        )))
                              ],
                            );
                          } else {
                            return Container();
                          }
                        })))
          ],
        ));
  }
}
