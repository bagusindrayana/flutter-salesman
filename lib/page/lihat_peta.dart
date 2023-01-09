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

class LihatPetaPage extends StatefulWidget {
  const LihatPetaPage({super.key});

  @override
  State<LihatPetaPage> createState() => _LihatPetaPageState();
}

class _LihatPetaPageState extends State<LihatPetaPage> {
  LatLng? currentLatLng;
  Completer<GoogleMapController> _controller = Completer();
  LocationPermission? permission;
  CameraPosition? cameraPosition;
  Set<Marker> markers = {};
  Pelanggan? selectPelanggan;

  List<PointLatLng> result = [];
  String coordinates = "";

  List<Pelanggan> listPelanggan = [];

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
        getPelanggan();
      });
    });
  }

  void getPelanggan() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/login');
      return;
    } else {
      await PelangganRepository().getAllPelanggan(token).then((res) {
        if (res.status == 200) {
          for (var pelanggan in res.data!) {
            markers
                .addLabelMarker(LabelMarker(
              onTap: () {
                setState(() {
                  selectPelanggan = pelanggan;
                  ;
                });
              },
              label: "${pelanggan.namaUsaha}",
              markerId: MarkerId("trip-${pelanggan.sId}"),
              position: LatLng(double.parse(pelanggan.latitude.toString()),
                  double.parse(pelanggan.longitude.toString())),
              backgroundColor: Colors.green,
            ))
                .then((value) {
              setState(() {});
            });
          }
          setState(() {
            listPelanggan = res.data!;
          });
        } else if (res.status == 401) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res.message!),
          ));
        }
      });
      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Peta Pelanggan"),
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
                      onTap: (a) {
                        setState(() {
                          selectPelanggan = null;
                        });
                      },
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
          (selectPelanggan != null)
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
                          "${selectPelanggan!.namaUsaha}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          "${selectPelanggan!.alamat}",
                          style: TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/detail-pelanggan',
                                  arguments: selectPelanggan!);
                            },
                            child: Text("Lihat Detail"))
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
