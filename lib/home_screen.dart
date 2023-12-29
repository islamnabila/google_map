import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final GoogleMapController _mapController;
  late Location _location = Location();
  LatLng? _currentLocation;
  StreamSubscription? _streamSubLocation;
  late Marker _marker;
  final List<LatLng> _latLngList = [];
  final Set<Polyline> _polyLines = {};
  final Set<Marker> _markers = {};
  bool isFollowing = true;

  @override
  void initState() {
    super.initState();
    listenToLocation();
  }

  void updateMarker() {
    _marker = Marker(
      markerId: const MarkerId('current_location'),
      position: _currentLocation!,
      infoWindow: InfoWindow(
        title: 'My current location',
        snippet:
            'Lat: ${_currentLocation?.latitude}, Lng: ${_currentLocation?.longitude}',
      ),
      onTap: () {
        _mapController.showMarkerInfoWindow(const MarkerId('current_location'));
      },
    );
    _markers.clear();
    _markers.add(_marker);
  }

  void updatePolyline() {
    _latLngList.add(_currentLocation!);
    _polyLines.add(Polyline(
      polylineId: const PolylineId('Basic-polyline'),
      points: _latLngList,
      color: Colors.blue,
      width: 5,
    ));
  }

  void listenToLocation() {
    _location.requestPermission();
    _location.hasPermission().then((value) {
      if (value == PermissionStatus.granted) {
        _location.changeSettings(interval: 10000);
        _streamSubLocation = _location.onLocationChanged.listen((LocationData locationData) {
          if(mounted) {
            setState(() {
              try {
                _currentLocation =
                    LatLng(locationData.latitude!, locationData.longitude!);
                updateMarker();
                updatePolyline();
                if (isFollowing) {
                  _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
                }
              } catch (e) {
                print(e);
              }
            });
          }
        });
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Location Tracker'),
      ),
      body: _currentLocation == null
          ? Container()
          : GoogleMap(
              initialCameraPosition:
                  CameraPosition(zoom: 19, target: _currentLocation!),
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _markers,
              polylines: _polyLines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }

  @override
  void dispose() {
    _streamSubLocation?.cancel();
    super.dispose();
  }
}
