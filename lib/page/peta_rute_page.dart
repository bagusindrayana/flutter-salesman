import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:label_marker/label_marker.dart';

class PetaRutePage extends StatefulWidget {
  const PetaRutePage({super.key});

  @override
  State<PetaRutePage> createState() => _PetaRutePageState();
}

class _PetaRutePageState extends State<PetaRutePage> {
  LatLng? currentLatLng;
  Completer<GoogleMapController> _controller = Completer();
  LocationPermission? permission;
  CameraPosition? cameraPosition;
  Set<Marker> markers = {};

  List<PointLatLng> result = [];
  String? coordinates;

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
        getRoute();
      });
    });
  }

  void getRoute() async {
    try {
      var url =
          "https://api.mapbox.com/optimized-trips/v1/mapbox/cycling/${currentLatLng?.longitude},${currentLatLng?.latitude};${coordinates}?access_token=pk.eyJ1IjoiYmFndXNpbmRyYXlhbmEiLCJhIjoiY2p0dHMxN2ZhMWV5bjRlbnNwdGY4MHFuNSJ9.0j5UAU7dprNjZrouWnoJyg";

      await Dio().get(url).then((value) {
        var valJson = value.data;
        PolylinePoints polylinePoints = PolylinePoints();
        setState(() {
          for (var i = 0; i < valJson['waypoints'].length; i++) {
            if (i > 0) {
              var wp = valJson['waypoints'][i];
              markers
                  .addLabelMarker(LabelMarker(
                    label: "${i}",
                    markerId: MarkerId("trip-$i"),
                    position: LatLng(wp['location'][1], wp['location'][0]),
                    backgroundColor: Colors.green,
                  ))
                  .then((value) {});
            }
          }
          result =
              polylinePoints.decodePolyline(valJson['trips'][0]['geometry']);
        });
      });
    } catch (e) {
      if (e is DioError) {
        print(e.response);
      } else {
        print(e);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    coordinates = ModalRoute.of(context)!.settings.arguments as String ?? null;
    return (currentLatLng != null)
        ? GoogleMap(
            polylines: Set<Polyline>.of(result.map((e) {
              return Polyline(
                polylineId: PolylineId(e.toString()),
                points:
                    result.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                width: 5,
                color: Colors.red,
                startCap: Cap.roundCap,
                endCap: Cap.buttCap,
              );
            }).toList()),
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
        : SizedBox();
  }
}
