import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/added/added_me.dart';
import 'package:snapchatClone/screens/home/camera/camera_state.dart';
import 'package:snapchatClone/screens/home/camera/memories_child.dart';
import 'package:snapchatClone/screens/home/search/search.dart';
import 'package:snapchatClone/screens/home/search/search_tile.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import '../../../services/auth.dart';
import '../../../services/helper/constants.dart';
import '../../../services/helper/helperfunctions.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class Memories extends StatefulWidget {
  final double statusBar;
  Memories({this.statusBar});
  @override
  _MemoriesState createState() => _MemoriesState();
}

class _MemoriesState extends State<Memories> {
  TextEditingController searchController = TextEditingController();
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot searchSnapshot;

  initializeSearch() async {
    if (searchController.text.isNotEmpty) {
      await databaseService.queryMemories(searchController.text).then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          //SearchSnapshot.searchSnapshot = searchSnapshot;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey[150],
    ));
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[800],
            size: 37,
          ),
          onPressed: () => Navigator.of(context).pop()),
      title: Container(
          child: Text('Memories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
      centerTitle: true,
      titleSpacing: 0.0,
      backgroundColor: Colors.transparent,
    );
    return Scaffold(
        primary: true,
        backgroundColor: Colors.grey[150],
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
                                  hintText: 'Search',
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
              Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(children: [
                    Container(
                        child: Text(
                      'Snaps',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold),
                    ))
                  ])),
              Expanded(
                  child: Container(
                      child: PageView(children: [
                searchController.text.isEmpty || searchController.text == null || searchController.text == ''
                    ? Container(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: DatabaseService(uid: user.uid).getMemories(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
                              if (snap.hasData && snap.data.docs.length > 0) {
                                print('the stream ${snap.data.docs.length}');
                                List<Map<String, dynamic>> memoriesArray = [];
                                for (int i = 0; i < snap.data.docs.length; i++) {
                                  Map<String, dynamic> memoriesMap = {
                                    'id': snap.data.docs[i].data()['id'],
                                    'snap': snap.data.docs[i].data()['snap'],
                                    'date': snap.data.docs[i].data()['created']
                                  };
                                  memoriesArray.add(memoriesMap);
                                }
                                return Container(
                                    color: Colors.transparent,
                                    margin: EdgeInsets.only(top: 8),
                                    child: Column(children: [
                                      Container(
                                          margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          width: MediaQuery.of(context).size.width,
                                          child: Text('Recently Added',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 14.6, color: Colors.black, fontWeight: FontWeight.bold))),
                                      Expanded(
                                          child: GridView.count(
                                              crossAxisCount: 4,
                                              childAspectRatio: (9 / 16),
                                              children: List.generate(memoriesArray.length, (int index) {
                                                print('made it till grid');
                                                return Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 1.1, vertical: 1.1),
                                                    child: MemoriesChild(
                                                      id: memoriesArray[index]['id'],
                                                      snap: memoriesArray[index]['snap'],
                                                      date: memoriesArray[index]['date'],
                                                      index: index,
                                                    ));
                                              })))
                                    ]));
                              } else if (snap.connectionState == ConnectionState.waiting) {
                                return Container();
                              } else {
                                return Container(
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                color: Colors.transparent,
                                                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                                                child: Container(
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                      Container(
                                                          child: Text('No Snaps...Yet!',
                                                              style: TextStyle(
                                                                fontSize: 16.2,
                                                                color: Colors.black,
                                                              ))),
                                                      Container(
                                                          child: Text(
                                                              'Snaps you create and save will be stored here so that you can look back later.',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 14.8,
                                                                color: Colors.grey[700],
                                                              ))),
                                                      Container(
                                                          margin: EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue[400],
                                                            borderRadius: BorderRadius.circular(30),
                                                          ),
                                                          padding: EdgeInsets.symmetric(vertical: 11, horizontal: 35),
                                                          child: Text('Create Snap',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 16,
                                                                  letterSpacing: 0.45,
                                                                  fontWeight: FontWeight.bold))),
                                                    ])))),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                color: Colors.transparent,
                                                child: GridView.count(
                                                    crossAxisCount: 4,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    primary: false,
                                                    childAspectRatio: 9 / 16,
                                                    children: List.generate(12, (int index) {
                                                      return Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 1.1, vertical: 1.1),
                                                          child: Container(color: Colors.grey[300]));
                                                    }))))
                                      ],
                                    ));
                              }
                            }))
                    : Container(
                        //margin: EdgeInsets.symmetric(vertical: 20),
                        child: FutureBuilder(
                            future: DatabaseService(uid: user.uid).queryMemories(searchController.text),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data.docs.length > 0) {
                                List<Map<String, dynamic>> memoriesArray = [];
                                for (int i = 0; i < snapshot.data.docs.length; i++) {
                                  Map<String, dynamic> memoriesMap = {
                                    'id': snapshot.data.docs[i].data()['id'],
                                    'snap': snapshot.data.docs[i].data()['snap'],
                                    'date': snapshot.data.docs[i].data()['created']
                                  };
                                  memoriesArray.add(memoriesMap);
                                }
                                return Container(
                                    color: Colors.transparent,
                                    margin: EdgeInsets.only(top: 8),
                                    child: Column(children: [
                                      Container(
                                          margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          width: MediaQuery.of(context).size.width,
                                          child: Text('Recently Added',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 14.6, color: Colors.black, fontWeight: FontWeight.bold))),
                                      Expanded(
                                          child: GridView.count(
                                              crossAxisCount: 4,
                                              childAspectRatio: (9 / 16),
                                              children: List.generate(memoriesArray.length, (int index) {
                                                print('made it till grid');
                                                return Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 1.1, vertical: 1.1),
                                                    child: MemoriesChild(
                                                      id: memoriesArray[index]['id'],
                                                      snap: memoriesArray[index]['snap'],
                                                      date: memoriesArray[index]['date'],
                                                      index: index,
                                                    ));
                                              })))
                                    ]));
                              } else if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container();
                              } else {
                                return Container(
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: Text('No Snaps found.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13.4,
                                                ))),
                                        Container(
                                            child: Text('Try searching for times, dates & locations.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13.4,
                                                )))
                                      ],
                                    ));
                              }
                            }))
              ])))
            ]))));
  }
}
