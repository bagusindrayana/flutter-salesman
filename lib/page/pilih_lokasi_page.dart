import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesman/provider/utility_provider.dart';

class PilihaLokasiPage extends StatefulWidget {
  const PilihaLokasiPage({super.key});

  @override
  State<PilihaLokasiPage> createState() => _PilihaLokasiPageState();
}

class _PilihaLokasiPageState extends State<PilihaLokasiPage> {
  LatLng? currentLatLng;
  Completer<GoogleMapController> _controller = Completer();
  LocationPermission? permission;
  CameraPosition? cameraPosition;
  bool loadingAdress = false;
  String _address = "";
  bool _IsSearching = false;
  List<dynamic> _list = [];
  TextEditingController _searchText = TextEditingController();
  FocusNode _focusNode = FocusNode();

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
      });
    });
  }

  Future<String?> getAddress() async {
    setState(() {
      loadingAdress = true;
    });
    try {
      var url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLatLng!.latitude},${currentLatLng!.longitude}&key=AIzaSyC2Km0O7fgfkJHKFt3uTw39_qOByE0mnk0";
      var response = await Dio().get(url);
      if (response.statusCode == 200) {
        setState(() {
          loadingAdress = false;
        });
        return response.data['results'][0]['formatted_address'];
      } else {}
    } catch (e, t) {
      if (e is DioError && e.response != null) {
      } else {
        print(e);
      }
    }
    setState(() {
      loadingAdress = false;
    });
    return null;
  }

  void searchPlaces(String query) async {
    _IsSearching = true;
    try {
      var url =
          "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=AIzaSyC2Km0O7fgfkJHKFt3uTw39_qOByE0mnk0";
      var response = await Dio().get(url);
      if (response.statusCode == 200) {
        setState(() {
          _list = response.data["results"];
        });
      } else {}
    } catch (e, t) {
      if (e is DioError && e.response != null) {
      } else {
        print(e);
      }
    }
  }

  Widget displaySearchResults() {
    if (_IsSearching) {
      return new Align(alignment: Alignment.topCenter, child: searchList());
    } else {
      return new Align(alignment: Alignment.topCenter, child: new Container());
    }
  }

  ListView searchList() {
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (context, int index) {
        return Container(
          decoration: new BoxDecoration(
              color: Colors.grey[100],
              border: new Border(
                  bottom: new BorderSide(color: Colors.grey, width: 0.5))),
          child: ListTile(
            onTap: () {
              setState(() {
                _IsSearching = false;
                _focusNode.unfocus();
              });
              _address = _list.elementAt(index)["formatted_address"];
              selectLocaton(LatLng(
                  _list.elementAt(index)["geometry"]["location"]["lat"],
                  _list.elementAt(index)["geometry"]["location"]["lng"]));
            },
            title: Text(_list.elementAt(index)["formatted_address"],
                style: new TextStyle(fontSize: 18.0)),
          ),
        );
      },
    );
  }

  void selectLocaton(LatLng coordinate) async {
    if (_controller != null && _controller.isCompleted) {
      GoogleMapController controller = await _controller.future;
      setState(() {
        currentLatLng = coordinate;
      });
      controller.animateCamera(CameraUpdate.newLatLng(coordinate));
    }
  }

  void pilihLokasi() async {
    if (currentLatLng == null) {
      return;
    }
    if (_address.isEmpty && _address != "") {
      await getAddress().then((value) {
        if (value != null) {
          _address = value;
        }
      });
    }
    Navigator.pop(context, {
      "address": _address,
      "lat": currentLatLng!.latitude,
      "lng": currentLatLng!.longitude
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    LatLng? args;
    var sets = ModalRoute.of(context)!.settings ?? null;
    if (sets != null) {
      args = sets.arguments as LatLng?;
    }
    return Scaffold(
      //search location
      appBar: AppBar(
        //make textfield with icon on back
        leading: (!_IsSearching)
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    _IsSearching = false;
                    _searchText.clear();
                    _focusNode.unfocus();
                  });
                },
                icon: Icon(Icons.cancel),
              ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextField(
                focusNode: _focusNode,
                onTap: () {
                  setState(() {
                    _IsSearching = true;
                  });
                },
                onChanged: (value) {
                  searchPlaces(value);
                },
                controller: _searchText,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Cari Lokasi"),
              )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  )),
            ],
          ),
        ),
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
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: currentLatLng!,
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        if (args != null) {
                          selectLocaton(args);
                        }
                      },
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: true,
                      markers: {
                        Marker(
                          markerId: MarkerId("current"),
                          position: currentLatLng ?? args!,
                        )
                      },
                      onCameraMove: (CameraPosition cameraPositiona) {
                        cameraPosition = cameraPositiona; //when map is dragging
                      },
                      onLongPress: (argument) async {
                        setState(() {
                          currentLatLng = argument;
                        });
                        await getAddress().then((value) {
                          if (value != null) {
                            setState(() {
                              _address = value;
                            });
                          }
                        });
                      },
                      // onCameraIdle: () async {
                      //   //add marker
                      //   if (cameraPosition != null) {
                      //     setState(() {
                      //       currentLatLng = cameraPosition!.target;
                      //     });
                      //   }
                      // },
                    )
                  : SizedBox()),
          Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                child: Text("Pilih"),
                onPressed: () {
                  pilihLokasi();
                },
              )),
          displaySearchResults(),
          (!_IsSearching && loadingAdress)
              ? Positioned(
                  bottom: 70,
                  left: 24,
                  right: 24,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ))
              : (_address != "")
                  ? Positioned(
                      bottom: 70,
                      left: 24,
                      right: 24,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "${_address}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ))
                  : SizedBox()
        ],
      ),
    );
  }
}
