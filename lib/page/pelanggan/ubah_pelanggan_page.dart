import 'dart:async';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/pelanggan_repository.dart';

class UbahPelangganPage extends StatefulWidget {
  const UbahPelangganPage({super.key});

  @override
  State<UbahPelangganPage> createState() => _UbahPelangganPageState();
}

class _UbahPelangganPageState extends State<UbahPelangganPage> {
  Pelanggan? pelanggan;
  LatLng? currentLatLng;
  Completer<GoogleMapController> _controller = Completer();
  LocationPermission? permission;
  CameraPosition? cameraPosition;
  TextEditingController _namaUsahaController = TextEditingController();
  TextEditingController _namaPemilikController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _noTelpController = TextEditingController();
  TextEditingController _tanggalTagihanController = TextEditingController();
  TextEditingController _totalTagihanController = TextEditingController();
  TextEditingController _keteranganController = TextEditingController();
  Tagihan? tagihan;
  GlobalKey _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  bool inputTagihan = false;

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
    await Geolocator.getCurrentPosition().then((currLocation) {
      setState(() {
        currentLatLng =
            new LatLng(currLocation.latitude, currLocation.longitude);
      });
    });
    // await getAddress().then((value) {
    //   _alamatController.text = value!;
    // });
  }

  Future<String?> getAddress() async {
    UtilityProvider.showLoadingDialog(context);
    try {
      var url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLatLng!.latitude},${currentLatLng!.longitude}&key=AIzaSyC2Km0O7fgfkJHKFt3uTw39_qOByE0mnk0";
      var response = await Dio().get(url);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        return response.data['results'][0]['formatted_address'];
      } else {}
    } catch (e, t) {
      if (e is DioError && e.response != null) {
      } else {
        print(e);
      }
    }
    Navigator.pop(context);
    return null;
  }

  void tambahPelanggan() async {
    UtilityProvider.showLoadingDialog(context);
    if (_namaPemilikController.text.isEmpty ||
        _namaUsahaController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _noTelpController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Peringatan"),
              content: Text("Semua data harus diisi"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"))
              ],
            );
          });
      Navigator.pop(context);
      return;
    }
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pushNamed(context, "/login");
    } else {
      await PelangganRepository()
          .updatePelanggan(
              token,
              new Pelanggan(
                  sId: pelanggan!.sId,
                  namaUsaha: _namaUsahaController.text,
                  namaPemilik: _namaPemilikController.text,
                  alamat: _alamatController.text,
                  noTelp: _noTelpController.text,
                  latitude: currentLatLng!.latitude.toString(),
                  longitude: currentLatLng!.longitude.toString()))
          .then((value) {
        if (value.status == 200) {
          Navigator.pop(context);
          Navigator.pop(context);
          UtilityProvider.showAlertDialog(
              "Berhasil", "Data Pelanggan Berhasil Di Buat", context);
        } else {
          Navigator.pop(context);
          UtilityProvider.showAlertDialog(
              "Gagal", "Data Pelanggan Gagal Di Buat", context);
        }
      });
    }
  }

  //datepicker
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        //format date before fill _tanggalTagihanController
        _tanggalTagihanController.text =
            DateFormat('dd-MM-yyyy').format(selectedDate);
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getCurrentPosition();
    Future.delayed(Duration.zero, () {
      if (pelanggan != null) {
        setState(() {
          currentLatLng = new LatLng(double.parse(pelanggan!.latitude!),
              double.parse(pelanggan!.longitude!));
        });
        _namaPemilikController.text = pelanggan!.namaPemilik!;
        _namaUsahaController.text = pelanggan!.namaUsaha!;
        _alamatController.text = pelanggan!.alamat!;
        _noTelpController.text = pelanggan!.noTelp!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pelanggan == null) {
      pelanggan = ModalRoute.of(context)!.settings.arguments as Pelanggan;
    }
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Ubah Pelanggan"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  (currentLatLng != null)
                      ? Container(
                          height: 300,
                          child: GoogleMap(
                            // myLocationButtonEnabled: true,
                            // myLocationEnabled: true,
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: currentLatLng!,
                              zoom: 15,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: {
                              Marker(
                                markerId: MarkerId("current"),
                                position: currentLatLng!,
                              )
                            },
                            // onCameraMove: (CameraPosition cameraPositiona) {
                            //   cameraPosition =
                            //       cameraPositiona; //when map is dragging
                            // },
                            // onCameraIdle: () async {
                            //   //add marker
                            //   if (cameraPosition != null) {
                            //     setState(() {
                            //       currentLatLng = cameraPosition!.target;
                            //     });
                            //   }
                            // },
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/pilih-lokasi",
                                arguments: currentLatLng)
                            .then((value) async {
                          if (value is Map &&
                              value != null &&
                              value['lat'] != null &&
                              value['lng'] != null) {
                            if (value['address'] != null &&
                                value['address'] != "") {
                              setState(() {
                                _alamatController.text = value['address'];
                              });
                            } else {
                              await getAddress().then((value) {
                                setState(() {
                                  _alamatController.text = value!;
                                });
                              });
                            }

                            setState(() {
                              currentLatLng =
                                  LatLng(value['lat'], value['lng']);
                            });

                            _controller.future.then((value) {
                              value.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                      target: currentLatLng!, zoom: 15)));
                            });
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on),
                          Text("Pilih Lokasi Lain")
                        ],
                      )),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _namaUsahaController,
                    decoration: InputDecoration(
                      labelText: "Nama Usaha",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _namaPemilikController,
                    decoration: InputDecoration(
                      labelText: "Nama Pemilik",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _alamatController,
                    decoration: InputDecoration(
                      labelText: "Alamat",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _noTelpController,
                    decoration: InputDecoration(
                      labelText: "No. Telp",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.black26,
                    height: 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            tambahPelanggan();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save),
                              Text("Simpan Data Pelanggan")
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
