import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MemorySnapChild extends StatefulWidget {
  final String timeAgo;
  final String theFile;
  final String name;
  final PageController ctrl;
  final dynamic nextPage;
  final dynamic prevPage;
  final int index;
  final void Function({String returnValue}) onClose;
  MemorySnapChild(
      {this.theFile, this.timeAgo, this.name, this.nextPage, this.prevPage, this.ctrl, this.index, this.onClose});
  @override
  _MemorySnapChildState createState() => _MemorySnapChildState();
}

class _MemorySnapChildState extends State<MemorySnapChild> {
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
    print('the index for mem snap child is ${widget.index}');
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Container(child: Icon(Icons.more_vert, color: Colors.white))],
      )),
      //titleSpacing: 0.0,
    );
    return Stack(children: [
      Container(child: videoOrImage(context)),
      Positioned(top: 0, left: 0, right: 0, child: appBar),
      Container(
          margin: EdgeInsets.only(top: appBar.preferredSize.height),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Row(children: [
            Expanded(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      widget.ctrl.previousPage(duration: Duration(milliseconds: 10), curve: Curves.ease);
                    },
                    child: Container())),
            Expanded(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      widget.ctrl.nextPage(duration: Duration(milliseconds: 10), curve: Curves.ease);
                    },
                    child: Container())),
          ])),
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
