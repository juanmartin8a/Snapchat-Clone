import 'package:flutter/material.dart';
import 'package:snapchatClone/screens/home/camera/add_friends.dart';
import 'package:snapchatClone/screens/home/chat/chat_and_groups.dart';
import 'package:snapchatClone/screens/home/profile/profile.dart';
import 'package:snapchatClone/screens/home/search/search.dart';

class Header extends StatefulWidget {
  final int theIndex;
  Header({Key key, this.theIndex}) : super(key: key);
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with SingleTickerProviderStateMixin {
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
          return AddFriends(statusBar: statusBarHeight);
          //});
        });
  }

  searchBottomSheet(BuildContext context) {
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
          return Search(statusBar: statusBarHeight);
          //});
        });
  }

  chatBottomSheet(BuildContext context) {
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
          return ChatAndGroups(statusBar: statusBarHeight);
          //});
        });
  }

  profileBottomSheet(BuildContext context) {
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
          return Profile(statusBar: statusBarHeight);
          //});
        });
  }

  AnimationController _controller;
  var animation;

  @override
  void didUpdateWidget(Header oldWidget) {
    if (widget.theIndex != oldWidget.theIndex) {
      _controller.forward(from: 0.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    animation = Tween(
      begin: 0.2,
      end: 1.0,
    ).animate(_controller);
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: animation,
        //switchInCurve: Curve.,
        child: IndexedStack(
          index: widget.theIndex,
          children: [
            AppBar(
              elevation: 0.0,
              automaticallyImplyLeading: true,
              leading: null,
              titleSpacing: 0.0,
              backgroundColor: Colors.transparent,
              title: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  profileBottomSheet(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.person, color: Colors.white, size: 24))),
                            GestureDetector(
                                onTap: () {
                                  searchBottomSheet(context);
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.search_rounded, color: Colors.white, size: 24))),
                          ],
                        ),
                        Row(children: [
                          GestureDetector(
                              onTap: () {
                                //friendsBottomSheet(context);
                              },
                              child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                  child: Icon(Icons.settings, color: Colors.white, size: 24))),
                        ])
                      ])),
              centerTitle: true,
            ),
            AppBar(
              elevation: 0.0,
              automaticallyImplyLeading: true,
              leading: null,
              titleSpacing: 0.0,
              backgroundColor: Colors.transparent,
              title: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  profileBottomSheet(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.person, color: Colors.grey[600], size: 24))),
                            GestureDetector(
                                onTap: () {
                                  searchBottomSheet(context);
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.search_rounded, color: Colors.grey[600], size: 24))),
                          ],
                        ),
                        Row(children: [
                          GestureDetector(
                              onTap: () {
                                friendsBottomSheet(context);
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                  child: Icon(Icons.person_add, color: Colors.grey[600], size: 24))),
                          GestureDetector(
                              onTap: () {
                                chatBottomSheet(context);
                              },
                              child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                  child: Icon(Icons.messenger_rounded, color: Colors.grey[600], size: 24))),
                        ])
                      ])),
              centerTitle: true,
            ),
            AppBar(
              elevation: 0.0,
              automaticallyImplyLeading: true,
              leading: null,
              titleSpacing: 0.0,
              backgroundColor: Colors.transparent,
              title: Container(
                  //alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width - 70,
                  //color: Colors.red,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  profileBottomSheet(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.person, color: Colors.white, size: 24))),
                            GestureDetector(
                                onTap: () {
                                  searchBottomSheet(context);
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.search_rounded, color: Colors.white, size: 24))),
                          ],
                        ),
                        /*Container(
                      width: MediaQuery.of(context).size.width * 0.22,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [*/
                        GestureDetector(
                            onTap: () {
                              friendsBottomSheet(context);
                            },
                            child: Container(
                                padding: EdgeInsets.all(8),
                                decoration:
                                    BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                child: Icon(Icons.person_add, color: Colors.white, size: 24))),
                        //Container(padding: EdgeInsets.all(8), height: 24, width: 24)
                        //]))
                      ])),
              //centerTitle: true,
            ),
            AppBar(
              elevation: 0.0,
              automaticallyImplyLeading: true,
              leading: null,
              titleSpacing: 0.0,
              backgroundColor: Colors.transparent,
              title: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  profileBottomSheet(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.person, color: Colors.grey[600], size: 24))),
                            GestureDetector(
                                onTap: () {
                                  searchBottomSheet(context);
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.search_rounded, color: Colors.grey[600], size: 24))),
                          ],
                        ),
                        Row(children: [
                          GestureDetector(
                              onTap: () {
                                friendsBottomSheet(context);
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                  child: Icon(Icons.person_add, color: Colors.grey[600], size: 24))),
                          GestureDetector(
                              onTap: () {
                                //friendsBottomSheet(context);
                              },
                              child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                  child: Icon(Icons.more_vert_rounded, color: Colors.grey[600], size: 24))),
                        ])
                      ])),
              centerTitle: true,
            ),
            AppBar(
              elevation: 0.0,
              automaticallyImplyLeading: true,
              leading: null,
              titleSpacing: 0.0,
              backgroundColor: Colors.transparent,
              title: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  profileBottomSheet(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.person, color: Colors.grey[600], size: 24))),
                            GestureDetector(
                                onTap: () {
                                  searchBottomSheet(context);
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                    child: Icon(Icons.search_rounded, color: Colors.grey[600], size: 24))),
                          ],
                        ),
                        Row(children: [
                          GestureDetector(
                              onTap: () {
                                friendsBottomSheet(context);
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                                  child: Icon(Icons.person_add, color: Colors.grey[600], size: 24))),
                        ])
                      ])),
              centerTitle: true,
            ),
          ],
        ));
  }
}
