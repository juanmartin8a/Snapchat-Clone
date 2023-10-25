import 'package:flutter/material.dart';
import 'package:snapchatClone/screens/home/chat/chat_image_prev.dart';
import 'package:snapchatClone/screens/home/chat/chat_video_prev.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class SnapsInChat extends StatefulWidget {
  final double statusBar;
  final String userName;
  final String chatRoomId;
  SnapsInChat({this.statusBar, this.userName, this.chatRoomId});
  @override
  _SnapsInChatState createState() => _SnapsInChatState();
}

class _SnapsInChatState extends State<SnapsInChat> {
  CameraController _controller;
  Future<void> _controllerInitializer;
  List cameras;
  int selectedCameraIndex;
  String imgPath;
  String thePath;

  getCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_controller.value.hasError) {
        print('Camera error ${_controller.value.errorDescription}');
      }
    });
    try {
      _controllerInitializer = _controller.initialize();
    } on CameraException catch (e) {
      print('the camera error is ${e.toString()}');
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onCapturePressed(context) async {
    try {
      final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      await _controller.takePicture(path);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatImagePrev(imgPath: path, userName: widget.userName, chatRoomId: widget.chatRoomId)),
      );
    } catch (e) {
      print('the error is ${e.toString()}');
    }
  }

  _onVideoCapturedPressed(context) async {
    try {
      final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.mp4');
      await _controller.startVideoRecording(path).then((_) {
        setState(() {
          thePath = path;
        });
      });
    } catch (e) {
      print('the error is on start vid ${e.toString()}');
    }
  }

  void _onVideoStopRecording(context) async {
    print('the path is $thePath');
    try {
      await _controller.stopVideoRecording();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatVideoPrev(imgPath: thePath, userName: widget.userName, chatRoomId: widget.chatRoomId)),
      );
    } catch (e) {
      print('the error is in stop vid ${e.toString()}');
    }
  }

  void onSwitchCamera() {
    selectedCameraIndex = selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    getCamera(selectedCamera);
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        getCamera(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });
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
      title: Container(
          child: Stack(children: [
        Container(
            width: MediaQuery.of(context).size.width,
            //color: Colors.red,
            child: Center(
                child: Column(children: [
              Container(
                child:
                    Text('Send To', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Container(
                child: Text('${widget.userName}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
              )
            ]))),
        Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.zero,
                //padding: EdgeInsets.only(top: widget.statusBar),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 37,
                ),
                //onPressed: () => Navigator.of(context).pop()
              ),
            )),
        Align(
            alignment: Alignment.centerRight,
            child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(100 / 2)),
                child: Column(
                  children: [
                    GestureDetector(
                        onTap: () {
                          print('hey switch camera');
                          onSwitchCamera();
                        },
                        child: Container(
                            child: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 24,
                        )))
                  ],
                )))
      ])),
      centerTitle: true,
      //titleSpacing: 0.0,
      backgroundColor: Colors.transparent,
    );
    return Stack(
      children: [
        ClipRRect(
            child: FutureBuilder(
                future: _controllerInitializer,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return Container(
                        color: Colors.black,
                        child: Center(child: Text('loading...', style: TextStyle(color: Colors.grey[50]))));
                  }
                })),
        Positioned.fill(
            child: GestureDetector(
          onDoubleTap: () => setState(() {
            print('double tap registered');
            onSwitchCamera();
          }),
        )),
        Positioned.fill(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 25),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                        onTap: () {
                          _onCapturePressed(context);
                        },
                        onLongPressStart: (details) {
                          _onVideoCapturedPressed(context);
                        },
                        onLongPressUp: () {
                          _onVideoStopRecording(context);
                        },
                        child: Container(
                            //width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height * 0.10,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    height: MediaQuery.of(context).size.height * 0.10,
                                    width: MediaQuery.of(context).size.height * 0.10,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(100 / 2),
                                        border: Border.all(
                                          width: 7,
                                          color: Colors.white,
                                        )))
                              ],
                            )))))),
        Positioned(
            top: 0, left: 0, right: 0, child: Container(margin: EdgeInsets.only(top: widget.statusBar), child: appBar))
      ],
    );
  }
}
