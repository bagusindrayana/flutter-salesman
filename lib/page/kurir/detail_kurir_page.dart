import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/model/user.dart';
import 'package:salesman/model/pembayaran.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/kurir_repository.dart';
import 'package:salesman/repository/pelanggan_repository.dart';
import 'package:salesman/repository/tagihan_repository.dart';

class DetailKurirPage extends StatefulWidget {
  const DetailKurirPage({super.key});

  @override
  State<DetailKurirPage> createState() => _DetailKurirPageState();
}

class _DetailKurirPageState extends State<DetailKurirPage> {
  User? user;
  List<Pelanggan> pelanggans = [];
  List<Pembayaran> pembayarans = [];
  bool loadPemabayaran = false;
  DateTime selectedDate = DateTime.now();

  TextEditingController _tanggalTagihanController = TextEditingController();
  TextEditingController _totalTagihanController = TextEditingController();
  TextEditingController _keteranganController = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
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

  void getDetailUser() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      return;
    } else if (user != null) {
      await KurirRepository().detailKurir(token, user!.sId!).then((value) {
        if (value.status == 200) {
          setState(() {
            user = value.data;
          });
          getTagihanUser();
        } else {
          Navigator.pop(context);
        }
      });
    }
  }

  void getTagihanUser() async {
    // UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      return;
    } else if (user != null) {
      await PelangganRepository()
          .getPelangganByKurir(token, user!.sId!)
          .then((value) {
        if (value.status == 200) {
          setState(() {
            pelanggans = value.data!;
          });
        }
      });
    }

    Navigator.pop(context);
  }

  void hapusKurir() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.of(context).pop();
      return;
    } else {
      await KurirRepository().hapusKurir(token, user!.sId!).then((value) {
        if (value.status == 200) {
          Future.delayed(const Duration(microseconds: 500), () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            UtilityProvider.showSnackBar("${value.message}", context);
          });
        } else {
          Navigator.of(context).pop();
          UtilityProvider.showAlertDialog("Gagal", "${value.message}", context);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(microseconds: 500), () {
      _tanggalTagihanController.text =
          DateFormat('dd-MM-yyyy').format(selectedDate);
      getDetailUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    //get user from argument
    if (user == null) {
      user = ModalRoute.of(context)!.settings.arguments as User;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Kurir"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/ubah-kurir", arguments: user)
                  .then((value) {
                getDetailUser();
              });
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              //alert
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Hapus User"),
                      content:
                          Text("Apakah anda yakin ingin menghapus user ini?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () {
                            hapusKurir();
                          },
                          child: Text("Hapus"),
                        ),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.delete),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: (() async {
          getDetailUser();
        }),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: (user != null)
              ? ListView(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Nama Kurir"),
                            subtitle: Text("${user?.nama}"),
                          ),
                          ListTile(
                            title: Text("Username"),
                            subtitle: Text("${user?.username}"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      child: Column(children: [
                        // Padding(
                        //     padding: EdgeInsets.all(10),
                        //     child: Text(
                        //       "Tagihan",
                        //       style: TextStyle(
                        //           fontSize: 18, fontWeight: FontWeight.bold),
                        //     )),
                        // Padding(
                        //     padding: EdgeInsets.all(10),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Text(
                        //           "${UtilityProvider.formatCurrency(user!.totalTagihan.toString())}",
                        //           style: TextStyle(fontSize: 20),
                        //         ),
                        //         Text(" / "),
                        //         Text(
                        //             "${UtilityProvider.formatCurrency(user!.totalBayar.toString())}",
                        //             style: TextStyle(
                        //                 fontSize: 20,
                        //                 color: (user!.totalBayar == null ||
                        //                         (user!.totalBayar <
                        //                             user!.totalTagihan))
                        //                     ? Colors.red
                        //                     : Colors.green)),
                        //       ],
                        //     )),

                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Data Pelanggan",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 16,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pelanggans.length,
                          itemBuilder: (context, index) {
                            //format utc to date Y-m-d

                            return Card(
                              child: ListTile(
                                title: Text(
                                  pelanggans[index].namaUsaha!,
                                  style: TextStyle(fontSize: 24),
                                ),
                                subtitle: Text(
                                  pelanggans[index].alamat!,
                                  style: TextStyle(fontSize: 16),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, '/detail-pelanggan',
                                          arguments: pelanggans[index])
                                      .then((value) => setState(() {}));
                                },
                              ),
                            );
                          },
                        )
                      ]),
                    ),
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
