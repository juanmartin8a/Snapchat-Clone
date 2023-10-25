import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/chat/chat_snaps.dart';
import 'package:snapchatClone/screens/home/chat/in_chat_child.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ConversationScreen extends StatefulWidget {
  final String myName;
  final String chatRoomId;
  final String userName;
  final bool chatType;
  ConversationScreen({this.myName, this.chatRoomId, this.userName, this.chatType});
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseService databaseService = DatabaseService();
  TextEditingController messageController = TextEditingController();
  final String chatId = DatabaseService().chatId;
  GlobalKey _textfieldKey = GlobalKey();
  var _textSize;
  Offset cardPosition;
  final ValueNotifier<double> _rowHeight = ValueNotifier<double>(-1);

  Stream chatMessagesStream;

  sendMessage(BuildContext context) {
    if (messageController.text.isNotEmpty) {
      final user = Provider.of<CustomUser>(context, listen: false);
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('chatRoom').doc(widget.chatRoomId).collection('chat').doc();
      Map<String, dynamic> messageMap = {
        'message': messageController.text,
        'sendBy': user.uid,
        'time': DateTime.now().millisecondsSinceEpoch,
        'deleted': widget.chatType ? DateTime.now().add(Duration(days: 1)) : null,
        'id': docRef.id,
        'type': 'text',
        'seen': widget.chatType ? null : false,
      };
      DatabaseService(uid: widget.chatRoomId).addConversationMessages(messageMap, docRef);
      setState(() {
        messageController.text = '';
      });
    }
  }

  chatMessagesList(
    BuildContext context,
    String myUid,
    /*ScrollController scrollController*/
  ) {
    ScrollController _scrollController = ScrollController();
    Timer(
      Duration(seconds: 1),
      () => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
      ),
    );
    return StreamBuilder(
        stream: chatMessagesStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<DocumentSnapshot>(
                        stream: DatabaseService(uid: snapshot.data.docs[index].data()['sendBy']).getUserProfile(),
                        builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                          if (snap.hasData) {
                            Map<String, dynamic> userData = snap.data.data();
                            return MessageTile(
                              message: snapshot.data.docs[index].data()['message'],
                              isSendByMe: snapshot.data.docs[index].data()['sendBy'] == myUid,
                              userName: widget.userName,
                              sendedBy: userData['name'],
                              type: snapshot.data.docs[index].data()['type'],
                              //userUids: snapshot.data.docs[index].data()['sendBy'],
                              //myProPic: widget.myProPic,
                              //proPic: widget.proPic,
                              chatRoomId: widget.chatRoomId,
                              chatRoomType: widget.chatType,
                              isSeen: snapshot.data.docs[index].data()['type'] == true,
                              messageId: snapshot.data.docs[index].data()['id'],
                            );
                          } else {
                            return Container();
                          }
                        });
                  })
              : Container();
        });
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
    DatabaseService().getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessagesStream = value;
      });
    }); //_toEnd();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _rowHeight.value = _textfieldKey.currentContext.size.height);
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  getSizeAndPosition(_) {
    var context = _textfieldKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (_textSize == newSize) return;

    _textSize = newSize;
    //widget.onChange(newSize);
    var _textFieldBox = _textfieldKey.currentContext;
    _textSize = _textFieldBox.size;
    //cardPosition = _textFieldBox.localToGlobal(Offset.zero);
    print('the text height is ${_textSize.height}');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            child: Container(
              color: Colors.grey[800],
              height: 0.2,
            ),
            preferredSize: Size.fromHeight(0.2),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Colors.grey[700],
                size: 34,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
          elevation: 0,
          backgroundColor: Colors.grey[50],
          title: Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  child: Row(children: [
                Container(
                  child: Text(widget.userName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        letterSpacing: 0.68,
                        fontWeight: FontWeight.bold,
                      )),
                )
              ])),
              /*GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.zero,
                  color: Colors.red,
                  child: Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey[700], size: 34,),
                ),
              )*/
            ],
          )),
          centerTitle: false,
        ),
        //backgroundColor: Colors.grey[150],
        body: Container(
            //color: Colors.blue,
            child: Stack(
          children: [
            Align(
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
                      key: _textfieldKey,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                            top: BorderSide(
                          color: Colors.grey[600],
                          width: 0.2,
                        )),
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
                                        color: Colors.grey[300],
                                      ),
                                      margin: EdgeInsets.only(right: 12),
                                      padding: EdgeInsets.only(top: 9, bottom: 9),
                                      child: Icon(Icons.camera_alt_rounded, color: Colors.grey[700])))),
                          Expanded(
                              flex: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.grey[300],
                                ),
                                child: TextField(
                                    textInputAction: TextInputAction.send,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    controller: messageController,
                                    cursorColor: Colors.pink[700],
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                      fontSize: 19,
                                    ),
                                    onSubmitted: (details) {
                                      sendMessage(context);
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 17, right: 17, top: 9, bottom: 9),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: 'Chat',
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
                      ))),
            ),
            Positioned(
                top: 0,
                bottom: _rowHeight.value,
                left: 0,
                right: 0,
                child: Container(
                  //margin: EdgeInsets.only(bottom: _rowHeight.value),
                  padding: EdgeInsets.only(
                    bottom: 16,
                  ),
                  //color: Colors.green,
                  child: chatMessagesList(context, user.uid),
                )),
          ],
        )));
  }
}
