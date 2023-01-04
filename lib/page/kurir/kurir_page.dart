import 'package:flutter/material.dart';
import 'package:salesman/model/user.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/kurir_repository.dart';

class KurirPage extends StatefulWidget {
  const KurirPage({super.key});

  @override
  State<KurirPage> createState() => _KurirPageState();
}

class _KurirPageState extends State<KurirPage> {
  List<User> _listKurir = [];
  List<User> listKurir = [];
  bool search = false;
  //focus node
  FocusNode _searchFocus = FocusNode();
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getKurir() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/login');
      return;
    } else {
      await KurirRepository().getAllKurir(token).then((res) {
        if (res.status == 200) {
          setState(() {
            _listKurir = res.data!;
            listKurir = res.data!;
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
      getKurir();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: (!search)
              ? Text("Data Kurir")
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
                        listKurir = _listKurir
                            .where((element) =>
                                element.username!
                                    .toLowerCase()
                                    .contains(value) ||
                                element.nama!.toLowerCase().contains(value))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Cari Kurir"),
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
                        listKurir = _listKurir;
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
          ],
        ),
        body: RefreshIndicator(
            child: (listKurir.length > 0)
                ? ListView.builder(
                    itemCount: listKurir.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            listKurir[index].username!,
                            style: TextStyle(fontSize: 24),
                          ),
                          subtitle: Text(
                            "${listKurir[index].nama}",
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/detail-kurir',
                                    arguments: listKurir[index])
                                .then((value) => getKurir());
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
              getKurir();
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/tambah-kurir').then((value) {
              getKurir();
            });
          },
          child: Icon(Icons.add),
        ));
  }
}
