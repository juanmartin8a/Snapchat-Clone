import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';

class ChangeName extends StatefulWidget {
  final double statusBar;
  final String name;
  ChangeName({this.statusBar, @required this.name});
  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  TextEditingController _nameController;

  changeName() {
    final user = Provider.of<CustomUser>(context, listen: false);
    DatabaseService(uid: user.uid).changeName(_nameController.text);
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: '${widget.name}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    AppBar appBar = AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: Colors.teal[400],
            size: 37,
          ),
          onPressed: () => Navigator.of(context).pop()),
      title: Container(
          child: Text('Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[400]))),
      centerTitle: true,
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[50],
      bottom: PreferredSize(
          child: Container(
            color: Colors.grey[600],
            height: 0.2,
          ),
          preferredSize: Size.fromHeight(0.2)),
    );
    return Scaffold(
        appBar:
            PreferredSize(preferredSize: Size.fromHeight(appBar.preferredSize.height), child: Container(child: appBar)),
        backgroundColor: Colors.grey[200],
        body: Container(
            child: Stack(children: [
          Container(
              child: Column(children: [
            Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                child: Text('This is how you appear on Snapchat, so pick a name your friends know you by.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12.4, fontWeight: FontWeight.w600))),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.white,
              child: TextField(
                  controller: _nameController,
                  maxLines: null,
                  cursorColor: Colors.blue,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (details) {
                    setState(() {
                      _nameController.text;
                    });
                  },
                  style: TextStyle(fontSize: 17.4, color: Colors.black, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    //hintText: 'Chat',
                  )),
            )
          ])),
          _nameController.text == '' || _nameController.text == null || _nameController.text == widget.name
              ? Container()
              : Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                      onTap: () {
                        changeName();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.07,
                          color: Colors.teal,
                          child: Center(
                              child: Text('SAVE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ))))))
        ])));
  }
}
