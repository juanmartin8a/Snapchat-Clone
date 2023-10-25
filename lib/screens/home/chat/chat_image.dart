import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/chat/chat_snaps.dart';
import 'package:video_player/video_player.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class ChatImage extends StatefulWidget {
  final String message;
  final String chatRoomId;
  final String userName;
  ChatImage({this.message, this.chatRoomId, this.userName});
  @override
  _ChatImageState createState() => _ChatImageState();
}

class _ChatImageState extends State<ChatImage> {
  VideoPlayerController _controller;
  Future hasInitialized;
  TextEditingController messageController = TextEditingController();

  sendMessage(BuildContext context) {
    if (messageController.text.isNotEmpty) {
      final user = Provider.of<CustomUser>(context, listen: false);
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('chatRoom').doc(widget.chatRoomId).collection('chat').doc();
      Map<String, dynamic> messageMap = {
        'message': messageController.text,
        'sendBy': user.uid,
        'time': DateTime.now().millisecondsSinceEpoch,
        'id': docRef.id,
        'type': 'text',
      };
      DatabaseService(uid: widget.chatRoomId).addConversationMessages(messageMap, docRef);
      setState(() {
        messageController.text = '';
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> initialize() async {
    //print(widget.index);
    final VideoPlayerController vController = VideoPlayerController.network(widget.message);
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
    if (widget.message.contains('mp4?')) {
      return FutureBuilder(
          future: hasInitialized,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ClipRRect(child: VideoPlayer(_controller));
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
            //borderRadius: BorderRadius.circular(100 / 2),
            image: DecorationImage(
              image: NetworkImage(
                widget.message,
              ),
              fit: BoxFit.cover,
            )),
      );
    }
  }

  cameraBottomSheet(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          print('the status bar height is $statusBarHeight');
          return SnapsInChat(statusBar: statusBarHeight, userName: widget.userName, chatRoomId: widget.chatRoomId);
        });
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
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert_rounded),
          onPressed: () {},
        )
      ],
      //titleSpacing: 0.0,
    );
    return Stack(
      children: [
        Positioned.fill(child: videoOrImage(context)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: appBar,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  //color: Colors.red,
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height * 0.05,
                  /*constraints: BoxConstraints.expand(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),*/
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 120,
                      ),
                      //height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                  onTap: () {
                                    cameraBottomSheet(context);
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: Colors.grey[500], width: 0.8),
                                        color: Colors.black26,
                                      ),
                                      margin: EdgeInsets.only(right: 12),
                                      padding: EdgeInsets.only(top: 9, bottom: 9),
                                      child: Icon(Icons.camera_alt_rounded, color: Colors.white)))),
                          Expanded(
                              flex: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.grey[500], width: 0.8),
                                  color: Colors.black26,
                                ),
                                child: TextField(
                                    textInputAction: TextInputAction.send,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    controller: messageController,
                                    cursorColor: Colors.white,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                    onSubmitted: (details) {
                                      sendMessage(context);
                                    },
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 17, right: 17, top: 9, bottom: 9),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: 'Send a chat',
                                    )),
                              )),
                          /*Expanded(
                            flex: 1,
                            child: Container(
                                child: IconButton(
                                    icon: Icon(Icons.send),
                                    onPressed: () {
                                      sendMessage();
                                    }))),*/
                        ],
                      )))),
        ),
      ],
    );
  }
}
