import 'package:flutter/material.dart';
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

  void getDetailPelanggan() async {
    var token = await StorageProvider.getToken();
    if (token == null) {
      return;
    } else if (pelanggan != null) {
      await PelangganRepository()
          .detailPelanggan(token, pelanggan!.sId!)
          .then((value) {
        if (value.status == 200) {
          setState(() {
            pelanggan = value.data;
          });
        }
      });
      getTagihanPelanggan();
    }
  }

  void getTagihanPelanggan() async {
    UtilityProvider.showLoadingDialog(context);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getTagihanPelanggan();
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
                        ListView.builder(
                          shrinkWrap: true,
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
                                Divider(),
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
                                                Navigator.pushNamed(
                                                    context, "/bayar-tagihan",
                                                    arguments: tagihans[index]);
                                              },
                                              child: Text("Bayar"),
                                            )
                                          : Chip(
                                              label: Text("Lunas"),
                                              backgroundColor: Colors.green,
                                            )
                                    ],
                                  ),
                                )
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
