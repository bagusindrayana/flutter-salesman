import 'package:flutter/material.dart';
import 'package:salesman/model/pelanggan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/pelanggan_repository.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  List<Pelanggan> _listPelanggan = [];
  List<Pelanggan> listPelanggan = [];
  bool search = false;
  //focus node
  FocusNode _searchFocus = FocusNode();
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
          setState(() {
            _listPelanggan = res.data!;
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
    Future.delayed(Duration.zero, () {
      getPelanggan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: (!search)
              ? Text("Data Pelanggan")
              : Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    focusNode: _searchFocus,
                    onChanged: (value) {
                      setState(() {
                        listPelanggan = _listPelanggan
                            .where((element) =>
                                element.namaUsaha!
                                    .toLowerCase()
                                    .contains(value) ||
                                element.alamat!.toLowerCase().contains(value))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Cari Pelanggan"),
                  ),
                ),
          actions: [
            (!search)
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        search = true;
                        _searchFocus.requestFocus();
                      });
                    },
                    icon: Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        search = false;
                        listPelanggan = _listPelanggan;
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
          ],
        ),
        body: RefreshIndicator(
            child: (listPelanggan.length > 0)
                ? ListView.builder(
                    itemCount: listPelanggan.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            listPelanggan[index].namaUsaha!,
                            style: TextStyle(fontSize: 24),
                          ),
                          subtitle: Text(
                            listPelanggan[index].alamat!,
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/detail-pelanggan',
                                    arguments: listPelanggan[index])
                                .then((value) => setState(() {}));
                          },
                        ),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("Tidak ada data"),
                    ),
                  ),
            onRefresh: () async {
              getPelanggan();
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/tambah-pelanggan').then((value) {
              getPelanggan();
            });
          },
          child: Icon(Icons.add),
        ));
  }
}
