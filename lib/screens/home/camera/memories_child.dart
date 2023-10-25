import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/snaps/memory_snaps.dart';
import 'package:video_player/video_player.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

class MemoriesChild extends StatefulWidget {
  final String id;
  final String snap;
  final Timestamp date;
  final int index;
  MemoriesChild({this.id, this.snap, this.date, this.index});
  @override
  _MemoriesChildState createState() => _MemoriesChildState();
}

class _MemoriesChildState extends State<MemoriesChild> {
  VideoPlayerController _controller;
  Future hasInitialized;
  //HeroController _heroController;
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    //print(widget.index);
    final VideoPlayerController vController = VideoPlayerController.network(widget.snap);
    vController.addListener(videoPlayerListener);
    await vController.setLooping(true);
    hasInitialized = vController.initialize();
    final VideoPlayerController oldController = _controller;
    if (mounted) {
      print('HEY!!!!!');
      setState(() {
        _controller = vController;
      });
    }
    //print('current post is ${widget.postsList}');
    await vController.pause();
    await oldController?.dispose();
    print('controller is $_controller');
  }

  get videoPlayerListener => () {
        if (_controller != null && _controller.value.size != null) {
          // Refreshing the state to update video player with the correct ratio.
          if (mounted) setState(() {});
          _controller.removeListener(videoPlayerListener);
        }
      };

  videoOrImage(BuildContext context) {
    if (widget.snap.contains('mp4?')) {
      return FutureBuilder(
          future: hasInitialized,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              return VideoPlayer(_controller);
            } else {
              return Container(
                color: Colors.grey[300],
              );
            }
          });
    } else {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.grey[300],
            image: DecorationImage(
              image: NetworkImage(
                widget.snap,
              ),
              fit: BoxFit.cover,
            )),
      );
    }
  }

  RectTween _createRectTween(Rect begin, Rect end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  Route onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => ShowSnaps(), settings: settings);
  }

  _showDialog(BuildContext context) {
    final user = Provider.of<CustomUser>(context, listen: false);
    showGeneralDialog(
        context: context,
        transitionDuration: Duration(milliseconds: 400),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          );
        },
        pageBuilder: (context, anim1, anim2) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          height: MediaQuery.of(context).size.height * 0.10,
                          child: AspectRatio(aspectRatio: 9 / 12, child: videoOrImage(context))),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'Delete Snap?',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            DatabaseService(uid: user.uid, docId: widget.id).deleteMemories();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(26),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 35),
                              child: Text(
                                'Delete Snap',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16.6,
                                  fontWeight: FontWeight.w700,
                                ),
                              ))),
                    ],
                  )));
        });
  }

  @override
  void initState() {
    print('the index for mem child is ${widget.index}');
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String searchString;

  @override
  Widget build(BuildContext context) {
    return //Stack(children: [
        OpenContainer<String>(
            closedColor: Colors.transparent,
            openColor: Colors.transparent,
            closedElevation: 0,
            openElevation: 0,
            openBuilder: (_, closeContainer) => ShowSnaps(index: widget.index, onClose: closeContainer),
            onClosed: (res) => setState(() {
                  searchString = res;
                }),
            tappable: false,
            transitionType: ContainerTransitionType.fade,
            transitionDuration: Duration(milliseconds: 800),
            closedBuilder: (_, openContainer) {
              return GestureDetector(
                  onLongPress: () {
                    _showDialog(context);
                  },
                  onTap: () {
                    openContainer();
                    /*Navigator.push(
                          context,
                          PageRouteBuilder(
                              transitionDuration: Duration(seconds: 5),
                              /*transitionsBuilder: (BuildContext context, Animation<double> animation,
                                  Animation<double> secondaryAnimation, Widget child) {
                                animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                                return Align(
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },*/
                              pageBuilder: (_, __, ___) => ShowSnaps(
                                    index: widget.index,
                                  )));*/
                  },
                  child: Container(child: videoOrImage(context)));
            });
  }
}
