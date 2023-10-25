import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/snaps/memory_snap_chils.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ShowSnaps extends StatefulWidget {
  final String id;
  final String snap;
  final Timestamp date;
  final int index;
  final void Function({String returnValue}) onClose;
  ShowSnaps({this.id, this.snap, this.date, this.index, this.onClose});
  @override
  _ShowSnapsState createState() => _ShowSnapsState();
}

class _ShowSnapsState extends State<ShowSnaps> {
  PageController _ctrl = PageController();
  PageController _controller;
  int currentPage;
  double vp;

  @override
  void initState() {
    _controller = PageController(initialPage: widget.index, viewportFraction: 1.45);
    currentPage = widget.index;
    _controller.addListener(() {
      int next = _controller.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
    super.initState();
  }

  void dispose() {
    _ctrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    final user = Provider.of<CustomUser>(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder<QuerySnapshot>(
            stream: DatabaseService(uid: user.uid).getMemories(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data.docs.length > 0) {
                print('the stream ${snapshot.data.docs.length}');
                List<Map<String, dynamic>> memoriesArray = [];
                for (int i = 0; i < snapshot.data.docs.length; i++) {
                  Map<String, dynamic> memoriesMap = {
                    'id': snapshot.data.docs[i].data()['id'],
                    'snap': snapshot.data.docs[i].data()['snap'],
                    'date': snapshot.data.docs[i].data()['created']
                  };
                  memoriesArray.add(memoriesMap);
                }
                return PageView.builder(
                    controller: _controller,
                    itemCount: memoriesArray.length,
                    itemBuilder: (context, index) {
                      bool active = index == currentPage;
                      final double blur = active ? 0 : 50;
                      final Color opacity = active ? Colors.transparent : Colors.black45;
                      final double height = active ? 0.0 : MediaQuery.of(context).size.height * 0.150;
                      return FractionallySizedBox(
                          widthFactor: 1 / _controller.viewportFraction,
                          child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeIn,
                              height: height,
                              decoration: BoxDecoration(color: opacity, boxShadow: [BoxShadow(blurRadius: blur)]),
                              margin: EdgeInsets.symmetric(vertical: height),
                              child: MemorySnapChild(
                                  theFile: memoriesArray[index]['snap'], ctrl: _controller, onClose: widget.onClose)));
                    });
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                return Container();
              }
            }));
  }
}
