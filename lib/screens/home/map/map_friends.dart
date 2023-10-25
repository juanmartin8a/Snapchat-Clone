import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/stories/stories_child.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:geocoder/geocoder.dart' as geoC;
import 'package:geocoding/geocoding.dart' as geocoding;
//import 'package:geocoder/geocoder.dart';

class MapFriends extends StatefulWidget {
  final dynamic currentLat;
  final dynamic currentLon;
  String mapCenterPoint;
  final GoogleMapController controller;
  MapFriends({this.currentLat, this.currentLon, this.mapCenterPoint, this.controller});
  @override
  _MapFriendsState createState() => _MapFriendsState();
}

class _MapFriendsState extends State<MapFriends> {
  Location location = Location();
  _animateToFriend(double latitude, double longitude) async {
    Navigator.of(context).pop();
    //var pos = await location.getLocation();
    final coordinatesPos = geoC.Coordinates(widget.currentLat, widget.currentLon);
    var newPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    var first = newPlace.first;

    widget.controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 15.0,
    )));
    setState(() {
      if (first.locality != null) {
        widget.mapCenterPoint = first.locality;
        print('position local is ${first.locality}');
      } else if (first.locality == null && first.adminArea != null) {
        print('position admin is ${first.adminArea}');
        widget.mapCenterPoint = first.adminArea;
      } else {
        null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context, listen: false);
    return ClipRRect(
        borderRadius: BorderRadius.only(
          /*bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),*/
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
            margin: EdgeInsets.only(bottom: 45),
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                /*topLeft: Radius.circular(20),
                topRight: Radius.circular(20),*/
              ),
            ),
            child: FutureBuilder(
                future: DatabaseService(uid: user.uid).getUserFriends(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Map<String, dynamic>> friendsArray = [];
                    if (snapshot.data.docs.length > 3) {
                      for (int i = 0; i < 3; i++) {
                        Map<String, dynamic> friendsMap = {'friend': snapshot.data.docs[i].data()['friend']};
                        friendsArray.add(friendsMap);
                      }
                    } else {
                      for (int i = 0; i < snapshot.data.docs.length; i++) {
                        Map<String, dynamic> friendsMap = {'friend': snapshot.data.docs[i].data()['friend']};
                        friendsArray.add(friendsMap);
                      }
                    }
                    return Container(
                        margin: EdgeInsets.only(top: 18),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text('Find Your Friends',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.grey[900],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ))),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(vertical: 18),
                              child: GridView.count(
                                  crossAxisCount: 5,
                                  shrinkWrap: true,
                                  childAspectRatio: (9 / 13),
                                  children: List.generate(friendsArray.length + 1, (int index) {
                                    return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 0.5),
                                        child: index < friendsArray.length
                                            ? StreamBuilder<DocumentSnapshot>(
                                                stream: DatabaseService(uid: friendsArray[index]['friend'])
                                                    .getUserProfile(),
                                                builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {
                                                  if (snap.hasData) {
                                                    Map<String, dynamic> userDocs = snap.data.data();
                                                    return FutureBuilder(
                                                        future: DatabaseService(
                                                                uid: friendsArray[index]['friend'],
                                                                docId: friendsArray[index]['friend'])
                                                            .getFriendsLocation(),
                                                        builder: (context, posSnap) {
                                                          if (posSnap.hasData) {
                                                            return GestureDetector(
                                                                onTap: () {
                                                                  print(
                                                                      ' the position is ${posSnap.data.data()['position']['geopoint'].latitude}');
                                                                  _animateToFriend(
                                                                      posSnap.data
                                                                          .data()['position']['geopoint']
                                                                          .latitude,
                                                                      posSnap.data
                                                                          .data()['position']['geopoint']
                                                                          .longitude);
                                                                },
                                                                child: Container(
                                                                    margin: EdgeInsets.only(top: 5),
                                                                    child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                              //width: MediaQuery.of(context).size.width * 0.12,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius:
                                                                                    BorderRadius.circular(100 / 2),
                                                                                color: Colors.white,
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.grey.withOpacity(0.3),
                                                                                    spreadRadius: 3,
                                                                                    blurRadius: 5,
                                                                                    offset: Offset(0,
                                                                                        3), // changes position of shadow
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              //padding: EdgeInsets.all(13),
                                                                              child: Container(
                                                                                  width: MediaQuery.of(context)
                                                                                          .size
                                                                                          .width *
                                                                                      0.12,
                                                                                  height: MediaQuery.of(context)
                                                                                          .size
                                                                                          .width *
                                                                                      0.12,
                                                                                  child: Icon(
                                                                                    Icons.person,
                                                                                    color: Colors.grey[900],
                                                                                  ))),
                                                                          Container(
                                                                              margin: EdgeInsets.symmetric(vertical: 8),
                                                                              width: MediaQuery.of(context).size.width *
                                                                                  0.12,
                                                                              child: Text(userDocs['name'],
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w700,
                                                                                    color: Colors.grey[900],
                                                                                  )))
                                                                        ])));
                                                          } else {
                                                            return Container();
                                                          }
                                                        });
                                                  } else {
                                                    return Container();
                                                  }
                                                })
                                            : Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                          //width: MediaQuery.of(context).size.width * 0.12,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(100 / 2),
                                                            color: Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.grey.withOpacity(0.3),
                                                                spreadRadius: 3,
                                                                blurRadius: 5,
                                                                offset: Offset(0, 3), // changes position of shadow
                                                              ),
                                                            ],
                                                          ),
                                                          //padding: EdgeInsets.all(13),
                                                          child: Container(
                                                              width: MediaQuery.of(context).size.width * 0.12,
                                                              height: MediaQuery.of(context).size.width * 0.12,
                                                              child: Icon(
                                                                Icons.search_rounded,
                                                                color: Colors.grey[900],
                                                              ))),
                                                      Container(
                                                          margin: EdgeInsets.symmetric(vertical: 8),
                                                          width: MediaQuery.of(context).size.width * 0.12,
                                                          child: Text('Search',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w700,
                                                                color: Colors.grey[900],
                                                              )))
                                                    ])));
                                  })))
                        ]));
                    /*ListView.builder(
                        itemCount: friendsArray.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container();
                        });*/
                  } else {
                    return Container();
                  }
                })));
  }
}
