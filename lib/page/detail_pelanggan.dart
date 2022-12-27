import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesman/model/pelanggan.dart';
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
    Navigator.pop(context);
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
          UtilityProvider.showAlertDialog("Gagal", "${value.message}", context);
        }
      });
    }
    Navigator.pop(context);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
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
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Tagihan",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        ElevatedButton(
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
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Bayar : ${UtilityProvider.formatCurrency(tagihans[index].totalBayar.toString())}"),
                                      (tagihans[index].totalBayar !=
                                              tagihans[index].totalTagihan)
                                          ? TextButton(
                                              onPressed: () {
                                                Navigator.pushNamed(context,
                                                        "/bayar-tagihan",
                                                        arguments:
                                                            tagihans[index])
                                                    .then((_) {
                                                  setState(() {});
                                                  UtilityProvider
                                                      .showLoadingDialog(
                                                          context);
                                                  getTagihanPelanggan();
                                                });
                                              },
                                              child: Text("Bayar"),
                                            )
                                          : Chip(
                                              label: Text("Lunas"),
                                              backgroundColor: Colors.green,
                                            ),
                                    ],
                                  ),
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
