
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription _locationSubscription;
  Marker  marker;
  Circle  circle;
  GoogleMapController _controller;
  Location _locationTracker = Location();

  static final CameraPosition initalLocation =
  CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 15);

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: getCurrentLocation,
        child: const Icon(Icons.location_searching),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initalLocation,
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
    );
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
    await DefaultAssetBundle.of(context).load('assets/car_icon.png');
    return byteData.buffer.asUint8List();
  }

  updateMarkerAndCircle(LocationData newLocationData, Uint8List imageData) {
    LatLng latLng =
    LatLng(newLocationData.latitude, newLocationData.longitude,);
    setState(() {
      marker = Marker(
        markerId: const MarkerId('home'),
        position: latLng,
        rotation: newLocationData.heading,
        draggable: false,
        zIndex: 2,
        flat: false,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData),
      );
      circle = Circle(
          circleId: const CircleId('car'),
          radius: newLocationData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
            if (_controller != null) {
              _controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      bearing: 192.8334901395799,
                      target:
                      LatLng(newLocalData.latitude, newLocalData.longitude),
                      tilt: 0,
                      zoom: 15.00)));
              updateMarkerAndCircle(newLocalData, imageData);
            }
          });
    } catch (e) {}
  }
}
