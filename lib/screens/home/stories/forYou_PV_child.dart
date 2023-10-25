import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ForYouPVChild extends StatefulWidget {
  final String timeAgo;
  final String theFile;
  final String name;
  final PageController ctrl;
  final dynamic nextPage;
  final dynamic prevPage;
  final void Function({String returnValue}) onClose;
  ForYouPVChild({this.theFile, this.timeAgo, this.name, this.nextPage, this.prevPage, this.ctrl, this.onClose});
  @override
  _ForYouPVChildState createState() => _ForYouPVChildState();
}

class _ForYouPVChildState extends State<ForYouPVChild> {
  VideoPlayerController _controller;
  Future hasInitialized;

  Future<void> initialize() async {
    //print(widget.index);
    final VideoPlayerController vController = VideoPlayerController.network(widget.theFile);
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
    await vController.play();
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
    if (widget.theFile.contains('mp4?')) {
      return FutureBuilder(
          future: hasInitialized,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              return VideoPlayer(_controller);
            } else {
              return Container();
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
                widget.theFile,
              ),
              fit: BoxFit.cover,
            )),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              child: Row(
            children: [
              Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      child: Text(widget.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.4,
                            letterSpacing: 0.4,
                            shadows: <Shadow>[
                              Shadow(
                                //offset: Offset(10.0, 10.0),
                                blurRadius: 10.0,
                                color: Colors.grey[900],
                              ),
                              Shadow(
                                //offset: Offset(10.0, 10.0),
                                blurRadius: 8.0,
                                color: Colors.grey[900],
                              ),
                            ],
                          ))),
                  Container(
                      child: Text('${widget.timeAgo} ago',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            letterSpacing: 0.3,
                            shadows: <Shadow>[
                              Shadow(
                                //offset: Offset(10.0, 0.0),
                                blurRadius: 10.0,
                                color: Colors.grey[900],
                              ),
                              Shadow(
                                //offset: Offset(10.0, 10.0),
                                blurRadius: 8.0,
                                color: Colors.grey[900],
                              ),
                            ],
                          )))
                ],
              ))
            ],
          ))
        ],
      )),
      //titleSpacing: 0.0,
    );
    return Stack(children: [
      videoOrImage(context),
      Positioned(top: 0, right: 0, left: 0, child: appBar),
      Container(
          margin: EdgeInsets.only(top: appBar.preferredSize.height),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      widget.ctrl.previousPage(duration: Duration(milliseconds: 10), curve: Curves.ease);
                    },
                    child: Container(
                      color: Colors.transparent,
                    )),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      widget.ctrl.nextPage(duration: Duration(milliseconds: 10), curve: Curves.ease);
                    },
                    child: Container(
                      color: Colors.transparent,
                    )),
              )
            ],
          )),
      Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dy > 0) {
                widget.onClose();
                //Navigator.of(context).pop();
              } else {
                null;
              }
              //memoriesBottomSheet(context);
            },
          ))
    ]);
  }
}
