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
  String namaToko = "";
  String address = "";

  List<PointLatLng> result = [];
  String coordinates = "";

  List<dynamic> listTempat = [];

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
    for (var pelanggan in listTempat) {
      coordinates += "${pelanggan['longitude']},${pelanggan['latitude']}";
      if (pelanggan != listTempat.last) {
        coordinates += ";";
      }
    }
    try {
      var url =
          "https://api.mapbox.com/optimized-trips/v1/mapbox/driving/${currentLatLng?.longitude},${currentLatLng?.latitude};${coordinates}?access_token=pk.eyJ1IjoiYmFndXNpbmRyYXlhbmEiLCJhIjoiY2p0dHMxN2ZhMWV5bjRlbnNwdGY4MHFuNSJ9.0j5UAU7dprNjZrouWnoJyg";
      await Dio().get(url).then((value) {
        var valJson = value.data;
        PolylinePoints polylinePoints = PolylinePoints();
        setState(() {
          for (var i = 0; i < valJson['waypoints'].length; i++) {
            if (i > 0) {
              var wp = valJson['waypoints'][i];
              markers
                  .addLabelMarker(LabelMarker(
                    onTap: () {
                      setState(() {
                        namaToko =
                            "${listTempat[i - 1]['nama_usaha']} / ${listTempat[i - 1]['no_telp']}";
                        address = listTempat[i - 1]['alamat'];
                      });
                    },
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
    Future.delayed(Duration(milliseconds: 500), () {
      getCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    listTempat = ModalRoute.of(context)!.settings.arguments as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Peta Rute"),
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
                      polylines: Set<Polyline>.of(result.map((e) {
                        return Polyline(
                          polylineId: PolylineId(e.toString()),
                          points: result
                              .map((e) => LatLng(e.latitude, e.longitude))
                              .toList(),
                          width: 4,
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
                  : SizedBox()),
          (address != "")
              ? Positioned(
                  bottom: 70,
                  left: 24,
                  right: 24,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          "${namaToko}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${address}",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ))
              : Positioned(
                  child: SizedBox(),
                  bottom: 0,
                )
        ],
      ),
    );
  }
}
