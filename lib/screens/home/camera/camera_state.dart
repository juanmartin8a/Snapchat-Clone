import 'package:flutter/material.dart';
import 'package:snapchatClone/screens/home/camera/add_friends.dart';
import 'package:snapchatClone/screens/home/camera/memories.dart';
import 'package:snapchatClone/screens/home/camera/preview_screen.dart';
import 'package:snapchatClone/screens/home/camera/preview_video_screen.dart';
import 'package:snapchatClone/screens/home/profile/profile.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraState extends StatefulWidget {
  final double statusBar;
  CameraState({Key key, this.statusBar}) : super(key: key);
  @override
  _CameraStateState createState() => _CameraStateState();
}

class _CameraStateState extends State<CameraState> {
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
            builder: (context) => PreviewScreen(
                  imgPath: path,
                )),
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
            builder: (context) => PreviewVideoScreen(
                  imgPath: thePath,
                )),
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

  memoriesBottomSheet(BuildContext context) {
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
          return Memories(statusBar: statusBarHeight);
          //});
        });
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
        automaticallyImplyLeading: true,
        leading: null,
        titleSpacing: 0.0,
        backgroundColor: Colors.transparent,
        title: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(),
              Container(
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
                  ))
            ])));
    return Stack(children: [
      ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: FutureBuilder(
              future: _controllerInitializer,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Container(child: Center(child: Text('loading...', style: TextStyle(color: Colors.grey[50]))));
                }
              })),
      Positioned.fill(
          child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dy > 0) {
            null;
          } else {
            memoriesBottomSheet(context);
          }
          //memoriesBottomSheet(context);
        },
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
                          height: MediaQuery.of(context).size.height * 0.11,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: MediaQuery.of(context).size.height * 0.11,
                                  width: MediaQuery.of(context).size.height * 0.11,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(100 / 2),
                                      border: Border.all(
                                        width: 6,
                                        color: Colors.white,
                                      )))
                            ],
                          )))))),
      Positioned(top: 0.0, left: 0.0, right: 0.0, child: appBar)
    ]);
  }
}
