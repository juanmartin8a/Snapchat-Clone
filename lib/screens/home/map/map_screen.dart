import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/map/map_friends.dart';
import '../../../services/database.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart' as geoC;
import 'package:geocoding/geocoding.dart' as geocoding;
////import 'package:geocoder/geocoder.dart';

class MapScreen extends StatefulWidget {
  final double statusBar;
  MapScreen({this.statusBar});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController _controller;
  Location location = Location();
  final Geolocator _geoLocator = Geolocator();
  Geoflutterfire geo = Geoflutterfire();
  List<Marker> myMarker = [];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _position;
  var currentLat;
  var currentLon;
  static var myLocationLat;
  static var myLocationLon;
  String mapCenterPoint;

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _controller = controller;
    });
  }

  _animateToUser() async {
    var pos = await location.getLocation();
    final coordinatesPos = geoC.Coordinates(currentLat, currentLon);
    var newPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    var first = newPlace.first;

    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: 12.0,
    )));
    setState(() {
      if (first.locality != null) {
        mapCenterPoint = first.locality;
        print('position local is ${first.locality}');
      } else if (first.locality == null && first.adminArea != null) {
        print('position admin is ${first.adminArea}');
        mapCenterPoint = first.adminArea;
      } else {
        null;
      }
    });
  }

  void _updateCameraPosition(CameraPosition position) async {
    final coordinatesPos = geoC.Coordinates(_position.target.latitude, _position.target.longitude);
    var newPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    var first = newPlace.first;
    setState(() {
      _position = position;
      print('position mid position is ${_position.target.toString()}');
      if (first.locality != null) {
        mapCenterPoint = first.locality;
        print('position local is ${first.locality}');
      } else if (first.locality == null && first.adminArea != null) {
        mapCenterPoint = first.adminArea;
        print('position admin is ${first.adminArea}');
      } else {
        print('poboth admin and locality are not working');
      }
    });
  }

  /*void getMapPos() async {
    final coordinatesPos = geoC.Coordinates(_position.target.latitude, _position.target.longitude);
    var newPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    var first = newPlace.first;
    setState(() {
      if (first.locality != null) {
        mapCenterPoint = first.locality;
        print('position local is ${first.locality}');
      } else if (first.locality == null && first.adminArea != null) {
        print('position admin is ${first.adminArea}');
        mapCenterPoint = first.adminArea;
      } else {
        null;
      }
    });
  }*/

  getCurrentPos() async {
    var currentLocation = await location.getLocation();
    setState(() {
      currentLat = currentLocation.latitude;
      currentLon = currentLocation.longitude;
    });
  }

  getFriendsLocation() async {
    final user = Provider.of<CustomUser>(context, listen: false);
    FirebaseFirestore.instance.collection('usernames').doc(user.uid).collection('friends').get().then((doc) {
      if (doc.docs.isNotEmpty) {
        for (int i = 0; i < doc.docs.length; i++) {
          FirebaseFirestore.instance
              .collection('usernames')
              .doc(doc.docs[i].data()['friend'])
              .collection('location')
              .get()
              .then((doc2) {
            if (doc2.docs.isNotEmpty) {
              for (int j = 0; j < doc.docs.length; j++) {
                FirebaseFirestore.instance.collection('usernames').doc(doc.docs[i].data()['friend']).get().then((doc3) {
                  if (doc3.exists) {
                    _addMarker(doc2.docs[i], doc2.docs[i].id, doc3.data()['name']);
                  }
                });
              }
            }
          });
          //_addMarker(docs.documents[i].data);
        }
      }
    });
  }

  getMyLocation() async {
    final user = Provider.of<CustomUser>(context, listen: false);
    FirebaseFirestore.instance.collection('usernames').doc(user.uid).collection('location').get().then((doc2) {
      if (doc2.docs.isNotEmpty) {
        for (int j = 0; j < doc2.docs.length; j++) {
          FirebaseFirestore.instance.collection('usernames').doc(user.uid).get().then((doc3) {
            if (doc3.exists) {
              _addMarker(doc2.docs[j], doc2.docs[j].id, doc3.data()['name']);
              setState(() {
                mapCenterPoint = doc2.docs[j].data()['positionName'];
                myLocationLat = doc2.docs[j].data()['position']['geopoint'].latitude;
                myLocationLon = doc2.docs[j].data()['position']['geopoint'].longitude;
              });
            }
          });
        }
      }
    });
  }

  _addMarker(theData, theUid, userName) {
    var markerIdPos = theUid;
    print('the markerIdPos is $markerIdPos');
    final MarkerId markerId = MarkerId(markerIdPos);
    final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(theData.data()['position']['geopoint'].latitude, theData.data()['position']['geopoint'].longitude),
        infoWindow: InfoWindow(title: '$userName'));
    setState(() {
      markers[markerId] = marker;
    });
  }

  friendsModalSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 4.0,
        isScrollControlled: true,
        barrierColor: Colors.black.withAlpha(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return MapFriends(
              mapCenterPoint: mapCenterPoint, currentLat: currentLat, currentLon: currentLon, controller: _controller);
        });
  }

  @override
  void initState() {
    if (mounted) {
      getCurrentPos();
      saveUserLocation();
      final user = Provider.of<CustomUser>(context, listen: false);
      FirebaseFirestore.instance.collection('usernames').doc(user.uid).collection('location').get().then((doc2) {
        if (doc2.docs.isNotEmpty) {
          for (int j = 0; j < doc2.docs.length; j++) {
            FirebaseFirestore.instance.collection('usernames').doc(user.uid).get().then((doc3) {
              if (doc3.exists) {
                _addMarker(doc2.docs[j], doc2.docs[j].id, doc3.data()['name']);
                setState(() {
                  mapCenterPoint = doc2.docs[j].data()['positionName'];
                  myLocationLat = doc2.docs[j].data()['position']['geopoint'].latitude;
                  myLocationLon = doc2.docs[j].data()['position']['geopoint'].longitude;
                  _position = CameraPosition(
                    target: LatLng(doc2.docs[j].data()['position']['geopoint'].latitude,
                        doc2.docs[j].data()['position']['geopoint'].longitude),
                    zoom: 12,
                  );
                });
              }
            });
          }
        }
      });
      getMyLocation();
      getFriendsLocation();
      print('the controller is $_controller');
    }
    super.initState();
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
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(30),
          ),
          width: MediaQuery.of(context).size.width * 0.60,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text('Palo Alto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87))),
      centerTitle: true,
    );
    return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Stack(children: [
          currentLat == null || currentLon == null
              ? Container()
              : GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(
                      () => new EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                  initialCameraPosition: CameraPosition(target: LatLng(currentLat, currentLon), zoom: 12),
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true, // Add little blue dot for device location, requires permission from user
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  markers: Set<Marker>.of(markers.values),
                  onCameraMove: _updateCameraPosition,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  //onTap: _addMarker
                ),
          Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.10,
                color: Colors.transparent,
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                  onTap: () {
                    _animateToUser();
                  },
                  child: Container(
                      margin: EdgeInsets.only(bottom: 30),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(100 / 2),
                      ),
                      child: Icon(Icons.near_me_sharp, color: Colors.white)))),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                  margin: EdgeInsets.only(top: widget.statusBar),
                  height: appBar.preferredSize.height,
                  width: MediaQuery.of(context).size.width * 0.5,
                  //margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                          child: Text(mapCenterPoint != null ? mapCenterPoint : '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              )))))),
          Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                  onTap: () {
                    friendsModalSheet(context);
                  },
                  child: Container(
                      margin: EdgeInsets.all(20),
                      //height: appBar.preferredSize.height,
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.width * 0.14,
                      //color: Colors.red,
                      //margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Stack(children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(100 / 2),
                                    border: Border.all(width: 5.5, color: Colors.grey[50])),
                                child: Icon(Icons.group_rounded, size: 40, color: Colors.yellow[700]))),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                child: Text('Friends',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[900],
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.02,
                                    ))))
                      ]))))
        ]));
  }

  void saveUserLocation() async {
    final user = context.read<CustomUser>();
    print('save user is being called 1 ');
    var loc = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: loc.latitude, longitude: loc.longitude);
    final coordinatesPos = geoC.Coordinates(loc.latitude, loc.longitude);
    var newNPlace = await geoC.Geocoder.local //google('AIzaSyA4w6O6Zjlx22C0GCEKAg6TmUwQPaL0jtk')
        .findAddressesFromCoordinates(coordinatesPos);
    var one = newNPlace.first;
    setState(() {
      currentLat = loc.latitude;
      currentLon = loc.longitude;
    });
    Map<String, dynamic> locationMap = {
      'position': point.data,
      'name': 'Yay I can be queried!',
      'uid': user.uid,
      'positionName': one.locality != null ? one.locality : one.adminArea,
    };
    print('save user is being called');
    print('the user uid is now ${user.uid}');
    print('save user is being called  o 2 ${one.locality != null ? one.locality : one.adminArea}');
    //print('the controller is ${_controller}');
    DatabaseService(uid: user.uid, docId: user.uid).saveUserLocation(locationMap);
  }
}
