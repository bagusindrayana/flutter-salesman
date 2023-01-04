import 'dart:async';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesman/model/user.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/kurir_repository.dart';

class UbahKurirPage extends StatefulWidget {
  const UbahKurirPage({super.key});

  @override
  State<UbahKurirPage> createState() => _UbahKurirPageState();
}

class _UbahKurirPageState extends State<UbahKurirPage> {
  User? user;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void tambahUser() async {
    UtilityProvider.showLoadingDialog(context);
    if (_namaController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _namaController.text.trim() == "" ||
        _usernameController.text.trim() == "") {
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
      await KurirRepository()
          .updateKurir(
              token,
              new User(
                  sId: user!.sId,
                  nama: _namaController.text,
                  username: _usernameController.text,
                  password: _passwordController.text))
          .then((value) {
        if (value.status == 200) {
          Navigator.pop(context);
          Navigator.pop(context);
          UtilityProvider.showAlertDialog(
              "Berhasil", "Data User Berhasil Di Ubah", context);
        } else {
          Navigator.pop(context);
          UtilityProvider.showAlertDialog(
              "Gagal", "Data User Gagal Di Ubah", context);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      user = ModalRoute.of(context)!.settings.arguments as User;

      _namaController.text = user!.nama!;
      _usernameController.text = user!.username!;
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
        title: Text("Ubah User"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      labelText: "Nama Kurir",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim() == "") {
                        return 'Silahkan isi nama kurir';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim() == "") {
                        return 'Silahkan isi username';
                      } else if (RegExp(r"\s").hasMatch(value)) {
                        return 'Username tidak boleh ada spasi';
                      } else if (value.length < 3) {
                        return 'Username tidak boleh kurang dari 3 huruf';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: "Password Baru",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              tambahUser();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save),
                              Text("Simpan Data Kurir")
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
