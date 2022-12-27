import 'package:flutter/material.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/stat_repository.dart';
import 'package:salesman/repository/tagihan_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? total_tagihan = null;
  int? total_pelanggan = null;
  bool loadingTagihan = true;
  List<Tagihan> tagihanMingguIni = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getStat() async {
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    UtilityProvider.showLoadingDialog(context);
    await StatRepository().getStat(token).then((value) {
      print(value.data);
      if (value.status == 200) {
        setState(() {
          total_tagihan = value.data['total_tagihan'];
          total_pelanggan = value.data['total_pelanggan'];
        });
      } else {
        UtilityProvider.showSnackBar(value.message!, context);
      }
    });
    Navigator.pop(context);
    getTagihanMingguIni();
  }

  void getTagihanMingguIni() async {
    setState(() {
      loadingTagihan = true;
    });
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    setState(() {
      loadingTagihan = true;
    });
    await TagihanRepository().tagihanMingguIni(token).then((value) {
      print(value.data);
      if (value.status == 200) {
        setState(() {
          tagihanMingguIni = value.data!;
        });
      } else {
        UtilityProvider.showSnackBar(value.message!, context);
      }
    });
    setState(() {
      loadingTagihan = false;
    });
  }

  void bukaRute() {
    var coordinates = "";
    for (var tagihan in tagihanMingguIni) {
      coordinates +=
          "${tagihan.pelanggan?.longitude},${tagihan.pelanggan?.latitude}";
      if (tagihan != tagihanMingguIni.last) {
        coordinates += ";";
      }
    }
    print(coordinates);
    Navigator.pushNamed(context, '/peta-rute', arguments: coordinates);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getStat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salesman"),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            getStat();
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.bar_chart, size: 50),
                          ListTile(
                            title: Text(
                              "${(total_tagihan == null) ? 'loading...' : UtilityProvider.formatCurrency("${total_tagihan}")}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Tagihan yang belum dibayar',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.people, size: 50),
                          ListTile(
                            title: Text(
                              "${(total_pelanggan == null) ? 'loading...' : total_pelanggan}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Total Pelanggan',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tagihan Lewat 7 Hari',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onTap: () {
                            bukaRute();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              "Buka Rute",
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                    ],
                  ),
                ),
                SizedBox(height: 10),
                (loadingTagihan)
                    ? Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tagihanMingguIni.length,
                        itemBuilder: (context, index) {
                          var tanggalTagihan =
                              tagihanMingguIni[index].tanggalTagihan;
                          //format string to date
                          var date = DateTime.parse(tanggalTagihan!);
                          //add 7 days to date
                          var date7 = date.add(Duration(days: 7));
                          //get YYYY-MM-DD
                          var date7String = date7.toString().substring(0, 10);
                          return Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.pushNamed(context, "/bayar-tagihan",
                                        arguments: tagihanMingguIni[index])
                                    .then((_) {
                                  setState(() {});
                                  getStat();
                                });
                              },
                              title: Text(
                                  "${tagihanMingguIni[index].pelanggan!.namaUsaha}"),
                              subtitle: Row(
                                children: [
                                  Text(
                                      '${UtilityProvider.formatCurrency("${tagihanMingguIni[index].totalTagihan}")}'),
                                  Text("/"),
                                  Text(
                                    '${UtilityProvider.formatCurrency("${tagihanMingguIni[index].totalBayar}")}',
                                    style: TextStyle(color: Colors.red),
                                  )
                                ],
                              ),
                              trailing: Chip(label: Text("${date7String}")),
                            ),
                          );
                        })
              ],
            ),
          )),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Welcome'),
            ),
            ListTile(
              title: const Text('Pelanggan'),
              onTap: () {
                Navigator.pushNamed(context, '/pelanggan');
              },
            ),
            ListTile(
              title: const Text('Tagihan'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }
}
