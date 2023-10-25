import 'package:flutter/material.dart';
import 'package:snapchatClone/screens/home/chat/chat_image.dart';
import '../../../services/database.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String userName;
  final bool isSendByMe;
  final String sendedBy;
  final String type;
  final String chatRoomId;
  final String messageId;
  final bool isSeen;
  final bool chatRoomType;
  MessageTile(
      {this.message,
      this.isSendByMe,
      this.userName,
      this.type,
      this.chatRoomId,
      this.sendedBy,
      this.messageId,
      this.isSeen,
      this.chatRoomType});
  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  chatImgBottomSheet(BuildContext context) {
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
          return ChatImage(message: widget.message, chatRoomId: widget.chatRoomId, userName: widget.userName);
          //});
        });
  }

  @override
  void initState() {
    if (!widget.isSendByMe && !widget.chatRoomType) {
      DatabaseService(uid: widget.chatRoomId, docId: widget.messageId).updateChat(true);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (!widget.isSendByMe && !widget.chatRoomType) {
      if (!widget.isSeen) {
        DatabaseService(uid: widget.chatRoomId, docId: widget.messageId).deleteChat();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String theOtherUserName = widget.sendedBy.toUpperCase();
    return Container(
        margin: EdgeInsets.only(
          left: 8,
          top: 6,
          right: 8,
        ),
        child: widget.isSendByMe
            ? Column(children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    width: MediaQuery.of(context).size.width,
                    child: Text('ME',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.red, fontSize: 13.6, letterSpacing: 0.7, fontWeight: FontWeight.w700))),
                widget.type == 'text'
                    ? GestureDetector(
                        onLongPress: () {
                          DatabaseService(uid: widget.chatRoomId, docId: widget.messageId).deleteChat();
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(left: BorderSide(color: Colors.red, width: 3))),
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                            child: Text(widget.message,
                                style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 0.4,
                                ))),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                              left: BorderSide(color: widget.isSendByMe ? Colors.red : Colors.blue[300], width: 3)),
                          //borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                        child: GestureDetector(
                            onTap: () {
                              chatImgBottomSheet(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Colors.grey[800], width: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                child: Row(children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      right: 6,
                                    ),
                                    child: Icon(Icons.send_rounded, color: Colors.red, size: 26),
                                  ),
                                  Text('Delivered',
                                      style:
                                          TextStyle(fontSize: 17.6, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                                ]))))
              ])
            : Column(children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    width: MediaQuery.of(context).size.width,
                    child: Text(theOtherUserName,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.blue[300], fontSize: 13.6, letterSpacing: 0.7, fontWeight: FontWeight.w700))),
                widget.type == 'text'
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(left: BorderSide(color: Colors.blue[300], width: 3))),
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                        child: Text(widget.message,
                            style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 0.4,
                            )))
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                              left: BorderSide(color: widget.isSendByMe ? Colors.red : Colors.blue[300], width: 3)),
                          //borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                        child: GestureDetector(
                            onTap: () {
                              chatImgBottomSheet(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Colors.grey[800], width: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Row(children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      right: 6,
                                    ),
                                    child: Icon(Icons.send_rounded, color: Colors.blue[300], size: 26),
                                  ),
                                  Text('Recieved',
                                      style:
                                          TextStyle(fontSize: 17.6, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                                ]))))
              ]));
  }
}
