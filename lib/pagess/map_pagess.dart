import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_route/pagess/consts.dart';
import 'package:location/location.dart';

class MapPages extends StatefulWidget {
  const MapPages({super.key});

  @override
  State<MapPages> createState() => _MapPages();
}

class _MapPages extends State<MapPages> {
  Location _locationcontroller = new Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const LatLng _pGoogleplex = LatLng(17.502270, 78.418739);
  static const LatLng _pApplepark = LatLng(16.470600, 79.438698);
  static const LatLng _mahesh = LatLng(17.4875, 78.3953);
  static const LatLng _manu = LatLng(17.5169, 78.3428);
  LatLng? _currentP = null;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
              child: Text('Loding...'),
            )
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: const CameraPosition(
                target: _pGoogleplex,
                zoom: 12,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('_currentLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentP!,
                ),
                const Marker(
                  markerId: MarkerId('_sourceLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pGoogleplex,
                ),
                const Marker(
                  markerId: MarkerId('_destinationLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pApplepark,
                ),
                const Marker(
                  markerId: MarkerId('kukatpally'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _mahesh,
                ),
                const Marker(
                  markerId: MarkerId('miyapur'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _manu,
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newcameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newcameraPosition));
  }

  Future<void> getLocationUpdate() async {
    bool _servicedEnebled;
    PermissionStatus _permissionGranted;
    _servicedEnebled = await _locationcontroller.serviceEnabled();
    if (_servicedEnebled) {
      _servicedEnebled = await _locationcontroller.requestService();
    } else {
      return;
    }
    _permissionGranted = await _locationcontroller.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationcontroller.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationcontroller.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.altitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> PolylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        GOOGLE_MAP_API_KEY,
        PointLatLng(_pGoogleplex.latitude, _pGoogleplex.longitude),
        PointLatLng(
          _pApplepark.latitude,
          _pApplepark.longitude,
        ),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        PolylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return PolylineCoordinates;
  }

  // void generatePolyLineFromPoints(List<LatLng> PolylineCoordinates) async {
  //   PolylineId id = PolylineId('poly');
  //   Polyline polyline = Polyline(
  //       polylineId: id,
  //       color: Colors.blue,
  //       points: PolylineCoordinates,
  //       width: 8);
  //   setState(() {
  //     polylines[id] = polyline;
  //   });
  // }
}
