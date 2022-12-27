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
  List<Pelanggan> listPelanggan = [];

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
          title: Text("Data Pelanggan"),
        ),
        body: RefreshIndicator(
            child: ListView.builder(
              itemCount: listPelanggan.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(listPelanggan[index].namaUsaha!),
                  subtitle: Text(listPelanggan[index].alamat!),
                  onTap: () {
                    Navigator.pushNamed(context, '/detail-pelanggan',
                        arguments: listPelanggan[index]);
                  },
                );
              },
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
