import 'package:flutter/material.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/model/user.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/auth_repository.dart';
import 'package:salesman/repository/pelanggan_repository.dart';
import 'package:salesman/repository/stat_repository.dart';
import 'package:salesman/repository/tagihan_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  int? total_tagihan = null;
  int? total_pelanggan = null;
  bool loadingTagihan = true;
  List<dynamic> tagihanMingguIni = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void checkAuth() async {
    var token = await StorageProvider.getToken();

    if (token == null) {
      print("token null");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      await AuthRepository().checkAuth(token).then((res) {
        print(res.message);
        if (res.status == 200 && res.user != null) {
          setState(() {
            user = res.user;
          });
        }
        getStat();
      });
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
    await PelangganRepository().tagihanPelangganMingguIni(token).then((value) {
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
    if (tagihanMingguIni.length <= 0) {
      UtilityProvider.showSnackBar("Tidak ada data tagihan", context);
      return;
    }
    for (var pelanggan in tagihanMingguIni) {
      coordinates += "${pelanggan['longitude']},${pelanggan['latitude']}";
      if (pelanggan != tagihanMingguIni.last) {
        coordinates += ";";
      }
    }

    Navigator.pushNamed(context, '/peta-rute', arguments: tagihanMingguIni);
  }

  void logout() async {
    await StorageProvider.clearToken();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      checkAuth();
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
            checkAuth();
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
                      child: InkWell(
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
                        onTap: () {
                          Navigator.pushNamed(context, '/tagihan');
                        },
                      ),
                    ),
                    Card(
                      child: InkWell(
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
                        onTap: () {
                          Navigator.pushNamed(context, '/pelanggan');
                        },
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
                        'Tagihan Lewat 6 Hari',
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
                          var tanggalTagihan = tagihanMingguIni[index]
                              ['tagihan_terbaru']['tanggal_tagihan'];
                          //format string to date
                          var date = DateTime.parse(tanggalTagihan!);
                          //add 7 days to date
                          var date7 = date.add(Duration(days: 7));
                          //get YYYY-MM-DD
                          var date7String = date7.toString().substring(0, 10);
                          return Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.pushNamed(
                                        context, "/tambah-pembayaran",
                                        arguments: Pelanggan.fromJson(
                                            tagihanMingguIni[index]))
                                    .then((_) {
                                  setState(() {});
                                  getStat();
                                });
                              },
                              title: Text(
                                  "${tagihanMingguIni[index]['nama_usaha']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          '${UtilityProvider.formatCurrency("${tagihanMingguIni[index]['total_tagihan']}")}'),
                                      Text("/"),
                                      Text(
                                        '${UtilityProvider.formatCurrency("${tagihanMingguIni[index]['total_bayar']}")}',
                                        style: TextStyle(color: Colors.red),
                                      )
                                    ],
                                  ),
                                  (tagihanMingguIni[index]['user'] != null)
                                      ? Text(
                                          "user : ${tagihanMingguIni[index]['user']['nama']}")
                                      : SizedBox(),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      "${DateTime.parse(tanggalTagihan!).toString().substring(0, 10)}"),
                                  Container(
                                    height: 2,
                                    width: 70,
                                    color: Colors.black26,
                                  ),
                                  Text(
                                    "${date7String}",
                                    style: TextStyle(color: Colors.red),
                                  )
                                ],
                              ),
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
              leading: Icon(Icons.people),
              title: const Text('Pelanggan'),
              onTap: () {
                Navigator.pushNamed(context, '/pelanggan');
              },
            ),
            ListTile(
              leading: Icon(Icons.file_open),
              title: const Text('Tagihan'),
              onTap: () {
                Navigator.pushNamed(context, '/tagihan');
              },
            ),
            (user != null && user?.level == "admin")
                ? ListTile(
                    leading: Icon(Icons.delivery_dining),
                    title: const Text('Kurir'),
                    onTap: () {
                      Navigator.pushNamed(context, '/kurir');
                    },
                  )
                : SizedBox(),
            //logout
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content: Text('Apakah anda yakin ingin logout?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Tidak')),
                          TextButton(
                              onPressed: () {
                                logout();
                              },
                              child: Text('Ya'))
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
