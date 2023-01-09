import 'dart:async';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:label_marker/label_marker.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/pelanggan_repository.dart';

class LokasiPelangganPage extends StatefulWidget {
  const LokasiPelangganPage({super.key});

  @override
  State<LokasiPelangganPage> createState() => _LokasiPelangganPageState();
}

class _LokasiPelangganPageState extends State<LokasiPelangganPage> {
  LatLng? currentLatLng;
  Completer<GoogleMapController> _controller = Completer();
  LocationPermission? permission;
  CameraPosition? cameraPosition;
  Set<Marker> markers = {};
  Pelanggan? pelanggan;

  late PolylinePoints polylinePoints;

  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];

  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  void getCurrentPosition() async {
    if (permission == null) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Silahkan Aktifkan Hak Akses Lokasi"),
                  content: Text(
                      "Aplikasi membutuhkan hak akses lokasi untuk menentukan lokasi anda"),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          await Geolocator.openAppSettings();
                          await Geolocator.openLocationSettings();
                        },
                        child: Text("OK"))
                  ],
                );
              });
        }
      }
    }
    Geolocator.getCurrentPosition().then((currLocation) {
      setState(() {
        currentLatLng =
            new LatLng(currLocation.latitude, currLocation.longitude);
        markers.add(Marker(
          markerId: MarkerId("current"),
          position: currentLatLng!,
        ));
      });
      Future.delayed(Duration(milliseconds: 500), () {
        markers
            .addLabelMarker(LabelMarker(
          onTap: () {
            _createPolylines(
                currLocation.latitude,
                currLocation.longitude,
                double.parse(pelanggan!.latitude.toString()),
                double.parse(pelanggan!.longitude.toString()));
          },
          label: "${pelanggan!.namaUsaha}",
          markerId: MarkerId("trip-${pelanggan!.sId}"),
          position: LatLng(double.parse(pelanggan!.latitude.toString()),
              double.parse(pelanggan!.longitude.toString())),
          backgroundColor: Colors.green,
        ))
            .then((value) {
          setState(() {});
        });
        _createPolylines(
            currLocation.latitude,
            currLocation.longitude,
            double.parse(pelanggan!.latitude.toString()),
            double.parse(pelanggan!.longitude.toString()));
      });
    });
  }

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyC2Km0O7fgfkJHKFt3uTw39_qOByE0mnk0", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );
    print(result.points.length);
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      print(result.points);

      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      getCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pelanggan == null) {
      pelanggan = ModalRoute.of(context)!.settings.arguments as Pelanggan;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Lokasi Pelanggan"),
      ),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: (currentLatLng != null)
                  ? GoogleMap(
                      polylines: Set<Polyline>.of(polylines.values),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: currentLatLng!,
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: true,
                      markers: markers,
                      onCameraMove: (CameraPosition cameraPositiona) {
                        cameraPosition = cameraPositiona; //when map is dragging
                      },
                    )
                  : SizedBox()),
        ],
      ),
    );
  }
}
