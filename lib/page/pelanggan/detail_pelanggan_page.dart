import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/model/pembayaran.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/pelanggan_repository.dart';
import 'package:salesman/repository/tagihan_repository.dart';

class DetailPelangganPage extends StatefulWidget {
  const DetailPelangganPage({super.key});

  @override
  State<DetailPelangganPage> createState() => _DetailPelangganPageState();
}

class _DetailPelangganPageState extends State<DetailPelangganPage> {
  Pelanggan? pelanggan;
  List<Tagihan> tagihans = [];
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

  void getDetailPelanggan() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      return;
    } else if (pelanggan != null) {
      await PelangganRepository()
          .detailPelanggan(token, pelanggan!.sId!)
          .then((value) {
        if (value.status == 200) {
          setState(() {
            pelanggan = value.data;
          });
          getTagihanPelanggan();
        }
      });
    }
  }

  void getTagihanPelanggan() async {
    // UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      return;
    } else if (pelanggan != null) {
      await TagihanRepository()
          .getTagihanByPelanggan(token, pelanggan!.sId!)
          .then((value) {
        if (value.status == 200) {
          setState(() {
            tagihans = value.data!;
          });
        }
      });
    }
    getRiwayatPembayaran();
    Navigator.pop(context);
  }

  void getRiwayatPembayaran() async {
    setState(() {
      loadPemabayaran = true;
    });
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      return;
    } else if (pelanggan != null) {
      await PelangganRepository()
          .riwayatPembayaran(token, pelanggan!.sId!)
          .then((value) {
        if (value.status == 200) {
          setState(() {
            for (var i = 0; i < value.data!.length; i++) {
              var d = value.data![i];
              print(d);
              pembayarans.add(Pembayaran.fromJson(d));
            }
          });
        }
      });
    }
    setState(() {
      loadPemabayaran = false;
    });
  }

  void tambahTagihan() async {
    UtilityProvider.showLoadingDialog(context);
    var dataTagihan = new Tagihan(
        tanggalTagihan: _tanggalTagihanController.text,
        totalTagihan: int.parse(_totalTagihanController.text),
        keterangan: _keteranganController.text,
        pelangganId: pelanggan!.sId!);

    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      return;
    } else if (pelanggan != null) {
      await TagihanRepository().createTagihan(token, dataTagihan).then((value) {
        if (value.status == 200) {
          Navigator.pop(context);
          UtilityProvider.showSnackBar("${value.message}", context);
          getTagihanPelanggan();
        } else {
          Navigator.pop(context);
          UtilityProvider.showAlertDialog("Gagal", "${value.message}", context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  //show dialog form add tagihan
  void showAddTagihanDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Tambah Tagihan"),
            content: Form(
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _selectDate(context);
                    },
                    child: TextFormField(
                      onTap: () async {
                        await _selectDate(context);
                      },
                      controller: _tanggalTagihanController,
                      readOnly: true,
                      //enabled: false,
                      decoration: InputDecoration(
                        labelText: "Tanggal Tagihan",
                      ),
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _totalTagihanController,
                    decoration: InputDecoration(
                      labelText: "Jumlah Tagihan",
                    ),
                  ),
                  TextFormField(
                    controller: _keteranganController,
                    decoration: InputDecoration(
                      labelText: "Keterangan",
                    ),
                  ),
                ],
              )),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  tambahTagihan();
                },
                child: Text("Simpan"),
              ),
            ],
          );
        });
  }

  void hapusPelanggan() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.of(context).pop();
      return;
    } else {
      await PelangganRepository()
          .hapusPelanggan(token, pelanggan!.sId!)
          .then((value) {
        if (value.status == 200) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          UtilityProvider.showSnackBar("${value.message}", context);
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
      getDetailPelanggan();
    });
  }

  @override
  Widget build(BuildContext context) {
    //get pelanggan from argument
    if (pelanggan == null) {
      pelanggan = ModalRoute.of(context)!.settings.arguments as Pelanggan;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Pelanggan"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/ubah-pelanggan",
                      arguments: pelanggan)
                  .then((value) {
                getDetailPelanggan();
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
                      title: Text("Hapus Pelanggan"),
                      content: Text(
                          "Apakah anda yakin ingin menghapus pelanggan ini?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () {
                            hapusPelanggan();
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
          getDetailPelanggan();
        }),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: (pelanggan != null)
              ? ListView(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Nama Usaha"),
                            subtitle: Text(pelanggan!.namaUsaha!),
                          ),
                          ListTile(
                            title: Text("Alamat"),
                            subtitle: Text(pelanggan!.alamat!),
                          ),
                          ListTile(
                            title: Text("Nama Pemilik"),
                            subtitle: Text(pelanggan!.namaPemilik!),
                          ),
                          ListTile(
                            title: Text("No. Telp"),
                            subtitle: Text(pelanggan!.noTelp!),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      child: Column(children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  onPressed: () {
                                    showAddTagihanDialog();
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add),
                                      Text("Tambah Tagihan")
                                    ],
                                  )),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                            context, "/tambah-pembayaran",
                                            arguments: pelanggan)
                                        .then((_) {
                                      setState(() {});
                                      getDetailPelanggan();
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.attach_money),
                                      Text("Bayar Tagihan")
                                    ],
                                  )),
                            )
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Tagihan",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${UtilityProvider.formatCurrency(pelanggan!.totalTagihan.toString())}",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(" / "),
                                Text(
                                    "${UtilityProvider.formatCurrency(pelanggan!.totalBayar.toString())}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: (pelanggan!.totalBayar == null ||
                                                (pelanggan!.totalBayar <
                                                    pelanggan!.totalTagihan))
                                            ? Colors.red
                                            : Colors.green)),
                              ],
                            )),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: tagihans.length,
                          itemBuilder: (context, index) {
                            //format utc to date Y-m-d
                            var utc = tagihans[index].tanggalTagihan;
                            var date = DateTime.parse(utc!);
                            var formattedDate =
                                "${date.day}-${date.month}-${date.year}";

                            //format price to currency
                            var price = tagihans[index].totalTagihan;

                            var priceFormat = UtilityProvider.formatCurrency(
                                price.toString());

                            return Column(
                              children: [
                                ListTile(
                                  onTap: (() {
                                    Navigator.pushNamed(
                                            context, "/detail-tagihan",
                                            arguments: tagihans[index])
                                        .then((value) => setState(() {}));
                                  }),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text("${priceFormat}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Chip(label: Text("${formattedDate}"))
                                    ],
                                  ),
                                  subtitle: Text(
                                      "Ket : ${tagihans[index].keterangan}"),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.all(10),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Text(
                                //           "Bayar : ${UtilityProvider.formatCurrency(tagihans[index].totalBayar.toString())}"),
                                //       (tagihans[index].totalBayar !=
                                //               tagihans[index].totalTagihan)
                                //           ? Chip(
                                //               label: Text("Belum Lunas"),
                                //               backgroundColor: Colors.red,
                                //             )
                                //           : Chip(
                                //               label: Text("Lunas"),
                                //               backgroundColor: Colors.green,
                                //             ),
                                //     ],
                                //   ),
                                // ),
                                Divider(),
                              ],
                            );
                          },
                        )
                      ]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      child: Column(children: [
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Riwayat Pembayaran",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        (loadPemabayaran)
                            ? CircularProgressIndicator()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: pembayarans.length,
                                itemBuilder: (context, index) {
                                  //format utc to date Y-m-d
                                  var utc = pembayarans[index].tanggalBayar;
                                  var date = DateTime.parse(utc!);
                                  var formattedDate =
                                      "${date.day}-${date.month}-${date.year}";

                                  //format price to currency
                                  var price = pembayarans[index].totalBayar;

                                  var priceFormat =
                                      UtilityProvider.formatCurrency(
                                          price.toString());

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text("${priceFormat}",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Chip(
                                                label: Text("${formattedDate}"))
                                          ],
                                        ),
                                        subtitle: Text(
                                            "Ket : ${pembayarans[index].keterangan}"),
                                      ),
                                      Divider(),
                                    ],
                                  );
                                },
                              )
                      ]),
                    )
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
