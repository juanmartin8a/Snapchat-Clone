import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/screens/home/stories/forYou_PV.dart';
import 'package:video_player/video_player.dart';

class ForYouChild extends StatefulWidget {
  final String theFilePrev;
  final String theUid;
  final int index;
  ForYouChild({this.theFilePrev, this.theUid, this.index});
  @override
  _ForYouChildState createState() => _ForYouChildState();
}

class _ForYouChildState extends State<ForYouChild> {
  VideoPlayerController _controller;
  Future hasInitialized;

  Future<void> initialize() async {
    print('the file prev is ${widget.theFilePrev}');
    final VideoPlayerController vController = VideoPlayerController.network(widget.theFilePrev);
    vController.addListener(videoPlayerListener);
    //await vController.setLooping(true);
    hasInitialized = vController.initialize();
    final VideoPlayerController oldController = _controller;
    if (mounted) {
      print('HEY!!!!!');
      setState(() {
        _controller = vController;
      });
    }
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
    if (widget.theFilePrev.contains('mp4?')) {
      return FutureBuilder(
          future: hasInitialized,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              return ClipRRect(borderRadius: BorderRadius.circular(14), child: VideoPlayer(_controller));
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
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(
              image: NetworkImage(
                widget.theFilePrev,
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

  String navigateFYString;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<String>(
        closedColor: Colors.transparent,
        openColor: Colors.transparent,
        closedElevation: 0,
        openElevation: 0,
        openBuilder: (_, closeContainer) => ForYouPV(uid: widget.theUid, index: widget.index, onClose: closeContainer),
        onClosed: (res) {
          if (mounted) {
            setState(() {
              navigateFYString = res;
            });
          }
        },
        tappable: false,
        transitionType: ContainerTransitionType.fade,
        transitionDuration: Duration(milliseconds: 800),
        closedBuilder: (_, openContainer) {
          return GestureDetector(
              onTap: () {
                openContainer();
                /*Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserStories(uid: widget.theUid, index: widget.index)));*/
              },
              child: videoOrImage(context));
        });
  }
}
